        # Equvalent to `systemctl --user add-wants niri.service dms`
        DEST_DIR="/usr/lib/systemd/user/niri.service.wants"
        mkdir -p "$DEST_DIR"
        ln -sf "../dms.service" "$DEST_DIR/dms.service"