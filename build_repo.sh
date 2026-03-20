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

# Generate a basic index.html for visitors
cat > index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Kodi Addon Repository</title>
</head>
<body>
    <h1>My Kodi Repository</h1>
    <p>To install these addons, add this repository URL into Kodi's File Manager:</p>
    <code>[Your GitHub Pages URL]</code>
</body>
</html>
EOF

echo "============================================="
echo "Build Complete! Master Repository is ready."
echo "============================================="
