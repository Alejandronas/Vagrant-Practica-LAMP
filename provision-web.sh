#!/usr/bin/env bash
set -e
export DEBIAN_FRONTEND=noninteractive

echo "==> Provisionamiento de servidor web (Apache + PHP)"

# ----------------------------
# 1️⃣ Actualizar e instalar paquetes
# ----------------------------
apt-get update -y
apt-get install -y apache2 php php-mysql libapache2-mod-php git unzip mariadb-client

# ----------------------------
# 2️⃣ Clonar o actualizar la aplicación
# ----------------------------
APP_DIR="/var/www/html/iaw-practica-lamp"

if [ ! -d "$APP_DIR" ]; then
    git clone https://github.com/josejuansanchez/iaw-practica-lamp "$APP_DIR"
else
    echo "Repositorio ya existe, actualizando..."
    cd "$APP_DIR"
    git pull
fi

# ----------------------------
# 3️⃣ Configurar permisos seguros
# ----------------------------
chown -R www-data:www-data "$APP_DIR"
find "$APP_DIR" -type d -exec chmod 755 {} \;
find "$APP_DIR" -type f -exec chmod 644 {} \;

# ----------------------------
# 4️⃣ Configurar Apache
# ----------------------------
cat > /etc/apache2/sites-available/iaw-practica.conf <<EOF
<VirtualHost *:80>
    DocumentRoot $APP_DIR
    <Directory $APP_DIR>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Deshabilitar sitio por defecto y habilitar el nuevo
a2dissite 000-default.conf
a2ensite iaw-practica.conf
a2enmod rewrite
systemctl restart apache2

# ----------------------------
# 5️⃣ Modificar config.php automáticamente
# ----------------------------
CONFIG_FILE="$APP_DIR/src/config.php"

cat > "$CONFIG_FILE" <<'EOF'
<?php
define('DB_HOST', '192.168.56.11');   // IP privada de la VM DB
define('DB_NAME', 'iawdb');           // nombre de la base de datos
define('DB_USER', 'iawuser');         // usuario de la DB
define('DB_PASSWORD', 'iawpass');     // contraseña del usuario

$mysqli = mysqli_connect(DB_HOST, DB_USER, DB_PASSWORD, DB_NAME);

if (!$mysqli) {
    die("Connection failed: " . mysqli_connect_error());
}
?>
EOF

# Asegurar permisos correctos para Apache
chown www-data:www-data "$CONFIG_FILE"
chmod 644 "$CONFIG_FILE"

echo "==> Archivo config.php actualizado correctamente."
echo "==> Web Provisionamiento completado!"
echo "==> Accede en: http://localhost:8080/"