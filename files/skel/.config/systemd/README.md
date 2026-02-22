# Automatic NTFS Drive Mounting Service

This guide shows you how to create a `systemd` user service to automatically mount an NTFS drive at startup and how to resolve common permission issues.

## Set Up and Enable the Service

1. **Create the systemd user service file link:**

    First, navigate to your dotfiles directory and use `stow` to create a symbolic link for the `systemd` user unit service file.

    ```bash
    cd ~/dotfiles
    stow systemd
    ```

2. **Enable the user service:**

    Next, reload the `systemd` daemon, then enable and start the service. Replace `{service-name}` with the actual name of your service file (e.g., `ntfs-mount.service`).

    ```bash
    systemctl --user daemon-reload
    systemctl --user enable {service-name}.service
    systemctl --user start {service-name}.service
    ```

-----

## Troubleshooting: "Not authorized to perform operation"

This error occurs because standard users are not typically allowed to mount internal drives directly. To fix this, you need to create a **PolicyKit** rule to grant your user permission.

1. **Create the PolicyKit rules file:**

    Using `sudo`, create a new PolicyKit rules file in the `/etc/polkit-1/rules.d/` directory. We'll name it `90-allow-udisksctl-mount.rules`.

    ```bash
    sudo nano /etc/polkit-1/rules.d/90-allow-udisksctl-mount.rules
    ```

    Paste one of the following code blocks into the file:

      * **Option 1 (Recommended): Allow a specific group**
        This rule is more secure as it only allows members of a specific group (e.g., `wheel`) to mount internal drives without authentication.

        ```javascript
        // Allow members of the "wheel" group to mount internal drives without authentication
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.udisks2.filesystem-mount-system" &&
                subject.isInGroup("wheel")) {
                return polkit.Result.YES;
            }
        });
        ```

        > **Note:** Be sure to replace `"wheel"` with your actual user group. You can find your user's primary group by running the command `id -g -n`.

      * **Option 2 (Less Secure): Allow all active users**
        This rule allows any user who is currently logged in to mount internal drives without authentication. This is simpler for single-user systems but is not recommended for multi-user environments.

        ```javascript
        // Allow all active users to mount internal drives without authentication
        polkit.addRule(function(action, subject) {
            if (action.id == "org.freedesktop.udisks2.filesystem-mount-system" &&
                subject.active) {
                return polkit.Result.YES;
            }
        });
        ```

2. **Restart the PolicyKit service:**

    To apply the new rule, restart the PolicyKit service.

    ```bash
    sudo systemctl restart polkit.service
    ```

    Alternatively, you can simply reboot your computer.
