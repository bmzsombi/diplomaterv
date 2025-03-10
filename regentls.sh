#!/bin/bash

sudo systemctl stop k3s
sudo k3s server --tls-san cloud-23195.vm.fured.cloud.bme.hu
sudo systemctl start k3s
