#!/bin/bash
# Update i instalacija
sudo apt update && sudo apt install -y ubuntu-gnome-desktop gnome-terminal gdm3 tightvncserver git python3-pip

# Instaliraj websockify preko pip
pip3 install --user websockify

# Postavi VNC lozinku
echo "Postavi lozinku za VNC:"
vncpasswd

# Kreiraj xstartup za GNOME
cat << 'EOF' > ~/.vnc/xstartup
#!/bin/bash
xrdb $HOME/.Xresources
gnome-session &
EOF
chmod +x ~/.vnc/xstartup

# Start VNC server
vncserver :1 -geometry 1920x1080 -depth 24

# Instaliraj noVNC
git clone https://github.com/novnc/noVNC.git ~/noVNC
git clone https://github.com/novnc/websockify.git ~/noVNC/utils/websockify

# Start noVNC server na portu 6080
~/noVNC/utils/launch.sh --vnc localhost:5901 --listen 6080 &

echo "Setup gotov! Idi u Ports tab, expose port 6080 → public → otvori u browseru → GNOME desktop ready!"
