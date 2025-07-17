# 1. Default 설정으로 테스트 (target base url, rp id, rp origin, accessToken)
java -jar e2eTest-passkey.jar --class-path e2eTest-passkey.jar --scan-classpath

# 2. 값 변경 하여 테스트
#java -jar e2eTest-passkey.jar --class-path e2eTest-passkey.jar --scan-classpath --config=baseUrl=http://localhost:8080 --config=rpId=localhost --config=rpOrigin=http://localhost:8081