FROM python:alpine

LABEL org.opencontainers.image.source="https://github.com/udochrist/open3e-docker"
LABEL org.opencontainers.image.description="Open3E is a tool that listens to CAN messages and publishes them to an MQTT broker. This Docker image provides a convenient way to run Open3E in a containerized environment."
LABEL org.opencontainers.image.title="Open3E Docker Image"
LABEL org.opencontainers.image.licenses="MIT"


RUN apk add --no-cache git iproute2 && \
    rm -rf /var/lib/apk/lists/*
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
