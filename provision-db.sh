#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Provisionando el servidor de base de datos (MariaDB)"

# ----------------------------
# 1️⃣ Actualizar e instalar MariaDB
# ----------------------------
apt-get update -y
apt-get install -y mariadb-server

# ----------------------------
# 2️⃣ Configurar MariaDB para escuchar en IP privada
# ----------------------------
sed -i "s/^bind-address.*/bind-address = 192.168.56.11/" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

# ----------------------------
# 3️⃣ Crear base de datos, usuario y datos iniciales
# ----------------------------
mysql -u root <<MYSQL_SCRIPT
-- Crear base de datos
CREATE DATABASE IF NOT EXISTS iawdb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;

-- Crear usuario y permisos
CREATE USER IF NOT EXISTS 'iawuser'@'192.168.56.%' IDENTIFIED BY 'iawpass';
GRANT ALL PRIVILEGES ON iawdb.* TO 'iawuser'@'192.168.56.%';
FLUSH PRIVILEGES;

-- Crear tabla de usuarios
USE iawdb;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fecha_registro DATE DEFAULT CURRENT_DATE
);

-- Insertar datos de ejemplo
INSERT INTO users (nombre, email) VALUES
('Ana Torres', 'ana.torres@example.com'),
('Luis Gómez', 'luis.gomez@example.com'),
('Marta Ruiz', 'marta.ruiz@example.com');
MYSQL_SCRIPT

echo "==> ¡Provisionamiento de la base de datos completado con datos iniciales!"
