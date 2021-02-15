#!/bin/bash

IMAGE="images/ubuntu-20.04.2-preinstalled-server-arm64+raspi.img"
FLASH="$(realpath "${BASE_DIR}/../flash/flash")"

export IMAGE FLASH
