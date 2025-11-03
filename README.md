# Práctica: Pila LAMP en dos niveles

## Autor
**Alejandro [Tu Apellido]**  
Fecha: 03/11/2025

---

## 1️⃣ Objetivo de la práctica

El objetivo de esta práctica es montar una infraestructura LAMP en **dos niveles**, con:

- Una máquina web que ejecuta **Apache + PHP**
- Una máquina de base de datos que ejecuta **MariaDB/MySQL**

Cada máquina está aprovisionada automáticamente mediante **scripts bash**, y la comunicación se realiza mediante una **red privada**.  
El acceso a Internet solo tiene la máquina web, mientras que la máquina de base de datos no tiene acceso externo.

---

## 2️⃣ Descripción de la infraestructura

| Máquina       | Servicios              | IP Privada      | Acceso a Internet |
|---------------|----------------------|----------------|-----------------|
| Web (Apache)  | Apache + PHP          | 192.168.56.10  | Sí (NAT)        |
| DB (MariaDB)  | MariaDB/MySQL         | 192.168.56.11  | No              |

Se utiliza **Vagrant** con **VirtualBox** para la virtualización y aprovisionamiento automático.

---

## 3️⃣ Scripts de aprovisionamiento

### 3.1 `provision-web.sh` – Servidor web

```bash
#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Provisionamiento de servidor web (Apache + PHP)"

# 1️⃣ Instalar paquetes
apt-get update -y
apt-get install -y apache2 php php-mysql libapache2-mod-php git unzip mariadb-client

# 2️⃣ Clonar o actualizar repositorio
APP_DIR="/var/www/html/iaw-practica-lamp"
if [ ! -d "$APP_DIR" ]; then
    git clone https://github.com/josejuansanchez/iaw-practica-lamp "$APP_DIR"
else
    cd "$APP_DIR" && git pull
fi

# 3️⃣ Configurar permisos
chown -R www-data:www-data "$APP_DIR"
find "$APP_DIR" -type d -exec chmod 755 {} \;
find "$APP_DIR" -type f -exec chmod 644 {} \;

# 4️⃣ Configurar Apache
cat > /etc/apache2/sites-available/iaw-practica.conf <<EOF
<VirtualHost *:80>
    DocumentRoot $APP_DIR
    <Directory $APP_DIR>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF
a2dissite 000-default.conf
a2ensite iaw-practica.conf
a2enmod rewrite
systemctl restart apache2

# 5️⃣ Configurar config.php automáticamente
CONFIG_FILE="$APP_DIR/src/config.php"
cat > "$CONFIG_FILE" <<'EOF'
<?php
define('DB_HOST', '192.168.56.11');
define('DB_NAME', 'iawdb');
define('DB_USER', 'iawuser');
define('DB_PASSWORD', 'iawpass');

$mysqli = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

if (!$mysqli) {
    die("Connection failed: " . mysqli_connect_error());
}
?>
EOF
chown www-data:www-data "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"

echo "==> Archivo config.php actualizado correctamente."
echo "==> Web Provisionamiento completado!"
echo "==> Accede en: http://localhost:8080/" 

```

### 3.2 `provision-db.sh` – Servidor de base de datos

```bash
#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Provisionando el servidor de base de datos (MariaDB)"

# 1️⃣ Instalar MariaDB
apt-get update -y
apt-get install -y mariadb-server

# 2️⃣ Configurar MariaDB para escuchar en IP privada
sed -i "s/^bind-address.*/bind-address = 192.168.56.11/" /etc/mysql/mariadb.conf.d/50-server.cnf
systemctl restart mariadb

# 3️⃣ Crear base de datos, usuario y tabla de ejemplo
mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE IF NOT EXISTS iawdb CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
CREATE USER IF NOT EXISTS 'iawuser'@'192.168.56.%' IDENTIFIED BY 'iawpass';
GRANT ALL PRIVILEGES ON iawdb.* TO 'iawuser'@'192.168.56.%';
FLUSH PRIVILEGES;

USE iawdb;
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    fecha_registro DATE DEFAULT CURRENT_DATE
);

INSERT INTO users (nombre, email) VALUES
('Ana Torres', 'ana.torres@example.com'),
('Luis Gómez', 'luis.gomez@example.com'),
('Marta Ruiz', 'marta.ruiz@example.com');
MYSQL_SCRIPT

echo "==> Provisionamiento de la base de datos completado con datos iniciales"

```

