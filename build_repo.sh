#!/bin/bash

# Configuration
# Resolving the absolute path for the Kodi dev directory assuming this script is in kodi-repo/
KODI_DIR="../Kodi"
FENLIGHT_DIR="$KODI_DIR/fenlight-am"
SKIN_DIR="$KODI_DIR/skin.nimbus"

echo "Building Master Kodi Repository..."

# 1. Create directories
mkdir -p plugin.video.fenlight.am

# 2. Copy FenLight Zip
echo "Copying FenLight..."
cp "$FENLIGHT_DIR"/plugin.video.fenlight.am-*.zip plugin.video.fenlight.am/
# Generate MD5 for the zip
for zip in plugin.video.fenlight.am/*.zip; do
    if command -v md5 >/dev/null 2>&1; then
        md5 -q "$zip" > "${zip}.md5"
    else
        md5sum "$zip" | awk '{print $1}' > "${zip}.md5"
    fi
done

# 3. Copy Skin and Helper Zips
echo "Copying Nimbus Skin and Helper..."
cp -r "$SKIN_DIR"/repo/skin.nimbus ./
cp -r "$SKIN_DIR"/repo/script.nimbus.helper ./

# 4. Generate Master addons.xml
echo "Generating master addons.xml..."
cat > addons.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<addons>
EOF

# Append FenLight addon.xml (strip <?xml ... ?> if exists)
sed 's/<?xml.*?>//g' "$FENLIGHT_DIR"/packages/plugin.video.fenlight.am/addon.xml >> addons.xml
echo "" >> addons.xml

# Append Nimbus Skin addon.xml
sed 's/<?xml.*?>//g' "$SKIN_DIR"/packages/skin.nimbus/addon.xml >> addons.xml
echo "" >> addons.xml

# Append Nimbus Helper addon.xml
sed 's/<?xml.*?>//g' "$SKIN_DIR"/packages/script.nimbus.helper/addon.xml >> addons.xml
echo "" >> addons.xml

cat >> addons.xml << 'EOF'
</addons>
EOF

# 5. Generate MD5 for addons.xml
echo "Generating addons.xml.md5..."
if command -v md5 >/dev/null 2>&1; then
    md5 -q addons.xml > addons.xml.md5
else
    md5sum addons.xml | awk '{print $1}' > addons.xml.md5
fi

# 6. Generate .nojekyll to prevent GitHub Pages Jekyll build errors
echo "Generating .nojekyll and index.html..."
touch .nojekyll

# Generate a dynamic index.html with zip links for visitors
echo "Generating index.html..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Kodi Addon Repository</title>
    <style>
        body { font-family: -apple-system, sans-serif; padding: 40px; line-height: 1.6; max-width: 800px; margin: 0 auto; color: #333; }
        h1 { border-bottom: 2px solid #eee; padding-bottom: 10px; }
        .instructions { background: #f9f9f9; padding: 15px; border-left: 4px solid #0366d6; margin: 20px 0; }
        code { background: #eee; padding: 2px 5px; border-radius: 3px; font-weight: bold; }
        ul { list-style-type: none; padding: 0; }
        li { margin: 10px 0; }
        a { text-decoration: none; color: #0366d6; font-weight: 500; font-size: 16px; }
        a:hover { text-decoration: underline; }
    </style>
</head>
<body>
    <h1>My Kodi Repository</h1>
    
    <div class="instructions">
        <h3>How to Install Automactially (Recommended)</h3>
        <p>You do not need to download these files! Simply open Kodi and go to <strong>File Manager &gt; Add Source</strong>.</p>
        <p>Type in the exact URL of this webpage (e.g. <code>https://yourusername.github.io/kodi-repo/</code>) and Kodi will automatically read the hidden files and install the repository.</p>
    </div>

    <hr>

    <h3>Direct Downloads (Manual Installation via USB)</h3>
    <p>If you prefer to install from a zip file manually, you can download them below:</p>
    <ul>
EOF

# Find all zip files and generate HTML links
for zip_file in $(find . -mindepth 2 -type f -name "*.zip" | sed 's|^\./||' | sort); do
    filename=$(basename "$zip_file")
    echo "        <li>&#128194; <a href=\"$zip_file\">Download $filename</a></li>" >> index.html
done

cat >> index.html << 'EOF'
    </ul>
</body>
</html>
EOF

echo "============================================="
echo "Build Complete! Master Repository is ready."
echo "============================================="
