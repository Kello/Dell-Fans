#!/usr/bin/env bash

# ----------------------------------------------------------------------------------
# Script for checking the temperature reported by the ambient temperature sensor, 
# and if deemed to high send the raw IPMI command to enable dynamic fan control.
#
# Requires ipmitool – apt-get install ipmitool
# 
# ----------------------------------------------------------------------------------


# IPMI DEFAULT R410 SETTINGS
# Modify to suit your needs.
IPMIHOST=111.222.333.444
IPMIUSER=root
IPMIPW=calvin

# TEMPERATURE
# Change this to the temperature in celcius you are comfortable with. 
# If it goes above it will send raw IPMI command to enable dynamic fan control
MAXTEMP=28

# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
# Do not edit unless you know what you do.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)


if [[ $TEMP > $MAXTEMP ]];
  then
    printf "Temperature is too high! ($TEMP C) Activating dynamic fan control!" | systemd-cat -t 4710-IPMI-TEMP
    echo "Temperature is too high! ($TEMP C) Activating dynamic fan control!"
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01
  else
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x23
    printf "Temperature is OK ($TEMP C)" | systemd-cat -t R410-IPMI-TEMP
    echo "Temperature is OK ($TEMP C)"
fi
