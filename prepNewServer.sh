#!/bin/bash


# function to log text 
log() {
   # Receive the "level" value
   level=$1
   # format the time stamp
   curDate=$(date +%Y-%M-%d_%H.%m.%S)
   # join timestamp and message
   msg="${curDate} ${2}"
   # Define some colors
   redOn="\033[31m"
   greenOn="\033[32m"
   yellowOn="\033[33m"
   whiteOn="\033[37m"
   colorOff="\033[0m"

# select the color based on the "level" received
   case ${level} in
  1)
    msgFormated="${whiteOn}${msg}${colorOff}"
    ;;
  2)
    msgFormated="${yellowOn}${msg}${colorOff}"
    ;;
  3)
    msgFormated="${redOn}${msg}${colorOff}"
    ;;
  *)
    msgFormated="${greenOn}${msg}${colorOff}"
    ;;
esac

# Print message with the correct color
echo -e ${msgFormated}
}
newBlock() {
#!!!Detect the column number and print the same number of characters!!!
printf "#============================================================#\n"
}
#========================================================

createUsers() {
# Create a new user "john" with the following parameters:
# -m: create a home directory for the user
# -s /bin/bash: set the default shell to bash
# -g users: add the user to the "users" group
# -G sudo,audio,video,cdrom,plugdev,lpadmin,sambashare: add the user to the specified supplementary groups
# -c "John Doe": set the GECOS field to "John Doe"
# -M: do not create a new entry in the /etc/motd file
# -k /etc/skel: use the default skeleton directory for the user's home directory
# -r: create a system account
for USER in "$@"; do 
# Test if the user "john" exists
if id -u $USER > /dev/null 2>&1; then
  log "3" "User $USER already exists"
else

log "1" "Creating user $USER"
groups="users"
useradd -m -s /bin/bash -g users -G ${groups} -c "Support user - INFRA"  -k /etc/skel -r $USER
log "1" "Set password for $USER"
password=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
echo "${USER}:${password}" | chpasswd
log "3" "Password for $USER is: ${password}"


# Test if docker
if dpkg -s docker-ce &> /dev/null; then 
  log "1" "Docker present, adding user to docker group";
  usermod -a -G docker $USER
fi
log "1" "test user creation"
#!!! create function to test if user created or not!!!
getent passwd $USER
fi
done
}

#========================================================
installDocker() {
# Test if docker is installed
if dpkg -s docker-ce &> /dev/null; then 
  log "3" "Docker already installed, skiping"
else
apt -y update
apt install -y  apt-transport-https ca-certificates curl gnupg2 software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg |  apt-key add -
add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable"
apt -y update
apt-cache policy docker-ce
apt install -y docker-ce
fi
}
#========================================================
installPackages() {
if [ "$linux_distro" == "debian" ] || [ "$linux_distro" == "Debian" ]; then  
echo "Se va a instalar todo esto: $@"
  for package in $@; do 
   echo "instalando $package"
    apt install -y $package &> /dev/null
      if dpkg -s $package &> /dev/null; then 
        log "1" "$package INSTALLED";
      else
        log  "3" "$package NOT INSTALLED";
      fi
  done
fi
}
#========================================================
#========================================================
#========================================================
#========================================================




#==========================================================================
#=============================== CALL FUNCTIONS ============================
#==========================================================================
newBlock #Insert spacer
# Create users?
if [ -n "$createUsers" ]; then
createUsers "$createUsers"
else 
  log "2"  "No user creation needed."
fi

newBlock #Insert spacer
# Install docker?
if [ -n "$needDocker" ]; then
  log "1" "Docker needed, installing..."
  # Get the Linux distribution using the `lsb_release` command
  linux_distro=$(lsb_release -i -s)
  # Print the Linux distribution to the console
  log "1" "Linux distribution: $linux_distro"
   # test if supported linux distro
  if [ "$linux_distro" == "debian" ] || [ "$linux_distro" == "Debian" ]; then  
    log "1" "Debian detected, we can continue..."
    log "3" "we?..I'm alone here... "
    log "100" "oh!! I'm with you!!";
    log "1" "ok, sorry... installing Docker"   
    # invoking the function to install docker
    installDocker
  fi
else
  log "2" "Docker not needed."
fi
newBlock #Insert spacer

# Install software
if [ -n "$installPackages" ]; then
installPackages "$installPackages"
else
log "2" "No package installation needed."
fi
newBlock #Insert spacer
