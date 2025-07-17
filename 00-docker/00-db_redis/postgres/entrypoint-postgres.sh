#!/bin/sh
# 템플릿 파일 읽기
template=$(cat /templates/init.sql.template)
# 환경 변수 치환
eval "echo \"$template\"" > /docker-entrypoint-initdb.d/init.sql

# PostgreSQL 시작 (백그라운드로!)
docker-entrypoint.sh postgres &

# PostgreSQL가 열릴 때까지 대기
until pg_isready -h localhost -p 5432 -U "${POSTGRES_USER}" -d passkey; do
  echo "⏳ PostgreSQL is unavailable - waiting..."
  sleep 1
done

# 이제 실행 가능
PGPASSWORD="${PASSKEY_DB_PW}" psql -h localhost -p 5432 -U "${PASSKEY_DB_USER}" -d passkey -f /01.postgres.init.passkey.sql
PGPASSWORD="${PASSKEY_DB_PW}" psql -h localhost -p 5432 -U "${PASSKEY_DB_USER}" -d passkey_admin -f /02.postgres.init.passkey_admin.sql

# foreground 로 실행
wait
