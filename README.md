# Open3E Docker

A Docker container for running Open3E energy monitoring system with CAN bus support.

## Description

This project provides a Dockerized version of [Open3E](https://github.com/open3e/open3e), an open-source energy monitoring system that communicates with energy meters via CAN bus and publishes data to MQTT.

## Features

- Lightweight Alpine Linux base with Python 3.11
- CAN bus interface management
- MQTT integration
- Persistent configuration storage
- Health checks for CAN interface and service status
- Docker Compose support

## Prerequisites

- Docker and Docker Compose
- CAN bus interface (physical or virtual)
- MQTT broker (e.g., Mosquitto)

## Installation

1. Clone this repository:
   ```bash
   git clone <repository-url>
   cd open3e-docker
   ```

2. Copy the environment template:
   ```bash
   cp .env.example .env
   ```

3. Edit `.env` with your configuration:
   ```bash
   nano .env
   ```

## Configuration

### Environment Variables

The following environment variables must be set in your `.env` file:

| Variable | Description | Example |
|----------|-------------|---------|
| `CAN` | CAN interface name | `can0` |
| `LISTENTOPIC` | MQTT topic to listen on | `open3e/listen` |
| `TOPIC` | MQTT topic to publish to | `open3e/server` |
| `FORMATSTRING` | MQTT message format | `open3e/{id}` |
| `CLIENTID` | MQTT client ID | `open3e` |
| `MQTT_HOST` | MQTT broker hostname | `mosquitto` |
| `MQTT_USER` | MQTT username | `mqtt_user` |
| `MQTT_PASSWORD` | MQTT password | `mqtt_password` |

### CAN Interface Setup

Ensure your CAN interface is available on the host system. For a physical CAN adapter:

```bash
# Bring up CAN interface (run on host)
sudo ip link set can0 type can bitrate 250000
sudo ip link set can0 up
```

For virtual CAN (testing):

```bash
# Create virtual CAN interface
sudo modprobe vcan
sudo ip link add dev vcan0 type vcan
sudo ip link set vcan0 up
```

## Usage

### Start the Container

```bash
docker-compose up -d
```

### View Logs

```bash
docker-compose logs -f open3e
```

### Stop the Container

```bash
docker-compose down
```

### Rebuild and Restart

```bash
docker-compose up -d --build
```

## Usage


### Standalone

The docker container will connect to the can-bus and read/write data from the attached Viessmann device.

### With Home Assistant

In your Home Assistant add the open3e-ha integration via hacs and point it towards the mqtt server that is receiving the data published by this docker container.


## Building

To build the Docker image manually:

```bash
docker build -t open3e-docker .
```

## Health Checks

The container includes health checks that verify:
- CAN interface availability
- Open3E service is running

Check health status:

```bash
docker ps
# Look for "healthy" in STATUS column
```

## Volumes

- `/config`: Persistent storage for Open3E configuration and device data

## Networking

The container runs with `NET_ADMIN` capability to manage CAN interfaces and uses a bridge network for MQTT communication.

## Troubleshooting

### CAN Interface Issues
- Ensure the CAN interface exists and is up on the host
- Check interface permissions (may need `--privileged` for some setups)
- Verify bitrate matches your hardware (default: 250000)

### MQTT Connection Issues
- Verify MQTT broker is running and accessible
- Check credentials in `.env`
- Ensure network connectivity between containers

### Service Won't Start
- Check logs: `docker-compose logs open3e`
- Verify all mandatory environment variables are set
- Ensure `/config` volume is writable

## Development

### Project Structure
```
.
├── Dockerfile              # Container definition
├── docker-compose.yml      # Compose configuration
├── .env.example           # Environment template
├── rootfs/                # Container filesystem
│   ├── entrypoint.sh      # Startup script
│   └── healthcheck.sh     # Health check script
└── README.md              # This file
```

### Customizing

- Modify `Dockerfile` for additional dependencies
- Update `entrypoint.sh` for custom startup logic
- Adjust `docker-compose.yml` for different networking or volumes

## Contributing

Contributions are welcome! Please open issues or pull requests on the GitHub repository.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Open3E Project](https://github.com/open3e/open3e) - Viessmann Open3E integration
- [Open3E Home Assistant Integration](https://github.com/MojoOli/open3e-ha) - Integration for Viessmann Heatpumps via mqtt/modbus 
- [Home Assistant](https://www.home-assistant.io/) - Home automation platform