# From the Kali linux base image
FROM kalilinux/kali-rolling

LABEL maintainer="https://github.com/Kr0ff"
LABEL website="https://cicadasec.com"

# Set what desktop env to install

# - v0.3
# XFCE has been changed to LXDE due to issues with high
# CPU usage and slight issue with black bars appearing around
# the desktop (https://lists.debian.org/debian-user/2021/01/msg00486.html)
ARG KALI_DESKTOP=lxde

# Update and apt install kali-defaults with non-interactive frontend
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt upgrade -y && \
    apt install -y \
        curl x11vnc xvfb dbus-x11 x2goserver iputils-arping \
        iputils-clockdiff iputils-ping iputils-tracepath  \
        zsh zsh-syntax-highlighting zsh-autosuggestions \
        META_PACKAGE kali-desktop-${KALI_DESKTOP}

# Required for X2GO, needs a display
ENV DISPLAY :0
ENV KALI_DESKTOP ${KALI_DESKTOP}

# Set entrypoint and working directory
WORKDIR /root/

# Make changes to the timezone if necessary
RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

RUN mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

RUN mkdir /root/.ssh/ && touch /root/.ssh/authorized_keys && \
    echo "SSH_PUBKEY" > /root/.ssh/authorized_keys

RUN curl -o /etc/ascii https://gist.githubusercontent.com/Kr0ff/0f528c31edfa2ab1a7ffcbab761edb9c/raw/5a990b1339edf91847e5455ec35b965646f40df9/kali-ascii

RUN echo "\
Include /etc/ssh/sshd_config.d/*.conf \n\
Port 22 \n\
ListenAddress 0.0.0.0 \n\
PermitRootLogin yes \n\
#PasswordAuthentication yes \n\
PermitEmptyPasswords no \n\
ChallengeResponseAuthentication no \n\
UsePAM yes \n\
X11Forwarding yes \n\
PermitTTY yes \n\
PrintMotd no \n\
Banner /etc/ascii \n\
AcceptEnv LANG LC_* \n\
Subsystem	sftp	/usr/lib/openssh/sftp-server" > /etc/ssh/sshd_config

# If you require zsh
RUN chsh -s /usr/bin/zsh
RUN touch ~/.hushlogin 
RUN mv /etc/motd /etc/motd.bak
RUN service ssh start

EXPOSE 22/tcp

CMD ["/usr/sbin/sshd","-D"]