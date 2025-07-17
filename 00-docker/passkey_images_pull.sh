#!/bin/bash
# 설정 파일 로드
source .env

# API URL과 Access Key 환경변수로 설정
export API_URL="$API_URL"
export API_ACCESS_KEY="$API_ACCESS_KEY"

# 이미지 목록
IMAGES=()

# 설정된 이미지를 배열에 추가 (빈 값은 제외)
if [ -n "$PASSKEY_SERVER_IMAGE" ]; then IMAGES+=("$PASSKEY_SERVER_IMAGE"); fi
if [ -n "$PASSKEY_ADMIN_IMAGE" ]; then IMAGES+=("$PASSKEY_ADMIN_IMAGE"); fi
if [ -n "$PASSKEY_METADATA_MANAGER_IMAGE" ]; then IMAGES+=("$PASSKEY_METADATA_MANAGER_IMAGE"); fi

# 이미지에 대해 반복 작업 수행
for IMAGE in "${IMAGES[@]}"; do
    echo ""
    echo ""
    echo "==============================================================="
    echo "Processing image: $IMAGE"
    ./docker_pull.sh "$IMAGE"
done

echo "All image processing complete."