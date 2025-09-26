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

-- Employees table used by Experiment 6
CREATE TABLE IF NOT EXISTS employees (
  eno INT PRIMARY KEY,
  name VARCHAR(100),
  gender VARCHAR(20),
  dept VARCHAR(50),
  salary FLOAT
);

CREATE DATABASE IF NOT EXISTS employee;
USE employee;
CREATE TABLE IF NOT EXISTS emp (
  rno INT PRIMARY KEY,
  name VARCHAR(100),
  age INT
);

-- Database used by labsheet5
CREATE DATABASE IF NOT EXISTS god;
USE god;
CREATE TABLE IF NOT EXISTS mark (
  rollno INT PRIMARY KEY,
  name VARCHAR(255),
  section VARCHAR(10),
  sub1 INT, sub2 INT, sub3 INT, sub4 INT, sub5 INT, sub6 INT,
  lab1 INT, lab2 INT
);

-- Database used by Experiment 7 login demo
CREATE DATABASE IF NOT EXISTS project;
USE project;
CREATE TABLE IF NOT EXISTS register (
  name VARCHAR(100),
  password VARCHAR(100)
);

-- RegistrationForm demo (if uncommented in code)
CREATE DATABASE IF NOT EXISTS registrationForm;
USE registrationForm;
CREATE TABLE IF NOT EXISTS details (
  name VARCHAR(100),
  email VARCHAR(100),
  password VARCHAR(100)
);

-- Project With All Components
CREATE DATABASE IF NOT EXISTS allCompo;
USE allCompo;
CREATE TABLE IF NOT EXISTS allCompo (
  name VARCHAR(255),
  rollNo VARCHAR(255),
  email VARCHAR(255),
  password VARCHAR(255),
  dob VARCHAR(255),
  phoneNo VARCHAR(255),
  gender VARCHAR(255),
  address VARCHAR(255)
);

-- Student Registration Form (module)
CREATE DATABASE IF NOT EXISTS module1;
USE module1;
CREATE TABLE IF NOT EXISTS StudentRegistrationForm (
  name VARCHAR(50),
  email VARCHAR(50),
  phone VARCHAR(50),
  address VARCHAR(50)
);

-- Simple JDBC insert examples
CREATE DATABASE IF NOT EXISTS jdbc_db;
USE jdbc_db;
CREATE TABLE IF NOT EXISTS student (
  id INT,
  name VARCHAR(100),
  branch VARCHAR(100)
);
SQL

echo "[mysql] MySQL is ready on localhost:$HOST_PORT"
