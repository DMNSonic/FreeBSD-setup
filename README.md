# FreeBSD-setup
Script pessoal para instalação do necessário para usar o FreeBSD como desktop.

Este script você instala:

- sudo
- nano

- Intel ou AMD para o video

- KDE Plasma e Wayland:

seatd
plasma6-plasma
kde
sddm
networkmgr
pavucontrol


- Compatibilidade com outros formatos de disco:

fusefs-exfat
fusefs-ext2
fusefs-gphotofs
fusefs-hfsfuse
fusefs-jmtpfs
fusefs-ntfs

- Programa para Wi-Fi

- Wine

- Outros bons programas:

octopkg
Firefox
pt_BR-libreoffice
cmatrix

Há coisas que ainda precisam ser feitas, então deixarei meu arquivo que tenho há anos ensinando coisas a se fazer no FreeBSD:
<br>
<br>

# Complemento - Instruções detalhadas

Vou deixar aqui a versão antiga do meu guia onde eu deixava em um Google Keep <br>
Aqui tem um passo a passo do que eu fazia manualmente, hoje o script neste git faz quase tudo<br>

Para dúvidas em geral tem o Handbook:
https://docs.freebsd.org/en/books/handbook/
<br>
<br>

**IMPORTANTE:**<br>
Quando criar o usuário coloque nos grupos 'wheel'  'operator' e 'video'
<br>
<br>

**PÓS INSTALAÇÃO INICIAL DO SISTEMA**
-------------------------------------
<br>

**Instalar o SUDO**

```pkg install sudo```

Lembre de adicionar o seu usário ao /usr/local/etc/sudoers

<br>

**Instalar o Nano (editor de texto do terminal)**

```pkg install nano```

<br>

Tembém tem o **Pico** por padrão para editar arquivos de texto, basta usar o 'edit'

<br>
<br>

**Instalar o driver de video**

Primeiro, verifique o seu video:

```pciconf -lv | grep -B4 VGA```
<BR>

No caso de Intel iGPU faça o seguinte:

```
pkg install drm-kmod
sysrc kld_list+=i915kms
pkg install xf86-video-intel
```
<BR>

No caso de AMD:
```
pkg install drm-kmod
sysrc kld_list+=amdgpu
pkg install xf86-video-amdgpu
```
<BR>
Coloque o usuário criado no grupo "video"

```
pw groupmod video -m usuario
```

<BR>
<BR>

**Instalar Wayland e o KDE Plasma**
<BR>
```
pkg install seatd plasma6-plasma kde sddm ly networkmgr pavucontrol
```
<BR>
Depois adicione os serviços:
<BR>

```
sysrc dbus_enable="YES"
sysrc seatd_enable="YES"
sysrc sddm_enable="NO"
sysrc ly_enable="YES"
sysctl net.local.stream.recvspace=65536
sysctl net.local.stream.sendspace=65536
```

<BR>
Para configurar o LY como login manager, pois o SDDM não funciona com Wayland:
<BR>

Modificar /etc/gettytab:
```sh
Ly:\
        :lo=/usr/local/bin/ly_wrapper:\
        :al=root:
```
Modificar /etc/ttys:
```
ttyv1   "/usr/libexec/getty Ly"         xterm   on secure
```

Instalar tudo e dar reboot, deve iniciar no KDE

Caso queira que após o login pelo terminal (sem o LY) inicie o KDE com Wayland, edite o arquivo oculto .profile e adicione esta linha para iniciar logo depois do login no terminal:

```
ck-launch-session dbus-run-session startplasma-wayland
```
<br>

**Usando diferentes tipos de partições**

```
pkg install fusefs-exfat fusefs-ext2 fusefs-gphotofs fusefs-hfsfuse fusefs-jmtpfs fusefs-ntfs
```

Depois adicione no /etc/rc.conf

```
fuse_enable="YES"
```
<br>

**Firefox**

```
pkg install firefox
```
<br>

**App para simular efeito Matrix**

Legal para depois configurar como protetor de tela no KDE

```
pkg install cmatrix
```
<br>

**Instalar Wine**

```
pkg install wine
```

Caso tenha problemas para atualizar softwares como o Wine, você tem que trocar o repositório de *'quartely'* para *'latest'*

O arquivo /etc/pkg/FreeBSD.conf tem os repositórios, altere o quarterly para latest e depois dê um pkg update
<br>
<br>

**Instalador de pacotes em modo gráfico**
```
pkg install octopkg
```
<br>

**Instalar LibreOffice e em português**
```
pkg install pt_BR-libreoffice
```
<br>

**App para manipular as conexões Wi-Fi**
```
pkg install wpa_supplicant_gui
```
<br>


# INSTALAÇÃO DE OUTRAS COISAS


Deixei aqui outras instruções de coisas que já instalei antes.<br>
Talvez ainda seja útil...
<br>


Instalar o Xorg
---------------

Quando instala o pacote de driver de vídeo da placa específica pode vir com o Xorg, caso não faça:
```
pkg install xorg
```
Digite:
```
Xorg -configure
```
Isso criará um arquivo de configuração do Xorg para editar faça:
```
nano /root/xorg.conf.new
```
Procure pelo "Device", haverá uma linha escrita "Driver", troque o "modesetting" para "intel"

Com isso feito você moverá o arquivo de configuração para a pasta original renomeado como 'xorg.conf'
```
mv /root/xorg.conf.new /usr/local/etc/X11/xorg.conf.d/xorg.conf
```
Para testar já execute um "startx", você deve ver uma interface gráfica simples rodando.
<br>


