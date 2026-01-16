#!/bin/sh

export PATH=$(echo $PATH | tr ":" "\n" | grep -v "/mnt/c" | paste -sd ":")
