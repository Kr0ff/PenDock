#!/bin/bash

#### COLORS ####
RED="\e[0;91m"
GREEN="\e[0;92m"
BLUE="\e[0;94m"
YELLOW='\e[0;33m'
CYAN='\e[0;36m'
RESET="\e[0m"

DOCKER="`which docker` > 2>/dev/null"

printf "\nThis script will install KaliLinux in docker and provide
GUI access to it over SSH on port 2222 via X2GO...\n
More information about the program can be found here:
https://wiki.x2go.org/doku.php
\n
${YELLOW}                 WARNING !${RESET} 
You will be asked for your sudo password.
That's so docker can execyte the commands 
the script will execute.\n
Press enter key to continue"
read # Just wait for user input... :)

sleep 1

# Check if docker exists on system
if [[ -z ${DOCKER} ]]; then
	printf "${RED}[-] Docker is not found !${RESET}"
else
	printf "${GREEN}[+] Docker is installed !${RESET}\n"
fi

sleep 1

printf "${YELLOW}[!] SSH key is needed to use the GUI access to Kali due to X2GO requirements.${RESET}\n"
printf "${BLUE}[*] Do you want to generate an SSH key ?${RESET} [Y/n]: "
read SSHGEN_CHOICE
if [[ ( ${SSHGEN_CHOICE} = "" ) || ( ${SSHGEN_CHOICE} = "y" ) || ( ${SSHGEN_CHOICE} = "Y" ) || ( ${SSHGEN_CHOICE} = "Yes" ) || ( ${SSHGEN_CHOICE} = "yes" ) ]]; then
	printf "${BLUE}[*] What to name the SSH key ?${RESET} "
	read SSHF_NAME
	if [[ ${SSHF_NAME} == "" ]]; then
		printf "${RED}[-] SSH key name can't be empty !${RESET}"
		exit 1
	else
		`which ssh-keygen` -f ${SSHF_NAME}
		# Place the public key into "Dockerfile"
		`which cat` $(pwd)/Dockerfile.mod | `which sed` "s|SSH_PUBKEY|$(cat ${SSHF_NAME}.pub)|g" > Dockerfile
	fi
elif [[ ( ${SSHGEN_CHOICE} = "n" ) || ( ${SSHGEN_CHOICE} = 'N' ) || ( ${SSHGEN_CHOICE} = "no" ) || ( ${SSHGEN_CHOICE} = "No" ) ]]; then
	printf "\nYou will have to generate your SSH and add
it to the Dockerfile to enable SSH and GUI
to the Kali docker container. Otherwise,
you will have an alternative method.\n"
else
	printf "${RED}[-] Invalid choice !${RESET}\n"
	exit 1
fi

sleep 1

printf "\n${BLUE}[*] Which package of kali tools would you like to install ?${RESET}\n
1. kali-linux-default ${CYAN}(Takes up to ~8.5GB)${RESET}
2. kali-linux-large ${CYAN}(Takes up to ~12GB)${RESET}
3. kali-linux-everything ${CYAN}(Takes up to ~19.5GB)${RESET} 
\n
Enter choice as number. i.e 1
\n
Choice: "
read PACKAGE_CHOICE

if [[ ${PACKAGE_CHOICE} -eq 1 ]]; then
	printf "${YELLOW}[!] Going to install 'kali-linux-default'${RESET}\n"
	`which cat` $(pwd)/Dockerfile | `which sed` 's/META_PACKAGE/kali-linux-default/g' >> Dockerfile 
elif [[ ${PACKAGE_CHOICE} -eq 2 ]]; then
	printf "${YELLOW}[!] Going to install 'kali-linux-large'${RESET}\n"
	`which cat` $(pwd)/Dockerfile | `which sed` 's/META_PACKAGE/kali-linux-large/g' >> Dockerfile
elif [[ ${PACKAGE_CHOICE} -eq 3 ]]; then
	printf "${YELLOW}[!] Going to install 'kali-linux-everything'${RESET}\n"
	`which cat` $(pwd)/Dockerfile | `which sed` 's/META_PACKAGE/kali-linux-everything/g' >> Dockerfile
else
	printf "${RED}[-] Choice doesn't exist, try again.${RESET}\n"
	exit 1
fi

# Choose the name of the kali container
printf "${BLUE}[*] How would you like to name the container image ?:${RESET} "
read CI_NAME
if [[ ${CI_NAME} == "" ]]; then
	printf "${RED}[-] Container image name can't be empty !${RESET}\n"
	exit 1
else
	`which sudo` `which docker` build -t ${CI_NAME} $(pwd)/ # Install the kali container from the file 'Dockerfile'
fi

sleep 1

printf "\n${BLUE}[*] Do you want to start the container ?${RESET} [Y/n]: "
read START_CHOICE 
if [[ ( ${START_CHOICE} = "") || ( ${START_CHOICE} = "y" ) || ( ${START_CHOICE} = "Y" ) || ( ${START_CHOICE} = "Yes" ) || ( ${START_CHOICE} = "yes" ) ]]; then
	printf "${BLUE}[*] What would you like to name your container ?:${RESET} "
	read CONTAINER_NAME
	if [[ ${CONTAINER_NAME} == "" ]]; then
		printf "${RED}[-] Container name can't be empty !${RESET}\n"
		printf "You will have to start the container manually or\n"
		printf "run the script again with the same choices.\n"
		exit 1
	else
		`which sudo` `which docker` run -t -d --name ${CONTAINER_NAME} -p 127.0.0.1:2222:22/tcp ${CI_NAME}
		printf "${GREEN}[+] Container has been started. You can SSH on port 2222 localhost.${RESET}\n"
		exit 0
	fi

elif [[ ( ${START_CHOICE} = "n" ) || ( ${START_CHOICE} = 'N' ) || ( ${START_CHOICE} = "no" ) || ( ${START_CHOICE} = "No" ) ]]; then
	printf "${GREEN}[!] All should be good now, hopefully. Start the container manually.${RESET}\n"
	exit 0

else
	printf "${RED}[-] Invalid choice !${RESET}\n"
	exit 1
fi