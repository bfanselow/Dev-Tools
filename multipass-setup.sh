#!/bin/sh

################################################################################################
#
# Create/launch a new multipass instance
#
# After running this script, you will want to do the following:
#   1) Add user account(s). Only user "ubuntu" will be configured after script.
#        adduser <username>
#
#   1) Add host routing to your local machine. Multipass does not expose 127.0.0.1 for local access.
#       * Get multipass IP address: multipass info sos-server1
#       * Edit your local machine's hosts: sudo nano /etc/hosts
#       * Add the following example lines to the end of the file:
#           ~~~~~~~~~~
#           192.168.64.2    alert.dev.spire.com
#           192.168.64.2    soc.dev.spire.com
#           ~~~~~~~~~~
#.     * Test:  dig, host and nslookup bypass this file, so to test:
#          $ dscacheutil -q host -a name soc.dev.spire.com
#
#   2) Configure VPN routing if the instance will be using VPN access.
#        * Find utun number(s) (while connected to the VPN(s)): netstat -nr | grep utun
#        * The utun[#] is associated with the IP addresses
#        * Add the following line to /etc/pf.conf after nat* line for each of the utun numbers
#             nat on utun[#] from bridge100:network to any -> (utun[#])
#           For example if you have utun1 and utun2 listed, add the following two lines:
#             ~~~~~~~~~~
#             nat on utun1 from bridge100:network to any -> (utun1)
#             nat on utun2 from bridge100:network to any -> (utun2)
#             ~~~~~~~~~~
#        * Refresh (with multipass instance running): sudo pfctl -f /etc/pf.conf
#        * Stop multipass instance: multipass stop
#        * Restart multipass:
#           $ sudo launchctl unload /Library/LaunchDaemons/com.canonical.multipassd.plist
#           $ sudo launchctl load /Library/LaunchDaemons/com.canonical.multipassd.plist
#
#
#   3) If you need to edit the specs of a lunched instance:
#     $  launchctl unload /Library/LaunchDaemons/com.canonical.multipassd.plist
#     $  vi /var/root/Library/Application\ Support/multipassd/multipassd-vm-instances.json
#     $  launchctl load /Library/LaunchDaemons/com.canonical.multipassd.plist
#
#########################################################################

MYNAME="multipass_launch.sh"

LOCAL_DATA_PATH_BASE="/Users/williamfanselow/MultiPass/mounts"
MOUNT_TARGET_BASE="/home/spire"

NAME=""
CPU=""
DISK=""
MEM=""

# Defaults
DEFAULT_DISK="100G"
DEFAULT_MEM="10G"
DEFAULT_CPU=1
MOUNT=0

## Parse the args: key/value pairs are assumed to passed as "<key>=<val>"
while [ "$1" != "" ]; do
    PARAM=`echo $1 | awk -F= '{print $1}'`
    VALUE=`echo $1 | awk -F= '{print $2}'`
    echo "$PARAM=$VALUE"
    case $PARAM in
        "--name")
          NAME=$VALUE
        ;;
        "--cpu")
          CPU=$VALUE
        ;;
        "--disk")
          DISK=$VALUE
        ;;
        "--mem")
          MEM=$VALUE
        ;;
        "--mount")
          MOUNT=1
        ;;
    esac
    shift
done


# We require name
if [ "X${NAME}" = "X" ]; then
   echo ""
   echo "$MYNAME: Cmd-line ERROR: must provide name (--name <name>)"
   exit 1
fi

if [ "$CPU" = "" ]; then
   CPU=${DEFAULT_CPU}
fi
if [ "$DISK" = "" ]; then
   DISK=${DEFAULT_DISK}
fi
if [ "$MEM" = "" ]; then
   MEM=${DEFAULT_MEM}
fi

LAUNCH_CMD="multipass launch --name $NAME --disk $DISK --mem $MEM --cpus ${CPU}"
echo $LAUNCH_CMD
#$LAUNCH_CMD

if [ $MOUNT -eq 1 ]; then
  LOCAL_DATA_PATH="${LOCAL_DATA_PATH_BASE}/${NAME}"
  MOUNT_TARGET="${MOUNT_TARGET_BASE}/${NAME}"

  if [ -d $LOCAL_DATA_PATH ]; then
    MOUNT_CMD="multipass mount $LOCAL_DATA_PATH ${NAME}:${MOUNT_TARGET}"
    echo $MOUNT_CMD
    #$MOUNT_CMD
  else
    echo "$MYNAME: ERROR - Local data path does not exist: $LOCAL_DATA_PATH"
    exit 1
  fi
fi

sleep 1
#multipass info $NAME
