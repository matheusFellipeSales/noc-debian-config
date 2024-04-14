#!/usr/bin/env bash

#CORES
AMARELO='\033[33m'
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
AZUL='\e[1;36m'
SEM_COR='\e[0m'

define_wallpaper () { # Baixa e define o papel de parede.
	wget https://github.com/qrocafe1535/noc-debian-config/raw/main/wallapaper/debian-wallpaper.png -O $HOME/Imagens/debian-wallpaper.png
	gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Imagens/debian-wallpaper.png"
	gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Imagens/debian-wallpaper.png"
	echo -e "\n${VERDE}Papel de parede definido!${SEM_COR}\n"
}

instala_zramtool () { # Habilita o swap em arquivo (Zram).
	sudo apt install zram-tools
	echo -e "ALGO=zstd\nPERCENT=20" | sudo tee -a /etc/default/zramswap
	echo -e "\n${VERDE}Habilitado suporte Zram!${SEM_COR}\n"
}

instala_adw3 () { # Habilita suporte a temas libadwaita trazendo melhora visual ao desktop.
	mkdir -p $HOME/Downloads/adw3
	wget -P $HOME/Downloads/adw3 https://github.com/lassekongo83/adw-gtk3/releases/download/v5.1/adw-gtk3v5-1.tar.xz
	sudo tar -xf $HOME/Downloads/adw3/adw-gtk3v5-1.tar.xz -C /usr/share/themes
	flatpak install org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
	gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	echo -e "\n${VERDE}Habilitado suporte a thema legado libadwaita dark!${SEM_COR}\n"
	sleep 1
}

unattended-upgrade () { # Habilitando security updates automáticos.
	sudo apt install unattended-upgrade -y
	sudo systemctl enable --now unattended-upgrade
	echo -e "\n${VERDE}Habilitado Security Updates Automáticos com sucesso!${SEM_COR}\n"
}

cron_update_auto () { # Automatiza update do sistema.
	# exporta o comando para o arquivo em /etc/crontab
	echo "0 9 * * * /usr/bin/apt update && /usr/bin/apt upgrade -y && /usr/bin/apt dist-upgrade -y && /usr/bin/apt autoremove -y " | sudo tee -a /etc/crontab
	echo -e "\n${VERDE}Habilitado Update Automático com sucesso todo dia as 09:00.${SEM_COR}\n"
	sleep 1
}

testes_internet () { # Testa conexão com a internet.
	if ! ping -c 1 8.8.8.8 -q &> /dev/null; then
		echo -e "${VERMELHO}[ERROR] - Seu computador não tem conexão com a Internet. Verifique a rede.${SEM_COR}"
		exit 1
	else
		echo -e "\n${VERDE}[INFO] - Conexão com a Internet funcionando normalmente.${SEM_COR}\n"
		sleep 1
	fi
}

travas_apt () { # Remove travas do apt
	sudo rm /var/lib/dpkg/lock-frontend
	sudo rm /var/cache/apt/archives/lock
	echo -e "${VERDE}Removido travas no APT${SEM_COR}\n"
	sleep 1
}

misc () { # Adiciona arquitetura i386x843 (32 bits) e função na barra de ferramentas.
	sudo dpkg --add-architecture i386
	echo -e "\n${VERDE}Adicionado Misc!${SEM_COR}\n"
	sleep 1
}

system_update () { # Atualiza o sistema.
	echo -e "\n${VERDE}Atualizando sistema${SEM_COR}\n"
	sleep 1
	sudo apt-get update && sudo apt-get upgrade -y
}

programas_para_instalar=( # Lisagem de programas a serem instalados.
# DEPENDÊNCIAS.
	net-tools
	traceroute
	ssh
	git
	network-manager-l2tp
	network-manager-l2tp-gnome
	apt-transport-https
	ca-certificates
	libreswan
	libfuse2
	curl
	scrot
	vim
	wget
	htop
	build-essential
	libssl-dev
	libffi-dev
	python3-dev
	python3-pip
	python3-venv
	python3-setuptools
	apt-transport-https
	ca-certificates
	software-properties-common
	printer-driver-all
)

instala_apt_packages () { # Instala programas da source $programas_para_instalar
	for nome_do_programa in "${programas_para_instalar[@]}"; do
		if ! dpkg -l | awk '{print $2}' | grep -q "^$nome_do_programa$"; then
			echo -e "${VERMELHO}[INSTALANDO...]${SEM_COR} $nome_do_programa..."
			sleep 1
			sudo apt install "$nome_do_programa" -y > /dev/null 2>&1
		else
			echo -e "${VERDE}[INSTALADO]${SEM_COR} - $nome_do_programa"
		fi
	done
}

