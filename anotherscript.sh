#!/bin/bash

# Provjera da li si root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Pokreni skriptu kao root (sudo)!"
  exit 1
fi

echo "➡️ Ažuriram pakete..."
apt update

echo "➡️ Instaliram GNOME + LightDM..."
DEBIAN_FRONTEND=noninteractive apt install -y ubuntu-desktop gnome-session lightdm

echo "➡️ Instaliram TightVNC Server..."
apt install -y tightvncserver curl

echo "➡️ Postavi VNC lozinku (unesi kad te pita)..."
tightvncserver :1
tightvncserver -kill :1

echo "➡️ Postavljam GNOME za VNC..."
mkdir -p ~/.vnc
cat > ~/.vnc/xstartup <<EOF
#!/bin/bash
export XKL_XMODMAP_DISABLE=1
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
gnome-session &
EOF

chmod +x ~/.vnc/xstartup

echo "➡️ Pokrećem VNC server..."
vncserver :1

echo "➡️ Dohvaćam javnu IP adresu..."
IP=$(curl -s https://icanhazip.com)

echo "✅ GNOME + LightDM + VNC Server pokrenuti!"
echo "🔗 Spoji se na: ${IP}:5901"
echo "ℹ️ Za zaustavljanje VNC-a: vncserver -kill :1"
