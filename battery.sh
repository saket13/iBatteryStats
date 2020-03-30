#!/bin/sh 
PATH=/bin:/sbin:/usr/bin:/usr/sbin
/bin/sh /etc/profile
#set -xv
INFO=$(ioreg -w 0 -f -r -c AppleSmartBattery -r)

# This script dumps the battery stats to log file
# which are then processed by Python script(battery.py)

# crontab entry:

# SHELL= /bin/bash   
# */1 * * * * /bin/bash/ /Users/saket/Downloads/battery.sh > /Users/saket/Downloads/back.log 2>&1

# Here in crontab entry 1st argument says script is called every minute and second argument specifies where the script is and third where the log file is 

#To create log file in the same directory as the script's
current_dir=$(pwd)
script_dir=$(dirname $0)
touch $script_dir/back.log              


# Charge and time remaining
CURRENT_CAPACITY=$(echo "$INFO" | grep CurrentCapacity | awk '{printf $3; exit}')
MAX_CAPACITY=$(echo "$INFO" | grep MaxCapacity | awk '{printf $3; exit}')
DESIGN_CAPACITY=$(echo "$INFO" | grep DesignCapacity | awk '{printf $3; exit}')
CHARGE=$((CURRENT_CAPACITY * 100 / MAX_CAPACITY))
CELLS=$(python -c "f='●'*($CHARGE/10) + '○'*(10-$CHARGE/10); print f")
STATUS_INFO=Draining...

CHARGING=$(echo "$INFO" | grep -i ischarging | awk '{printf("%s", $3)}')
TIME_TO_EMPTY=$(echo "$INFO" | grep -i AvgTimeToEmpty | awk '{printf("%s", $3)}')
TIME_LEFT=Calculating…

if [ "$TIME_TO_EMPTY" -lt 15000 ]; then
    TIME_LEFT=$(echo "$INFO" | grep -i AvgTimeToEmpty | awk '{printf("%i:%.2i", $3/60, $3%60)}')
fi

if [ "$CHARGING" == Yes ]; then
    TIME_FULL=$(echo "$INFO" | grep -i AvgTimeToFull | tr '\n' ' | ' | awk '{printf("%i:%.2i", $3/60, $3%60)}')
    TIME_INFO=$(echo "$TIME_FULL" until full)
    STATUS_INFO=Charging...
    BATT_ICON=charging.png
else
    FULLY_CHARGED=$(echo "$INFO" | grep -i FullyCharged | awk '{printf("%s", $3)}')
    EXTERNAL=$(echo "$INFO" | grep -i ExternalConnected | awk '{printf("%s", $3)}')
    if [ "$FULLY_CHARGED" == Yes ]; then
        if [ "$EXTERNAL" == Yes ]; then
            TIME_INFO="On AC power"
            STATUS_INFO="Fully Charged"
            BATT_ICON=power.png
            CHARGE="100"
            CELLS="●●●●●●●●●●"
        else
            TIME_INFO=$TIME_LEFT
            BATT_ICON=full.png
        fi
    else
        TIME_INFO=$TIME_LEFT
        BATT_ICON=critical.png
        if [ "$CHARGE" -gt 80 ]; then
            BATT_ICON=full.png
        elif [ "$CHARGE" -gt 50 ]; then
            BATT_ICON=medium.png
        elif [ "$CHARGE" -gt 10 ]; then
            BATT_ICON=low.png
        fi
    fi
fi
# Temperature
TEMPERATURE=$(echo "$INFO" | grep Temperature | awk '{printf ("%.1f", $3/10-273)}')
# Cycle count
CYCLE_COUNT=$(echo "$INFO" | grep -e '"CycleCount" =' | awk '{printf ("%i", $3)}')
# Battery health

# Serial
SERIAL=$(echo "$INFO" | grep BatterySerialNumber | awk '{printf ("%s", $3)}' | tr -d '"')
# Battery age
MANUFACTURE_DATE=$(echo "$INFO" | grep ManufactureDate | awk '{printf ("%i", $3)}')
day=$((MANUFACTURE_DATE&31))
month=$(((MANUFACTURE_DATE>>5)&15))
year=$((1980+(MANUFACTURE_DATE>>9)))
AGE=$(python -c "from datetime import date as D; d1=D.today(); d2=D($year, $month, $day); print ( (d1.year - d2.year)*12 + d1.month - d2.month )")

# Outputting the commands which I needed to show on the menu bar
echo "$CHARGE $CELLS"
echo "$STATUS_INFO"
echo "$TIME_INFO"
echo "$TEMPERATURE"
echo "$CYCLE_COUNT"
echo "$MAX_CAPACITY"
echo "$SERIAL"
echo "$AGE"