Instalar o XFCE
---------------

Depois de instalar o Xorg e configurar voce digita
```
pkg install xfce
```
Depois da instalação voce deve fazer um arquivo no nano 
```
nano /home/seuusuario/.xinirc
```
E nele digitar
```
export LANG="pt_BR.UTF-8"
export LC_ALL="pt_BR.UTF-8"
exec startxfce4
```
Depois instalar o slim para tela de login
```
pkg install slim slim-themes
```
Depois configurar tudo:
```
sysrc dbus_enable=yes
Sysrc hald_enable=yes
Sysrc slim_enable=yes
Sysrc sound_load=yes
Sysrc snd_hda_load=yes
```
Pronto, o XFCE tá instalado e em portugues
<br>


Instalar o Gnome
----------------
```
pkg install gnome gnome-desktop gdm dbus
```
Depois adicione as linhas no sysrc
```
sysrc dbus_enable=YES
sysrc gdm_enable=YES
sysrc gnome_enable=YES
sysrc hald_enable=YES
```
Editar o fstab
```
nano /etc/fstab
```
adicione na última linha o seguinte
```
proc   /proc   procfs   rw   0   0
```

Dê um reboot


**Trocar o Gnome para português**
---------------------------------

Editar o arquivo:
/usr/local/etc/gdm/locale.conf
```
LANG="pt_BR.UTF-8"
LC_CTYPE="pt_BR.UTF-8"
LC_MESSAGES="pt_BR.UTF-8"
```
<br>


**Instalar extensões usando o Firefox para o GNOME** 
---------------------------------------

No site Gnome Extensions e o plugin do site

Instale o chrome-gnome-shell

Instalar o Dash to Dock para o Gnome
Instalar o Logo Menu para o Gnome
<br>


**Trocar o logo no "Sobre" do Gnome**
-------------------------------------

Trocar os arquivos localizados em /usr/local/share/icons
gnome-logo-text.svg
gnome-logo-text-dark.svg

Há versões muito boas de imagens oficiais do FreeBSD no site oficial:
https://freebsdfoundation.org/about-us/about-the-foundation/project/
<br>


**Trocar o logo na tela de login do GDM**
-----------------------------------------
```
sudo gdm dbus-launch gsettings set org.gnome.login-screen logo '/usr/local/share/icons/FREEBSD_White_mini.png'
```
rode tanto com o sudo tanto com o root usando o su

outra forma:
/usr/local/etc/dconf/db/gdm.d/02-logo

[org/gnome/login-screen]
logo='/path/to/logo.png'

Recompile a database do GDM
<br>


Instalar o Mizuma
-----------------

Ajuda com jogos e outras coisas com o Wine
```
pkg install mizuma
```
<br>


Instalar o Automount
--------------------
```
pkg install automount
service devd restart
```
Edite o /usr/local/etc/automount.conf
```
USERMOUNT=YES
ATIME=NO
FM="nautilus"
USER=demian
ENCODING=pt_BR.UTF-8
```
<br>


Instalar a camada Linux
-----------------------

```
pkg install debootstrap (para sistemas Debian e Ubuntu)

debootstrap 'distro debian' /compat/debian
```

Altere a tabela de partições em /etc/fstab e adicione:
```
devfs           /compat/debian/dev      devfs           rw,late   0   0
tmpfs           /compat/debian/dev/shm  tmpfs           rw,late,size=1g,mode=1777    0   0
fdescfs         /compat/debian/dev/fd   fdescfs         rw,late,linrdlnk   0   0
linprocfs       /compat/debian/proc     linprocfs       rw,late   0   0
linsysfs        /compat/debian/sys      linsysfs        rw,late   0       0
/tmp            /compat/debian/tmp      nullfs          rw,late   0   0
/home           /compat/debian/home     nullfs          rw,late   0   0
```

Depois execute:
```
mount -al
```

Dar acesso a chroot:
```
chroot /compat/debian /bin/bash
```

Para mais informações:
https://docs.freebsd.org/en/books/handbook/linuxemu/
<br>


Configurar o Wi-Fi por linha de comando
---------------------------------------

Primeiro verifique se a placa de rede é vista no FreeBSD

```
sysctl net.wlan.devices
```

Ele dará o nome o adaptador, geralmente 'ath0'

Segundo você irá fazer uma busca da rede desejada. Você pode usar o próprio 'bsdconfig' para localizar o nome da rede. Não consegui usar o bsdconfig para ativar a rede.

Quando tiver o nome da rede você irá usar um comando para procurar a senha e colocar no arquivo wpa_supplicant.conf

```
wpa_passphrase 'nome da rede' 'senha da rede' >> /etc/wpa_supplicant.conf
```

No arquivo /etc/wpa_supplicant.conf tem as configurações de rede

Aonde estiver escrito a rede que configurou coloque logo abaixo da linha 'psk':
```
scan_ssid=1
priority=5
```
Por fim, edite o arquivo /etc/rc.conf e coloque estas linhas:
```
wlans_'nome do adaptador'="wlan0"
ifconfig_wlan0="WPA SYNCDHCP"
```
<br>


Reiniciar a rede
----------------

```
Service netif restart
```
<br>


Configurar Webcam
-----------------
https://www.davidschlachter.com/misc/freebsd-webcam-browser
<br>


Analisar o hardware pelo BSD
----------------------------
https://bsd-hardware.info/



