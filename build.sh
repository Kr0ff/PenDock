#!/bin/bash

# Rev: 0.2 - Minor changes + new package added in choices
# Rev: 0.3 - Changes to desktop environment.. XFCE -> LXDE
# Rev: 0.4 - Add support for Blackarch container deployment 

#### COLORS ####
RED="\e[0;91m"
GREEN="\e[1;92m"
BLUE="\e[1;94m"
YELLOW="\e[1;33m"
CYAN="\e[0;36m"
PURPLE="\e[0;35m"
WHITE="\e[0;97m"
RESET="\e[0m"

#### ASCII ####
ASCII="
    ${RED} _____        ${RESET}${PURPLE} ____          _   ${RESET}
    ${RED}|  _  |___ ___${RESET}${PURPLE}|    \ ___ ___| |_ ${RESET}
    ${RED}|   __| -_|   ${RESET}${PURPLE}|  |  | . |  _| '_|${RESET}
    ${RED}|__|  |___|_|_${RESET}${PURPLE}|____/|___|___|_,_|${RESET}
				 v0.4
"

DOCKER="`which docker`"
VNCPASSWD="`which vncpasswd`"
BLACKARCH_FOLDER="`pwd`/blackarch"
KALI_FOLDER="`pwd`/kali"

printf "${ASCII}\n"
printf "\nThis script will install ${BLUE}Kali Linux${RESET} or ${CYAN}Blackarch${RESET}
in Docker and provide GUI access via X2GO or VNC...\n
More information about the program can be found here:
https://wiki.x2go.org/doku.php
\n
              ${RED}!${RESET}${YELLOW}[WARNING]${RESET}${RED}!${RESET}
 You will be asked for your sudo password.
 That's so Docker can execute the commands
	  the script will use.\n
      Press enter key to continue\n"
read # Just wait for user input... :)

sleep 0.5

# Check if docker exists on system
if [[ -z ${DOCKER} ]]; then
	printf "${RED}[-]${RESET} Docker is not installed !\n"
	exit 1
else
	printf "${GREEN}[+]${RESET} Docker is installed !\n"
fi

sleep 0.5

###############################################
# Delete created [{kali,barch}.mod2] files ####
###############################################
function del_mod2files {
	printf "${YELLOW}[!]${RESET} Deleting unecessary files after build..\n"
	printf "${BLUE}[*]${RESET} Files:\n"
	printf "----------------------------\n"
	printf "Dockerfile.barch.mod2\n"
	printf "Dockerfile.kali.mod2\n"
	printf "----------------------------\n"

	`which rm` ${BLACKARCH_FOLDER}/Dockerfile.barch.mod2
	`which rm` ${KALI_FOLDER}/Dockerfile.kali.mod2
}

