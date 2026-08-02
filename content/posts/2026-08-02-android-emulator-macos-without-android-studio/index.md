---
title: "Running an Android Emulator on macOS Without Android Studio"
slug: "android-emulator-macos-without-android-studio"
date: "2026-08-02T14:00:00+03:00"
description: "I wanted a phone screen with a Play Store on it. It took four dead ends, two deprecated tools and a documentation page that lies. Here's the setup that actually works on Apple Silicon in 2026."
featuredImage: "posts/android-emulator-macos-without-android-studio/images/cover.webp"
tags:
  - android
  - emulator
  - macos
  - apple-silicon
  - cli
  - developer-tools
  - homebrew
  - adb
  - tutorial
  - english
categories:
  - Development
author: "Arda Kılıçdağı"
draft: false
---

All I wanted was a phone screen with a Play Store on it. I had an APK to sanity-check and no interest in downloading a multi-gigabyte IDE to look at it once. The Android emulator ships as a standalone SDK component, it runs natively on Apple Silicon through Hypervisor.framework, and this should have been a fifteen-minute job.

It was not a fifteen-minute job.

## Why this was harder than it should have been

Every guide I found, including the ones I wrote for myself as I went, was wrong in the same way: **Android's command-line tooling is mid-migration, and the documentation is describing the destination while the binaries are still somewhere on the road.**

The old world was `sdkmanager` and `avdmanager` — Java programs shipped in the SDK's `cmdline-tools` package. The new world is a single native `android` binary. Both exist on your machine right now. Both appear in search results. Google's own documentation site documents flags the shipped binary rejects.

That produces a specific, exhausting failure pattern. Every command fails for a *different* reason, so you never build a mental model — you just keep patching the last error:

1. `sdkmanager` needs a JVM you don't have, and the wrapper script hides that behind `line 173: test: : integer expression expected` before it gets to the actual message.
2. Install a JDK, and `avdmanager` dies on `Could not load devices from .../devices.xml` — because it scans every installed system image for a file that newer images no longer ship.
3. Reach for the replacement, and `brew install android-cli` returns `No available formula`, because it's distributed through a tap nobody mentions.
4. Get the new CLI, follow the official docs, and `--profile=medium_phone` comes back `Unknown option` — the flag became a positional argument and the docs didn't follow.

Four failures, four unrelated causes, none of which tell you the real story: *you are using the wrong generation of tool, and then the right tool with the wrong generation of documentation.*

There's a second, quieter problem underneath. Several of these tools **lie about their own state**. `android sdk list` cheerfully reported "no installed packages match" for system images I could `ls` on disk thirty seconds later. If you trust the tool over the filesystem, you'll reinstall the same 3 GB image three times wondering why it isn't sticking.

So: the working path, with the dead ends marked, so you can skip them.

---

## 1. Install the Android CLI

It lives in a Google-run Homebrew **tap**. Skip the tap and you get `No available formula with the name "android-cli"`:

```bash
brew tap android/tap
brew install android-cli
android update
android --version
```

If you'd rather not use Homebrew, there's a user-local installer (no sudo) and a system-wide one:

```bash
curl -fsSL https://dl.google.com/android/cli/latest/darwin_arm64/install.sh | bash
curl -fsSL https://dl.google.com/android/cli/latest/darwin_arm64/install_root.sh | bash
```

Use `darwin_arm64` on Apple Silicon, `darwin_x86_64` on Intel.

## 2. Confirm the SDK root

```bash
android info
```

You'll get something like `sdk: /Users/you/Library/Android/sdk`. **Everything below is relative to that path.** Export it so `adb` and `emulator` land on your `PATH` — in `~/.zshrc`:

```bash
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$PATH:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator"
```

Then go delete any *stale* `ANDROID_HOME` from an earlier attempt — a Homebrew `share/android-commandlinetools` path, most likely. Two SDK roots is the single most disorienting failure mode here: you install an image into one, the emulator reads from the other, and nothing you do appears to have any effect.

To pin a different SDK permanently, `~/.androidrc` takes one flag per line:

```
--sdk=/Volumes/External/android-sdk
```

## 3. A JDK, but only if you're building

The `android` binary is native and doesn't need Java. Gradle does. If you're only running prebuilt APKs, skip this entirely.

```bash
brew install --cask temurin@21
```

```bash
export JAVA_HOME="$(/usr/libexec/java_home -v 21)"
export PATH="$JAVA_HOME/bin:$PATH"
```

Use the **cask**. `brew install openjdk@21` is keg-only and isn't registered with `/usr/libexec/java_home`, so you'd be hardcoding paths forever.

## 4. Install the SDK components

Package names use **slashes** now, not the old semicolons:

```bash
android sdk install platform-tools emulator
android sdk list --all "system-images"
android sdk install system-images/android-37.1/google_apis_playstore_ps16k/arm64-v8a
```

That image name is dense, so here's how to read it — `system-images/android-<api>/<variant>/<abi>`:

