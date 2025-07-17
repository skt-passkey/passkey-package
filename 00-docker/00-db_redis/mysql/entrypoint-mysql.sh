#!/bin/sh
# 템플릿 파일 읽기
template=$(cat /templates/init.sql.template)
# 환경 변수 치환
eval "echo \"$template\"" > /docker-entrypoint-initdb.d/init.sql
exec docker-entrypoint.sh mysqld