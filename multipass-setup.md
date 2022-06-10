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

### VirtualBox - From Image

1. Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for your system.
2. Restart your computer (VirtualBox requires a restart to setup properly).
3. Download and import [the provided VM image](https://drive.google.com/drive/folders/16VC_CAAHxb5le9dJ1J_HAvyv1bwNXVVI).
4. Set up your local hosts file to route links properly.
    1. Open a bash terminal on your local machine. Type `sudo nano /etc/hosts` and enter your password for your computer to open up your computer's hosts file.
    2. Add the following lines to the end of the file.
        ```
        127.0.0.1   alert.dev.spire.com
        127.0.0.1   soc.dev.spire.com
        ```
        ![](images/dev_setup_05.png)
    3. Press ctrl + x, then "Y" then enter to save the changes.
5. Connect to the VM with your terminal.
    1. First, power up the VM in "Headless Mode." To do this, select your VM. Click the little black arrow next to "Start", then click "Headless Start." Headless Mode will not pop up a screen to interact with, but that's ok because we will be accessing the VM through the terminal. ![](images/dev_setup_06.png)
    2. Open up your terminal. From any directory, type
        ```
        ssh -p 2222 <username>@localhost
        ```
        replacing \<username> with the username you selected when setting up the VM. If you are using the provided VM, the username is "spire" and the password is "changeme" This command tells the computer to try to make a connection with the VM using port 2222 and the username given. ![](images/dev_setup_19.png)
    3. You'll likely receive a warning that the authenticity of the host cannot be established. This is safe to ignore because we're connecting to a local device, so type yes and hit enter. ![](images/dev_setup_33.png)
    4. You'll then be prompted for your password. This is the password you entered when setting up the VM earlier. ![](images/dev_setup_36.png)
    5. If you did everything right, you should see something similar to the following appear. ![](images/dev_setup_47.png)

### VirtualBox - From Scratch

1. Download [VirtualBox](https://www.virtualbox.org/wiki/Downloads) for your system.
2. Restart your computer (VirtualBox requires a restart to setup properly).
3. Download version **18.04** of an [Ubuntu Server image](https://ubuntu.com/download/server#releases).
    1. Click on "Option 2 - Manual server installation". ![](images/dev_setup_02.png)
    2. Scroll down to "Alternative downloads" and click "Get Ubuntu Server 18.04 LTS" This will download the server image. ![](images/dev_setup_29.png)
    3. If the file name is **ubuntu-18.04.5-live-server-amd64.iso** you have downloaded the correct image.
4. Open VirtualBox. Click "New" to create a new virtual machine.
    1. Name the VM whatever you would like. Leave the Machine Folder the same. Select "Linux" for "Type" and "Ubuntu (64-bit)" for version. ![](images/dev_setup_34.png)
    2. Allocate RAM for the VM. We recommend at least 8 gigabytes of RAM, so 8192 megabytes (MB). ![](images/image4.png)
    3. Click "Create a virtual hard disk now" and then "Create". ![](images/dev_setup_38.png)
    4. Click "VDI (VirtualBox Disk Image)" then "Continue". ![](images/dev_setup_35.png)
    5. Select "Fixed size"then click "Continue". ![](images/dev_setup_44.png)
    6. Leave the file location at the default. We recommend 80 GB. You may allocate more memory but we do not recommend allocating less. Click "Create". ![](images/dev_setup_22.png)
5. Attach the Ubuntu server image you downloaded as the controller.
    1. On your new VM, select "Settings".
    2. Go to "Storage". ![](images/dev_setup_15.png)
    3. Select "Adds optical disk". ![](images/dev_setup_11.png)
    4. Select the Ubuntu server image you downloaded and click "Open". ![](images/dev_setup_31.png)
    5. Select it from the menu and click "Choose". ![](images/dev_setup_26.png)
    6. Click "Ok" to save your settings.
6. Set up Ubuntu.
    1. We will normally be running in "Headless Mode" but for set-up, just click "Start" on the VM you created.
    2. Click inside the VM when it pops up and allow mouse capturing. ![](images/dev_setup_40.png)
    3. Select your preferred language. ![](images/dev_setup_41.png)
    4. Select "Update to the new installer" and wait for the install to run. ![](images/dev_setup_07.png)
    5. Select your keyboard, then select "Done." ![](images/dev_setup_23.png)
    6. Select "Done" or "Continue" until you reach "Profile setup." There is no need to `snap install` anything during this process - that is done through a script in the SOC codebase once the VM is set up. Enter whatever information you would like, but make sure you keep track of what you entered or you will not be able to use the VM. ![](images/dev_setup_42.png)
    7. Select "Install OpenSSH server," then "Done." You will need OpenSSH to access the VM from the terminal. ![](images/dev_setup_32.png)
    8. Select "Done" until you see this screen. Allow Ubuntu to finish installing whatever is left until the bottom button changes to "Reboot". ![](images/dev_setup_24.png)
    9. Hit "Enter" at the prompts provided until the machine reboots, then power down the machine.
7. Set up ports from the virtual machine to your home computer.
    1. Go to Settings on your created VM. ![](images/dev_setup_13.png)
    2. Click "Network" then click "Advanced" at the bottom. Click "Port Forwarding". ![](images/dev_setup_37.png)
    3. We are going to add 2 port forwards. One to talk to the VM through the terminal, and one so the VM can talk to our browser so we can pull up the SOC locally. First, click the "Adds a new port forwarding rule." Button on the top right. ![](images/dev_setup_08.png)
    4. Name the rule "guesthttp" set the host port to 80 and the guest port to 8080. Then, add a new port forwarding rule with the same button on the top right. Name this rule "guestssh" set the host port to 2222 and the guest port to 22. The ports should look like this when you are finished. ![](images/dev_setup_16.png)
    5. Click "Ok" to save your changes, then "Ok" again.
8. Set up your local hosts file to route links properly.
    1. Open a bash terminal on your local machine. Type `sudo nano /etc/hosts` and enter your password for your computer to open up your computer's hosts file.
    2. Add the following lines to the end of the file.
        ```
        127.0.0.1   alert.dev.spire.com
        127.0.0.1   soc.dev.spire.com
        ```
        ![](images/dev_setup_05.png)
    3. Press ctrl + x, then "Y" then enter to save the changes.
9. Connect to the VM with your terminal.
    1. First, power up the VM in "Headless Mode." To do this, select your VM. Click the little black arrow next to "Start", then click "Headless Start." Headless Mode will not pop up a screen to interact with, but that's ok because we will be accessing the VM through the terminal. ![](images/dev_setup_06.png)
    2. Open up your terminal. From any directory, type
        ```
        ssh -p 2222 <username>@localhost
        ```
        replacing \<username> with the username you selected when setting up the VM. If you are using the provided VM, the username is "spire" and the password is "changeme" This command tells the computer to try to make a connection with the VM using port 2222 and the username given. ![](images/dev_setup_19.png)
    3. You'll likely receive a warning that the authenticity of the host cannot be established. This is safe to ignore because we're connecting to a local device, so type yes and hit enter. ![](images/dev_setup_33.png)
    4. You'll then be prompted for your password. This is the password you entered when setting up the VM earlier. ![](images/dev_setup_36.png)
    5. If you did everything right, you should see something similar to the following appear. ![](images/dev_setup_47.png)

## Setting up the SOC

First, ensure that you…

-   Have access to the [nsat/operations-center](https://github.com/nsat/operations-center) Github repository.
-   Have a database dump of the SOC to use to populate the database. [You can find the database dump here](https://drive.google.com/drive/folders/16VC_CAAHxb5le9dJ1J_HAvyv1bwNXVVI).
-   Are currently connected to the LAN VPN.
-   Have started and launched a shell to the VM.

You can proceed with installation for now, but you will also need to have an updated _.env_ file from an SOS developer to boot up the SOC. Contact the SOS team on Slack to request the required changes to the _.env_. Because the updated _.env_ includes information like database passwords, it must be requested directly and cannot be placed in the git repository.

1. Github Set-up and Cloning
    1. Ssh into your VM if you are not already in it.
    2. First, you'll need to connect your VM to your Github account. [Here are the instructions to set up Github sshing.](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh) Please note you will likely have to use the Linux instructions since the VM is running Linux. The Github instructions default to whatever physical machine you are on, so be sure to check that you're looking at the Linux instructions. Additionally, you do not have to install xclip when Github recommends you do so. You can instead `cat` the ssh file to the terminal such as `cat ~/.ssh/id_ed25519.pub` and copy and paste it.
    3. Run
        ```
        git clone git@github.com:nsat/operations-center.git
        ```
        to clone the repository. ![](images/dev_setup_25.png)
    4. Type `cd operations-center/` to get to the operations center folder.
    5. Run 
        ```
        git submodule init
        ```
2. Installing necessary dependencies and development tools.

    1. The majority of the downloads are taken care of using a bash script, which can be found in the bin file. You can run the shell script using `make install_dependencies`.
    2. You may have to enter "y" at certain points to confirm you want to download various packages.
    3. After the script has fully run, enter
        ```
        sudo usermod -aG docker <vm-username>
        ```
        to add yourself to the docker group. You may need to enter your password.
    4. Run `sudo npm install` to install all necessary npm packages. This should run the installation of the needed packages.
    5. Finally, type `exit` to logout, then ssh back into the server.

3. Bringing up the SOC

    1. From the operations folder, update the ".env" file with the extra variables from a member of the SOS team. You can do this using nano in the [same way you did with the etc/hosts file earlier.](#connection-set-up-and-dependency-installation)
    2. Run `make build` This tells docker to begin setting up everything the SOC will need to run. The first "make build" takes a while but future runs will be significantly faster. Go make some tea or take a walk and come back in 5-10 minutes.
    3. After make build is complete, run `make run` to bring up the containers and get them talking to each other. This shouldn't take more than a minute or two.
    4. Now run
        ```
        sudo chown -R 1000:1000 keys/ logs/ shared/ static/
        ```
        to change the owner of some of the directories so your user can access them.
    5. Run `make restart` to restart the docker containers. If at any point you receive a "502 Bad Gateway Error" or an "Disallowed host name" generally running `make restart` will fix it.
       ![](images/dev_setup_48.png)
    6. In your browser on your local machine, go to soc.dev.spire.com You should receive a Google Authorization Error. That's actually a good thing, it means set up went well, we just need to get the database ready and add your user account as an admin and we'll be good to go!

        ![](images/dev_setup_21.png)

4. Creating the database.
    1. Ensure that you have unzipped the database dump.
    2. Now we need to get the database from our physical machine to our remote VM. Open a new terminal and change into the directory where you have the database dump on your local machine. ![](images/dev_setup_03.png)
    3. Run the following command
        ```
        scp -P 2222 <name_of_database_dump>.sql <username>@localhost:~/…<path to operations center directory>.../operations-center/bin
        ```
        replacing the name of the database dump, the username, and the path to the operations center with what you set them as. ![](images/dev_setup_45.png)
    4. If it worked, you should be able to see the database dump in the operations-center/bin folder inside of the VM. ![](images/dev_setup_10.png)
    5. Enter `make load_db` which loads the database dump. This will take a while to run because it is creating millions of database entries.
    6. Run `make build` and `make run` again to rebuild and reboot the containers.
    7. You can either delete the database dump file by typing `rm ./bin/database_dump.sql` or you can keep it for future use. The dump file is ignored by git so it will not be committed.
5. Create an admin account and log in.
    1. Still in the operations-center directory, run `make createsuperuser` to start the process of making an admin account. This will be the account you use to access the admin page of the SOC and for general SOC navigation and use. Even if you have an account in the production or staging SOC, you need to create a superuser here in order to access the admin page, which is needed for creating Unified Alerting Tokens or editing and adding data to the database.
    2. The terminal will prompt you for your username, email, and password. These are what you will log into the SOC with. ![](images/dev_setup_30.png)
    3. After you are finished and the terminal has printed "Superuser created successfully." go to [soc.dev.spire.com/admin/](http://soc.dev.spire.com/admin/) You should see a log-in page. Log into the SOC with the username and password you just created as a super user. ![](images/dev_setup_27.png)
    4. You should now hit the Django admin page, which looks like the screenshot below. To access the home page of the SOC, go to [soc.dev.spire.com](http://soc.dev.spire.com/) ![](images/dev_setup_12.png)

**OPTIONAL FURTHER STEPS**

-   Connect VScode to the VM using ssh follow [these instructions from VScode](https://code.visualstudio.com/docs/remote/ssh) We have found that placing the following in the .ssh/config file on your home machine works well to allow VScode to connect easily.

    ```
    Host old_vm
    HostName localhost
    Port 2222
    User kayden
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_rsa
    StrictHostKeyChecking no
    ```

-   [Change the password of the spire user.](https://itsfoss.com/change-password-ubuntu/)
