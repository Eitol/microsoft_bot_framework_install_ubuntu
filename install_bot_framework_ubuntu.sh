############### CONFIG #########
GITHUB_REPO_URL=https://github.com/microsoft/BotFramework-Emulator
NODE_VERSION=12
FILE_TYPE=linux-x86_64.AppImage
INSTALLATION_DIR=/opt/microsoft/bot_framework
NODE_BIN=/usr/bin/node
VERSION=latest  # for specific version use for example: v4.4.2
################################

get_version(){
   if [ ${VERSION} == "latest" ]; then
	   CHECK_LATEST_VERSION_URL=${GITHUB_REPO_URL}/releases/${VERSION}
	   curl -sq ${CHECK_LATEST_VERSION_URL} | \
	   grep -Po "tag\/.*\">" | \
	   grep -Po "v.*\"" |      \
	   sed -n "s/\"//p" |      \
	   sed -n "s/v//p"
   else
      checked_version=${GITHUB_REPO_URL}/releases/tag/${VERSION}          
      if [ ${checked_version} == "Not Found" ]; then
          echo "Invalid bot framework version: \"${VERSION}\"" 
          exit 1
      fi
   fi
}

############### RUN CONFIG #########
VERSION=$(get_version)
EXECUTABLE_NAME=BotFramework-Emulator-${VERSION}-${FILE_TYPE}
####################################

program_is_installed() {
  # set to 1 initially
  local return_=1
  # set to 0 if not found
  type $1 >/dev/null 2>&1 || { local return_=0; }
  # return value
  echo "$return_"
}

check_if_fail(){
   if [ $? -eq 0 ]; then
      echo OK
   else
      echo FAIL
      exit 1
   fi
}

install_deps(){
   echo "################# Installing deps  ###########"
   sudo apt-get -y install curl gcc g++ make libsecret-1-dev wget 
}

install_node(){
   if [ $(program_is_installed node) == "1" ];  then
      echo "node is installed, skipping..."
   else
      echo "################# Installing NODE   ############"
      curl -sL https://deb.nodesource.com/setup_${NODE_VERSION}.x | sudo -E bash -
      sudo apt-get -y install nodejs	
      node -v
   fi
}

create_installation_dir(){
   if [ -d "${INSTALLATION_DIR}" ]; then
      echo "The installation directory already exist"
   else
      sudo mkdir -p ${INSTALLATION_DIR} 
   fi
}

download_bot_framework(){   
   cd ${INSTALLATION_DIR}
   echo "Download bot framework v${VERSION}"
   if [ -f "${EXECUTABLE_NAME}" ]; then
     echo "${EXECUTABLE_NAME} already downloaded"
   else
     echo "URL: ${GITHUB_REPO_URL}/releases/download/v${VERSION}/${EXECUTABLE_NAME}"
     sudo wget  ${GITHUB_REPO_URL}/releases/download/v${VERSION}/${EXECUTABLE_NAME}
     sudo chmod +x ${EXECUTABLE_NAME}
   fi
}

install_bot_framework(){
     cd ${INSTALLATION_DIR}
     echo "Running the installer"
     ${INSTALLATION_DIR}/${EXECUTABLE_NAME}
}


############ RUNNING ################
echo "Installing the bot framework \"${VERSION}\""
install_deps
check_if_fail
install_node
check_if_fail
create_installation_dir
check_if_fail
download_bot_framework
check_if_fail
install_bot_framework
check_if_fail
