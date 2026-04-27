#! /bin/sh


# Check that all mandatory variables are set
if [ -z "$CAN" ] || [ -z "$LISTENTOPIC" ] || [ -z "$TOPIC" ] || [ -z "$FORMATSTRING" ] || [ -z "$CLIENTID" ] || [ -z "$MQTT_HOST" ] || [ -z "$MQTT_USER" ] || [ -z "$MQTT_PASSWORD" ]; then
  echo "Error: One or more mandatory configuration variables are missing or empty"
  exit 1
fi


# Check if CAN interface is available
#ip link show "$CAN" > /dev/null 2>&1
#if [ $? -ne 0 ]; then
#    echo "CAN interface $CAN not available"
#    exit 1
#fi

ip link | grep $CAN


# restart the can interface with the correct bitrate
ip link set down $CAN
ip link set $CAN type can bitrate 250000 && ip link set up $CAN

ip link | grep $CAN


# clean config directory. we need to discover the connected devices and create the config file for open3e
if [ ! -f /config/devices.json ]; then
  echo "No devices.json found. Running open3e_depictSystem -c $CAN ... This may take a while"
   cd /config
   open3e_depictSystem -c $CAN
   if [ $? -ne 0 ]; then
      echo "Error running open3e_depictSystem -c $CAN. Exiting."
      exit 1
   fi
fi

# start the open3e service
echo "Starting Open3e service"

cd /config
open3e --can $CAN \
       --mqtt $MQTT_HOST:1883:$TOPIC \
       --mqttuser $MQTT_USER:$MQTT_PASSWORD \
       --mqttformatstring $FORMATSTRING \
       --mqttclientid $CLIENTID \
       --listen $LISTENTOPIC \
       --config /config/devices.json
