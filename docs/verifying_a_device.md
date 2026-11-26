# Verifying a device yourself

Everything on this page only reads state: no settings, no lighting, no firmware,
no writes to devices you have not identified. It is the sequence worth going
through before writing a driver, or before opening an issue that says "my device
shows nothing".

The app answers three questions on its own, and Windows answers a fourth:

1. what the app already sees — `--list`
2. what Windows already knows — `--dump`, PnP properties
3. which identity the device has (receiver, cable, Bluetooth) — `--dump`
4. what the vendor protocol looks like — a capture or a documented source

## 1. What the app already sees

```
> WirelessBattery.exe --list
PMOKEY WAVE 75  [2.4 GHz receiver]  83%   (pmo:3002)
Razer Basilisk V3 X HyperSpeed  [Razer receiver]  {Razer}  44%   (razer:00B9)
Monster Airmars XKT09  [Bluetooth]  100%   (bt:{E8C24A8A-87FF-5FB2-A39C-E1E0FD7E4CA1})
```

One line per device, in this order:

```
<name>  [<via>]  [{<brand>}]  <level> (<detail>)   (<key>)
```

* `via` is how the device is attached, as the driver understands it: `USB cable`,
  `2.4 GHz receiver`, `Bluetooth`, or a vendor-specific wording such as Razer's.
  A wrong wording here is a driver bug, not a device problem.
* `{brand}` only appears for drivers that draw a coloured icon.
* `level` is `NN%`, or `asleep`, or `off / not connected`, or `unknown`.
* `detail` is whatever the driver wants to expose — a step count, a connection
  mode, a firmware string. FlyDigi pads show `3/5` here because the pad only
  knows steps, and the percentage is derived from them.
* `key` identifies the device inside the app (`pmo:3002`, `razer:00B9`,
  `bt:{container-guid}`). It is the quickest way to tell whether two runs are
  talking about the same physical device.

If a device is missing here but `--dump` lists it, the problem is in matching or
in the read, not in enumeration.

## 2. What Windows already knows

Windows keeps its own cache for Bluetooth devices, and it is often enough to
answer "is the battery fine" without any vendor protocol. Read it by property
GUID, not by listing the node's properties:

```powershell
$id = 'BTHLE\DEV_xxxxxxxxxxxx\...'   # InstanceId from Device Manager, or from --dump
Get-PnpDeviceProperty -InstanceId $id -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2'
```

`{104EA319-...} 2` is `DEVPKEY_Device_BatteryLevel`; the value is a single byte,
already a percentage. To sweep every Bluetooth node:

