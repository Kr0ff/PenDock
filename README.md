# Kali linux custom docker container
```bash
                                  ██╗  ██╗██╗  ██╗ █████╗ ██╗     ██╗
                                  ╚██╗██╔╝██║ ██╔╝██╔══██╗██║     ██║
                                   ╚███╔╝ █████╔╝ ███████║██║     ██║
                                   ██╔██╗ ██╔═██╗ ██╔══██║██║     ██║
                                  ██╔╝ ██╗██║  ██╗██║  ██║███████╗██║
                                  ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═╝
```
Custom Kali linux docker image allowing for GUI access over X2Go.

## 0x01 - Update:
There is now a script to use for building a Kali container image. It will now allow access to Kali over X11 using X2Go. Access to the container is achieved by using an SSH key due to X2Go requirements.

The script will use the "*Dockerfile.mod*
" file as a template to create a new "*Dockerfile*" and append the necessary details to it such as which kali metapackage to install and SSH key.

- <span style="color: yellow">WARNING</span>: The script uses sudo to run docker commands due to default linux installation not including the low-privileged user in the docker group.

Currently, the script will use 4 of the main metapackages that Kali has in its repository

- kali-linux-core (Takes up to ~2.2GB)
- kali-linux-default (Takes up to ~8.5GB)
- kali-linux-large (Takes up to ~12GB)
- kali-linux-everything (Takes up to ~19.5GB)

If you would like to make it so you have only individual packages that you need, you can simply edit the script, push a merge request with your Dockerfile and prefered packages or fork and create your own 🙂.
There are 2 bits you need to change if you're editing the script, the `SSH_PUBKEY` and `META_PACKAGE`. Simply replace with your changes and you're ready to build the image.

## 0x02 - How to build:

```bash
git clone https://github.com/Kr0ff/Kali_Docker
cd Kali_Docker && chmod +x build.sh
./build.sh
```
Then follow the on-screen instruction and you should be good to go. After successful deployment of the container you can check if the container has port 2222 on localhost directed to 22 on the container. 

Type in terminal:
```bash
docker container ls -a
```
Example output:
```bash
CONTAINER ID   IMAGE       COMMAND               CREATED        STATUS         PORTS                    NAMES
5f89dcd8b5b5   kalilinux   "/usr/sbin/sshd -D"   47 hours ago   Up 2 seconds   127.0.0.1:2222->22/tcp   kalilinux
```
## 0x03 - Connect via X2Go
GUI connection to the container is done very simply. After installing X2Go, open it and click on the button to create new connection.

![X2Go setup example](pictures/setup_x2go.png)

find out more: https://wiki.x2go.org/doku.php/doc:installation:x2goclient

In the new window, set up the field parameters, `Host` should be set as `127.0.0.1`(✅) instead of ~~`localhost`~~(❌). For some reason X2Go can't understand localhost as its domain alternative but whatever...
After everything is filled, press OK, then click on the new entry and your session should start.

![X2Go kali access example](pictures/access_kali.png)

### 0x031 Important about X2Go and desktop environment !

As of `v0.3`, the default desktop environment for the kali container will be LXDE. Due to high CPU usage problems with XFCE and black bars appearing around the desktop, XFCE has been replaced. 

If you want to use XFCE update the `Dockerfile.mod` file and replace the line `ARG KALI_DESKTOP=lxde` with the one you would like to use. 

Desktop environments are selected from the pre-built official Kali metapackages. This can be seen on line 23 of the `Dockerfile.mod` file where a desktop environment is selected to be installed. Therefore, you would need to choose a package that has the prefix of `kali-desktop-X` or just replace entirely with a package available in the repository.

## 0x04 - Tested on:

- MacOS Big Sur (11.1)
- Linux
