# From the Kali linux base image
FROM blackarchlinux/blackarch

LABEL maintainer="https://github.com/Kr0ff"
LABEL website="https://cicadasec.com"

# Update and apt install blackarch-core with non-interactive frontend
RUN rm -rf /etc/pacman.d/gnupg && \
    pacman-key --init && \
    pacman-key --populate && \
    pacman-key --update && \
    pacman --noconfirm -Syu && \
    pacman --noconfirm -S \
        curl \
        vim\
        x11vnc \
        iputils \
        net-tools \
        inetutils \
        openssh \
        tigervnc \
        htop \
        zsh \
        zsh-syntax-highlighting \
        zsh-autosuggestions \
        blackarch-config-zsh \
        nmap \
        wfuzz \
        gnu-netcat \
        pwncat \
        crackmapexec \
        python3 \
        python2 \
        git \
        aria2 \
        wget \
        lxde META_PACKAGE

# Set entrypoint and working directory
WORKDIR /root/

# Make changes to the timezone if necessary
RUN ln -sf /usr/share/zoneinfo/Europe/London /etc/localtime

RUN mv /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

RUN mkdir /root/.ssh/ && touch /root/.ssh/authorized_keys && \
    echo "SSH_PUBKEY" > /root/.ssh/authorized_keys

RUN curl -o /etc/ascii https://gist.githubusercontent.com/Kr0ff/7bb04f91cde9c8de66c8a56c9f13f5b6/raw/16d572bd6cb66d4435b91fab55b55ffaaa4a0112/blackarch-ascii.txt

RUN echo "Include /etc/ssh/sshd_config.d/*.conf" > /etc/ssh/sshd_config
RUN echo "ListenAddress 0.0.0.0" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes " >> /etc/ssh/sshd_config
RUN echo "#PasswordAuthentication yes " >> /etc/ssh/sshd_config
RUN echo "PermitEmptyPasswords no " >> /etc/ssh/sshd_config
RUN echo "ChallengeResponseAuthentication no " >> /etc/ssh/sshd_config
RUN echo "UsePAM yes " >> /etc/ssh/sshd_config
RUN echo "X11Forwarding yes "  >> /etc/ssh/sshd_config
RUN echo "PermitTTY yes " >> /etc/ssh/sshd_config
RUN echo "PrintMotd no" >> /etc/ssh/sshd_config
RUN echo "Banner /etc/ascii" >> /etc/ssh/sshd_config
RUN echo "AcceptEnv LANG LC_*" >> /etc/ssh/sshd_config
RUN echo "Subsystem	sftp	/usr/lib/openssh/sftp-server" >> /etc/ssh/sshd_config

# If you require zsh
RUN chsh -s /usr/bin/zsh
RUN cp /usr/share/blackarch/config/zsh/zshrc ~/.zshrc
RUN echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> ~/.zshrc
RUN ssh-keygen -A

RUN mkdir /root/.vnc && \
	echo "startlxde" > /root/.vnc/xstartup && \
	echo "killall Xvnc 2> /dev/null" > /usr/bin/startx && \
	echo "rm -rf /tmp/.* 2> /dev/null" >> /usr/bin/startx && \	
	echo "vncserver :0" >> /usr/bin/startx

RUN chmod +x /root/.vnc/xstartup /usr/bin/startx

ENV DISPLAY=:0

EXPOSE 22/tcp
EXPOSE 5900/tcp

CMD ["/usr/sbin/sshd","-D"]