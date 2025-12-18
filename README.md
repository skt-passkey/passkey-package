# Passkey Package

## Overview
This package provides Docker-based deployment for the Passkey system, including the Passkey Server, Admin Portal, and Metadata Manager.

---

## Quick Start

### 1. System Requirements

Ensure the following are installed:

- **Docker** - Container runtime
- **curl** - Command-line tool for HTTP requests

**Installation:**

```bash
# macOS
brew install curl docker

# Ubuntu/Debian
sudo apt-get install curl docker.io

# CentOS/RHEL
sudo yum install curl docker
```

**Verify Installation:**
```bash
docker --version
curl --version
```

---

### 2. Configure Environment

Navigate to the `00-docker` directory:

```bash
cd ./00-docker
```

Edit the `.env` file with your configuration:

```env
# =============================================================================
# PASSKEY License Key
# Description: JWT token for ECR authentication and license validation
# 설명: ECR 인증 및 라이선스 검증을 위한 JWT 토큰
# =============================================================================
PASSKEY_LICENSE_KEY="your-license-key-here"

# =============================================================================
# Docker Images
# Description: Passkey application images to be pulled from ECR
# 설명: ECR에서 다운로드할 Passkey 애플리케이션 이미지
# =============================================================================
PASSKEY_SERVER_IMAGE="passkey/release/passkey-server:1.21.0"
PASSKEY_ADMIN_IMAGE="passkey/release/passkey-admin:1.21.0"
PASSKEY_METADATA_MANAGER_IMAGE="passkey/release/passkey-metadata-manager:1.21.0"

# =============================================================================
# Database Type Selection
# Options: mariadb, mysql, postgres
# 선택 옵션: mariadb, mysql, postgres
# =============================================================================
PASSKEY_DB_TYPE="postgres"

# =============================================================================
# Storage Type Selection
# Options: memory (tmpfs - 재시작 시 삭제), disk (volume - 영구 보존)
# 선택 옵션: memory (메모리 임시 저장), disk (디스크 영구 저장)
# =============================================================================
PASSKEY_STORAGE_TYPE="disk"

# =============================================================================
# Docker Compose Profile Control (Auto-generated)
# Description: Automatically combines DB type and storage type
# 설명: DB 타입과 저장 방식을 자동으로 조합합니다 (예: postgres_disk)
# =============================================================================
COMPOSE_PROFILES="${PASSKEY_DB_TYPE}_${PASSKEY_STORAGE_TYPE}"

# =============================================================================
# Database Connection URLs
# Description: Pre-configured JDBC URLs for each database type
# 설명: 각 데이터베이스 타입의 미리 설정된 JDBC URL
# =============================================================================
PASSKEY_MARIADB_URL="jdbc:mariadb://host.docker.internal:3306"
PASSKEY_MYSQL_URL="jdbc:mysql://host.docker.internal:3307"
PASSKEY_POSTGRES_URL="jdbc:postgresql://host.docker.internal:5432"

# =============================================================================
# Database Credentials
# Description: Database authentication information
# 설명: 데이터베이스 인증 정보
# WARNING: In production environments, never store passwords in plain text!
# 경고: 운영 환경에서는 절대로 평문으로 암호를 저장하지 마세요!
# =============================================================================
PASSKEY_DB_USER="passkeyuser"
PASSKEY_DB_PW="qwer1234"
```

---

### 3. Verify Docker is Running

```bash
docker info
```

If Docker is not running, start it before proceeding.

---

### 4. Pull Docker Images

Run the image pull script:

```bash
bash passkey_images_pull.sh
```

**What the script does:**
1. Extracts ECR access credentials from the license key
2. Authenticates with AWS ECR
3. Pulls all configured Docker images
4. Tags images locally for easy reference

**Note:** The first run may take several minutes depending on image size and network speed.

---

### 5. Verify Images

Check that all images were downloaded successfully:

```bash
docker images | grep passkey
```

**Expected Output:**
```
passkey/release/passkey-server             1.21.0   <image-id>   <size>
passkey/release/passkey-admin              1.21.0   <image-id>   <size>
passkey/release/passkey-metadata-manager   1.21.0   <image-id>   <size>
```

---

## Running the Application

### 1. Database and Storage Configuration

Edit the `.env` file to choose your database type and storage method:

```env
# Choose database type
PASSKEY_DB_TYPE="postgres"    # Options: mariadb, mysql, postgres

# Choose storage type
PASSKEY_STORAGE_TYPE="disk"   # Options: memory (tmpfs), disk (persistent)
```

**Storage Type Explanation:**