| Fragment | Meaning |
|---|---|
| `android-37.1` | API level, **with minor version**. Plain `37` won't resolve. `-beta1` and `CANARY` mark pre-release. |
| `google_apis` | Google services, no Play Store. Unlocked bootloader, so `adb root` works. |
| `google_apis_playstore` | Play Store included. Locked bootloader — no `adb root`, no `adb remount`. |
| `_ps16k` | 16 KB memory pages, matching modern Pixel hardware. Prefer it; newer API levels ship nothing else. |
| `arm64-v8a` | Native on Apple Silicon. `x86_64` falls back to full emulation and is unusably slow. |

> **Don't trust `android sdk list`.** It will report "no installed packages match" for images that are demonstrably on disk, and occasionally "no available packages" for a pattern that returned twenty results minutes earlier. Check the filesystem instead:
>
> ```bash
> ls "$ANDROID_HOME/system-images/"
> ls "$ANDROID_HOME/system-images/android-37.1/google_apis_playstore_ps16k/arm64-v8a/"
> ```
>
> If `system.img` is there, the install worked. Believe your eyes over the tool.

One more trap: `emulator 37.1.11` and `platform-tools 37.0.1` are **tool** versions and have nothing whatsoever to do with API level 37.1. Pure coincidence, maximum confusion.

## 5. Check acceleration

```bash
emulator -accel-check
```

You want **Hypervisor.Framework**. That's the whole reason this is fast.

## 6. Create the device

```bash
android emulator create --list-profiles
```

Here's the thing nobody warns you about — the profiles are generic form factors. There is no `pixel_10`, no `pixel_9`, no device models at all:

```
large_desktop   medium_desktop   medium_phone
medium_tablet   small_desktop    small_phone
```

And the profile is a **positional argument**. `--profile=` is rejected, whatever the documentation says. When the docs and `-h` disagree, `-h` is telling the truth:

```bash
android emulator create medium_phone
```

## 7. Fix the system image it picked for you

`emulator create` takes no image argument. It chooses, and it may well not choose the image you just spent ten minutes downloading. Mine silently grabbed API 36 while 37.1 sat unused on disk.

```bash
grep -E 'image.sysdir|^target|tag.id' ~/.android/avd/medium_phone.avd/config.ini
```

To repoint it, read the tag string out of the image's own metadata rather than guessing — a wrong tag makes the emulator refuse to boot, or boot without a Play Store:

```bash
cat "$ANDROID_HOME/system-images/android-37.1/google_apis_playstore_ps16k/arm64-v8a/source.properties"
```

Then **edit these lines in place** in `config.ini`:

```ini
image.sysdir.1=system-images/android-37.1/google_apis_playstore_ps16k/arm64-v8a/
target=android-37.1
tag.id=<SystemImage.TagId from source.properties>
tag.ids=<same>
```

If it stops booting afterwards, revert those four lines and you have a working device again.

## 8. Tune it

Same file. **Edit in place, never append** — duplicate keys in an INI have undefined precedence, which is a fun bug to chase at midnight.

`medium_phone` already gets the display right: `hw.lcd.width=1080`, `hw.lcd.height=2400`, `hw.lcd.density=420`. That's Pixel-class geometry already, so leave it alone. Three values are worth raising:

| Key | Default | Set to | Why |
|---|---|---|---|
| `hw.ramSize` | `2048` | `8192` | 2 GB is tight with Play services running |
| `vm.heapSize` | `228` | `512` | Small per-app heap |
| `disk.dataPartition.size` | `6G` | `12G` | Fills fast once Play installs things |

## 9. Boot it

```bash
android emulator list
android emulator start medium_phone
```

A window opens with the phone screen and a floating toolbar — rotate, volume, screenshot, plus extended controls for location, battery and sensors. First boot is cold; give it 30–60 seconds.

```bash
adb devices                    # emulator-5554   device
adb shell getconf PAGE_SIZE    # 16384 confirms ps16k took
```

The raw binary still takes every classic flag if you want more control:

```bash
emulator -avd medium_phone -gpu host -no-boot-anim
```

## 10. Sign in to Play

Swipe up for the app drawer, open Play Store, sign in. It'll sit on a spinner for a minute while it updates itself. Let it finish before you try to install anything.

---

## Stopping and starting again

This part matters more than it looks, because it's where a whole category of "my changes did nothing" bugs comes from.

```bash
android emulator stop emulator-5554
```

Closing the window or `adb emu kill` do the same thing. All three write a **Quick Boot snapshot** capturing RAM and disk. Restarting restores it in a few seconds instead of a full boot, with your Google account and apps intact:

```bash
android emulator start medium_phone
```

**But a snapshot pins the old hardware config.** Bump `hw.ramSize`, restart normally, and the emulator resumes the RAM image it captured under the old settings — your edit is silently ignored. After any `config.ini` change, force one cold boot:

```bash
emulator -avd medium_phone -no-snapshot-load
```

Or throw the snapshot away outright:

