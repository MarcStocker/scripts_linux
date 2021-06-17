# ----------------------------------
# Colors
# ----------------------------------
NOCOLOR='\033[0m'
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LIGHTGRAY='\033[0;37m'
GRAY='\033[0;37m'
DARKGRAY='\033[1;30m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[0;33m'
LIGHTBLUE='\033[1;34m'
LIGHTPURPLE='\033[1;35m'
LIGHTCYAN='\033[1;36m'
WHITE='\033[1;37m'
# ----------------------------------
# Symbols
# ----------------------------------
#GREENCHECK="${LIGHTGREEN}\u2714${NOCOLOR}"
GREENCHECK="\U2705"
REDCROSS="\U274C"
YELLOWHAZARD="${YELLOW}\U1F6AB${NOCOLOR}"
WARNING="\U2620"
FIRE="\U1F525"


# ----------------------------------
# Variables
# ----------------------------------
prefix="${GRAY}[ ${CYAN}TestVPN ${GRAY}]${NOCOLOR} "
vpnContainer="gluetun"

testDockerVPNIP() {
	# Test only dockers that should be behind a VPN
	dockers=("Jackett" "qBitTorrent" "Sonarr" "Radarr" "Lidarr" "Bazarr" "Overseerr" "Ombi")
	columns=2

	out=""
	for i in ${!dockers[@]}; do
		#echo "Docker: ${container}"
		dockerIP=$(docker exec ${dockers[$i],,} curl -s ifconfig.io)

		if [ $((($i+1) % $columns)) -eq 1 ]; then
			out+="${prefix}"
		fi

		if [[ ${dockerIP} == ${VPNIP} && ${dockerIP} != "" ]]; then
			out+="${GREENCHECK} ${dockers[$i]},"
		elif [[ -z ${dockerIP} ]]; then
			out+="${REDCROSS} ${dockers[$i]},"
		else
			out+="${FIRE} ${RED}${dockers[$i]}${NOCOLOR},"
		fi

		if [ $((($i+1) % $columns)) -eq 0 ]; then
			out+="\n"
		fi
	done

	echo -e "$out" | column -ts $',' 
}

getPublicIP()
{
	for i in {1..3}; do
		if [[ -z "$PUBLICIP" ]]; then
			case $i in
				1 )
					#echo "1) Dig"
					PUBLICIP=`dig +short myip.opendns.com @resolver1.opendns.com &` > /dev/null
					break;;
				2 )
					#echo "2) Curl amazon"
					PUBLICIP=`curl -w "\n" -s -X GET https://checkip.amazonaws.com &` > /dev/null
					break;;
				3 )
					#echo "3) Curl ifconfig.io"
					PUBLICIP=`curl ifconfig.io &` > /dev/null
					break;;
			esac
		fi
	done
}
getVpnIP()
{
	for i in {1..2}; do
		if [[ -z "$VPNIP" ]]; then
			case $i in
				1 )
					#echo "3) Curl ifconfig.io"
					VPNIP=`docker exec ${vpnContainer} curl -s ifconfig.io &` > /dev/null
					break;;
				2 )
					#echo "2) Curl amazon"
					VPNIP=`docker exec ${vpnContainer} curl -w "\n" -s -X GET https://checkip.amazonaws.com &` > /dev/null
					break;;
			esac
		fi
	done
}

#getDockerIPs()
#{
#	JACKETTIP=`docker exec jackett curl -s ifconfig.io &`
#	QBITTORRENTIP=`docker exec qbittorrent curl -s ifconfig.io &`
#	SONARRIP=`docker exec sonarr curl -s ifconfig.io &`
#	RADARRIP=`docker exec radarr curl -s ifconfig.io &`
#	LIDARRIP=`docker exec lidarr curl -s ifconfig.io &`
#	BAZARRIP=`docker exec bazarr curl -s ifconfig.io &`
#	OVERSEERRIP=`docker exec overseerr curl -s ifconfig.io &`
#	OMBIIP=`docker exec ombi curl -s ifconfig.io &`
#}

echo -e "${prefix}${CYAN}===============================================${NOCOLOR}"
echo -e "${prefix}${CYAN}== ${NOCOLOR}Testing Docker containers attached to VPN ${CYAN}==${NOCOLOR}"
echo -e "${prefix}${CYAN}===============================================${NOCOLOR}"
echo -e "${prefix}${GREENCHECK} = ${GREEN}Connected to VPN${NOCOLOR}"
echo -e "${prefix}${REDCROSS} = ${ORANGE}No Internet${NOCOLOR}"
echo -e "${prefix}${FIRE} = ${RED}Not connected to VPN${NOCOLOR}"
echo -e "${prefix}"
echo -en "${prefix}Please wait..."

getPublicIP
getVpnIP

#Clear Please Wait line 
echo -en "\033[999D\033[K"

echo -e "${prefix}${CYAN}-----------------------------------${NOCOLOR}"
echo -e "${prefix}${CYAN}------${NOCOLOR}   Public IP Address   ${CYAN}------${NOCOLOR}"
echo -e "${prefix}${CYAN}------    ${ORANGE}${PUBLICIP}${CYAN}     ------${NOCOLOR}"
echo -e "${prefix}${CYAN}-----------------------------------${NOCOLOR}"
echo -e "${prefix}${CYAN}------${NOCOLOR}  VPN Pub IP Address   ${CYAN}------${NOCOLOR}"
echo -e "${prefix}${CYAN}------     ${ORANGE}${VPNIP}${CYAN}      ------${NOCOLOR}"
echo -e "${prefix}${CYAN}-----------------------------------${NOCOLOR}"

testDockerVPNIP

exit
