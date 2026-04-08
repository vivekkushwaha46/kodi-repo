#!/bin/bash

# Configuration
# Using absolute paths for robustness
KODI_DIR="/Users/imvivek/work/Kodi"
FENLIGHT_DIR="$KODI_DIR/fenlight-am"
SKIN_DIR="$KODI_DIR/skin.nimbus"
REPO_DIR="/Users/imvivek/work/Kodi/kodi-repo"

# Ensure we are in the repo directory
cd "$REPO_DIR" || exit 1

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

# Zip and Append Nimbus Repository
echo "Packaging repository.nimbus..."
rm -f repository.nimbus/*.zip repository.nimbus/*.md5
zip -r repository.nimbus/repository.nimbus-1.0.2.zip repository.nimbus/addon.xml > /dev/null
if command -v md5 >/dev/null 2>&1; then
    md5 -q repository.nimbus/repository.nimbus-1.0.2.zip > repository.nimbus/repository.nimbus-1.0.2.zip.md5
else
    md5sum repository.nimbus/repository.nimbus-1.0.1.zip | awk '{print $1}' > repository.nimbus/repository.nimbus-1.0.1.zip.md5
fi
sed 's/<?xml.*?>//g' repository.nimbus/addon.xml >> addons.xml
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

# Generate Kodi-compatible index.html files (Recursive Apache mod_autoindex style)
echo "Generating Kodi-compatible index.html files for File Manager..."

generate_indexes() {
    local dir="$1"
    local title="Index of /$(basename "$dir")"
    if [ "$dir" = "." ]; then
        title="Kodi Addon Repository"
    fi
    
    local index_file="$dir/index.html"
    
    # Kodi's scraper is extremely strict and expects exactly this standard Apache format
    echo "<html><head><title>$title</title></head><body><h1>$title</h1><hr><pre>" > "$index_file"
    echo "<a href=\"../\">../</a>" >> "$index_file"
    
    # List directories (with trailing slash so Kodi knows they are folders)
    for d in "$dir"/*/; do
        if [ -d "$d" ]; then
            local foldername="$(basename "$d")"
            # Ignore hidden or repo system folders
            if [[ "$foldername" != "repo" && "$foldername" != "packages" && "$foldername" != ".*" ]]; then
                echo "<a href=\"$foldername/\">$foldername/</a>" >> "$index_file"
                generate_indexes "$d"
            fi
        fi
    done
    
    # List files (exclude index.html and bash scripts)
    for f in "$dir"/*; do
        if [ -f "$f" ]; then
            local filename="$(basename "$f")"
            if [[ "$filename" != "index.html" && "$filename" != "build_repo.sh" && "$filename" != ".*" ]]; then
                echo "<a href=\"$filename\">$filename</a>" >> "$index_file"
            fi
        fi
    done
    
    echo "</pre><hr></body></html>" >> "$index_file"
}

generate_indexes "."

echo "============================================="
echo "Build Complete! Master Repository is ready."
echo "============================================="
