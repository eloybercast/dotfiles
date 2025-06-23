# SDDM Customization

This directory contains configuration files for the SDDM display manager with the Chili theme.

## Customization

You can customize your SDDM login screen by editing the `theme.conf` file in this directory.

### Main Configuration Options

- `background`: Path to your background image
- `type`: Background type (image or color)
- `color`: Background color (used if type=color or as fallback)
- `fontSize`: Font size for the interface
- `showLoginButton`: Whether to show the login button
- `passwordLeftMargin`: Left margin for the password field
- `usernameLeftMargin`: Left margin for the username field
- `passwordFieldWidth`: Width of the password field
- `usernameFieldWidth`: Width of the username field
- `showPassword`: Whether to show password text
- `passwordAlignment`: Alignment of text in password field
- `usernameAlignment`: Alignment of text in username field

### Advanced Customization

For more advanced customization, you can modify the QML files in the `chili` directory.

## Applying Changes

After modifying the configuration, run the setup script again:

```bash
bash ~/Documents/eloybercast/dotfiles/scripts/setup-sddm.sh
```

This will update your SDDM configuration with the changes.
