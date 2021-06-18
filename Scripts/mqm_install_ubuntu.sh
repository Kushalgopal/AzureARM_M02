#!/bin/bash

script_location="https://raw.githubusercontent.com/Kushalgopal/AzureARM_M02/master/Scripts/install_mqm.sh"
cd ~
wget -qO- -O install_mqm.sh $script_location
# curl https://raw.githubusercontent.com/Kushalgopal/AzureARM/master/install_mqm.sh > ~/install_mqm.sh
chmod +x ~/install_mqm.sh
#./install_mqm.sh
