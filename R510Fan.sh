# ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW  sdr type fan
 
# Enable Manual fan speed
# ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
 
# Set fan speed to auto
# ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01
 
# IPMI SETTINGS:
IPMIHOST=111.222.333.4444
IPMIUSER=root
IPMIPW=calvin
 
# TEMPERATURE
# If the temperature goes above the set degrees it will send raw IPMI command to enable dynamic fan control
MAXTEMP=32
WARNTEMP=29
 
# This variable sends a IPMI command to get the temperature, and outputs it as two digits.
TEMP=$(ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW sdr get "Ambient Temp" | grep "Sensor Reading" | awk '{print $4}')
 
 
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
    printf "R510 Temperature is BAD ($TEMP C)" | systemd-cat -t R510-IPMI-TEMP
    # Set fan speed to auto
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x01
 
elif [[ $TEMP > $WARNTEMP ]];
  then
    #echo "Temperature is WARN ($TEMP c)"
    printf "R510 Temperature is WARN ($TEMP C)" | systemd-cat -t R510-IPMI-TEMP
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x1B
 
else
    #echo "Temperature is OK ($TEMP C)"
    printf "R510 Temperature is OK ($TEMP C)" | systemd-cat -t R510-IPMI-TEMP
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x01 0x00
    ipmitool -I lanplus -H $IPMIHOST -U $IPMIUSER -P $IPMIPW raw 0x30 0x30 0x02 0xff 0x17
fi
 
