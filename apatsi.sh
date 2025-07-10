#!/bin/bash

# Install Apache2
echo "📦 Installing Apache2..."
sudo apt update
sudo apt install apache2 -y

# Create Virtual Host for anipaca.site
echo "🛠️ Setting up Apache Virtual Host for anipaca.site..."

sudo bash -c 'cat > /etc/apache2/sites-available/anipaca.site.conf <<EOF
<VirtualHost *:80>
    ServerName anipaca.site
    ServerAlias www.anipaca.site
    DocumentRoot /var/www/html

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/anipaca_error.log
    CustomLog \${APACHE_LOG_DIR}/anipaca_access.log combined
</VirtualHost>
EOF'

# Enable site and restart Apache
sudo a2ensite anipaca.site.conf
sudo a2dissite 000-default.conf
sudo systemctl reload apache2

echo "✅ Apache is configured for anipaca.site"