suporte_flatpak () { # Instala suporte a flatpak
	sudo apt-get install flatpak gnome-software-plugin-flatpak -y
	sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	echo -e "${VERDE}Adicionado Suporte a Flatpaks${SEM_COR}\n"
	sleep 1
}

instala_winbox () { # Instala Winbox
	mkdir -p $HOME/Downloads/Winbox
	git clone https://github.com/mriza/winbox-installer.git $HOME/Downloads/Winbox
	chmod a+x $HOME/Downloads/Winbox/winbox-setup
	sudo bash $HOME/Downloads/Winbox/winbox-setup install
	sudo ln -s /usr/local/bin/winbox.sh /usr/bin/winbox
}

instala_dude () { # Instala The Dude Client 6.48.6
	mkdir -p $HOME/Downloads/Dude
	wget -P $HOME/Downloads/Dude https://download.mikrotik.com/routeros/6.48.6/dude-install-6.48.6.exe 
	wine $HOME/Downloads//Dude/dude-install-6.48.6.exe
}

mk_soft () { # Pergunta se deseja instalar os apps da mikrotik. (recomendado)
	echo "Você deseja instalar o Winbox & TheDudeClient? (s/n)"
	read resposta

	case $resposta in
	    s|S)
	        echo -e "${VERDE}Instalando...${SEM_COR}"
	        instala_winbox
	        instala_dude
            ;;
	    n|N)
        	echo -e "\nPulando instalação...\n"
            ;;
	    *)
	        echo "Opção inválida."
	        ;;
    esac
}


instala_chrome () { # Instala google chrome
	mkdir -p $HOME/Downloads/chrome
	wget -P $HOME/Downloads/chrome https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	sudo sudo dpkg -i $HOME/Downloads/chrome/google-chrome-stable_current_amd64.deb
	echo -e "\n${VERDE}Instalado Google Chrome${SEM_COR}\n"
	sleep 1
}

system_clean () {
	sudo apt update -y
	flatpak update -y
	sudo apt autoclean -y
	sudo apt autoremove -y
	sudo apt install -f
	sudo rm -r $HOME/Downloads/chrome
	sudo rm -r $HOME/Downloads/Dude
	sudo rm -r $HOME/Downloads/Winbox
	echo -e "\n${VERDE}Sistema limpo!${SEM_COR}\n"
	sleep 1
}

repositorio_non-free () { # Habilita o repositório non-free
	sudo apt-add-repository contrib non-free -y
}

instala_wine () { # Adiciona arquitetura de 32 bits e instala o Wine
	sudo dpkg --add-architecture i386 && sudo apt update
	sudo apt install \
      wine \
      wine32 \
      wine64 \
      libwine \
      libwine:i386 \
      fonts-wine
}

# instala_wine () { # Instala o wine no debian.
# 	sudo dpkg --add-architecture i386
# 	sudo mkdir -pm755 /etc/apt/keyrings
# 	sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
# 	sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
# 	sudo apt update
# 	sudo apt install --install-recommends winehq-stable -y
# 	echo -e "${VERDE}Wine instalado...${SEM_COR}\n"
# 	sleep 1
# }

main_update_debian () {
	echo -e "\n${AZUL}Começando em 3... 2... 1....\n${SEM_COR}\n"
	sleep 3
	testes_internet
	travas_apt
	instala_zramtool
	instala_apt_packages
	repositorio_non-free
	misc
	define_wallpaper
	instala_wine
	system_update
	unattended-upgrade
	suporte_flatpak
	instala_adw3
	instala_chrome
	mk_soft
	system_clean
	echo -e "${AZUL}\nFinalizado com exito!\n${SEM_COR}"
	sleep 3
}

main () {
    if [[ $UID -eq 0 ]]; then # Verifica se for root fecha o programa.
        echo -e "\n${VERMELHO}[ERRO]${SEM_COR} O programa não deve ser executado como root."
        sleep 2
        exit 1
    fi

    # Verifica se o SO é Debian.
    if [ "$(lsb_release -is)" == "Debian" ]; then
        echo "Iniciando configuração!"
        sleep 2
        clear
        main_update_debian
    else
        echo -e "${VERMELHO}O script foi feito pensado apenas no debian stable!${SEM_COR}"
        exit 1
    fi
}

main