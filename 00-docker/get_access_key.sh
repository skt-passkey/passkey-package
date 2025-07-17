#!/bin/bash

# API Gateway URL 설정
API_URL="${API_URL:-}"
IMAGE="${IMAGE:-}"
API_ACCESS_KEY="${API_ACCESS_KEY:-}"

# IMAGE_ACCESS_KEY가 설정되지 않았다면 오류 메시지 출력
if [ -z "$API_ACCESS_KEY" ]; then
    echo "Error: API_ACCESS_KEY 환경 변수가 설정되지 않았습니다."
    exit 1
fi

# POST 요청 보내기
curl -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d '{
            "image": "'"$IMAGE"'",
            "apiAccessKey": "'"$API_ACCESS_KEY"'"
        }'