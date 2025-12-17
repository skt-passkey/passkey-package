#!/bin/bash

echo "=========================================="
echo "🎯 Passkey Images Pull Script"
echo "=========================================="

# 설정 파일 로드
echo "📂 Loading configuration from .env..."
if [ ! -f .env ]; then
    echo "❌ Error: .env file not found"
    exit 1
fi
source .env
echo "✓ Configuration loaded"

# License Key에서 DNS 추출하여 API_URL 동적 설정
echo ""
echo "🔐 Extracting API URL from License Key..."

# extract_dns.sh 함수 로드
if [ -f ./scripts/extract_dns.sh ]; then
    source ./scripts/extract_dns.sh

    # License Key에서 DNS 추출 시도
    EXTRACTED_HOST=$(extract_dns_from_license "$PASSKEY_LICENSE_KEY")

    if [ $? -eq 0 ] && [ -n "$EXTRACTED_HOST" ]; then
        # DNS 추출 성공 - 동적으로 API_URL 설정
        API_URL="https://${EXTRACTED_HOST}/portal/backend/ecr/request-ecr-access-info"
        echo "✓ API URL extracted from certificate: $API_URL"
    else
        # DNS 추출 실패 - .env의 기본값 사용
        echo "⚠️  Failed to extract DNS from certificate, using default API_URL from .env"
    fi
else
    echo "⚠️  extract_dns.sh not found, using default API_URL from .env"
fi

# API URL과 License Key 명시적으로 export
export API_URL
export PASSKEY_LICENSE_KEY

echo ""
echo "🔧 Environment setup:"
echo "   API_URL: $API_URL"
# 라이선스 키 앞 30자 추출
LICENSE_KEY_SHORT=$(printf "%.30s" "$PASSKEY_LICENSE_KEY")
echo "   LICENSE_KEY: ${LICENSE_KEY_SHORT}..."

# 이미지 목록
IMAGES=()

# 설정된 이미지를 배열에 추가 (빈 값은 제외)
if [ -n "$PASSKEY_SERVER_IMAGE" ]; then IMAGES+=("$PASSKEY_SERVER_IMAGE"); fi
if [ -n "$PASSKEY_ADMIN_IMAGE" ]; then IMAGES+=("$PASSKEY_ADMIN_IMAGE"); fi
if [ -n "$PASSKEY_METADATA_MANAGER_IMAGE" ]; then IMAGES+=("$PASSKEY_METADATA_MANAGER_IMAGE"); fi

echo ""
echo "📦 Images to process: ${#IMAGES[@]}"
for i in "${!IMAGES[@]}"; do
    echo "   $((i+1)). ${IMAGES[$i]}"
done

# 이미지에 대해 반복 작업 수행
FAILED_IMAGES=()
SUCCESS_COUNT=0

for i in "${!IMAGES[@]}"; do
    IMAGE="${IMAGES[$i]}"
    CURRENT=$((i+1))
    TOTAL=${#IMAGES[@]}

    echo ""
    echo ""
    echo "=========================================="
    echo "[$CURRENT/$TOTAL] Processing image: $IMAGE"
    echo "=========================================="

    if ./scripts/docker_pull.sh "$IMAGE"; then
        echo "✅ Successfully processed: $IMAGE"
        ((SUCCESS_COUNT++))
    else
        echo "❌ Failed to process: $IMAGE"
        FAILED_IMAGES+=("$IMAGE")
    fi
done

echo ""
echo ""
echo "=========================================="
echo "📊 Processing Summary"
echo "=========================================="
echo "✅ Successful: $SUCCESS_COUNT/${#IMAGES[@]}"

if [ ${#FAILED_IMAGES[@]} -gt 0 ]; then
    echo "❌ Failed: ${#FAILED_IMAGES[@]}"
    for failed_image in "${FAILED_IMAGES[@]}"; do
        echo "   - $failed_image"
    done
else
    echo "✅ All images processed successfully!"
fi
echo "=========================================="

