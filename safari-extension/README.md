# Safari Extension (H2M Vocabulary)

This folder contains a Safari Web Extension scaffold that wraps the existing web app.

## Structure

```text
safari-extension/
└── web-extension/
    ├── manifest.json
    ├── popup.html
    ├── popup.css
    ├── popup.js
    └── background.js
```

## What the Extension Does

- Adds a toolbar popup in Safari.
- Provides quick buttons to open:
  - Main app
  - Favorites view
  - Recency view
- Toggle an in-page overlay panel on the current tab
- Supports a custom app URL saved in extension storage.

## Build a Native Safari Extension Project

Run from repository root:

```bash
xcrun safari-web-extension-converter "./safari-extension/web-extension" --app-name "H2M Vocabulary Extension" --bundle-identifier "com.h2m.vocabulary.extension" --copy-resources --no-open
```

This creates an Xcode project for Safari.

If your shell line-continuation fails, use a single-line command:

```bash
xcrun safari-web-extension-converter "/Users/minhhh/Downloads/Code/vocabApp/safari-extension/web-extension" --project-location "/Users/minhhh/Downloads/Code/vocabApp/safari-extension" --app-name "H2M Vocabulary Extension" --bundle-identifier "com.h2m.vocabulary.extension" --copy-resources --no-open --no-prompt --force
```

## Enable and Run in Safari

1. Open generated Xcode project.
2. Select signing team and unique bundle identifier if needed.
3. Build and run.
4. In Safari:
   - `Settings` -> `Extensions`
   - Enable `H2M Vocabulary Extension`

## Troubleshooting

- **Error: utility not found**
  - Run:
    - `sudo xcode-select -s /Applications/Xcode.app/Contents/Developer`
    - `sudo xcodebuild -runFirstLaunch`

- **Converter only prints Usage / exit 64**
  - Do not put extra spaces after `\` in multiline commands.
  - Prefer the provided single-line command.

- **Cannot run from Xcode because of signing**
  - In Xcode -> each target -> `Signing & Capabilities`:
    - enable `Automatically manage signing`
    - select your Apple Team
    - ensure unique bundle IDs for app and extension targets

- **App runs but extension not visible**
  - In Safari, enable Developer menu:
    - Safari -> Settings -> Advanced -> Show features for web developers
  - Then open Safari `Settings -> Extensions` and enable your extension.

## Development Notes

- The popup defaults to `https://h2mvocab.vercel.app`.
- You can override URL in the popup and save it.
- The app now reads `?view=favorites` and `?view=recency` to switch initial tab.
- Some pages (like `safari://` and browser-internal pages) do not allow content script injection, so use **Open App** on those pages.
