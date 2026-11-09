---
title: "Run Windows Installers on Android: Install Non-Steam Games with GameNative"
slug: "installing-non-steam-games-android-gamenative"
date: "2026-11-09T18:00:00+03:00"
description: "GameNative runs setup.exe fine — then hides the game. Where to install (A: vs C:), how to point the launcher at the exe, and the Reset vs Remove trap."
tags:
  - android
  - gaming
  - gamenative
  - wine
  - steam
  - proton
  - installers
  - tutorial
  - english
categories:
  - Gaming
author: "Arda Kılıçdağı"
draft: false
---

All I wanted was to run a `setup.exe` on my phone. GameNative boots a Windows container on Android, so this should be double-click installer, pick exe, play.

I installed to `C:` twice before I saw it: the launcher only scans `A:`.

Once that clicks, the rest is bookkeeping. Here is the map, then the 5 steps.

## TL;DR — the 5 steps

1. **Add Custom Game** → pick a folder. That folder becomes `A:`.
2. **Open container** → boots `wfm.exe` file manager.
3. Run `setup.exe` from `D:` (Downloads) → install to `A:\GameName`.
4. **Edit container → General → Executable Path** → pick the exe.
5. Play. If it installed to `C:`, use **Custom path…** instead.

Needs **v1.2.1+** for custom paths, **v1.3.0+** for WMV codecs. Current is v1.4.0.

## The drive map

| Drive | What it is | In exe dropdown? |
|---|---|---|
| `A:` | Your game folder, symlinked in | Yes — only this |
| `C:` | Container's own Wine prefix | No |
| `D:` | Android Downloads | No |
| `E:` | GameNative storage | No |
| `Z:` | ImageFS root | No |

**`A:` is a symlink, not a copy into the container.** On modern Android, Add Custom Game first imports a copy into GameNative storage (SAF copy + verify, optional delete-source), then symlinks that. Check the real target in **Edit container → Drives**.

`C:` is per game. Two custom games get two separate `C:` drives.

## 1. Add the game first

**Add Custom Game → pick a folder.**

Pick the folder you want the game to live in if you install to `A:`. Pick an empty folder if you plan to use `C:` — it just gives the container an `A:` drive.

First launch creates the container and prefix. It is slow once. Later boots are fast.

> If the picker shows a copy progress dialog, let it finish. A 20 GB folder is a 20 GB copy.

## 2. Open the container

Game menu → **Open container**.

This boots the same container with `wfm.exe` instead of the game. Browse drives, double-click the installer. That is all it does, and that is enough.

## 3. Run the installer

Put `setup.exe` where the container sees it:

- Android Downloads → shows as `D:\` — least friction
- Game folder → shows as `A:\`
- Or add a drive in **Edit container → Drives**

Run it from `wfm.exe`. Accept `C:\Program Files (x86)\...` or change it to `A:\GameName`.

My default is `A:\GameName`. The dropdown finds it. The working directory is correct. Removing a broken container does not delete the game.

`C:` works too. It just needs manual exe selection, and the game dies with the container.

Installers needing VC++ are covered — `vcrun2005` through `vcrun2022` are Win Components. **.NET is not bundled.** Install it inside the container if the game needs it.

DRM or launcher-based installers may fail. That is Wine, not your path.

## 4. Point GameNative at the exe

**Edit container → General → Executable Path.**

- Game in `A:` → pick it from the dropdown. Recursive scan, ignores `unins*`. One exe in folder = auto-selected.
- Game in `C:` → **Custom path…** → paste exact path:

```text
C:\Program Files (x86)\Whatever\game.exe
```

**No file picker. No validation.** Trimmed and saved as-is. Empty + no unique exe in `A:` = boots `wfm.exe`. That is the fallback, not a bug.

Spaces are fine. Launch is `winhandler.exe "$executablePath"` — quoted.

## 5. The working-directory trap

Relative `A:` path → working dir = exe folder. Correct.

Absolute `C:\...` path → no working dir set. Launcher leaves it at default.

Games loading assets relative to CWD fail on `C:` even with the right exe. Fix: install under `A:`, use the relative path.

## Reset vs Remove vs Uninstall

Pick the wrong one and you lose an evening.

- **Reset Container** → resets settings to defaults, keeps drives. Deletes `executablePath`. Does **not** wipe `drive_c`.
- **Remove container** → deletes container root including `drive_c`. Game folder in `A:` survives. This is the real wipe.
- **Uninstall game** → removes game files + container.

Broken prefix? Use **Remove container**, not Reset.

## Codecs in 3 steps

Cutscenes go black = WMV9. Fix:

1. **Edit container → Win Components → Windows Media Decoder = Native (Windows).** Default. Needs **v1.3.0+**. 32-bit = all four DLLs native. 64-bit = only `wmadmod`/`wmvdecod` native, `wmvcore` + `wmasf` stay builtin (DRM libs).
2. Still black → toggle **DirectShow** to Native, relaunch. Or try Decoder = Builtin. No reset needed, re-extracts automatically.
3. Still black → install **WMF 11 Runtime** (`wmfdist11.exe`) in container. Or LAV Filters **portable ZIP** — `syswow64\regsvr32` for 32-bit, `system32\regsvr32` for 64-bit. Last resort: transcode to H.264.

Skip K-Lite (admin checks, half-registers, breaks prefix).

Stuck? **Settings → Debug → Save logcat.** Or game menu → **Diagnostic Run / Share diagnostics.**

## What fails

| Symptom | Fix |
|---|---|
| Installer done, not in dropdown | Installed to `C:`. Use **Custom path…**. |
| Launch opens file manager | No exe selected or path typo. Re-paste. |
| Game can't find data | `C:` path = no working dir. Reinstall to `A:`. |
| Black cutscenes | Win Components, step above. Check MediaInfo: WMV7/8 often hopeless. |
| Prefix feels broken | **Remove container**, not Reset. |

## What I'd tell myself at the start

**Install under `A:` unless the installer refuses.** Dropdown, working dir, and survival all line up.

**Reset is settings. Remove is wipe.** Learn it before you “reset” a broken prefix for an hour.

**Custom path is a promise, not a picker.** Paste exact path. Prefer relative `A:` path when you can.

The installer was never hard. The drive letters were the tutorial.

---

## Further reading

- [GameNative on GitHub](https://github.com/utkarshdalal/GameNative) — custom games live in code, not docs
- [GameNative releases](https://github.com/utkarshdalal/GameNative/releases) — v1.2.1 adds custom path, v1.3.0 fixes codecs
- [PR #1918 — custom executable path](https://github.com/utkarshdalal/GameNative/pull/1918)
- [PR #2085 — 64-bit decoders](https://github.com/utkarshdalal/GameNative/pull/2085) / [PR #2130 — CLSID fix](https://github.com/utkarshdalal/GameNative/pull/2130)
- [Winlator File Manager](https://github.com/brunodev85/wfm) — the `wfm.exe` behind Open container
