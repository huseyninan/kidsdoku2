# UI automation: automatic screenshots with Maestro

[Maestro](https://github.com/mobile-dev-inc/maestro) drives the iOS Simulator with YAML flows.
The flows in `.maestro/` walk through each screen and save PNGs with `takeScreenshot`.

## Requirements (macOS only)
- Xcode + an iOS Simulator (default: `iPhone 15`)
- Maestro: `curl -Ls "https://get.maestro.mobile.dev" | bash`
- Java 17+ (Maestro dependency)

## Run
```bash
scripts/screenshots.sh                    # builds, installs, runs light then dark
scripts/screenshots.sh "iPhone 15 Pro"    # other simulator
scripts/screenshots.sh "iPhone 15" --no-build
```
Results: `screenshots/light/` and `screenshots/dark/`.

## How it works
- The script switches appearance with `xcrun simctl ui <udid> appearance light|dark`
  and runs all flows once per mode, passing `-e SHOT_DIR=screenshots/<mode>`.
- Flows use `${SHOT_DIR}/<name>` as the screenshot path.
- `.maestro/01_onboarding.yaml` captures first launch; `02_main_flow.yaml` skips onboarding
  and captures: main menu, tutorial, parental gate, puzzle selection, game, settings.

## Notes / limitations
- Flows match English UI text, so keep the simulator language on English.
- The app's Paywall is not captured: the parental gate asks a random math question.
- Only the "Start Journey: 4x4" path and the first puzzle are captured; copy the
  puzzle-selection/game steps for 3x3 / 6x6 or other themes (Back to School, etc.).
- Matching by text breaks if copy changes. Adding `.accessibilityIdentifier(...)` to key
  views and using `tapOn: { id: ... }` makes flows sturdier.
- The app may not fully support dark mode; dark screenshots show what the system provides.
- To add a screen: append `tapOn`/`assertVisible`/`takeScreenshot` steps to a flow.
  Use `maestro studio` to inspect elements interactively.
