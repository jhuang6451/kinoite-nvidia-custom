#!/usr/bin/env bash
set -euo pipefail

echo "Configuring Systemd user units..."

DMS_SERVICE_PATH="/usr/lib/systemd/user/dms.service"
if [ -f "$DMS_SERVICE_PATH" ]; then
    echo "✅ SUCCESS: Target file $DMS_SERVICE_PATH exists."
else
    echo "⚠️  WARNING: Target file $DMS_SERVICE_PATH not found."
fi

# Equvalent to `systemctl --user add-wants niri.service dms`
NIRI_WANTS_DIR="/usr/lib/systemd/user/niri.service.wants"
LINK_PATH="$NIRI_WANTS_DIR/dms.service"
mkdir -p "$NIRI_WANTS_DIR"
ln -sf "../dms.service" "$LINK_PATH"

if [ -L "$LINK_PATH" ]; then
    echo "✅ SUCCESS: Symlink created at $LINK_PATH"
    echo "   Link points to: $(readlink "$LINK_PATH")"
else
    echo "❌ ERROR: Symlink was NOT created!"
    exit 1
fi