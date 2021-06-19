#!/bin/bash

script_location="https://raw.githubusercontent.com/Kushalgopal/AzureARM_M02/master/Scripts/install_mqm.sh"
apt-get update
mkdir /usr/local/ibm_mq && cd /usr/local/ibm_mq
wget -qO- -O install_mqm.sh $script_location
# curl https://raw.githubusercontent.com/Kushalgopal/AzureARM/master/install_mqm.sh > ~/install_mqm.sh
chmod u+x install_mqm.sh
#./install_mqm.sh
