FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    ubuntu-desktop-minimal gnome-session gdm3 \
    tigervnc-standalone-server git websockify \
    neofetch pulseaudio pipewire pipewire-audio-client-libraries \
    xterm curl net-tools sudo \
    gimp blender \
    && apt clean

# VS Code
RUN curl -fsSL https://code.visualstudio.com/sha/download?build=stable&os=linux-deb-x64 -o vscode.deb && \
    apt install -y ./vscode.deb && rm vscode.deb

# noVNC
RUN git clone https://github.com/novnc/noVNC.git /opt/noVNC

# VNC lozinka
RUN mkdir -p /root/.vnc && \
    echo "tepih341" | vncpasswd -f > /root/.vnc/passwd && \
    chmod 600 /root/.vnc/passwd

# GNOME + PipeWire + Neofetch startup
RUN echo "#!/bin/bash\n\
export XDG_SESSION_TYPE=x11\n\
export XDG_CURRENT_DESKTOP=GNOME\n\
export GDMSESSION=gnome\n\
pulseaudio --start\n\
pipewire &\n\
neofetch\n\
gnome-session &" > /root/.vnc/xstartup && \
    chmod +x /root/.vnc/xstartup

# Pokretanje
CMD vncserver :1 -geometry 1920x1080 -depth 24 && \
    /opt/noVNC/utils/launch.sh --vnc localhost:5901