```powershell
Get-PnpDevice -Class Bluetooth | ForEach-Object {
    $p = Get-PnpDeviceProperty -InstanceId $_.InstanceId `
         -KeyName '{104EA319-6EE2-4701-BD47-8DDBF425BBE5} 2' -ErrorAction SilentlyContinue
    if ($p) { '{0}  {1}%' -f $_.FriendlyName, $p.Data }
}
```

Two things to know before trusting that number:

* **It is a cache.** `DEVPKEY_Bluetooth_LastConnectedTime` tells you when it was
  written. A keyboard that had not been connected for four days still answered
  `84%`, and the app showed a device that was not actually there.
* **It can be wrong.** A FlyDigi pad reported `4/6` steps over its own protocol
  and `99%` through the Windows cache within the same hour. The cache is a
  starting point, not a source of truth.
* Reading the key by GUID works even when enumerating all of the node's
  properties does not include `BatteryLevel` — that is what happens on `BTHLE\`
  nodes in our tests, so a property dump that shows no battery does not prove
  there is none.

The app's generic Bluetooth path only lists devices whose node is currently
connected, so a cached level on a sleeping device does not appear in `--list`.
That is deliberate, not a bug.

## 3. Which identity the device has

```
> WirelessBattery.exe --dump
VID:PID    IF  UsagePg:Usage  In  Out Feat  Product
36B0:3002   2  0001:0002      6   0   0   Wireless 2.4G Dongle
1532:00B9   0  0001:0002      9   0  91   Razer Basilisk V3 X HyperSpeed
36B0:3002   1  FF60:0061     33  33   0   Wireless 2.4G Dongle
...
```

One line per HID collection:

| Column | Meaning |
|---|---|
| `VID:PID` | the identity the app matches on |
| `IF` | interface index — collections on the same device share a VID/PID, so this is what distinguishes them |
| `UsagePg:Usage` | usage page and usage; vendor pages are `FF00`–`FFFF` |
| `In` / `Out` / `Feat` | input, output and feature report lengths in bytes |
| `Product` | the product string, empty when the collection cannot be opened |

`--dump` also prints the collections it could not open, the non-HID USB devices,
and every Bluetooth device Windows knows about with its cached level. The whole
output is written to `%TEMP%\WirelessBattery-dump.txt`, because a windowed
program may lose console output.

What to look for:

* **Vendor collection.** A usage page in `FF00`–`FFFF` with non-zero out or
  feature length is the usual place for a battery query. Use its exact lengths
  in the driver, as `docs/pmo_wave75.md` does (`FF60:0061`, 33/33).
* **A receiver hides the product.** `36B0:3002` reports itself as "Wireless 2.4G
  Dongle"; the keyboard's name is not available from the receiver at all, which
  is why the driver names the device from the protocol, not from the string.
* **One device, many collections.** The Razer mouse has nine collections on one
  interface; only the one with a 91-byte feature report answers. Matching on
  VID/PID alone would open the wrong one.
* **XInput shows a generic identity.** A pad in XInput mode appears as
  `045E:028E` with no vendor collection at all. Anything read from it is one of
  four buckets (5 / 25 / 60 / 100), never a real percentage — see the note in
  `docs/flydigi_vader4.md` about claiming that identity afterwards.
* **BLE exposes its own VID.** A pad in Bluetooth mode becomes `D7D7:0041` with
  only usage page `0001` collections; there is nothing vendor-specific to query.

## 4. Reading a protocol without changing anything

Rules that apply to every driver in this repository:

* Send only requests that read state. Never set a mode, a colour or a profile.
* Only talk to devices matched by vendor and product ID, or by a collection that
  is unique to the protocol.
* Keep one absolute deadline per collection. A missing device must not stall the
  poll for more than about a second.
* Cite where the protocol comes from in a comment at the top of the driver.

How to get the protocol in the first place, cheapest first:

1. **The vendor's own software.** Extract the app and read its constants; PMO Hub
   (Electron) and the Razer tools are both readable this way. The three-step
   `AA 10` / `AA 30 18` / `AA 11` conversation came from there.
2. **Another open implementation.** HeadsetControl, OpenRazer, Solaar, rivalcfg,
   OpenRGB, OpenLinkHub. Credit them.
3. **A local IPC channel.** Some vendor services answer on a named pipe; FlyDigi's
   is documented in `docs/flydigi_vader4.md`, including the frame format and how
   to dump the reply.
4. **A capture.** Wireshark + USBPcap for USB traffic. Confirm that every frame
   you copy is a read, and re-check the direction of the transfer: an output
   report that changes a setting looks exactly like a query.

A read needs a writable handle: a collection opened for reading only can never
send a query frame, so "read-only" in this repository means "the command only
reads", not "the handle is opened read-only".

## 5. What to put in an issue

For a device that shows nothing, or shows a wrong value:

* the device name, and the connection mode (receiver, cable, Bluetooth) —
  the same hardware is a different device in each mode;
* the output of `WirelessBattery.exe --list`;
* the output of `WirelessBattery.exe --dump` (the `%TEMP%` file is fine);
* what the vendor's own software shows at the same moment;
* the Windows build number, shown in the app's "Request support" window.

The two dumps together usually say whether the device is missing from
enumeration, missing its battery property, or simply not matched by a driver.

## 6. Traps worth remembering

Each of these cost us a wrong conclusion at least once:

* A stale Bluetooth cache is not a reading. Check `LastConnectedTime`.
* A receiver that is enumerating locks the HID tree for a moment; a single pass
  can come back empty or short. Re-run before concluding a device disappeared.
* `100%` from an XInput pad is a bucket, not a measurement.
* A device that is asleep reports no level; the app keeps the last known value
  and marks it `asleep` instead of inventing a number.
* If the vendor app is running and holds the collection exclusively, the query
  cannot be sent at all. Close it and re-run.
