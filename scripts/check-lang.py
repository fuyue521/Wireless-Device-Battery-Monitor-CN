#!/usr/bin/env python3
"""Checks every built-in language against lang/_template.txt.

The files in lang/ are concatenated into one resource (see the Makefile), and the app falls back to
English for any line a translation leaves empty. Nothing complains at runtime when a language is
missing a key or drops a {placeholder}, so the check lives here and runs in CI.

Errors (exit 1): unreadable file, byte order mark, duplicate key, key missing from a language, key
the template does not have, a {placeholder} set that differs between the English key and its
translation, and a language that forgot @code or @name.

Reported but not an error: how many lines are still English (empty after "="), which is legal and
means "use the English text".

Usage: python3 scripts/check-lang.py [lang-dir]
"""

import os
import re
import sys

PLACEHOLDER = re.compile(r"\{[^{}]*\}")
# Meta keys carry the language's own code and name; @rtl only appears in right-to-left languages.
META = ("@code", "@name", "@rtl")


def read_pairs(path, problems):
    """Returns ([(key, value)], {key: lineno}) for one language file, reporting anything unparsable."""
    name = os.path.basename(path)
    try:
        raw = open(path, "rb").read()
    except OSError as e:
        problems.append(f"{name}: cannot read ({e})")
        return [], {}
    if raw.startswith(b"\xef\xbb\xbf"):
        problems.append(
            f"{name}: starts with a UTF-8 byte order mark (windres keeps it, so the first key cannot match)"
        )
        raw = raw[3:]
    try:
        text = raw.decode("utf-8")
    except UnicodeDecodeError as e:
        problems.append(f"{name}: not valid UTF-8 ({e})")
        return [], {}
    pairs = []
    lines = {}
    for lineno, line in enumerate(text.splitlines(), 1):
        stripped = line.strip()
        if not stripped or stripped.startswith("#"):
            continue
        if "=" not in stripped:
            problems.append(f"{name}:{lineno}: no '=' (expected 'key = value')")
            continue
        key, value = stripped.split("=", 1)
        key = key.strip()
        pairs.append((key, value.strip()))
        lines.setdefault(key, lineno)
    return pairs, lines


def main(argv):
    lang_dir = argv[1] if len(argv) > 1 else "lang"
    template_path = os.path.join(lang_dir, "_template.txt")
    if not os.path.exists(template_path):
        print(f"error: {template_path} not found")
        return 2

    problems = []
    template, _ = read_pairs(template_path, problems)
    if problems:
        for p in problems:
            print(f"error: {p}")
        return 1
    template_keys = [key for key, _ in template]
    template_set = set(template_keys)

    files = sorted(f for f in os.listdir(lang_dir) if f.endswith(".txt") and f != "_template.txt")
    if not files:
        print(f"error: no languages found in {lang_dir}")
        return 1

    total_english = 0
    for name in files:
        pairs, _ = read_pairs(os.path.join(lang_dir, name), problems)
        seen = set()
        values = {}
        for key, value in pairs:
            if key in seen:
                problems.append(f"{name}: duplicate key '{key}'")
                continue
            seen.add(key)
            values[key] = value
            if key not in template_set and key not in META:
                problems.append(f"{name}: key '{key}' is not in _template.txt")

        for key in template_keys:
            if key not in seen:
                problems.append(f"{name}: missing key '{key}'")

        for key, value in values.items():
            if key in META or not value:
                continue  # empty means "use the English text", so there is nothing to compare
            want = set(PLACEHOLDER.findall(key))
            got = set(PLACEHOLDER.findall(value))
            if want != got:
                problems.append(
                    f"{name}: '{key}' has {sorted(got) or 'no'} placeholder(s), "
                    f"the English text has {sorted(want) or 'none'}"
                )

        for key in ("@code", "@name"):
            if key in seen and not values[key]:
                problems.append(f"{name}: {key} is empty")

        english = sum(1 for key, value in values.items() if not value and key not in META)
        total_english += english
        note = f", {english} line(s) still English" if english else ""
        print(f"{name}: {len(values)} keys{note}")

    if problems:
        print()
        for p in problems:
            print(f"error: {p}")
        print(f"\n{len(problems)} problem(s) in {len(files)} language file(s)")
        return 1
    print(
        f"\nall {len(files)} languages match _template.txt "
        f"({len(template_keys)} keys, {total_english} line(s) untranslated)"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
