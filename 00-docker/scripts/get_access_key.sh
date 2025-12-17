#!/bin/bash

# API Gateway URL 설정
API_URL="${API_URL:-}"
IMAGE="${IMAGE:-}"
PASSKEY_LICENSE_KEY="${PASSKEY_LICENSE_KEY:-}"

# 환경변수 검증 (로그는 stderr로)
if [ -z "$API_URL" ]; then
    echo "❌ Error: API_URL 환경 변수가 설정되지 않았습니다." >&2
    exit 1
fi

if [ -z "$PASSKEY_LICENSE_KEY" ]; then
    echo "❌ Error: PASSKEY_LICENSE_KEY 환경 변수가 설정되지 않았습니다." >&2
    exit 1
fi

if [ -z "$IMAGE" ]; then
    echo "❌ Error: IMAGE 환경 변수가 설정되지 않았습니다." >&2
    exit 1
fi

echo "📋 API Configuration:" >&2
echo "   API_URL: $API_URL" >&2
echo "   IMAGE: $IMAGE" >&2
LICENSE_KEY_SHORT=$(printf "%.30s" "$PASSKEY_LICENSE_KEY")
echo "   LICENSE_KEY: ${LICENSE_KEY_SHORT}..." >&2

echo "" >&2
echo "🔗 Sending request to ECR API..." >&2

# POST 요청 보내기 - 응답은 stdout으로, 진행 표시는 stderr로
RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "accept: application/json;charset=UTF-8" \
    -H "Content-Type: application/json;charset=UTF-8" \
    -d '{
            "licenseKey": "'"$PASSKEY_LICENSE_KEY"'",
            "image": "'"$IMAGE"'"
        }')

# API 응답 확인 - error 필드가 있는지 체크
if echo "$RESPONSE" | grep -q '"error"'; then
    echo "" >&2
    echo "❌ API Error Response:" >&2
    echo "$RESPONSE" >&2
    echo "✗ API request failed" >&2
    exit 1
fi

# 성공 응답 출력
echo "$RESPONSE"

echo "" >&2
echo "✓ API request completed" >&2

