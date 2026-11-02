# QuestCraft 26.3

Work-in-progress port of [QuestCraft](https://github.com/QuestCraftPlusPlus/QuestCraft) to Minecraft 26.3 (Java 25, LWJGL 3.4, SDL3) with Vivecraft on Quest standalone.

## Quick start

1. Edit `questcraft.config` and set `GITHUB_OWNER` to your GitHub name.
2. Run `release.cmd` (double-click) or `./release.sh` from Git Bash.
3. Follow `dist/release/NEXT-STEPS.txt`: upload the release files, push the Pojlib fork, build the APK, sideload it.

`./release.sh --check-links` also checks every mod download in `mods.json`. `--skip-checks` skips the compile/test step.

Needs: JDK 25 on PATH and Git for Windows. To build the APK you also need Android Studio (SDK + NDK) and Unity 2022.3.62f3 with Android support.

## What's in here

| Folder | What it is |
|---|---|
| `VivecraftMod/` | Vivecraft `Multiloader-26.3` + QuestCraft's OpenXR backend (branch `questcraft-26.3`) |
| `Pojlib/` | Launcher core (branch `QuestCraft-6.0.0` + 26.3 changes) |
| `Pojlib/jre_lwjgl34/` | SDL3 shim + fake GLFW built against LWJGL 3.4.1 |
| `QCXR-XR-Wrapper/` | Unity launcher UI (unchanged so far) |
| `Amethyst-Android/` | Reference only (LWJGL 3.4 Android natives come from here) |
| `dist/` | Build outputs |

## How 26.3 runs on the Quest

- **Java 25.** `JavaRuntimes` picks Java 25 for 26.x and the legacy Java 22 runtime for older versions, also when offline.
- **SDL3.** Minecraft 26.x replaced GLFW with SDL3. Instead of real SDL (which wants its own Android activity), `Pojlib/jre_lwjgl34/src/org/lwjgl/sdl` implements the 85 SDL functions Minecraft calls on top of QuestCraft's existing fake GLFW, so the native input/EGL bridge is unchanged. Input arrives as GLFW callbacks and is turned into SDL events by `QCSDLBridge`.
- **Rendering.** Minecraft is forced onto its OpenGL backend (`--graphicsBackend opengl`), translated to GLES by LTW as before. Vivecraft renders each eye and copies it into the OpenXR swapchain with `glCopyImageSubData`, a raw copy that avoids sRGB double-encoding.
- **LWJGL 3.4** for 26.x goes into a separate classpath jar and natives folder (`assets/lwjgl34`), so older versions keep the 3.3 setup.

## Checks

```bash
sh Pojlib/scripts/check-pojlib.sh
```

This compiles all of Pojlib against the Android 14 API (no SDK needed, Robolectric's android-all is downloaded once into `.check-cache/`). It then runs:
- `VersionSelectionTest`: Java/LWJGL selection against Mojang's real version files
- `QCSDLBridgeTest`: 52 checks on the SDL shim's events, key mapping and pixel formats

## Not verified yet

Everything below needs a headset:
- LTW with 26.3's new renderer (renderpearl)
- the OpenXR copy path and image orientation
- SDL functions that mods call beyond the 85 Minecraft uses (they'd show up as `NoSuchMethodError` in the log)
- Sodium 0.9 on the Quest GPU

Grab logs with `adb logcat -d > log.txt`.

## Scripts

| Script | Does |
|---|---|
| `release.sh` | Everything below plus staging and next steps |
| `Pojlib/scripts/build-lwjgl34.sh` | Builds the LWJGL 3.4 + SDL shim jar and stages natives |
| `Pojlib/scripts/package-jre25.sh` | Repackages the Android Java 25 build into `JRE-25.zip` |
| `Pojlib/scripts/check-pojlib.sh` | Compile check + tests |
| `Pojlib/scripts/test-lwjgl34.sh` | SDL shim tests only |
| `Pojlib/scripts/gen-sdl-shim-constants.sh` | Regenerates SDL constants from the LWJGL jar |

## Credits / licenses

- QuestCraft / Pojlib / QCXR (QuestCraftPlusPlus), LGPL-3.0
- Vivecraft, LGPL-3.0
- Android Java 25 build: AngelAuraMC/angelauramc-openjdk-build, GPLv2 with Classpath Exception
- LWJGL 3.4.1 Android natives and the GLFW stub lineage: PojavLauncher / Amethyst-Android, LGPL-3.0; LWJGL itself is BSD-3
