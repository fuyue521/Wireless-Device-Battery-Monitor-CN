# Contributing

## 提交 PR 之前 / Before you open a PR

1. 新建 PR 时 GitHub 会自动带出 [PR 模板](.github/pull_request_template.md)，请按四段填写：
   **这个 PR 做了什么**（修 bug 必写复现方式与根因）、**协议来源**（含关键帧格式）、
   **实机验证**（`--list` 原始输出，并与厂商软件对照）、**自查清单**。
2. 本地跑过构建：`make`（或 `build.bat`）与 `make test`，并在模板最后一条打勾。
3. 一个 PR 尽量只做一件事；顺手重排格式、改注释会让评审变慢。
4. 允许使用 AI 辅助写作与编码，但请自己跑过构建、如实填写实机验证；提交信息里不要带
   `Co-authored-by` 之类的 AI 署名。

没有把握也欢迎直接 fork 自行维护，GPLv3 允许修改与再分发。


## Reporting whether a device works

Most drivers were written from protocol documentation and could not be tested on every model.
Please open an issue with:

- the device name, and whether it is connected by receiver, cable or Bluetooth
- the output of `WirelessBattery.exe --list`
- the output of `WirelessBattery.exe --dump`
- what the vendor's own software shows as the battery level

[docs/verifying_a_device.md](docs/verifying_a_device.md) walks through the same
steps in more detail, including how to read the level Windows itself caches and
what each `--dump` column means.

## Adding a device

1. Run `WirelessBattery.exe --dump` and find your device's vendor and product IDs, and the
   vendor-defined collections (usage page `FFxx`) with their report sizes.
2. Find the battery protocol. Good places to look: HeadsetControl, OpenRazer, Solaar, rivalcfg,
   OpenRGB, OpenLinkHub, or a USB capture of the vendor software (Wireshark + USBPcap).
3. If the vendor already has a driver in `src/drivers/`, add the product ID (and any differences) there.
   Otherwise create `src/drivers/<vendor>.cpp`:

   ```cpp
   #include "drivers.h"

   void PollAcme(PollContext& ctx) {
       for (auto [vid, pid] : ctx.Products(0x1234)) {           // unclaimed products of this vendor
           for (const HidColl* c : ctx.Find(vid, pid, [](const HidColl& c) { return c.page() == 0xFF00; })) {
               HidDev d;
               if (!d.Open(*c)) continue;
               std::vector<BYTE> r;
               if (!d.Write({ 0x01, 0x02 }) || d.Read(r, 500) < 3) continue;   // hidapi-style buffers
               DeviceStatus s;
               s.key = L"acme:" + Hex4(pid);
               s.name = HidProduct(*c);
               s.kind = DeviceKind::Mouse;
               s.via = L"2.4 GHz receiver";
               s.percent = Clamp100(r[2]);
               ctx.Add(s, vid, pid);
               break;
           }
       }
   }
   ```

4. Declare the function in `src/drivers/drivers.h`, call it from `PollAllDevices()` in
   `src/devices.cpp` (before the generic fallbacks). `build.bat` and the Makefile pick up new files automatically.
5. Update the device table in `README.md`.

### Rules for drivers

- **Read-only:** only send requests that read state. Never change settings, lighting or modes.
- **Exact matching:** only talk to devices you recognise by vendor and product ID, or by a
  vendor-specific collection that is unique to the protocol.
- **Always time out:** a missing device must not stall the poll for more than about a second.
  Passive protocols may need longer to cover a documented push interval (for example, Delux and
  Rapoo). Keep a single absolute deadline of at most 4 seconds per matching collection, do not
  restart it for unrelated reports, and document why the exception is needed.
- **Credit sources:** cite where the protocol comes from in a comment at the top of the file.

## Translations

A language is one UTF-8 text file in `lang/` (copy `lang/_template.txt`, fill in `@code`, `@name` and the phrases). It is built into the app automatically. New UI text in the code goes through `T(L"...")`, or `TF(L"... {name} ...", { { L"name", value } })` when it contains values; never build translated sentences from pieces. After adding phrases, add them to `lang/_template.txt` too.

## Code style

C++17, Win32 only, no third-party dependencies. Keep the binary small. Format roughly as the
existing code does (4-space indent, 120-column lines).

## Automatic safety check

Every pull request is scanned by the "PR safety check" for things this app should never do (network
access, launching programs, reading keyboard/clipboard/screen, startup entries, binaries, build or
release changes). A flag is not a rejection: the step is advisory, it lists the matching lines in the
check summary and asks the reviewer to read that part of the diff.

Using AI tools is fine, but please remove `Co-authored-by` lines that credit them (for example
`Co-authored-by: Claude ...`) from your commit messages. The check fails while they are present.

## How the CI is split

- **`ci.yml`** runs on every push to `main` and on pull requests: `make` + `make test` only, and it
  uploads the built `WirelessBattery.exe`. Pushes that only touch `*.md`, `docs/**` or `LICENSE` are
  skipped, so editing this file does not queue a build.
- **`release.yml`** runs only for a `v*` tag: it adds the HeadsetControl binary, builds the NSIS
  installer and the portable zip, and publishes the GitHub release. You can also start it by hand
  (`workflow_dispatch`) to check packaging without publishing anything.
- A new push to the same branch cancels the previous, still running job, so quick follow-up commits do
  not queue up behind each other.

Larger changes are split between the maintainer and parallel agents; that workflow file is kept
locally and is deliberately not part of the published repository.