#########################################
# Start building Blackarch container ####
#########################################
function build_blackarch {
	printf "${GREEN}[+]${RESET} Starting ${CYAN}Blackarch${RESET} Linux Docker build !\n"
	sleep 1

	printf "${YELLOW}[!]${RESET} SSH key is needed to access the container !\n"
	printf "${BLUE}[*]${RESET} Do you want to generate an SSH key ? [Y/n]: "
	read SSHGEN_CHOICE

	if [[ ( ${SSHGEN_CHOICE} = "" ) || ( ${SSHGEN_CHOICE} = "y" ) || ( ${SSHGEN_CHOICE} = "Y" ) || ( ${SSHGEN_CHOICE} = "Yes" ) || ( ${SSHGEN_CHOICE} = "yes" ) ]]; then
		printf "${BLUE}[*]${RESET} What to name the SSH key ? "
		read SSHF_NAME

		if [[ ${SSHF_NAME} == "" ]]; then
			printf "${RED}[-]${RESET} SSH key name can't be empty !\n"
			exit 1

		else
			`which ssh-keygen` -f ${BLACKARCH_FOLDER}/${SSHF_NAME}
			# Place the public key into "Dockerfile" for Blackarch container
			`which cat` ${BLACKARCH_FOLDER}/Dockerfile.barch.mod | `which sed` "s|SSH_PUBKEY|$(cat ${BLACKARCH_FOLDER}/${SSHF_NAME}.pub)|g" > ${BLACKARCH_FOLDER}/Dockerfile.barch.mod2
		fi

	elif [[ ( ${SSHGEN_CHOICE} = "n" ) || ( ${SSHGEN_CHOICE} = 'N' ) || ( ${SSHGEN_CHOICE} = "no" ) || ( ${SSHGEN_CHOICE} = "No" ) ]]; then
		printf "\n
${YELLOW}[!]${RESET} NOTE:

You will have to generate your SSH key and 
add it to the ${CYAN}Blackarch${RESET} Dockerfile to enable SSH and GUI
to the Kali docker container. Then rerun docker build command
manually. Otherwise, you will have to use an alternative method.

Press enter key to continue\n
"
	read

	else
		printf "${RED}[-]${RESET} Invalid choice !\n"
		exit 1
	fi

	sleep 1

	printf "\n${BLUE}[*]${RESET} Which package of ${CYAN}Blackarch${RESET} tools would you like to install ?\n
1. blackarch-core ${CYAN}(Takes up to ~1.67GB)${RESET}\n
Enter choice as number. i.e 1\n
Choice: "
	read PACKAGE_CHOICE

	if [[ ${PACKAGE_CHOICE} -eq 1 ]]; then
		printf "${YELLOW}[!]${RESET} Going to install just the core package of Blackarch...\n"
		`which cat` ${BLACKARCH_FOLDER}/Dockerfile.barch.mod2 | `which sed` 's/META_PACKAGE//g' >> ${BLACKARCH_FOLDER}/Dockerfile

	else
		printf "${RED}[-]${RESET} Choice doesn't exist, try again.\n"
		exit 1
	fi

	# Check if vncpasswd exists on system
	# Needed for Xvnc and passwd file generation for Blackarch
	printf "${YELLOW}[!]${RESET} Checking if 'vncpasswd' exists !\n"
	sleep 0.5
	
	if [[ -z ${VNCPASSWD} ]]; then
		printf "${RED}[-]${RESET} Couldn't find 'vncpasswd' !\n"
		sleep 0.5

	else
		printf "${GREEN}[+]${RESET} Found 'vncpasswd' !\n"
		printf "${BLUE}[*]${RESET} Do you want to generate a VNC passwd file ? [Y/n]: "
		read VNC_CHOICE

		if [[ ( ${VNC_CHOICE} = "") || ( ${VNC_CHOICE} = "y" ) || ( ${VNC_CHOICE} = "Y" ) || ( ${VNC_CHOICE} = "Yes" ) || ( ${VNC_CHOICE} = "yes" ) ]]; then
			`which vncpasswd`
			`which cp` ~/.vnc/passwd ${BLACKARCH_FOLDER}
			printf "${GREEN}[+]${RESET} VNC passwd file generated !\n"
			printf "${GREEN}[+]${RESET} VNC passwd file will be added to the Blackarch container !\n"
			`echo "ADD 'passwd' '/root/.vnc/passwd'" >> ${BLACKARCH_FOLDER}/Dockerfile`

		elif [[ ( ${VNC_CHOICE} = "n" ) || ( ${VNC_CHOICE} = 'N' ) || ( ${VNC_CHOICE} = "no" ) || ( ${VNC_CHOICE} = "No" ) ]]; then
			printf "${YELLOW}[!]${RESET} VNC passwd file will not be generated !\n"
		
		else
			printf "${RED}[-]${RESET} Invalid choice !\n"
			exit 1
			
		fi
	
	fi

	# Choose the name of the Blackarch container
	printf "${BLUE}[*]${RESET} How would you like to name the container image ?: "
	read CI_NAME

	if [[ ${CI_NAME} == "" ]]; then
		printf "${RED}[-]${RESET} Container image name can't be empty !\n"
		exit 1

	else
		# Install the kali container from the file 'Dockerfile'
		`which sudo` `which docker` build -t ${CI_NAME} ${BLACKARCH_FOLDER}/.
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
		
		else # For Blackarch listen on 2223 and VNC on 5900
			`which sudo` `which docker` run -t -d ${DIRS_TO_SHARE} \
			--name ${CONTAINER_NAME} \
			-p 127.0.0.1:2223:22/tcp \
			-p 127.0.0.1:5900:5900/tcp \
			${CI_NAME}
			
			printf "${GREEN}[+]${RESET} ${CYAN}Blackarch${RESET} container has been started. You can SSH on port 2223 localhost.\n"
			printf "${GREEN}[+]${RESET} For VNC access, log in to the container over SSH, run 'vncpasswd' then type 'nohup startx &'"
			del_mod2files
			
			exit 0
		fi

	elif [[ ( ${START_CHOICE} = "n" ) || ( ${START_CHOICE} = 'N' ) || ( ${START_CHOICE} = "no" ) || ( ${START_CHOICE} = "No" ) ]]; then
		printf "${YELLOW}[!]${RESET} All should be good now, hopefully. Start the ${CYAN}Blackarch${RESET} container manually.\n"
		del_mod2files
		exit 0

	else
		printf "${RED}[-]${RESET} Invalid choice !\n"
		exit 1
	fi
}

