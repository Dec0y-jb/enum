#!/bin/bash

# Most of this script was pulled from Lazyrecon (creds to Nahamsec)
# Creds to Patrick Gillespie for the logo (awesome ASCII Art Generator) - http://patorjk.com/software/taag/
# This will enumerate subdomains, and check CNAMES for potential takeovers.
#
# There is no right or wrong. There's only fun and boring.
#
# Todo: Add loot folders with timestamps
#
# Decoy

red=`tput setaf 1; tput bold`
green=`tput setaf 2; tput bold`
reset=`tput sgr0`

crtsh(){
	~/massdns/scripts/ct.py "$domain" | ~/massdns/bin/massdns -r ~/massdns/lists/resolvers.txt -t A -q -o S -w ./crtsh.tmp
}

sublister(){
	python ~/tools/Sublist3r/sublist3r.py -d "$domain" -t 10 -v -o ./sublister.tmp
}

certspotter(){
	curl -s https://certspotter.com/api/v0/certs\?domain\="$domain" | jq '.[].dns_names[]' | sed 's/\"//g' | sed 's/\*\.//g' | sort -u | grep "$domain" >> ./certspotter.tmp
}

mass(){
	~/massdns/scripts/subbrute.py ~/tools/all.txt "$domain" | ~/massdns/bin/massdns -r ~/massdns/lists/resolvers.txt -t A -q -o S -w ./massdns.tmp
}

amass(){
	~/amass_v3.0.27_linux_amd64/amass enum -passive -d "$domain" -o ./amass.tmp
}

cname(){
	cat ./enum.tmp | awk '{print $3}' | sort -u | while read line; do
		wildcard=$(cat ./enum.tmp | grep -m 1 "$line")
        	echo "$wildcard" >> ./clean.tmp
	done

	cat ./clean.tmp | grep "CNAME" >> ./$domain.cnames.txt > /dev/null
	cat ./$domain.cnames.txt | sort -u | while read line; do
		hostrec=$(echo "$line" | awk '{print $1}')
		if [[ $(host $hostrec | grep NXDOMAIN) != "" ]]
		then
			echo -e "${green}Check the following domain for NS takeover:  $line ${reset}"
			echo "$line" >> ./$domain.takeovers.txt
		else
			echo -ne "${red}Reticulating splines...${reset}"
		fi
	done

	sleep 5
}

# Its in that place where I put that thing that time
save(){
	echo -e "\n${red}Compiling results...${reset}"
	cat ./sublister.tmp ./certspotter.tmp ./massdns.tmp ./amass.tmp ./crtsh.tmp | tee -a ./enum.tmp > /dev/null && sleep 1
	echo -e "${green}Complete."

	echo -e "\n${red}Beginning CNAME enumeration...${reset}"
	cname
	echo -e "${green}Complete."

	echo -e "\n${red}Cleaning up...${reset}"
	cat ./enum.tmp | awk '{print $1}' | while read line; do
		x="$line"
		echo "${x%?}" | tee -a ./final.tmp > /dev/null
	done

	cat ./final.tmp | sort -u | tee -a $outputfile > /dev/null && sleep 1

	rm ./massdns.tmp
	rm ./amass.tmp
	rm ./sublister.tmp
	rm ./certspotter.tmp
	rm ./crtsh.tmp
	rm ./clean.tmp
	rm ./enum.tmp
	rm ./final.tmp

	count=$(wc -l $outputfile | awk '{ print $1 }')
	echo -e "\n${green}Enumeration Complete:" $count "unique subdomains found! Happy Hunting!${reset}"
}

logo(){
echo "${red}"
echo -e "\n"
echo -e " (\`-')  _<-. (\`-')_            <-. (\`-')  "
echo -e " ( OO).-/   \( OO) )     .->      \(OO )_ "
echo -e "(,------.,--./ ,--/ ,--.(,--.  ,--./  ,-.)"
echo -e " |  .---'|   \ |  | |  | |(\`-')|   \`.'   |"
echo -e "(|  '--. |  . '|  |)|  | |(OO )|  |'.'|  |"
echo -e " |  .--' |  |\    | |  | | |  \|  |   |  |"
echo -e " |  \`---.|  | \   | \  '-'(_ .'|  |   |  |"
echo -e " \`------'\`--'  \`--'  \`-----'   \`--'   \`--'"
echo -e "There is no right or wrong. There's only fun and boring."
echo "${reset}"
}

# get options
while getopts ":d:o:c" opt; do
        case ${opt} in
                d )
                        domain=$OPTARG ;;
                o )
                        outputfile=$OPTARG ;;
                c )
                        crt=1 ;;
                \? )
                        echo "Usage: ./enum.sh [-d domain] [-o output file] [-c include crtsh]"
                        exit 1 ;;
        esac
done
shift $((OPTIND -1))

# check for domain
if [ -z "$domain" ]
then
        echo "Usage: ./enum.sh [-d domain] [-o output file] [-c include crtsh]"
        exit 1
fi

# start
clear
logo
touch ./crtsh.tmp
touch ./certspotter.tmp
touch ./sublister.tmp
touch ./amass.tmp
touch ./massdns.tmp
touch ./enum.tmp
touch ./final.tmp

# target
echo -e "\n${red}Target:" $domain "${reset}"

# sublist3r
echo -e "\n${red}Beginning sublist3r enumeration...${reset}"
sublister > /dev/null 2>&1 && count=$(wc -l ./sublister.tmp | awk '{ print $1 }')
echo -e "${green}Complete:" $count "subdomains found.${reset}"

# certspotter
echo -e "\n${red}Beginning certspotter enumeration...${reset}"
certspotter > /dev/null 2>&1 && count=$(wc -l ./certspotter.tmp | awk '{ print $1 }')
echo -e "${green}Complete:" $count "subdomains found.${reset}"

#crt.sh
if [ "$crt" ]
then
        echo -e "\n${red}Beginning crt.sh enumeration...${reset}"
        crtsh | tac > /dev/null 2>&1 && count=$(wc -l ./crtsh.tmp | awk '{ print $1 }')
        echo -e "${green}Complete:" $count "subdomains found.${reset}"
fi

# massdns
echo -e "\n${red}Beginning massdns enumeration...${reset}"
mass > /dev/null 2>&1 && count=$(wc -l ./massdns.tmp | awk '{ print $1 }')
echo -e "${green}Complete:" $count "subdomains found.${reset}"

#amass
echo -e "\n${red}Beginning amass enumeration...${reset}"
amass > /dev/null 2>&1 && count=$(wc -l ./amass.tmp | awk '{ print $1 }')
echo -e "${green}Complete:" $count "subdomains found.${reset}"

# save loot
save
