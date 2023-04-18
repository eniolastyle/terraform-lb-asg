#!/bin/bash

sudo apt-get update
sudo apt-get install ${var.server} -y
sudo systemctl start ${var.server}
sudo systemctl enable ${var.server}