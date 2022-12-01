#!/bin/bash

unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    CYGWIN*)    machine=Cygwin;;
    MINGW*)     machine=MinGw;;
    *)          machine="UNKNOWN:${unameOut}"
esac

export JAVA_ARGS="-XX:+UseG1GC -XX:+ParallelRefProcEnabled -XX:MaxGCPauseMillis=200 -XX:+UnlockExperimentalVMOptions -XX:+DisableExplicitGC -XX:+AlwaysPreTouch -XX:G1NewSizePercent=30 -XX:G1MaxNewSizePercent=40 -XX:G1HeapRegionSize=8M -XX:G1ReservePercent=20 -XX:G1HeapWastePercent=5 -XX:G1MixedGCCountTarget=4 -XX:InitiatingHeapOccupancyPercent=15 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:SurvivorRatio=32 -XX:+PerfDisableSharedMem -XX:MaxTenuringThreshold=1 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true -Dfml.readTimeout=180 -Dfml.queryResult=confirm"

export MCVER="1.19.2"
export FORGEVER="43.1.57"
export MAX_RAM="${RAM:-5G}"

sync_jars() {
	echo ""
	echo ""
	echo "Starting mods sync"
	java -jar InstanceSync.jar
}

install_server(){
	echo "Starting install of Forge/Minecraft server binaries"
	echo "DEBUG: Starting install of Forge/Minecraft server binaries"
	export URL="https://maven.minecraftforge.net/net/minecraftforge/forge/${MCVER}-${FORGEVER}/forge-${MCVER}-${FORGEVER}-installer.jar"
	echo $URL
	which wget >> /dev/null
	if [ $? -eq 0 ]; then
		echo "DEBUG: (wget) Downloading ${URL}"
		wget -O installer.jar "${URL}"
	else
		which curl >> /dev/null
		if [ $? -eq 0 ]; then
			echo "DEBUG: (curl) Downloading ${URL}"
			curl -o installer.jar "${URL}"
		else
			echo "Neither wget or curl were found on your system. Please install one and try again"
			echo "ERROR: Neither wget or curl were found"
		fi
	fi

	if [ ! -f installer.jar ]; then
		echo "Forge installer did not download"
		echo "ERROR: Forge installer did not download"
		exit 0
	else
		echo "Moving unneeded files/folders to ./DELETEME"
		echo "INFO: Moving unneeded files/folders to ./DELETEME"
		rm -rf ./DELETEME
		mv -f ./asm ./DELETEME
		mv -f ./libraries ./DELETEME
		mv -f ./llibrary ./DELETEME
		mv -f ./minecraft_server*.jar ./DELETEME
		mv -f ./forge*.jar ./DELETEME
		mv -f ./OpenComputersMod*lua* ./DELETEME
		echo "Installing Forge Server, please wait..."
		echo "INFO: Installing Forge Server"
		java -jar installer.jar --installServer
		echo "Deleting Forge installer (no longer needed)"
		echo "INFO: Deleting installer.jar"
		rm -rf installer.jar
		echo "INFO: Write Forge Version file"
		touch ./minecraft-${MCVER}-${FORGEVER}
	fi
}

check_binaries(){
	if [ ! -f ./minecraft-${MCVER}-${FORGEVER} ] ; then
		echo "WARN: minecraft-${MCVER}-${FORGEVER} not found"
		echo "Required files not found, need to install Forge"
		install_server
	fi
	if [ ! -d ./libraries ] ; then
		echo "WARN: library directory not found"
		echo "Required files not found, need to install Forge"
		install_server
	fi
}

remove_client_mods() {
	echo ""
	echo ""
	echo "Remove clients mods"
	allClientMods=("Ding" "ReAuth" "moreoverlays" "Neat" "ToastControl" "PackMenu" "CustomWindowTitle" "BetterF3" "MouseTweaks" "LegendaryTooltips" "oculus" "rubidium")
	for f in ${allClientMods[@]}; do
        rm /minecraft-server/mods/${f}*.jar
		rm ./mods/${f}*.jar
    done
}

start_server() {
	echo ""
	echo ""
	echo "Starting server"
	echo "INFO: Starting Server at " $(date -u +%Y-%m-%d_%H:%M:%S)
	java -Xmx${MAX_RAM} ${JAVA_ARGS} @user_jvm_args.txt @libraries/net/minecraftforge/forge/${MCVER}-${FORGEVER}/unix_args.txt nogui "$@"
}

eula(){
	if [ ! -f eula.txt ]; then
		echo "Could not find eula.txt starting server to generate it"
		echo "eula=true" >> /minecraft-server/eula.txt
		echo "eula=true" >> ./eula.txt
		echo ""
	else
		if grep -Fxq "eula=false" eula.txt; then
			echo "Could not find 'eula=true' in 'eula.txt'"
		fi
	fi
}

echo "INFO: Starting script at" $(date -u +%Y-%m-%d_%H:%M:%S)
echo "DEBUG: Dumping starting variables: "
echo "DEBUG: MAX_RAM=$MAX_RAM"
echo "DEBUG: JAVA_ARGS=$JAVA_ARGS"
echo "DEBUG: MCVER=$MCVER"
echo "DEBUG: FORGEVER=$FORGEVER"
echo "DEBUG: Basic System Info: " $(uname -a)
if [ "$machine" = "Mac" ] 
then
  echo "DEBUG: Total RAM estimate: " $(sysctl hw.memsize | awk 'BEGIN {total = 1} {if (NR == 1 || NR == 3) total *=$NF} END {print total / 1024 / 1024" MB"}')
else
  echo "DEBUG: Total RAM estimate: " $(getconf -a | grep PAGES | awk 'BEGIN {total = 1} {if (NR == 1 || NR == 3) total *=$NF} END {print total / 1024 / 1024" MB"}')
fi
echo "DEBUG: Java Version info: " $(java -version)
echo "DEBUG: Dumping current directory listing "
ls -s1h

check_binaries
eula
sync_jars
remove_client_mods
start_server

exec "$@"
