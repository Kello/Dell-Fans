#!/bin/bash

# ----------------------------------------------------------------------------------
# Script for checking the temperature reported by the ambient temperature sensor,
# and if deemed too high send the raw IPMI command to enable dynamic fan control.
#
# Requires:
# ipmitool â€“ apt-get install ipmitool
# slacktee.sh â€“ https://github.com/course-hero/slacktee
# ----------------------------------------------------------------------------------


# IPMI SETTINGS:
# Modify to suit your needs.
# DEFAULT IP: 192.168.0.120
IPMIHOST=x.x.x.x
IPMIUSER=root
IPMIPW=Rcalvin
IPMIEK=0000000000000000000000000000000000000000

# TEMPERATURE
# If the temperature goes above the set degrees it will send raw IPMI command to enable dynamic fan control
MAXTEMP=32
WARNTEMP=29

# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK sdr type temperature |grep Ambient |grep degrees |grep -Po '\d{2}' | tail -1)

# R510 Fan Speeds
# 0x11 3120rpm
# 0x10 3000rpm
# 0x09 2280rpm
# 0x08 2160rpm
# 0x07 2040rpm
# 0x06 1920rpm
# 0x05 1800rpm
# 0x04 1680rpm

if [[ $TEMP > $MAXTEMP ]];
  then
    #echo "Temperature is BAD ($TEMP C)"
    printf "Lab1 Temperature is BAD ($TEMP C)" | systemd-cat -t R710-Lab1-TEMP
    echo "Temperature is BAD ($TEMP C)"
    # Set fan speed to auto
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x01

elif [[ $TEMP > $WARNTEMP ]];
  then
    #echo "Temperature is WARN ($TEMP c)"
    printf "Lab1 Temperature is WARN ($TEMP C)" | systemd-cat -t R710-Lab1-TEMP
    echo "Temperature is Warm ($TEMP C)"
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x17

else
    #echo "Temperature is OK ($TEMP C)"
    printf "Lab1 Temperature is OK ($TEMP C)" | systemd-cat -t R710-Lab1-TEMP
    echo "Temperature is OK ($TEMP C)"
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW -y $IPMIEK raw 0x30 0x30 0x02 0xff 0x09
fi
