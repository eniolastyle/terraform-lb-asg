#!/bin/bash

sudo apt-get update
sudo apt-get install ${vars.server} -y
sudo systemctl start ${vars.server}
sudo systemctl enable ${vars.server}