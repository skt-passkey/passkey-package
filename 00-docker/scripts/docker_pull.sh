#!/bin/bash

echo "=========================================="
echo "Docker Pull Script Started"
echo "=========================================="

# 환경변수에서 API_URL과 LICENSE_KEY 받기 (전달받은 값 유지)
API_URL="${API_URL}"
PASSKEY_LICENSE_KEY="${PASSKEY_LICENSE_KEY}"

# IMAGE 값을 커맨드라인 인자로 받아오기
if [ -z "$1" ]; then
  echo "❌ Error: IMAGE argument is required."
  exit 1
fi
export IMAGE="$1"
echo "✓ Image specified: $IMAGE"

# get_access_key.sh 스크립트 실행
echo ""
echo "📡 Requesting ECR access credentials..."
# 현재 스크립트의 디렉토리를 기준으로 get_access_key.sh 호출
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT=$("$SCRIPT_DIR/get_access_key.sh")

if [ -z "$OUTPUT" ]; then
  echo "❌ Error: Failed to get ECR credentials from API"
  exit 1
fi
echo "✓ ECR credentials received"

# JSON 파싱 (jq 없이 grep/sed 사용)
echo "🔍 Parsing response..."

# 전체 응답에서 data 객체 추출 후 각 필드 파싱
DATA_SECTION=$(echo "$OUTPUT" | sed -n '/"data"/,/}/p' | head -20)

# loginCommand 추출 - "docker login" 문자열로 시작하는 부분
LOGIN_COMMAND=$(echo "$DATA_SECTION" | grep -o '"docker login[^"]*"' | sed 's/"//g' | head -1)

# imageUri 추출 - 여러 형식 지원
# 먼저 "imageUri" 필드 찾기
IMAGE_URI=$(echo "$DATA_SECTION" | grep -o '"imageUri"[[:space:]]*:[[:space:]]*"[^"]*"' | cut -d'"' -f4 | head -1)

# imageUri가 없으면 다른 형식 시도
if [ -z "$IMAGE_URI" ]; then
    # ECR URL 패턴으로 직접 추출
    IMAGE_URI=$(echo "$DATA_SECTION" | grep -oE '[0-9]{12}\.dkr\.ecr\.[a-z0-9-]+\.amazonaws\.com/[^"[:space:]]*' | head -1)
fi

if [ -z "$LOGIN_COMMAND" ]; then
  echo "❌ Error: Failed to extract login command from response"
  exit 1
fi

if [ -z "$IMAGE_URI" ]; then
  echo "❌ Error: Failed to extract image URI from response"
  exit 1
fi

# 이미지 URL에서 https:// 제거
IMAGE_URI=$(echo "$IMAGE_URI" | sed 's|https://||')
echo "✓ Image URI: $IMAGE_URI"

# Docker login 수행
echo ""
echo "🔐 Logging in to ECR..."
if eval "$LOGIN_COMMAND"; then
  echo "✓ ECR login successful"
else
  echo "❌ Error: ECR login failed"
  exit 1
fi

# Docker pull 수행
echo ""
echo "⬇️  Pulling image from ECR..."
if docker pull "$IMAGE_URI"; then
  echo "✓ Image pulled successfully"
else
  echo "❌ Error: Failed to pull image"
  exit 1
fi

# tag 달아주기
echo ""
echo "🏷️  Tagging image as: $IMAGE"
if docker tag "$IMAGE_URI" "$IMAGE"; then
  echo "✓ Image tagged successfully"
else
  echo "❌ Error: Failed to tag image"
  exit 1
fi

# 결과 출력
echo ""
echo "=========================================="
echo "✅ Docker pull and tag complete!"
echo "=========================================="

