# Passkey Package

## Passkey Distribution Package
This guide provides instructions for deploying and running the Passkey package using Docker.

---

## Docker Setup

### Navigate to the Working Directory
```bash
cd ./docker
```

### Check if Docker is Running
```bash
docker info
```
Ensure Docker is running. If not, start Docker before proceeding.

### Set API Access Key
The API Access Key must be set in the `.env` file.

```env
# API Access Key
API_ACCESS_KEY="###" # Replace "###" with the actual API key.
```

---

## Downloading Images

### Pull Docker Images
Run the following script to pull the required images:
```bash
./passkey_images_pull.sh
```

### Verify Downloaded Images
```bash
docker images
```

### Example Output After Successful Download
```plaintext
REPOSITORY                                                                           TAG                                        IMAGE ID       CREATED        SIZE
891377192443.dkr.ecr.ap-northeast-2.amazonaws.com/passkey/passkey-admin              e5d3f33030f413b2d20dc53d7f7b25bd6d3cccbe   6d952a2e9a29   55 years ago   604MB
passkey/passkey-admin                                                                e5d3f33030f413b2d20dc53d7f7b25bd6d3cccbe   6d952a2e9a29   55 years ago   604MB
891377192443.dkr.ecr.ap-northeast-2.amazonaws.com/passkey/passkey-metadata-manager   v1.18.0-6-g65dca925                        de3afd111f5e   55 years ago   498MB
passkey/passkey-metadata-manager                                                     v1.18.0-6-g65dca925                        de3afd111f5e   55 years ago   498MB
891377192443.dkr.ecr.ap-northeast-2.amazonaws.com/passkey/passkey-server             1.18.0-43b7a15d                            ede0552ade18   55 years ago   537MB
passkey/passkey-server                                                               1.18.0-43b7a15d                            ede0552ade18   55 years ago   537MB
```

---

## Running the Application
### Start Docker Compose
```bash
docker compose up
```

This command starts the containers using Docker Compose.

## Open Source Licenses

This software includes third-party open source libraries.  
For detailed license information, please refer to the `OSS-LICENSES.txt` file included in this package.

