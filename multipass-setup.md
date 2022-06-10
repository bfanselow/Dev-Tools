# Development Setup

## VM Setup

There are two recommended VM options: [multipass](https://multipass.run) and [VirtualBox](https://www.virtualbox.org). Multipass is more lightweight and allocates storage dynamically, but it does not readily support bridge networking. VirtualBox is well-established and has a pre-built VM you can import.

### Multipass

1. Install multipass: [Linux](https://multipass.run/docs/installing-on-linux), [MacOS](https://multipass.run/docs/installing-on-macos), [Windows](https://multipass.run/docs/installing-on-windows)
2. _Optional_: Set `sos-server` as primary: `multipass set client.primary-name=sos-server`
    - See https://multipass.run/docs/primary-instance for more information
3. Launch VM: `multipass launch --disk 100G --mem 10G --name sos-server`
    - Unfortunately, there isn’t a `multipass` option to increase disk storage (easily), but `multipass` allocates storage dynamically, so request much more than you need.
    - Multipass instances default to 1G of memory. There is a way to reallocate memory after instance creation, but you'll likely want at least 10GB.
4. If not setting `sos-server` as primary, manually mount host disk access: `multipass mount $HOME sos-server:/home/ubuntu/[dir]`
    - _MacOS_: For `multipass` to access Documents/Downloads:
        - System Preferences -> Security & Privacy -> Full Disk Access
        - Unlock and select _multipassd_.
5. Launch shell
    - If `sos-server` is the primary instance:
        1. `multipass shell`
    - Else:
        1. `multipass start sos-server`
        2. `multipass shell sos-server`
    - These commands can be used to restart the shell after any `multipass stop [instance]`.
6. Add host routing to your local machine:
    1. Get multipass IP address: `multipass info sos-server`
    2. Edit your local machine's hosts: `sudo nano /etc/hosts`
    3. Add the follow lines to the end of the file:
        ```
        192.168.64.2    alert.dev.spire.com
        192.168.64.2    soc.dev.spire.com
        ```
7. Access addresses through VPN(s) (if not connected automatically)
    1. Find utun number(s) (while connected to the VPN(s)): `netstat -nr | grep utun`
        - The `utun[#]` is associated with the IP addresses
    2. Add the following line to /etc/pf.conf after nat\* line
        - `nat on utun[#] from bridge100:network to any -> (utun[#])`
    3. Refresh (with `multipass` instance running): `sudo pfctl -f /etc/pf.conf`
    4. Stop `multipass` instance: `multipass stop`
    5. Restart `multipass`:
        - `sudo launchctl unload /Library/LaunchDaemons/com.canonical.multipassd.plist`
        - `sudo launchctl load /Library/LaunchDaemons/com.canonical.multipassd.plist`

