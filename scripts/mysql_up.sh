#!/usr/bin/env bash
set -euo pipefail

DB_ROOT_PASS="Akash@123"
CONTAINER_NAME="mysql-3308"
HOST_PORT="3308"

echo "[mysql] Starting MySQL 8 in Docker as $CONTAINER_NAME on port $HOST_PORT ..."

if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
  docker start "$CONTAINER_NAME" >/dev/null
else
  docker run --name "$CONTAINER_NAME" -e MYSQL_ROOT_PASSWORD="$DB_ROOT_PASS" -p "$HOST_PORT:3306" -d mysql:8.0 >/dev/null
fi

echo "[mysql] Waiting for MySQL to be ready..."
until docker exec "$CONTAINER_NAME" mysqladmin ping -uroot -p"$DB_ROOT_PASS" --silent; do
  sleep 2
  printf "."
done
echo

echo "[mysql] Creating databases/tables..."
docker exec -i "$CONTAINER_NAME" mysql -uroot -p"$DB_ROOT_PASS" <<'SQL'
CREATE DATABASE IF NOT EXISTS module2;
USE module2;
CREATE TABLE IF NOT EXISTS studentMarks (
  rollno INT PRIMARY KEY,
  name VARCHAR(255),
  section VARCHAR(10),
  sub1 INT, sub2 INT, sub3 INT, sub4 INT, sub5 INT, sub6 INT,
  lab1 INT, lab2 INT
);

CREATE DATABASE IF NOT EXISTS employee;
USE employee;
CREATE TABLE IF NOT EXISTS emp (
  rno INT PRIMARY KEY,
  name VARCHAR(100),
  age INT
);
SQL

echo "[mysql] MySQL is ready on localhost:$HOST_PORT"
