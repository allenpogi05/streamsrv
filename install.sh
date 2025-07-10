#!/bin/bash

# STEP 1: Update package list
echo "🔄 Updating package list..."
sudo apt update

# STEP 2: Install Apache2
echo "📦 Installing Apache2..."
sudo apt install apache2 -y

# STEP 3: Install FUSE
echo "📦 Installing FUSE..."
sudo apt install fuse -y

# STEP 4: Install Rclone
echo "📦 Installing Rclone..."
sudo apt install rclone -y

# STEP 5: Launch Rclone config
echo "⚙️  Launching Rclone configuration..."
rclone config

# STEP 6: Enable user_allow_other in /etc/fuse.conf
echo "🔧 Enabling 'user_allow_other' in /etc/fuse.conf..."
sudo sed -i 's/^#user_allow_other/user_allow_other/' /etc/fuse.conf
if ! grep -q "^user_allow_other" /etc/fuse.conf; then
  echo "user_allow_other" | sudo tee -a /etc/fuse.conf
fi

# STEP 7: Mount idrive: to /var/www/html with streaming optimizations
echo "🔗 Mounting idrive: to /var/www/html..."
sudo rclone mount idrive: /var/www/html \
  --vfs-cache-mode full \
  --vfs-cache-max-size 10G \
  --vfs-read-ahead 256M \
  --vfs-read-chunk-size 32M \
  --vfs-read-chunk-size-limit 512M \
  --buffer-size 64M \
  --allow-other \
  --dir-cache-time 12h \
  --attr-timeout 1s \
  --poll-interval 30s \
  --timeout 1h \
  --daemon

# STEP 8: Create a systemd service for auto-mount at boot
echo "🛠️ Creating systemd service for Rclone mount..."

cat <<EOF | sudo tee /etc/systemd/system/rclone-mount.service > /dev/null
[Unit]
Description=Rclone Mount for IDrive E2
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/rclone mount idrive: /var/www/html \\
  --vfs-cache-mode full \\
  --vfs-cache-max-size 10G \\
  --vfs-read-ahead 256M \\
  --vfs-read-chunk-size 32M \\
  --vfs-read-chunk-size-limit 512M \\
  --buffer-size 64M \\
  --allow-other \\
  --dir-cache-time 12h \\
  --attr-timeout 1s \\
  --poll-interval 30s \\
  --timeout 1h

ExecStop=/bin/fusermount -uz /var/www/html
Restart=on-failure
User=root
Group=root

[Install]
WantedBy=multi-user.target
EOF

# STEP 9: Enable and start the systemd service
echo "🚀 Enabling and starting Rclone mount service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable rclone-mount
sudo systemctl start rclone-mount

echo "✅ Done! Rclone is mounted to /var/www/html and will auto-mount at boot."
