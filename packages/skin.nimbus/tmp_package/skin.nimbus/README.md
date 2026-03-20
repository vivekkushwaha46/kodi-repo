# Nimbus Lite — Optimized Kodi Skin for Low-End Devices

An optimized fork of the popular [Nimbus](https://github.com/ivarbrandt/skin.nimbus) skin by **Ivar Brandt**, tuned for smooth performance on low-end Smart TV processors (ARM-based SoCs, limited RAM). All original features, layouts, and navigation remain **identical** — only under-the-hood GPU/CPU-heavy operations (blur effects, excessive animations, deep visibility chains, widget pre-loading) have been stripped or simplified.

> **Kodi Version:** Omega (21.x)
> **Base Skin Version:** 0.1.42
> **Addon ID:** `skin.nimbus`

---

## What's Changed (Performance)

| Area | Original | Optimized |
|---|---|---|
| **Blur Effects** | Dynamic multi-layer blur on backgrounds | Removed / replaced with static diffuse overlays |
| **Animations** | Fade, slide, and pulse on many elements | Kept only essential focus animations |
| **Visibility** | Deeply nested `<visible>` boolean chains | Flattened and simplified where possible |
| **Widget Limits** | High item counts per widget | Capped to lower limits to reduce RAM usage |
| **Layout & Features** | *(unchanged)* | *(unchanged)* |

---

## Prerequisites

- **Kodi Omega (v21.x)** installed on your Smart TV (Android TV, Fire TV, etc.)
- The **Nimbus Helper** script addon (`script.nimbus.helper`) — Kodi will prompt you to install this dependency automatically when you enable the skin. If it doesn't, install it manually from the same source where you originally got Nimbus.

---

## How to Package the Skin as a ZIP

Kodi requires skins to be installed from a ZIP file where the **root folder** inside the ZIP matches the addon ID (`skin.nimbus`).

### Step 1 — Update the Version in `addon.xml`

Before packaging, bump the version number so Kodi recognizes this as a newer release than whatever is currently installed.

Open `addon.xml` and change the `version` attribute:

```xml
<!-- Before -->
<addon id="skin.nimbus" version="0.1.42" name="Nimbus" ...>

<!-- After (example — pick any higher version) -->
<addon id="skin.nimbus" version="1.0.0" name="Nimbus" ...>
```

> **Tip:** If you plan to push multiple updates, use semantic versioning (e.g., `1.0.1`, `1.0.2`, …).

### Step 2 — Create the ZIP

The ZIP must contain a single root folder named `skin.nimbus` (matching the addon ID). From the **parent** directory of your clone:

#### Automated Script (macOS / Linux)
I have created a helper script to do this automatically with the correct structure:

1. Open your terminal in the `skin.nimbus` folder.
2. Run: `chmod +x package.sh && ./package.sh`
3. This creates a ready-to-install `skin.nimbus.zip` in your current folder.

#### Manual (macOS / Linux)
If you prefer doing it manually from the **parent** directory of your clone:
```bash
cd /Users/imvivek/work   # parent of skin.nimbus
zip -r skin.nimbus.zip skin.nimbus/ -x "skin.nimbus/.git/*" -x "skin.nimbus/.gitignore" ...
```

### Step 3 — Verify the ZIP Structure

Before installing, verify the structure is correct:

```
skin.nimbus.zip
└── skin.nimbus/
    ├── addon.xml          ← must be here (not at ZIP root)
    ├── xml/
    ├── media/
    ├── fonts/
    ├── colors/
    ├── resources/
    ├── language/
    └── ...
```

If `addon.xml` is at the ZIP root instead of inside `skin.nimbus/`, Kodi will fail to install it.

---

## How to Install on Your TV

### Method 1 — Direct ZIP Install (Recommended for One-Time Setup)

1. **Download the ZIP** from your GitHub repository:
   - Go to: **[https://github.com/vivekkushwaha46/skin.nimbus/releases](https://github.com/vivekkushwaha46/skin.nimbus/releases)**
   - Download the latest `skin.nimbus.zip` from the release assets.
   - Alternatively, download the ZIP of the entire repo using the green **Code → Download ZIP** button (then rename the inner folder from `skin.nimbus-main` to `skin.nimbus` and re-zip).

2. **Transfer the ZIP to your TV:**
   - Copy via USB flash drive, or
   - Use a file manager app on Android TV (e.g., **X-plore**, **Solid Explorer**) to download directly from the URL, or
   - Use `adb push skin.nimbus.zip /sdcard/Download/` if you have ADB access.

3. **Install in Kodi:**
   - Open Kodi → **Settings** (⚙️ gear icon)
   - Go to **Add-ons** → **Install from zip file**
   - If prompted about "Unknown sources", go to **Settings → System → Add-ons** and enable **Unknown sources**, then return.
   - Navigate to the ZIP file location (e.g., `/sdcard/Download/`) and select `skin.nimbus.zip`.
   - Kodi will install the skin and ask if you want to switch to it — select **Yes**.

### Method 2 — Add GitHub as a File Source (For Easy Future Updates)

This method lets you point Kodi directly at your GitHub repository so you can re-download updated ZIPs without manually transferring files each time.

1. **Create the GitHub Release (Required for this link to work):**
   - On GitHub, go to your repository.
   - Click **Releases** → **Create a new release** (on the right sidebar).
   - Tag it (e.g., `v1.0.0`), give it a title.
   - **Attach the `skin.nimbus.zip`** you created locally into the assets box.
   - Click **Publish release**.

2. **Add the source in Kodi's File Manager:**
   - Open Kodi → **Settings** → **File Manager** → **Add Source**
   - Enter this URL as the source:
     ```
     https://github.com/vivekkushwaha46/skin.nimbus/releases/latest/download/skin.nimbus.zip
     ```
   - Name it `Nimbus Lite`.
   - Select **OK**.

> [!IMPORTANT]
> The link above will **404** until you have published at least one **Release** on GitHub with a ZIP asset.

3. **Install from the source:**
   - Go to **Settings** → **Add-ons** → **Install from zip file**.
   - Select the **Nimbus Optimized** source.
   - Select `skin.nimbus.zip` and install.

4. **Updating in the future:**
   - Package a new ZIP (with a bumped version in `addon.xml`).
   - Upload it to a new GitHub Release with the **same filename** (`skin.nimbus.zip`).
   - In Kodi: **Add-ons → Install from zip file → Nimbus Optimized** → select the new ZIP.

### Method 3 — ADB Sideload (Advanced / Fire TV)

If your TV supports ADB (e.g., Amazon Fire TV Stick):

```bash
# Push the ZIP
adb connect <TV_IP_ADDRESS>
adb push skin.nimbus.zip /sdcard/Download/

# Then install via Kodi UI as described in Method 1, Step 3
```

---

## Reverting to the Original Skin

If anything goes wrong, you can always switch back:

1. Open Kodi → **Settings** → **Interface** → **Skin** → select a different skin (e.g., **Estuary**).
2. Uninstall this skin: **Settings** → **Add-ons** → **My add-ons** → **Look and feel** → **Skin** → **Nimbus** → **Uninstall**.
3. Reinstall the original Nimbus from [ivarbrandt's repository](https://github.com/ivarbrandt/skin.nimbus).

---

## Troubleshooting

| Problem | Solution |
|---|---|
| *"Does not have the correct structure"* | The ZIP root must contain a folder named `skin.nimbus` with `addon.xml` inside it. Re-zip correctly. |
| *Missing dependency: `script.nimbus.helper`* | Install the helper addon first. Get it from the same source you originally installed Nimbus from, or from ivarbrandt's GitHub. |
| *Skin loads but looks broken* | Clear Kodi's skin cache: **Settings → System → Troubleshooting → Reset above settings to default**. Then restart Kodi. |
| *TV still lags* | Lower Kodi's GUI resolution: **Settings → System → Display → Resolution** → try 720p. Also disable hardware acceleration if available. |
| *Can't find "Unknown sources" toggle* | Change the Settings level to **Expert** (bottom-left of Settings screen). |

---

## Credits

- **Original Skin:** [Nimbus by Ivar Brandt](https://github.com/ivarbrandt/skin.nimbus)
- **License:** CC BY-SA 4.0 / GNU GPL v2.0 (see [LICENSE.txt](LICENSE.txt))
- **Optimization Fork:** [vivekkushwaha46](https://github.com/vivekkushwaha46/skin.nimbus)
