FROM parrotsec/core

# Usual creator rant
LABEL maintainer="https://github.com/Kr0ff"
LABEL website="https://cicadasec.com"

#ARG PARROT_DESKTOP=lxde

# Set non-interactive frontend and install some packages
RUN export DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt upgrade -y && \
    apt install -y \
        curl \
        x11vnc \
        vim \
        ssh \
        xvfb \
        dbus-x11 \
        x2goserver \
        iputils-arping \
        iputils-clockdiff \
        iputils-ping \
        iputils-tracepath \
        META_PACKAGE


# Required for X2GO, needs a display
ENV DISPLAY :0

# Set working directory
WORKDIR /root/

# Make changes to the timezone if necessary
RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

RUN mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

RUN mkdir /root/.ssh/ && touch /root/.ssh/authorized_keys && \
    echo "SSH_PUBKEY" > /root/.ssh/authorized_keys

# Grab the ascii 
RUN curl -o /etc/ascii https://gist.githubusercontent.com/Kr0ff/f60277855befb1b50e3412ee0641fc1a/raw/60aba728d60c7f79e6c7c2bcb48cac90dd7e8a17/parrotsec-ascii

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
# Note: some packages seemed to return a 404 
# when APT was retrieving them so they are removed
# RUN chsh -s /usr/bin/zsh
RUN cp /etc/skel/.profile  /root/
RUN cp /etc/skel/.vimrc /root/
RUN cp /etc/skel/.zshrc /root/
RUN mv /etc/motd /etc/motd.bak
RUN service ssh start

EXPOSE 22/tcp

# Entrypoint necessary for running 'sshd -D'
# Unfortunately standalone CMD doesn't seem to work
COPY entrypoint.sh .
RUN chmod 755 ./entrypoint.sh
# CMD ["/usr/sbin/sshd","-D"]
ENTRYPOINT [ "./entrypoint.sh" ]