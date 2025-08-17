#!/bin/bash

echo "🔧 Updating system..."
sudo apt update && sudo apt upgrade -y

echo "🖥️ Installing XFCE desktop..."
sudo apt install xfce4 xfce4-goodies -y

echo "📡 Installing TightVNC server..."
sudo apt install tightvncserver -y

echo "🌐 Installing Firefox..."
sudo apt install firefox -y

echo "🔐 Setting up VNC password..."
vncserver :1
vncserver -kill :1

echo "🖼️ Starting VNC with resolution 1280x800..."
vncserver :1 -geometry 1280x800

echo "✅ Done! Forward port 5901 in GoormIDE or Ports in VS Code on a workspace in github workspaces and connect via VNC Viewer."
