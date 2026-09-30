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

Há coisas que ainda precisam ser feitas, como colocar seu usuário para usar o sudo
Lembre de adicionar o seu usário ao /usr/local/etc/sudoers

Wine instala apenas a parte 64 bits. Para instalar a parte 32 bits é necessário passos adicionais

Caso tenha problemas para atualizar softwares como o Wine, você tem que trocar o repositório de 'quartely' para 'latest'
O arquivo /etc/pkg/FreeBSD.conf tem os repositórios, altere o quarterly para latest e depois dê um pkg update