#########################################
# Start building Kali Linux container ###
#########################################
function build_kali {
	printf "${GREEN}[+]${RESET} Starting ${BLUE}Kali Linux${RESET} Docker build !\n"
	sleep 1

	printf "${YELLOW}[!]${RESET} SSH key is needed to use the GUI access to ${BLUE}Kali Linux${RESET} due to X2GO requirements.\n"
	printf "${BLUE}[*]${RESET} Do you want to generate an SSH key ? [Y/n]: "
	read SSHGEN_CHOICE

	if [[ ( ${SSHGEN_CHOICE} = "" ) || ( ${SSHGEN_CHOICE} = "y" ) || ( ${SSHGEN_CHOICE} = "Y" ) || ( ${SSHGEN_CHOICE} = "Yes" ) || ( ${SSHGEN_CHOICE} = "yes" ) ]]; then
		printf "${BLUE}[*]${RESET} What to name the SSH key ? "
		read SSHF_NAME

		if [[ ${SSHF_NAME} == "" ]]; then
			printf "${RED}[-]${RESET} SSH key name can't be empty !\n"
			exit 1

		else
			`which ssh-keygen` -f ${KALI_FOLDER}/${SSHF_NAME}
			# Place the public key into "Dockerfile" for Kali Linux
			`which cat` ${KALI_FOLDER}/Dockerfile.kali.mod | `which sed` "s|SSH_PUBKEY|$(cat ${KALI_FOLDER}/${SSHF_NAME}.pub)|g" > ${KALI_FOLDER}/Dockerfile.kali.mod2
		fi

	elif [[ ( ${SSHGEN_CHOICE} = "n" ) || ( ${SSHGEN_CHOICE} = 'N' ) || ( ${SSHGEN_CHOICE} = "no" ) || ( ${SSHGEN_CHOICE} = "No" ) ]]; then
		printf "\n
${YELLOW}[!]${RESET} NOTE:

You will have to generate your SSH key and 
add it to the ${BLUE}Kali Linux${RESET} Dockerfile to enable SSH and GUI
to the Kali docker container. Then rerun docker build command
manually. Otherwise, you will have to use an alternative method.

Press enter key to continue\n
"
	read 
	else
		printf "${RED}[-]${RESET} Invalid choice !\n"
		exit 1
	fi

	sleep 1

	printf "\n${BLUE}[*]${RESET} Which package of ${BLUE}Kali Linux${RESET} tools would you like to install ?\n
1. kali-linux-core ${CYAN}(Takes up to ~2.2Gb)${RESET}
2. kali-linux-default ${CYAN}(Takes up to ~8.5GB)${RESET}
3. kali-linux-large ${CYAN}(Takes up to ~12GB)${RESET}
4. kali-linux-everything ${CYAN}(Takes up to ~19.5GB)${RESET}\n
Enter choice as number. i.e 1\n
Choice: "
	read PACKAGE_CHOICE

	if [[ ${PACKAGE_CHOICE} -eq 1 ]]; then
		printf "${YELLOW}[!]${RESET} Going to install just the core package of ${BLUE}Kali Linux${RESET}...\n"
		`which cat` ${KALI_FOLDER}/Dockerfile.kali.mod2 | `which sed` 's/META_PACKAGE/kali-linux-core/g' >> ${KALI_FOLDER}/Dockerfile

	elif [[ ${PACKAGE_CHOICE} -eq 2 ]]; then
		printf "${YELLOW}[!]${RESET} Going to install 'kali-linux-default'\n"
		`which cat` ${KALI_FOLDER}/Dockerfile.kali.mod2 | `which sed` 's/META_PACKAGE/kali-linux-default/g' >> ${KALI_FOLDER}/Dockerfile

	elif [[ ${PACKAGE_CHOICE} -eq 3 ]]; then
		printf "${YELLOW}[!]${RESET} Going to install 'kali-linux-large'\n"
		`which cat` ${KALI_FOLDER}/Dockerfile.kali.mod2 | `which sed` 's/META_PACKAGE/kali-linux-large/g' >> ${KALI_FOLDER}/Dockerfile

	elif [[ ${PACKAGE_CHOICE} -eq 4 ]]; then
		printf "${YELLOW}[!]${RESET} Going to install 'kali-linux-everything'\n"
		`which cat` ${KALI_FOLDER}/Dockerfile.kali.mod2 | `which sed` 's/META_PACKAGE/kali-linux-everything/g' >> ${KALI_FOLDER}/Dockerfile

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
		# Install the Kali Linux container from the file 'Dockerfile'
		`which sudo` `which docker` build -t ${CI_NAME} ${KALI_FOLDER}/.
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
			`which sudo` `which docker` run -t -d ${DIRS_TO_SHARE} \
			--name ${CONTAINER_NAME} \
			-p 127.0.0.1:2222:22/tcp \
			${CI_NAME}
			
			printf "${GREEN}[+]${RESET} ${BLUE}Kali Linux${RESET} container has been started. You can SSH on port 2222 localhost.\n"
			del_mod2files
			exit 0
		fi

	elif [[ ( ${START_CHOICE} = "n" ) || ( ${START_CHOICE} = 'N' ) || ( ${START_CHOICE} = "no" ) || ( ${START_CHOICE} = "No" ) ]]; then
		printf "${YELLOW}[!]${RESET} All should be good now, hopefully. Start the ${BLUE}Kali Linux${RESET} container manually.\n"
		del_mod2files
		exit 0

	else
		printf "${RED}[-]${RESET} Invalid choice !\n"
		exit 1
	fi
}

function main {

	printf "\n${BLUE}[*]${RESET} Which distribution to build ?\n
1. ${BLUE}Kali Linux${RESET}
2. ${CYAN}Blackarch${RESET}\n
Enter choice as number. i.e 1\n
Choice: "
	
	read DISTRO_CHOICE

	if [[ ${DISTRO_CHOICE} -eq 1 ]]; then
		build_kali

	elif [[ ${DISTRO_CHOICE} -eq 2 ]]; then
		build_blackarch

	else
		printf "${RED}[-]${RESET} Choice doesn't exist, try again.\n"
		exit 1
	fi

}

main
