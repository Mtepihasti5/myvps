#!/bin/bash
# install-plex.sh
# Skripta za instalaciju Plex Media Servera + aliasi za upravljanje

# Update paketa
sudo apt update && sudo apt upgrade -y

# Dodaj Plex repo i key
curl https://downloads.plex.tv/plex-keys/PlexSign.key | sudo apt-key add -
echo "deb https://downloads.plex.tv/repo/deb public main" | sudo tee /etc/apt/sources.list.d/plexmediaserver.list

# Instaliraj Plex
sudo apt update
sudo apt install -y plexmediaserver

# Dodaj alias-e u .bashrc
{
  echo "alias start-plex-server='sudo systemctl start plexmediaserver && echo Plex Server pokrenut na portu 32400'"
  echo "alias stop-plex-server='sudo systemctl stop plexmediaserver && echo Plex Server zaustavljen'"
  echo "alias restart-plex-server='sudo systemctl restart plexmediaserver && echo Plex Server restartan'"
  echo "alias plex-status='systemctl status plexmediaserver --no-pager'"
} >> ~/.bashrc

# Refrešaj bashrc da alias odmah rade
source ~/.bashrc

echo "✅ Plex instaliran! Koristi start-plex-server za pokretanje."
echo "ℹ️  Plex web sučelje: http://localhost:32400/web"
