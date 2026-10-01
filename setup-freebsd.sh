#!/bin/sh
#
# setup-freebsd.sh
# Configuração inicial de um desktop FreeBSD
#
# Execute como root:
#   chmod +x setup-freebsd.sh
#   ./setup-freebsd.sh
#

set -eu

# ------------------------------------------------------------
# Funções auxiliares
# ------------------------------------------------------------

info() {
    echo
    echo "============================================================"
    echo "$1"
    echo "============================================================"
}

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERRO: este script precisa ser executado como root."
        echo "Execute: su -"
        echo "Depois:  ./setup-freebsd.sh"
        exit 1
    fi
}

install_packages() {
    pkg install -y "$@"
}

# Adiciona uma configuração ao sysrc somente se necessário.
set_sysrc() {
    key="$1"
    value="$2"
    sysrc "${key}=${value}"
}

# ------------------------------------------------------------
# Início
# ------------------------------------------------------------

require_root

echo "Configuração inicial do FreeBSD"
echo
echo "Este script instalará pacotes e alterará configurações do sistema."
echo "Certifique-se de estar conectado à Internet."
echo

printf "Deseja continuar? [s/N]: "
read answer

case "$answer" in
    s|S|sim|SIM|Sim)
        ;;
    *)
        echo "Operação cancelada."
        exit 0
        ;;
esac

# ------------------------------------------------------------
# Atualização dos repositórios
# ------------------------------------------------------------

info "Atualizando os repositórios do pkg"

pkg update

# ------------------------------------------------------------
# Pacotes básicos
# ------------------------------------------------------------

info "Instalando sudo e nano"

install_packages sudo nano

# ------------------------------------------------------------
# Placa de vídeo
# ------------------------------------------------------------

info "Configuração da placa de vídeo"

echo "Selecione o tipo de GPU:"
echo
echo "  1) Intel iGPU"
echo "  2) AMD"
echo "  3) Não configurar GPU"
echo

while :; do
    printf "Opção [1-3]: "
    read gpu

    case "$gpu" in
        1)
            info "Configurando Intel iGPU"

            install_packages drm-kmod
            set_sysrc kld_list+ i915kms
            install_packages xf86-video-intel

                        echo "Adicionando root ao grupo video..."
            pw groupmod video -m root

            echo
            printf "Digite o nome do usuário criado no FreeBSD: "
            read username

            if [ -z "$username" ]; then
                echo "ERRO: nenhum usuário informado."
                exit 1
            fi

            if id "$username" >/dev/null 2>&1; then
                echo "Adicionando $username ao grupo video..."
                pw groupmod video -m "$username"
            else
                echo "ERRO: o usuário '$username' não existe."
                echo "Crie o usuário primeiro ou execute novamente."
                exit 1
            fi

            break
            ;;

        2)
            info "Configurando AMD"

            install_packages drm-kmod
            set_sysrc kld_list+ amdgpu
            install_packages xf86-video-amdgpu

            echo "Adicionando root ao grupo video..."
            pw groupmod video -m root

            echo
            printf "Digite o nome do usuário criado no FreeBSD: "
            read username

            if [ -z "$username" ]; then
                echo "ERRO: nenhum usuário informado."
                exit 1
            fi

            if id "$username" >/dev/null 2>&1; then
                echo "Adicionando $username ao grupo video..."
                pw groupmod video -m "$username"
            else
                echo "ERRO: o usuário '$username' não existe."
                echo "Crie o usuário primeiro ou execute novamente."
                exit 1
            fi

            break
            ;;

        3)
            echo "Configuração de GPU ignorada."
            break
            ;;

        *)
            echo "Opção inválida. Escolha 1, 2 ou 3."
            ;;
    esac
done

# ------------------------------------------------------------
# Desktop KDE Plasma / SDDM / áudio / rede
# ------------------------------------------------------------

info "Instalando KDE Plasma, SDDM, seatd e ferramentas de desktop"

install_packages \
    seatd \
    plasma6-plasma \
    kde \
    sddm \
    networkmgr \
    pavucontrol

info "Habilitando serviços"

set_sysrc dbus_enable YES
set_sysrc seatd_enable YES
set_sysrc sddm_enable YES

# ------------------------------------------------------------
# Ajustes de sockets locais
# ------------------------------------------------------------

info "Aplicando ajustes de sockets locais"

sysctl net.local.stream.recvspace=65536
sysctl net.local.stream.sendspace=65536

# ------------------------------------------------------------
# Sistemas de arquivos / dispositivos
# ------------------------------------------------------------

info "Instalando suporte a sistemas de arquivos e dispositivos"

install_packages \
    fusefs-exfat \
    fusefs-ext2 \
    fusefs-gphotofs \
    fusefs-hfsfuse \
    fusefs-jmtpfs \
    fusefs-ntfs

set_sysrc fuse_enable YES

# ------------------------------------------------------------
# Wi-Fi
# ------------------------------------------------------------

info "Instalando interface gráfica para wpa_supplicant"

install_packages wpa_supplicant_gui

# ------------------------------------------------------------
# Wine
# ------------------------------------------------------------

info "Instalando Wine"

install_packages wine

# ------------------------------------------------------------
# Aplicativos adicionais
# ------------------------------------------------------------

info "Instalando aplicativos adicionais"

install_packages \
    octopkg \
    firefox \
    pt_BR-libreoffice \
    cmatrix

# ------------------------------------------------------------
# Finalização
# ------------------------------------------------------------

info "Configuração concluída"

echo "Os principais pacotes foram instalados."
echo "Os serviços foram habilitados no rc.conf."
echo
echo "IMPORTANTE:"
echo "  - Reinicie o computador para carregar os módulos de vídeo"
echo "    e aplicar todas as configurações."
echo
echo "Comando recomendado:"
echo "  reboot"
echo
echo "Após reiniciar, o SDDM/KDE Plasma deverá estar disponível."
echo "Caso após o login não funcionar o Wayland será necessário "
echo "configuração adicional no arquivo .profile do usuário"
