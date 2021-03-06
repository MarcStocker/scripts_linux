## Get the current external IP address
getPublicIP () {
	echo -en "Retrieving Public IP Address..."
	for i in {1..3}; do
		case $i in
			1 )
				#echo "1) Dig"
				PUBLICIP=`dig +short myip.opendns.com @resolver1.opendns.com &` 2> /dev/null
				break;;
			2 )
				#echo "2) Curl amazon"
				PUBLICIP=$(curl -w "\n" -s -X GET https://checkip.amazonaws.com) 2> /dev/null
				break;;
			3 )
				#echo "3) Curl ifconfig.io"
				PUBLICIP=$(curl -s ifconfig.io) 2> /dev/null
				break;;
		esac
	done
}

getPublicIP

#Clear line
echo -en "\033[999D\033[K"
echo "Public IP:"
echo $PUBLICIP
