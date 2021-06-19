#!/bin/bash
# -*- mode: sh -*-
# © Copyright IBM Corporation 2015, 2019
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Install script for silent install of IBM MQ on Ubuntu
# Requires apt
# We need super user permissions for some steps

# Ensure Java is installed
$java_package="java"
dpkg -s $java_package &> /dev/null
if [ $? -ne 0 ]
    then
        echo "Java is not installed"  
        sudo apt-get update
        sudo apt install default-jre -y
        echo "Installed Java version is"
        java -version
    else
        echo  "Java is installed with version"
        java -version
fi

# Create user, groups and assign password
sudo addgroup mqclient
#sudo adduser app
sudo adduser --quiet --disabled-password --shell /bin/bash --home /home/app --gecos "User" app
passwd="admin"
username="app"
echo "$username:$passwd" | sudo chpasswd
sudo adduser app mqclient
groups app

# Before we start the install and config, check that the user created the group "mqclient"

getent group mqclient
#returnCode=$?
if [ $? -eq 0 ]
then
    echo "Group mqclient exists. Proceeding with install."
    echo
else
    echo "Group mqclient does not exist!" 
    echo "Please visit https://developer.ibm.com/tutorials/mq-connect-app-queue-manager-ubuntu/ to learn how to create the required group."
    exit $?
fi

# Download MQ Advanced from public repo
cd ~
wget -c https://public.dhe.ibm.com/ibmdl/export/pub/software/websphere/messaging/mqadv/mqadv_dev920_ubuntu_x86-64.tar.gz
#returnCode=$?
if [ $? -eq 0 ]
then 
    echo "Download complete"
    echo
else
    echo "wget failed. See return code: " $?
    exit $?
fi

# Unzip and extract .tar.gz file
gunzip mqadv_dev920_ubuntu_x86-64.tar.gz
echo ".gz extract complete"
echo
tar -xf ./mqadv_dev920_ubuntu_x86-64.tar
#returnCode=$?
if [ $? -eq 0 ]
then 
    echo "File extraction complete"
    echo
else
    echo "File extraction failed. See return code: " $?
    exit $?
fi

# Accept the license
cd MQServer
# sudo chmod +x MQServer/*.sh
sudo ./mqlicense.sh -accept
#returnCode=$?
if [ $? -eq 0 ]
then
    echo "license accepted"
    echo
else
    echo "license not accepted"
    exit $?
fi

# Create a .list file to let the system add the new packages to the apt cache
cd ~
cp -r ~/MQServer /var/tmp/MQServer_Packages
MQ_PACKAGES_LOCATION="/var/tmp/MQServer_Packages"
echo "deb [trusted=yes] file:$MQ_PACKAGES_LOCATION ./" > mq-install.list
sudo mv ~/mq-install.list /etc/apt/sources.list.d/
sudo apt update
#returnCode=$?
if [ $? -eq 0 ]
then
    echo "apt cache update succeeded."
    echo
else
    echo "apt cache update failed! See return code: " $?
    exit $?
fi

echo "Beginning MQ install"
sudo apt install -y "ibmmq-*"
#returnCode=$?
if [ $? -eq 0 ]
then
    echo "Install succeeded."
else
    echo "Install failed. See return code: " $?
    exit $?
fi

echo "Checking MQ version"
/opt/mqm/bin/dspmqver
#returnCode=$?
if [ $? -ne 0 ]
then
    echo "Error with dspmqver. See return code: " $?
    exit $?
fi

# Delete .list file and run apt update again to clear the apt cache
sudo rm /etc/apt/sources.list.d/mq-install.list
sudo apt-get update
#returnCode=$?
if [ $? -ne 0 ]
then
    echo "Could not delete .list file /etc/apt/sources.list.d/mq-install.list."
    echo " See return code: " $?
else
    echo "Successfully removed .list file"
fi

# The group "mqm" is created during the installation. Add the current user to it
sudo adduser ${SUDO_USER:-${USER}} mqm
echo "Successfully added ${SUDO_USER:-${USER}} to group mqm"


export PATH=$PATH:/opt/mqm/bin
# Add command which will allow user create permissions 
exec sudo -u ${SUDO_USER:-${USER}} /bin/bash - << eof
cd /opt/mqm/bin
. setmqenv -s
#returnCode=$?
if [ $? -eq 0 ]
then
    echo "MQ environment set"
else
    echo "MQ environment not set. See return code: " $?
    exit $?
fi
# Create and start a queue manager
sudo su mq_admin | export PATH=$PATH:/opt/mqm/bin
/opt/mqm/bin/crtmqm QM1
#returnCode=$?
if [ $? -eq 0 ]
then
    echo "Successfully created a queue manager" 
else
    echo "Problem when creating a queue manager. See return code: " $?
    exit $?
fi
eof
exit 0
