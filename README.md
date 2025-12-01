# docker-iredmail-server

## Custom configurations

All your own configuration files or templates should be placed in the directory:

```
${DOCKER_VOLUMES_PATH}/custom
```

where `DOCKER_VOLUMES_PATH` - path to the directory specified in your `.env` file.

---

## 🔧 Maintenance Mode

The repository includes utility scripts for managing maintenance mode, allowing you to temporarily disable access to the mail server for updates or maintenance work.

### Location
```
scripts/maintenance/
├── toggle.sh   # Switch maintenance mode on/off
└── status.sh   # Check maintenance mode status
```

### Usage

#### Toggle Maintenance Mode
Automatically enables or disables maintenance mode:

```bash
./scripts/maintenance/toggle.sh
```

#### Check Status
Displays detailed information about maintenance mode and system state:

```bash
./scripts/maintenance/status.sh
```

### First Time Setup

Make the scripts executable:
```bash
chmod +x scripts/maintenance/*.sh
```

---
