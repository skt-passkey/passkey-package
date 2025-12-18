#!/bin/bash

# License Key에서 DNS 정보를 추출하는 함수
# test_header.sh의 검증된 로직을 사용

extract_dns_from_license() {
    local LICENSE_KEY="$1"

    if [ -z "$LICENSE_KEY" ]; then
        return 1
    fi

    # JWT 헤더에서 x5c 인증서 추출
    local HEADER=$(echo "$LICENSE_KEY" | cut -d'.' -f1)

    # Base64Url 디코딩을 위한 패딩 처리 및 문자 치환
    # 1. - 와 _ 를 + 와 / 로 치환
    # 2. 길이를 4의 배수로 맞추기 위해 = 패딩 추가
    local B64_INPUT=$(echo "$HEADER" | tr '_-' '/+')
    local LEN=${#B64_INPUT}
    local MOD=$((LEN % 4))
    if [ $MOD -eq 2 ]; then
        B64_INPUT="${B64_INPUT}=="
    elif [ $MOD -eq 3 ]; then
        B64_INPUT="${B64_INPUT}="
    fi

    # base64 디코딩 (OS 호환성 처리)
    local DECODED_HEADER=""
    if echo "test" | base64 -d >/dev/null 2>&1; then
        # Linux / Modern macOS
        DECODED_HEADER=$(echo "$B64_INPUT" | base64 -d 2>/dev/null)
    else
        # Old macOS / BSD
        DECODED_HEADER=$(echo "$B64_INPUT" | base64 -D 2>/dev/null)
    fi

    # x5c 필드 추출
    local CERT_B64=$(echo "$DECODED_HEADER" | sed -n 's/.*"x5c":\["\([^"]*\)".*/\1/p')

    if [ -z "$CERT_B64" ]; then
        return 1
    fi

    # 인증서를 base64 디코딩하고 openssl로 처리
    # 인증서 디코딩 시에도 호환성 고려
    if echo "test" | base64 -d >/dev/null 2>&1; then
        printf '%s' "$CERT_B64" | base64 -d 2>/dev/null | openssl x509 -inform DER -text -noout 2>/dev/null | grep -oE "DNS:[^,]*" | head -1 | cut -d':' -f2
    else
        printf '%s' "$CERT_B64" | base64 -D 2>/dev/null | openssl x509 -inform DER -text -noout 2>/dev/null | grep -oE "DNS:[^,]*" | head -1 | cut -d':' -f2
    fi

    return 0
}

# 직접 호출할 경우
if [ "$0" = "${BASH_SOURCE[0]}" ]; then
    LICENSE_KEY="${1:-}"

    if [ -z "$LICENSE_KEY" ]; then
        echo "❌ Error: License Key required"
        exit 1
    fi

    DNS=$(extract_dns_from_license "$LICENSE_KEY")
    if [ -n "$DNS" ]; then
        echo "$DNS"
        exit 0
    else
        echo "❌ Failed to extract DNS"
        exit 1
    fi
fi

