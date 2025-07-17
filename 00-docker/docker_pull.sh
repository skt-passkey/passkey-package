#!/bin/bash

export API_URL="${API_URL:-}"
export API_ACCESS_KEY="${API_ACCESS_KEY:-}"
# IMAGE 값을 커맨드라인 인자로 받아오기
if [ -z "$1" ]; then
  echo "Error: IMAGE argument is required."
  exit 1
fi
export IMAGE="$1"

# get_access_key.sh 스크립트 실행
OUTPUT=$(./get_access_key.sh)

#echo "Output: $OUTPUT"

# loginCommand와 imageUri 추출
LOGIN_COMMAND=$(echo "$OUTPUT" | jq -r '.loginCommand')
IMAGE_URI=$(echo "$OUTPUT" | jq -r '.imageUri')
# 이미지 URL에서 https:// 제거
IMAGE_URI=$(echo "$IMAGE_URI" | sed 's|https://||')

# Docker login 수행
echo "Logging in to ECR..."
$LOGIN_COMMAND

# Docker pull 수행
echo "Pulling image from ECR $IMAGE_URI"
docker pull "$IMAGE_URI"

# tag 달아주기
echo "Tagging image as: $IMAGE"
docker tag "$IMAGE_URI" "$IMAGE"

# 결과 출력
echo "Docker login and image pull complete."