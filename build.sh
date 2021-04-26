#!/bin/bash

# Rev: 0.2 - Minor changes + new package added in choices
# Rev: 0.3 - Changes to desktop environment.. XFCE -> LXDE 

#### COLORS ####
RED="\e[0;91m"
GREEN="\e[0;92m"
BLUE="\e[0;94m"
YELLOW='\e[0;33m'
CYAN='\e[0;36m'
WHITE='\e[0;97m'
RESET="\e[0m"

#### ASCII ####
ASCII="
    ${WHITE}@@@  @@@${RESET}${BLUE} @@@  @@@  @@@@@@  @@@      @@@${RESET}
    ${WHITE}@@!  !@@${RESET}${BLUE} @@!  !@@ @@!  @@@ @@!      @@!${RESET}
    ${WHITE} !@@!@!${RESET}${BLUE}  @!@@!@!  @!@!@!@! @!!      !!@${RESET}
    ${WHITE} !: :!!${RESET}${BLUE}  !!: :!!  !!:  !!! !!:      !!:${RESET}
    ${WHITE}:::  :::${RESET}${BLUE}  :   :::  :   : : : ::.: : :  ${RESET}
				       ${WHITE}v0.3${RESET}
"

DOCKER="`which docker` > 2>/dev/null"
printf "${ASCII}\n"
printf "\nThis script will install Kali linux in Docker and provide
GUI access to it over SSH on port 2222 via X2GO...\n
More information about the program can be found here:
https://wiki.x2go.org/doku.php
\n
                ${RED}!${RESET}${YELLOW}[WARNING]${RESET}${RED}!${RESET}
 You will be asked for your sudo password.
 That's so Docker can execute the commands
	   the script will use.\n
       Press enter key to continue\n"
read # Just wait for user input... :)

sleep 1

# Check if docker exists on system
if [[ -z ${DOCKER} ]]; then
	printf "${RED}[-]${RESET} Docker is not found !"

else
	printf "${GREEN}[+]${RESET} Docker is installed !\n"
fi

sleep 1

printf "${YELLOW}[!]${RESET} SSH key is needed to use the GUI access to Kali due to X2GO requirements.\n"
printf "${BLUE}[*]${RESET} Do you want to generate an SSH key ? [Y/n]: "
read SSHGEN_CHOICE

if [[ ( ${SSHGEN_CHOICE} = "" ) || ( ${SSHGEN_CHOICE} = "y" ) || ( ${SSHGEN_CHOICE} = "Y" ) || ( ${SSHGEN_CHOICE} = "Yes" ) || ( ${SSHGEN_CHOICE} = "yes" ) ]]; then
	printf "${BLUE}[*]${RESET} What to name the SSH key ? "
	read SSHF_NAME

	if [[ ${SSHF_NAME} == "" ]]; then
		printf "${RED}[-]${RESET} SSH key name can't be empty !"
		exit 1

	else
		`which ssh-keygen` -f ${SSHF_NAME}
		# Place the public key into "Dockerfile"
		`which cat` $(pwd)/Dockerfile.mod | `which sed` "s|SSH_PUBKEY|$(cat ${SSHF_NAME}.pub)|g" > Dockerfile
	fi

elif [[ ( ${SSHGEN_CHOICE} = "n" ) || ( ${SSHGEN_CHOICE} = 'N' ) || ( ${SSHGEN_CHOICE} = "no" ) || ( ${SSHGEN_CHOICE} = "No" ) ]]; then
	printf "\nYou will have to generate your SSH key and add
it to the Dockerfile to enable SSH and GUI
to the Kali docker container. Then rerun docker build command
manually. Otherwise, you will have to use an alternative method.\n"

else
	printf "${RED}[-]${RESET} Invalid choice !\n"
	exit 1
fi

sleep 1

printf "\n${BLUE}[*]${RESET} Which package of kali tools would you like to install ?\n
1. kali-linux-core ${CYAN}(Takes up to ~2.2Gb)${RESET}
2. kali-linux-default ${CYAN}(Takes up to ~8.5GB)${RESET}
3. kali-linux-large ${CYAN}(Takes up to ~12GB)${RESET}
4. kali-linux-everything ${CYAN}(Takes up to ~19.5GB)${RESET}
\n
Enter choice as number. i.e 1
\n
Choice: "
read PACKAGE_CHOICE

if [[ ${PACKAGE_CHOICE} -eq 1 ]]; then
    printf "${YELLOW}[!]${RESET} Going to install just the core package of KaliLinux...\n"
    `which cat` $(pwd)/Dockerfile | `which sed` 's/META_PACKAGE/kali-linux-core/g' >> Dockerfile

