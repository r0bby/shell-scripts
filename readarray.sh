#!/bin/bash
readarray -t eCollection < <(cut -d, -f2 file.csv)
printf '%s\n' "${eCollection[0]}"