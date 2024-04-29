#!/usr/bin/env bash

#CORES
AMARELO='\033[33m'
VERMELHO='\e[1;91m'
VERDE='\e[1;92m'
AZUL='\e[1;36m'
SEM_COR='\e[0m'

##############################################################################
#                                  FUNÇÕES                                   #
##############################################################################


codecs_proprietarios () {
	# Realiza a instação dos codecs proprietários.
	sudo apt install -y faad ffmpeg gstreamer1.0-fdkaac gstreamer1.0-libav \
	gstreamer1.0-vaapi gstreamer1.0-plugins-bad gstreamer1.0-plugins-base \
	gstreamer1.0-plugins-good gstreamer1.0-plugins-ugly lame libavcodec-extra \
	libavcodec-extra59 libavdevice59 libgstreamer1.0-0 sox twolame vorbis-tools

	# Suporte a descompactação
	sudo apt install -y arc arj cabextract lhasa p7zip p7zip-full p7zip-rar rar \
	unrar unace unzip xz-utils zip

	# Remove lixo desnecessário.
	sudo apt autoremove -y

	echo -e "\n${VERDE}Adicionado CODECS e descompactação${SEM_COR}\n"
}

inicializacao () {
	# Verifica se o diretório ~/.config/autostart existe, se não, cria.
	if [ ! -d ~/.config/autostart ]; then
	    mkdir -p ~/.config/autostart
	fi

	# Tray do sistema ao inicializar.
	echo "[Desktop Entry]
	Type=Application
	Exec=gnome-extensions enable ubuntu-appindicators@ubuntu.com
	Hidden=false
	X-GNOME-Autostart-enabled=true
	Name=Habilitar App Indicators" > ~/.config/autostart/enable_app_indicators.desktop

	# Google chrome como navegador principal ao inicializar.
	echo "[Desktop Entry]
	Type=Application
	Exec=xdg-settings set default-web-browser google-chrome.desktop
	Hidden=false
	X-GNOME-Autostart-enabled=true
	Name=Definir Google Chrome como navegador padrão" > ~/.config/autostart/set_default_browser.desktop
}

install_tlp () { # Baixa e instala tlp para notebooks.
	sudo systemctl disable --now power-profiles-daemon.service
	sudo apt remove power-profiles-daemon -y && \
	sudo apt install tlp tlp-rdw -y && \
	sudo systemctl enable --now tlp.service
}

misc () {
	# Baixa e define o papel de parede. (Muito importante.)
	wget https://github.com/qrocafe1535/noc-debian-config/raw/main/wallapaper/debian-wallpaper.png -O $HOME/Imagens/debian-wallpaper.png
	gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Imagens/debian-wallpaper.png"
	gsettings set org.gnome.desktop.background picture-uri-dark "file://$HOME/Imagens/debian-wallpaper.png"

	# Fix pesquisa lenta dos apps.
	gsettings set org.gnome.desktop.search-providers disable-external true

	# Habilita o botão de maximizar e minimizar.
	gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

	# Desabilita barulho chato do dude.
	gsettings set org.gnome.desktop.sound event-sounds false

	# Habilita clique no touchpad.
	gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true

	echo -e "\n${VERDE}Setada algumas configurações do gnome!${SEM_COR}\n"
}

instala_zramtool () { # Habilita o swap em arquivo (Zram).
	sudo apt install zram-tools -y
	echo -e "ALGO=zstd\nPERCENT=20" | sudo tee -a /etc/default/zramswap
	echo -e "\n${VERDE}Habilitado suporte Zram!${SEM_COR}\n"
}

instala_adw3 () { # Habilita suporte a temas libadwaita trazendo melhora visual ao desktop.
	mkdir -p $HOME/Downloads/adw3
	wget -P $HOME/Downloads/adw3 https://github.com/lassekongo83/adw-gtk3/releases/download/v5.1/adw-gtk3v5-1.tar.xz
	sudo tar -xf $HOME/Downloads/adw3/adw-gtk3v5-1.tar.xz -C /usr/share/themes
	flatpak install --noninteractive org.gtk.Gtk3theme.adw-gtk3 org.gtk.Gtk3theme.adw-gtk3-dark
	gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark' && \
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
	echo -e "\n${VERDE}Habilitado suporte a thema legado libadwaita dark!${SEM_COR}\n"
	sleep 1
}