elif [[ ${PACKAGE_CHOICE} -eq 2 ]]; then
	printf "${YELLOW}[!]${RESET} Going to install 'kali-linux-default'\n"
	`which cat` $(pwd)/Dockerfile | `which sed` 's/META_PACKAGE/kali-linux-default/g' >> Dockerfile

elif [[ ${PACKAGE_CHOICE} -eq 3 ]]; then
	printf "${YELLOW}[!]${RESET} Going to install 'kali-linux-large'\n"
	`which cat` $(pwd)/Dockerfile | `which sed` 's/META_PACKAGE/kali-linux-large/g' >> Dockerfile

elif [[ ${PACKAGE_CHOICE} -eq 4 ]]; then
	printf "${YELLOW}[!]${RESET} Going to install 'kali-linux-everything'\n"
	`which cat` $(pwd)/Dockerfile | `which sed` 's/META_PACKAGE/kali-linux-everything/g' >> Dockerfile

else
	printf "${RED}[-]${RESET} Choice doesn't exist, try again.\n"
	exit 1
fi

# Choose the name of the kali container
printf "${BLUE}[*]${RESET} How would you like to name the container image ?: "
read CI_NAME

if [[ ${CI_NAME} == "" ]]; then
	printf "${RED}[-]${RESET} Container image name can't be empty !\n"
	exit 1

else
    `which sudo` `which docker` build -t ${CI_NAME} $(pwd)/ # Install the kali container from the file 'Dockerfile'
fi

sleep 1

printf "\n${BLUE}[*]${RESET} Do you want to start the container ? [Y/n]: "
read START_CHOICE
if [[ ( ${START_CHOICE} = "") || ( ${START_CHOICE} = "y" ) || ( ${START_CHOICE} = "Y" ) || ( ${START_CHOICE} = "Yes" ) || ( ${START_CHOICE} = "yes" ) ]]; then
	
	printf "${BLUE}[*]${RESET} Would you like to add any shared directories ? [Y/n]: "
	read SHARED_DIRS_CHOICE

	if [[ ( ${SHARED_DIRS_CHOICE} = "") || ( ${SHARED_DIRS_CHOICE} = "y" ) || ( ${SHARED_DIRS_CHOICE} = "Y" ) || ( ${SHARED_DIRS_CHOICE} = "Yes" ) || ( ${SHARED_DIRS_CHOICE} = "yes" ) ]]; then
		
		printf "${YELLOW}What directories would you like to share ?${RESET}\n"
		printf "Example: /home/user1/Desktop:/shared\n"
		printf "Input: "
		read SHARED_DIRS
		
		if [[ ${SHARED_DIRS} == "" ]]; then
			printf "${YELLOW}[!]${RESET} No shared directories chosen !\n"
		else	
			DIRS_TO_SHARE="-v ${SHARED_DIRS}"
		fi
		
	elif [[ ( ${SHARED_DIRS_CHOICE} = "n" ) || ( ${SHARED_DIRS_CHOICE} = 'N' ) || ( ${SHARED_DIRS_CHOICE} = "no" ) || ( ${SHARED_DIRS_CHOICE} = "No" ) ]]; then
		printf "${YELLOW}[!]${RESET} No shared directories will be added !\n"
	fi

	printf "${BLUE}[*]${RESET} What would you like to name your container ?: "
	read CONTAINER_NAME
	
	if [[ ${CONTAINER_NAME} == "" ]]; then
		printf "${RED}[-]${RESET} Container name can't be empty !\n"
		printf "You will have to start the container manually or\n"
		printf "run the script again with the same choices.\n"
		exit 1
	
	else
        `which sudo` `which docker` run -t -d ${DIRS_TO_SHARE} --name ${CONTAINER_NAME} -p 127.0.0.1:2222:22/tcp ${CI_NAME}
		printf "${GREEN}[+]${RESET} Container has been started. You can SSH on port 2222 localhost.\n"
		exit 0
	fi

elif [[ ( ${START_CHOICE} = "n" ) || ( ${START_CHOICE} = 'N' ) || ( ${START_CHOICE} = "no" ) || ( ${START_CHOICE} = "No" ) ]]; then
	printf "${GREEN}[!]${RESET} All should be good now, hopefully. Start the container manually.\n"
	exit 0

else
	printf "${RED}[-]${RESET} Invalid choice !\n"
	exit 1
fi