```bash
rm -rf ~/.android/avd/medium_phone.avd/snapshots
android emulator start medium_phone
```

Either way the next shutdown writes a fresh snapshot with the new settings, and fast restarts resume.

For a full user-data reset that keeps the device definition:

```bash
emulator -avd medium_phone -wipe-data
```

## Installing an app

```bash
android run --apks=app.apk
android run --apks=app.apk --activity=.MainActivity
android run --apks=base.apk,density-hdpi.apk,lang-en.apk
```

`android run` deploys only; it doesn't build. Plain `adb` still works fine too:

```bash
adb install app.apk
adb shell monkey -p com.your.package -c android.intent.category.LAUNCHER 1
```

## The translation table

If you're following an older guide — and almost every guide online is older — this is what maps to what:

| Deprecated | Current |
|---|---|
| `sdkmanager --list` | `android sdk list --all <pattern>` |
| `sdkmanager --install "pkg;a;b"` | `android sdk install pkg/a/b` |
| `sdkmanager --update` | `android sdk update` |
| `sdkmanager --uninstall` | `android sdk remove <pkg>` |
| `avdmanager list avd` | `android emulator list` |
| `avdmanager list device` | `android emulator create --list-profiles` |
| `avdmanager create avd -n X -d Y -k Z` | `android emulator create <profile>` |
| `emulator -avd X` | `android emulator start X` |
| `adb emu kill` | `android emulator stop emulator-5554` |
| `adb install X.apk` | `android run --apks=X.apk` |

Note the semicolons becoming slashes. That one silently ruins copy-pasted commands.

## Errors, and what they actually mean

| What you see | What's wrong |
|---|---|
| `No available formula with the name "android-cli"` | Missing tap: `brew tap android/tap` |
| `line 173: test: : integer expression expected` + `Unable to locate a Java Runtime` | No JDK. The first line is the wrapper choking on an empty version string. |
| `Could not load devices from .../devices.xml` | Old `avdmanager` scanning a newer image. Use `android emulator create`. |
| `Unknown option: '--profile=...'` | Positional now: `android emulator create medium_phone` |
| `sdk list` empty for images that exist | Known flakiness. `ls "$ANDROID_HOME/system-images/"` |
| Device booted the wrong image | `emulator create` chose for you. Repoint `image.sysdir.1`. |
| `config.ini` edits have no effect | A snapshot is pinning the old config. Cold boot. |
| Stuck on the boot animation | `emulator -avd medium_phone -no-snapshot-load` |
| Rendering glitches | `-gpu software` instead of `-gpu host` |

## If you want it all gone

I rebuilt this from scratch twice before it worked, so here's the full teardown. Budget on reclaiming 10–40 GB.

```bash
# stop everything
android emulator stop emulator-5554
adb kill-server
pkill -f qemu-system

# devices, snapshots, adb keys, cache
rm -rf ~/.android ~/.androidrc

# the SDK and every system image — this is the big one
rm -rf ~/Library/Android

# leftovers from a Homebrew cmdline-tools attempt
brew uninstall --cask android-commandlinetools 2>/dev/null
rm -rf "$(brew --prefix)/share/android-commandlinetools"

# the CLI itself
brew uninstall android-cli 2>/dev/null
brew untap android/tap 2>/dev/null

# the JDK, if nothing else needs it
brew uninstall --cask temurin@21
```

Then strip `ANDROID_HOME`, `ANDROID_SDK_ROOT`, `ANDROID_AVD_HOME`, `JAVA_HOME` and any Android `PATH` entries out of `~/.zshrc`, run `exec zsh`, and verify:

```bash
which -a android adb emulator avdmanager sdkmanager   # should print nothing
```

If you used a `curl | bash` installer instead of Homebrew, `which android` and follow the symlink before you remove the shell config — otherwise you'll lose the trail to it.

## What I'd tell myself at the start

Three things would have saved me an evening.

**Check `-h` before you check the docs.** Google's Android CLI page is genuinely good and genuinely out of date in at least two places. The binary on your disk is the authority.

**Verify state on the filesystem, not through the tool.** `android sdk list` was confidently wrong about what was installed. `ls` never is.

**When a command fails, ask which generation you're in before you debug the error.** Three of my four dead ends were the same root cause wearing different costumes: old tool, new artifacts.

The setup itself is genuinely good once you're through it. Cold boot is under a minute, snapshot restore is a couple of seconds, and it's fully native on Apple Silicon. It's just that the road there is currently under construction, and the signage hasn't been updated.

---

## Further reading

- [Android CLI overview](https://developer.android.com/tools/agents/android-cli) — accurate on `sdk`, stale on `emulator create`
- [Android CLI downloads](https://developer.android.com/tools/agents/android-cli/download) — where the Homebrew tap is documented
- [Support 16 KB page sizes](https://developer.android.com/guide/practices/page-sizes) — background on `ps16k`
- [Configure hardware acceleration](https://developer.android.com/studio/run/emulator-acceleration) — `-accel-check` and `-gpu` modes
