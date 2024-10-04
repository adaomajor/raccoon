#!/bin/bash
 
#colors
BLUE='\033[1;34m'
GREEN='\033[1;32m'
NC='\033[0m'

tools=("python3" "go" "assetfinder" "subfinder" "sublist3r" "httprobe" "katana" "waybackurls" "gau" "uro" "gf")

echo -e "$BLUE "
cat /usr/share/raccoon/banner.txt 2>/dev/dull
echo -e "$NC"

uninstalled=()
echo -e "[+] $BLUE checking tools...$NC"
sleep 5
for tool in "${tools[@]}";
do
        if [ -z $(which "$tool") ]; then
                uninstalled+=($tool)
        else
                echo -e "[✅] $tool ok..."
        fi
done

printf "\n\n"

for tool in "${uninstalled[@]}";
do
        echo -e "[❌] $tool"
done
echo ""
if [ ${#uninstalled} -gt 0 ]; then
	echo "[⚠ ] some tools need to be installed!"
	exit 1
fi


if [ -z "$1" ]; then
	echo -e "usage: $0 <main-domain>"
	exit 1
fi

all_subdomains="all_subdomains"
alive_subdomains="alive_subdomains"

gf_patterns=("xss" "ssrf" "ssti" "redirect" "sqli" "idor" "lfi" "rce")

echo -e "$GREEN[+] running assetfinder...$NC"
assetfinder --subs-only $1 > assetfinder.txt
cat assetfinder.txt > "$all_subdomains"

echo -e "$GREEN[+] running subfinder...$NC"
sleep 3
subfinder -d $1 -all -recursive -o subfinder.txt
cat subfinder.txt >> "$all_subdomains"  

echo -e "$GREEN[+] running sublist3r...$NC"
sleep 3
sublist3r -d $1 -o sublist3r.txt  
cat sublist3r.txt  >> "$all_subdomains"

sort -u "$all_subdomains" 
grep -v '\*\..*\.*' "$all_subdomains" > subdomains.txt
echo -e "$GREEN[+] httpx | probing all subdomains...$NC"
cat subdomains.txt | httprobe > "$alive_subdomains"

echo -e "$GREEN[+] getting all urls...$NC"
sleep 3

echo -e "$GREEN[+] running katana...$NC"
katana -u alive_subdomains -d 5 -ps -kf -jc -fx -ef css,woff,woff2 -o katana.txt
cat katana.txt > all_urls.txt

echo -e "$GREEN[+] running waybackurls...$NC"
cat alive_subdomains | waybackurls > waybackurl.txt
cat waybackurl.txt >> all_urls.txt

echo -e "$GREEN[+] running gau...$NC"
for sub in $(cat alive_subdomains);
do
	gau "$sub" >> gau.txt
done

cat gau.txt >> all_urls.txt

uro -i all_urls.txt -o urls.txt
sort -u urls.txt

echo -e "$GREEN[+] getting all js files...$NC"
cat all_urls.txt | grep -E "\.js$|\.js?[a-zA-Z]$|\.js?[0-9]$" > jsfiles.txt >/dev/null
sleep 5

echo -e "$GREEN[+] running gf-patterns"
sleep 5
for patt in "${gf_patterns[@]}";
do
    cat  urls.txt | gf "$patt" | > "$patt.txt"
done
rm assetfinder.txt subfinder.txt sublist3r.txt katana.txt waybackurl.txt gau.txt

echo -e "$GEEN HAPPY HACKING 😎$NC"
