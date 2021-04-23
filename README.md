# install-salt-macos
Bash script to install saltstack on macOS using the official salt repo installer.

## Usage

```
install_salt_macos.sh <salt version number> [user] [install homebrew] [archived version]
```

## Parameters
| Parameter | Accepted Value | Use |
| --------- | -------------- | --- |
| salt version number | integer | version to install, i.e. 3003 |
| (optional) user | user name | user who should install salt, defaults to current |
| (optional) install homebrew | 0 for yes; anything else for no | should homebrew also be installed, defaults to yes |
| (optional) archived version | 0 for yes; anything else for no | download from the salt archive, defaults to no |

## Contributing
Please see our [guide to contributing](https://github.com/suransys/contributing).