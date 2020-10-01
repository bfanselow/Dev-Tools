#!/bin/bash
####################################################################################################
# Install all the DEV tools necessary for the dev environment
#
# Currently configured for install on Ubuntu-server (18.04)
#
# !!! Assumes python3 is already installed. Not done here as this can be a trickier issue due to current python installs 
#
# INSTALLED TOOLS: pip3, virtualenv3, docker, docker-compose, nodejs, npm, typescript
#
####################################################################################################

## Ensure python3 first!
python3 --version
if [ $? -ne 0 ]; then
   echo "You must install a version of Python3 prior to running this script"
   exit
fi

#==========================
echo ""
sleep 1
## pip3 
TOOL='pip3'
pip3 --version
if [ $? -eq 0 ]; then
  echo "Install found: $TOOL"
else
  echo "Install not found: $TOOL"
  
  echo ""
  echo "Installing $TOOL..."
  sudo apt-get install python3-pip

  pip3 --version
  if [ $? -ne 0 ]; then
     echo "Install failed: $TOOL"
     exit 1
  else
     echo "You may want to symlink pip3 to pip(2) if pip was not previously installed: ln -s /usr/bin/pip3 /usr/bin/pip"
  fi
fi


#==========================
echo ""
sleep 1
## virtualenv
TOOL='virtualenv'
virtualenv --version
if [ $? -eq 0 ]; then
  echo "Install found: $TOOL"
else
  echo "Install not found: $TOOL"

  echo "Installing $TOOL..."
  sudo pip3 install virtualenv

  virtualenv --version
  if [ $? -ne 0 ]; then
     echo "Install failed: $TOOL"
     exit 1
  fi
fi


#==========================
echo ""
## Docker
TOOL='docker'
docker --version
if [ $? -eq 0 ]; then
   echo "Install found: $TOOL"
else
   echo "Install not found: $TOOL"

  echo ""
  echo "Installing $TOOL..."
  sudo apt-get remove docker docker-engine docker.io containerd runc
  sudo apt-get update
  sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
  sudo apt-key fingerprint 0EBFCD88
  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
  sudo apt-get update
  sudo apt-get install docker-ce docker-ce-cli containerd.io
  
  docker --version
  if [ $? -ne 0 ]; then
     echo "Install failed: $TOOL"
     exit 1
  else
     echo "You probably want to add yourself to the docker group: sudo usermod -aG docker \${USER}. Logout/login to take affect"
  fi
fi

#==========================
echo ""
sleep 1
## docker-compose
TOOL='docker-compose'
docker-compose --version
if [ $? -eq 0 ]; then
   echo "Install found: $TOOL"
else
   echo "Install not found: $TOOL"

   echo ""
   echo "Installing $TOOL..."
   sudo curl -L "https://github.com/docker/compose/releases/download/1.27.4/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose
   docker-compose --version
   if [ $? -ne 0 ]; then
      echo "Install failed: $TOOL"
      exit 1
   fi
fi


#==========================
echo ""
sleep 1
## nodejs
TOOL='nodejs'
nodejs -v
if [ $? -eq 0 ]; then
   echo "Install found: $TOOL"
else
   echo "Install not found: $TOOL"

   echo ""
   echo "Installing $TOOL..."
   sudo apt install nodejs

   nodejs -v
   if [ $? -ne 0 ]; then
      echo "Install failed: $TOOL"
      exit 1
   fi
fi


#==========================
echo ""
sleep 1
# npm
TOOL='npm'
npm -v
if [ $? -eq 0 ]; then
   echo "Install found: $TOOL"
else
   echo "Install not found: $TOOL"

   echo ""
   echo "Installing $TOOL..."

   sudo apt install npm
   npm -v
   if [ $? -ne 0 ]; then
      echo "Install failed: $TOOL"
      exit 1
   fi
fi


#==========================
echo ""
sleep 1
# typescript 
TOOL='typescript'
tsc -v
if [ $? -eq 0 ]; then
   echo "Install found: $TOOL"
else
   echo "Install not found: $TOOL"

   echo ""
   echo "Installing $TOOL..."

   sudo npm install -g typescript
   tsc -v
   if [ $? -ne 0 ]; then
      echo "Install failed: $TOOL"
      exit 1
   fi
fi
