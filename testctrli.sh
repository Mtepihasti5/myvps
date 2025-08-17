# ...existing code...
#!/usr/bin/env bash
set -euo pipefail

# Simple installer + runner for a noVNC session on Ubuntu 24.04
# Usage:
#   VNC_PASSWORD=secret ./testctrli.sh    # to set a VNC password
# The script will:
#  - install needed packages (uses sudo)
#  - create a VNC password
#  - start a VNC desktop on :1 (port 5901)
#  - start noVNC proxy on http://localhost:6080
#  - try to open the URL with "$BROWSER" if set

VNC_DISPLAY=":1"
VNC_PORT=5901
NOVNC_PORT=6080
VNC_GEOMETRY="1280x720"
VNC_PASSWORD="${VNC_PASSWORD:-vncpass}"   # default password if not provided

# require sudo for package installation and some commands
if ! sudo -v >/dev/null 2>&1; then
  echo "This script needs sudo. Please run a command with a password prompt first or run the script with a user that can use sudo."
  exit 1
fi

echo "Updating apt and installing packages..."
sudo apt update -y
sudo apt install -y --no-install-recommends \
  tigervnc-standalone-server tigervnc-common \
  git wget python3 python3-pip

# Try to install novnc/websockify via apt; if not present we'll clone
if ! apt-cache show novnc >/dev/null 2>&1; then
  echo "apt package 'novnc' not found or not available; will clone noVNC/websockify if needed."
else
  sudo apt install -y novnc websockify || true
fi

# determine novnc proxy path
NOVNC_PROXY=""
if command -v novnc_proxy >/dev/null 2>&1; then
  NOVNC_PROXY="$(command -v novnc_proxy)"
elif [ -x "/usr/share/novnc/utils/novnc_proxy" ]; then
  NOVNC_PROXY="/usr/share/novnc/utils/novnc_proxy"
fi

# fallback: clone noVNC and websockify into /opt if novnc_proxy not found
if [ -z "$NOVNC_PROXY" ]; then
  echo "Cloning noVNC and websockify into /opt/noVNC and /opt/websockify..."
  sudo rm -rf /opt/noVNC /opt/websockify || true
  sudo git clone --depth 1 https://github.com/novnc/noVNC.git /opt/noVNC
  sudo git clone --depth 1 https://github.com/novnc/websockify.git /opt/websockify
  NOVNC_PROXY="/opt/noVNC/utils/novnc_proxy"
  # ensure python deps available
  sudo python3 -m pip install --upgrade pip setuptools >/dev/null 2>&1 || true
  sudo python3 -m pip install --upgrade websockify >/dev/null 2>&1 || true
fi

echo "Using novnc proxy: $NOVNC_PROXY"

# prepare VNC password (non-interactive)
echo "Setting VNC password..."
mkdir -p "$HOME/.vnc"
# use tigervnc's vncpasswd to create a password file
printf "%s\n%s\n\n" "$VNC_PASSWORD" "$VNC_PASSWORD" | vncpasswd -f > "$HOME/.vnc/passwd"
chmod 600 "$HOME/.vnc/passwd"

# kill any existing :1 session and start new one
echo "Restarting VNC server on display $VNC_DISPLAY..."
vncserver -kill "$VNC_DISPLAY" >/dev/null 2>&1 || true
# Start with the chosen geometry; -localhost yes keeps VNC accessible only locally (novnc will proxy)
vncserver "$VNC_DISPLAY" -geometry "$VNC_GEOMETRY" -localhost yes >/dev/null

# wait a moment for vncserver to be ready
sleep 1

# start noVNC proxy in background
echo "Starting noVNC proxy on http://localhost:$NOVNC_PORT ..."
# If novnc_proxy is a python script path, run with python3, otherwise run directly
if [[ "$NOVNC_PROXY" == *.py || "$NOVNC_PROXY" == */novnc_proxy ]]; then
  # run with nohup so it stays after script exits; redirect logs to /tmp/novnc.log
  nohup python3 "$NOVNC_PROXY" --vnc "localhost:$VNC_PORT" --listen "$NOVNC_PORT" >/tmp/novnc.log 2>&1 &
else
  nohup "$NOVNC_PROXY" --vnc "localhost:$VNC_PORT" --listen "$NOVNC_PORT" >/tmp/novnc.log 2>&1 &
fi

sleep 0.5

CONNECT_URL="http://localhost:$NOVNC_PORT/vnc.html?host=localhost&port=$NOVNC_PORT"
echo "noVNC should be available at: $CONNECT_URL"
echo "VNC password: (the one set by VNC_PASSWORD or default 'vncpass')"

# try to open in host browser if $BROWSER is set
if [ -n "${BROWSER:-}" ]; then
  echo "Opening $CONNECT_URL in host default browser..."
  # per workspace instruction: use "$BROWSER" <url>
  "$BROWSER" "$CONNECT_URL" >/dev/null 2>&1 || true
fi

echo "Logs: /tmp/novnc.log"
echo "To stop:"
echo "  vncserver -kill $VNC_DISPLAY"
echo "  pkill -f novnc_proxy || true"