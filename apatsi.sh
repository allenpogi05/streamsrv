#!/bin/bash

# STEP 1: Install Apache2 if not installed
echo "📦 Installing Apache2..."
sudo apt update
sudo apt install apache2 -y

# STEP 2: Create Virtual Host config for anipaca.site
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

# STEP 3: Enable the site and reload Apache
echo "✅ Enabling site..."
sudo a2ensite anipaca.site.conf
sudo a2dissite 000-default.conf

echo "🔄 Reloading Apache..."
sudo systemctl reload apache2

echo "✅ Apache is configured for http://anipaca.site"

# Optional: Ask user if they want to install HTTPS with Certbot
read -p "Do you want to install SSL using Let's Encrypt now? (y/n): " enable_ssl
if [[ "$enable_ssl" == "y" || "$enable_ssl" == "Y" ]]; then
  echo "🔐 Installing Certbot and enabling HTTPS..."
  sudo apt install certbot python3-certbot-apache -y
  sudo certbot --apache -d anipaca.site -d www.anipaca.site
else
  echo "⚠️ Skipped SSL setup. You can run it later using: sudo certbot --apache -d anipaca.site"
fi
