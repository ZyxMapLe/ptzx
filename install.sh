#!/bin/bash

if (( $EUID != 0 )); then
    echo -e "${CYAN}Run this script using root"
    exit
fi

clear

instalartema(){
    cd /var/www/
    tar -cvf pterodactylbackup.tar.gz pterodactyl
    echo -e "${CYAN}Installing themes..."
    cd /var/www/pterodactyl
    rm -r pterodactylthemes
    git clone https://github.com/wffzy/pterodactylthemes.git
    cd pterodactylthemes
    rm /var/www/pterodactyl/resources/scripts/pterodactylthemes.css
    rm /var/www/pterodactyl/resources/scripts/index.tsx
    rm /var/www/pterodactyl/resources/scripts/components/server/files/FileManagerContainer.tsx
    mv FileManagerContainer.tsx /var/www/pterodactyl/resources/scripts/components/server/files/FileManagerContainer.tsx
    mv FetchButton.tsx /var/www/pterodactyl/resources/scripts/components/server/files/FetchButton.tsx
    mv index.tsx /var/www/pterodactyl/resources/scripts/index.tsx
    mv pterodactylthemes.css /var/www/pterodactyl/resources/scripts/pterodactylthemes.css
    rm /var/www/pterodactyl/public/assets/svgs/pterodactyl.svg
    mv pterodactyl.svg /var/www/pterodactyl/public/assets/svgs/pterodactyl.svg
   rm resources/scripts/components/server/console/Console.tsx
   mv Console.tsx resources/scripts/components/server/console/Console.tsx
   
   cd /var/www/pterodactyl
    
    curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash -
    apt update
    apt install -y nodejs
    npm i -g yarn
    yarn
    cd /var/www/pterodactyl
    yarn run build:production 
    chown -R www-data:www-data * 
    php artisan view:clear 
    php artisan cache:clear
    sudo php artisan optimize:clear


}

voltar(){
bash <(curl https://raw.githubusercontent.com/wffzy/pterodactylthemes/main/menu.sh)
}

instaladordetemas(){
    while true; do
        read -p "Are you sure you want to install the theme [y/n]? " yn
        case $yn in
            [Yy]* ) instalartema; break;;
            [Nn]* ) exit;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

restaurarbackup(){
    echo "Restoring Backup..."
    cd /var/www/
    tar -xvf pterodactylbackup.tar.gz
    rm pterodactylthemes.tar.gz

    cd /var/www/pterodactyl
    yarn build:production
    sudo php artisan optimize:clear
}

    CYAN='\033[0;36m'
    echo -e "${CYAN}Copyright 2023 NextSekai Theme"
    echo -e "${CYAN}This program is free software, you can modify and distribute it without any problems."
    echo -e ""
    echo -e "${CYAN}Website : https://nextsekai.in/"
    echo -e ""
    echo -e "${CYAN} [1] Install Theme"
    echo -e "${CYAN} [2] Restore Backup"
    echo -e "${CYAN} [3] Back"
    echo -e "${CYAN} [0] Exit"

read -p "Enter a number: " choice
if [ $choice == "1" ]
    then
    instaladordetemas
fi
if [ $choice == "2" ]
    then
    restaurarbackup
fi
if [ $choice == "3" ]
    then
    voltar
fi
 
if [ $choice == "0"]
    then
    exit
fi
