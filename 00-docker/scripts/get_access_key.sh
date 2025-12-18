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

# POST 요청 보내기 - HTTP 상태 코드와 본문 분리
# -w "%{http_code}" : 마지막에 HTTP 상태 코드 출력
HTTP_RESPONSE=$(curl -s -w "\n%{http_code}" -X POST "$API_URL" \
    -H "accept: application/json;charset=UTF-8" \
    -H "Content-Type: application/json;charset=UTF-8" \
    -d '{
            "licenseKey": "'"$PASSKEY_LICENSE_KEY"'",
            "image": "'"$IMAGE"'"
        }')

# curl 실행 실패 확인
if [ $? -ne 0 ]; then
    echo "❌ Error: Failed to execute curl command" >&2
    exit 1
fi

# 상태 코드와 본문 분리
HTTP_STATUS=$(echo "$HTTP_RESPONSE" | tail -n1)
HTTP_BODY=$(echo "$HTTP_RESPONSE" | sed '$d')

# HTTP 상태 코드 확인 (200 OK가 아니면 에러 처리)
if [ "$HTTP_STATUS" -ne 200 ]; then
    echo "" >&2
    echo "❌ API Request Failed (Status: $HTTP_STATUS)" >&2
    echo "Response Body:" >&2
    echo "$HTTP_BODY" >&2
    exit 1
fi

# API 응답 확인 - error 필드가 있는지 체크 (200 OK라도 에러 메시지가 있을 수 있음)
if echo "$HTTP_BODY" | grep -q '"error"'; then
    echo "" >&2
    echo "❌ API Error Response:" >&2
    echo "$HTTP_BODY" >&2
    echo "✗ API request failed" >&2
    exit 1
fi

# 성공 응답 출력
echo "$HTTP_BODY"

echo "" >&2
echo "✓ API request completed" >&2

