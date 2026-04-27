# Open3E Docker

A Docker container for running Open3E energy monitoring system with CAN bus support for Viessmann heat pumps.

## Description

This project provides a Dockerized version of [Open3E](https://github.com/open3e/open3e), an open-source energy monitoring system that communicates with Viessmann heat pumps via CAN bus and publishes data to MQTT for integration with home automation systems.

## Features

- Lightweight Alpine Linux base with Python 3.11
- CAN bus interface management with NET_ADMIN capabilities
- MQTT integration for data publishing
- Persistent configuration storage
- Health checks for CAN interface and service status
- Docker Compose support with environment-based configuration

## Prerequisites

- Docker and Docker Compose
- CAN bus interface (physical or virtual)
- MQTT broker (e.g., Mosquitto, Eclipse Mosquitto)

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/your-username/open3e-docker.git
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
| `MQTT_HOST` | MQTT broker hostname/IP | `mosquitto` |
| `MQTT_USER` | MQTT username | `mqtt_user` |
| `MQTT_PASSWORD` | MQTT password | `mqtt_password` |

### CAN Interface Setup

Ensure your CAN interface is available on the host system. For a physical CAN adapter:

```bash
# Bring up CAN interface (run on host)
sudo ip link set can0 type can bitrate 250000
sudo ip link set can0 up
```

For virtual CAN (testing/development):

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

### Standalone Operation

The Docker container connects to the CAN bus and reads/writes data from attached Viessmann devices, publishing measurements to MQTT topics for consumption by home automation systems or other monitoring tools.

## Building

To build the Docker image manually:

```bash
docker build -t open3e-docker .
```

## Automated publishing

This repository includes a GitHub Actions workflow at `.github/workflows/docker-image.yml`.

Behavior:
- `push` to `main` publishes `latest` and a commit-sha image.
- `push` of a tag like `v1.0.0` or `release-1.0.0` publishes the tag name and commit-sha images only.

Required GitHub secrets:
- `REGISTRY_USERNAME`
- `REGISTRY_PASSWORD`

Default registry configuration:
- `ghcr.io`
- image name: `ghcr.io/udochrist/open3e-docker`

If you want to use Docker Hub, update `.github/workflows/docker-image.yml` and use a registry value of `docker.io`.

## Health Checks

The container includes health checks that verify:
- CAN interface availability and configuration
- Open3E service is running and operational

Check health status:

```bash
docker ps
# Look for "healthy" in STATUS column
```

## Volumes

- `/config`: Persistent storage for Open3E configuration files and discovered device data

## Networking

The container runs with `NET_ADMIN` capability to manage CAN interfaces and uses a bridge network for MQTT communication.

## Troubleshooting

### CAN Interface Issues
- Ensure the CAN interface exists and is up on the host
- Check interface permissions (may need `--privileged` for some setups)
- Verify bitrate matches your hardware (default: 250000)
- Use `ip link show` to verify interface status

### MQTT Connection Issues
- Verify MQTT broker is running and accessible
- Check credentials in `.env` file
- Ensure network connectivity between containers
- Test MQTT connection with tools like `mosquitto_pub`

### Service Won't Start
- Check logs: `docker-compose logs open3e`
- Verify all mandatory environment variables are set
- Ensure `/config` volume is writable
- Check CAN interface availability in health check output

### Device Discovery Issues
- Ensure Viessmann device is connected to CAN bus
- Check CAN bus termination and wiring
- Run `open3e_depictSystem` manually to debug device detection

## Development

### Project Structure
```
.
├── Dockerfile              # Container definition
├── docker-compose.yml      # Compose configuration
├── .env.example           # Environment template
├── rootfs/                # Container filesystem
│   ├── entrypoint.sh      # Startup script with CAN setup
│   └── healthcheck.sh     # Health check script
└── README.md              # This file
```

### Customizing

- Modify `Dockerfile` for additional dependencies
- Update `entrypoint.sh` for custom startup logic
- Adjust `docker-compose.yml` for different networking or volumes
- Add device-specific configurations in `/config`

## Contributing

Contributions are welcome! Please:
- Open issues for bugs or feature requests
- Submit pull requests for improvements
- Test changes with both physical and virtual CAN interfaces

## License

This project is licensed under the same terms as the Open3E project. See the [Open3E repository](https://github.com/open3e/open3e) for license details.

## Acknowledgments

- [Open3E Project](https://github.com/open3e/open3e) - Core Viessmann Open3E integration
- [Open3E Home Assistant Integration](https://github.com/MojoOli/open3e-ha) - HA integration for MQTT data
- Docker and Alpine Linux communities for containerization tools