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
    local CERT_B64=$(echo "$HEADER" | base64 -d 2>/dev/null | sed -n 's/.*"x5c":\["\([^"]*\)".*/\1/p')

    if [ -z "$CERT_B64" ]; then
        return 1
    fi

    # 인증서를 base64 디코딩하고 openssl로 처리
    # test_header.sh에서 검증된 방식
    printf '%s' "$CERT_B64" | base64 -d 2>/dev/null | openssl x509 -inform DER -text -noout 2>/dev/null | grep -oE "DNS:[^,]*" | head -1 | cut -d':' -f2

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

