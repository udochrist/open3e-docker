FROM python:3.11-alpine

RUN apk update && apk add --no-cache git iproute2
RUN mkdir -p /data

# Mandatory environment variables (must be provided at runtime):
# - CAN: CAN interface (e.g., can0)
# - LISTENTOPIC: MQTT listen topic
# - TOPIC: MQTT server topic
# - FORMATSTRING: MQTT format string
# - CLIENTID: MQTT client ID
# - MQTT_HOST: MQTT broker host
# - MQTT_USER: MQTT username
# - MQTT_PASSWORD: MQTT password

VOLUME /config

RUN pip install git+https://github.com/open3e/open3e.git

COPY /rootfs/ /
RUN chmod +x /entrypoint.sh /healthcheck.sh

HEALTHCHECK --interval=2m --timeout=3s \
  CMD /bin/sh /healthcheck.sh || exit 1

ENTRYPOINT [ "/bin/sh", "/entrypoint.sh" ]
