#!/bin/bash

IMAGE="images/ubuntu-20.04.1-preinstalled-server-armhf+raspi.img"
FLASH="$(realpath "${BASE_DIR}/../flash/flash")"

export IMAGE FLASH
