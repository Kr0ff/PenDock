# From the Kali linux base image
FROM kalilinux/kali-rolling

# Update and apt install programs
RUN apt-get update && apt-get upgrade -y && apt-get dist-upgrade -y && apt-get install -y \
 exploitdb \
 vim \
 p7zip \
 exploitdb-bin-sploits \
 git \
 gdb \
 gobuster \
 hashcat \
 hydra \
 man-db \
 minicom \
 nasm \
 nmap \
 sqlmap \
 sslscan \
 wordlists \
 seclists \
 metasploit-framework \
 python \
 python3 \
 golang \
 python3-impacket \
 python3-pip \
 python-pip \
 iputils-arping \
 iputils-ping \
 iputils-tracepath \
 htop \
 commix \
 crackmapexec \
 crowbar \
 cupp \
# dirbuster \
# dnsutil \
 dnsenum \
 dnsmap \
 dnschef \
 masscan \
 enum4linux \
 evil-ssdp \
 ftp \
 hping3 \
 iodine \
 kali-tools-windows-resources \
 knockd \
 knocker \
 nbtscan-unixwiz \
 ncat \
 nishang \
 onesixtyone \
 openvpn \
 p0f \
 powercat \
 powersploit \
 powershell-empire \
 proxychains \
 set \
 smbmap \
 snmp \
# snort \
 tcpdump \
 telnet \
 tftp \
 unicornscan \
 wfuzz \
# yersenia \
 zaproxy

# Create known_hosts for git cloning
RUN mkdir -p /root/.ssh

# Other installs
RUN pip install pwntools
RUN pip install impacket

# Set entrypoint and working directory
WORKDIR /root/

# Indicate we want to expose ports 80 and 443
#EXPOSE 80/tcp 443/tcp <--- uncomment and adjust to your needs...