| Type | Storage | Restart Behavior | Use Case |
|------|---------|------------------|----------|
| `memory` | tmpfs (RAM) | Data deleted on restart | Development/Testing |
| `disk` | Named volume | Data persists | Production/Development |

**Example Configurations:**
```env
# Development with ephemeral storage
PASSKEY_DB_TYPE="postgres"
PASSKEY_STORAGE_TYPE="memory"

# Production with persistent storage
PASSKEY_DB_TYPE="postgres"
PASSKEY_STORAGE_TYPE="disk"
```

### 2. Start Services

Run the following command:

```bash
docker compose up -d
```

The correct database and storage configuration will automatically be applied based on your `.env` settings.

**How it Works:**
1. `.env` sets `PASSKEY_DB_TYPE` and `PASSKEY_STORAGE_TYPE`
2. `COMPOSE_PROFILES` is automatically set to combine them (e.g., `postgres_disk`)
3. Docker Compose activates only the matching database profile
4. Other database services are automatically skipped
5. Redis and Passkey services always start

**Services Started:**
- Selected database only (MariaDB, MySQL, or PostgreSQL)
- Selected storage type (memory or disk)
- Redis cache (always starts)
- Passkey Server (port 8080)
- Passkey Admin (port 8001)
- Passkey Metadata Manager (port 8088)

### 3. View Logs

View real-time logs from all services:

```bash
docker compose logs -f
```

View logs from a specific service:

```bash
# View database logs
docker compose logs -f postgres_disk    # or mariadb_disk, mysql_disk

# View application logs
docker compose logs -f passkey-server
```

### 4. Access Services

Once all services are running, access them at:

- **Passkey Server**: http://localhost:8080
- **Passkey Admin**: http://localhost:8001
- **Metadata Manager**: http://localhost:8088

### 5. Stop Services

To stop all services and clean up containers:

```bash
docker compose down
```

**Important:** 
- If `PASSKEY_STORAGE_TYPE="disk"`, your data will persist
- If `PASSKEY_STORAGE_TYPE="memory"`, your data will be lost when you stop the services

---

## Troubleshooting

### "curl: command not found"
Install curl using your system's package manager (see System Requirements above).

**macOS:**
```bash
brew install curl
```

**Ubuntu/Debian:**
```bash
sudo apt-get update && sudo apt-get install curl
```

**CentOS/RHEL:**
```bash
sudo yum install curl
```

### "docker: permission denied"
Add your user to the docker group:
```bash
sudo usermod -aG docker $USER
newgrp docker
```

Then log out and log back in for changes to take effect.

### "License key validation failed"
Ensure your `PASSKEY_LICENSE_KEY` in `.env` is valid and properly formatted.

**Check the license key format:**
```bash
echo $PASSKEY_LICENSE_KEY | cut -d'.' -f1 | base64 -d
```

### "docker compose: command not found"
Ensure Docker Compose is installed:
```bash
docker compose version
```

If not installed, follow the [Docker Compose installation guide](https://docs.docker.com/compose/install/).

### "Port already in use"
If you get an error like "bind: address already in use", the port is already occupied.

**Change the port mapping in `docker-compose.yml`:**
```yaml
passkey-server:
  ports:
    - "8080:8080"    # Change first number to available port, e.g., "8081:8080"
```

Then restart:
```bash
docker compose down
docker compose up -d
```

### "ECR authentication failed"
Verify your network connectivity to AWS ECR and that your license key is valid.

**Check API connectivity:**
```bash
curl -X POST "https://portal.passkey-sktelecom.com/portal/backend/ecr/request-ecr-access-info" \
  -H "Content-Type: application/json" \
  -d '{"licenseKey":"your-license-key","image":"passkey/release/passkey-server:1.21.0"}'
```

### "Insufficient disk space"
If you chose `PASSKEY_STORAGE_TYPE="disk"`, ensure you have enough space for the database volumes:

```bash
df -h
```

Clean up unused Docker resources if needed:
```bash
docker system prune -a
```

---

## Directory Structure

```
passkey-package/
├── 00-docker/
│   ├── passkey_images_pull.sh          (Main image pull script)
│   ├── scripts/
│   │   ├── docker_pull.sh              (Helper script)
│   │   ├── get_access_key.sh           (ECR authentication)
│   │   └── extract_dns.sh              (License key parsing)
│   ├── .env                            (Configuration file)
│   ├── docker-compose.yml              (Docker Compose definition)
│   ├── 01-passkey-server/
│   ├── 02-passkey-metadata-manager/
│   └── 03-passkey-admin/
├── README.md
└── OSS-LICENSES.txt
```

---

## Open Source Licenses

This software includes third-party open source libraries.  
For detailed license information, please refer to the `OSS-LICENSES.txt` file included in this package.

