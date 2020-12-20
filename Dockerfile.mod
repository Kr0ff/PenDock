# From the Kali linux base image
FROM kalilinux/kali-rolling

LABEL maintainer="https://github.com/Kr0ff"
LABEL website="https://cicadasec.com"

# Set what desktop env to install
ARG KALI_DESKTOP=xfce

# Update and apt install kali-defaults with non-interactive frontend (doesnt ask for user interaction)
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt upgrade -y && \
    apt install -y \
        x11vnc xvfb novnc dbus-x11 x2goserver iputils-arping \
        iputils-clockdiff iputils-ping iputils-tracepath  \
        META_PACKAGE kali-desktop-${KALI_DESKTOP}

ENV DISPLAY :0
ENV KALI_DESKTOP ${KALI_DESKTOP}

# Set entrypoint and working directory
WORKDIR /root/

RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

RUN mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

RUN mkdir /root/.ssh/ && touch /root/.ssh/authorized_keys && \
    echo "SSH_PUBKEY" > /root/.ssh/authorized_keys

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
PrintMotd yes \n\
Banner none \n\
AcceptEnv LANG LC_* \n\
Subsystem	sftp	/usr/lib/openssh/sftp-server" > /etc/ssh/sshd_config

RUN service ssh start

EXPOSE 22/tcp

CMD ["/usr/sbin/sshd","-D"]