unattended-upgrades () { # Habilitando security updates automáticos.
	sudo apt install unattended-upgrades -y
	sudo systemctl enable --now unattended-upgrades
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
	libfuse2
	curl
	scrot
	vlc
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
	software-properties-common
	printer-driver-all
	ttf-mscorefonts-installer
	gnome-shell-extension-appindicator
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
	cd $HOME/Downloads/Winbox
	chmod a+x $HOME/Downloads/Winbox/winbox-setup
	sudo bash $HOME/Downloads/Winbox/winbox-setup install
	mkdir -p $HOME/.wine/drive_c/winbox
	sudo ln -s /usr/local/bin/winbox.exe $HOME/.wine/drive_c/winbox/winbox.exe
	cd ~/
}

instala_dude () { # Instala The Dude Client 6.48.6
	mkdir -p $HOME/Downloads/Dude
	wget -P $HOME/Downloads/Dude https://download.mikrotik.com/routeros/6.48.6/dude-install-6.48.6.exe 
	wine $HOME/Downloads/Dude/dude-install-6.48.6.exe
}

mk_soft () { # Pergunta se deseja instalar os apps da mikrotik. (recomendado)
	echo "Você deseja instalar o Winbox & TheDudeClient? (s/N)"
	read resposta_instalar

	case $resposta_instalar in
	    s|S)
	        echo -e "${VERDE}Instalando mikrotik services...${SEM_COR}"
	        instala_dude
	        instala_winbox
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
	sudo dpkg -i $HOME/Downloads/chrome/google-chrome-stable_current_amd64.deb
	sudo apt install -f -y
	echo -e "\n${VERDE}Instalado Google Chrome${SEM_COR}\n"
	sleep 1
}

system_clean () {
	sudo apt update -y
	flatpak update -y
	sudo apt upgrade -y && \
	sudo apt full-upgrade -y
	sudo apt install -f -y
	sudo apt autoclean -y
	sudo apt autoremove -y
	sudo rm -r $HOME/Downloads/chrome
	sudo rm -r $HOME/Downloads/Dude
	sudo rm -r $HOME/Downloads/Winbox
	sudo rm -r $HOME/Downloads/adw3

	# Remove cache de fonts.
	fc-cache -f -v > /dev/null 2>&1
	echo -e "\n${VERDE}Sistema limpo!${SEM_COR}\n"
	sleep 1
}

repositorio_non-free () { # Habilita o repositório non-free
	sudo apt-add-repository contrib non-free -y
}

instala_wine () { # Adiciona arquitetura de 32 bits e instala o Wine
	sudo dpkg --add-architecture i386 && sudo apt update
	sudo apt install -y \
      wine \
      wine32 \
      wine64 \
      libwine \
      libwine:i386 \
      fonts-wine
}


##############################################################################
#                            INICIO DO PROCESSO                              #
##############################################################################

main_update_debian () {
	echo -e "\n${AZUL}Começando em 3... 2... 1....\n${SEM_COR}\n"
	sleep 3
	testes_internet
	travas_apt
	instala_zramtool
	install_tlp
	repositorio_non-free
	instala_apt_packages
	codecs_proprietarios
	misc
	instala_wine
	system_update
	unattended-upgrades
	suporte_flatpak
	instala_adw3
	instala_chrome
	mk_soft
	system_clean
	inicializacao
	echo -e "${AZUL}\nFinalizado com exito! Por favor reinicie o sistema.\n${SEM_COR}"
	sleep 2
}

pergunta_continuar () {
	echo "O script fará inúmeras alterações, deseja continuar? (s/N)"
	read resposta

	case $resposta in
	    s|S)
			echo "Iniciando instalação..."
			main_update_debian
            ;;
	    n|N)
        	echo -e "Saindo..."
            ;;
	    *)
	        echo "Opção inválida."
	        ;;
    esac
}

main () {
    if [[ $UID -eq 0 ]]; then # Verifica se for root fecha o programa.
        echo -e "\n${VERMELHO}[ERRO]${SEM_COR} O programa não deve ser executado como root."
        sleep 2
        exit 1
    fi

    # Verifica se o SO é Debian.
    if [ "$(lsb_release -is)" == "Debian" ]; then
        pergunta_continuar
    else
        echo -e "${VERMELHO}O script foi feito pensado apenas no debian stable!${SEM_COR}"
        exit 1
    fi
}

main