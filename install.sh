#!/bin/bash

tools=("python3" "go" "assetfinder" "subfinder" "sublist3r"
       "httprobe" "katana" "waybackurls" "gau" "uro" "gf")

uninstalled=()
echo "[+] checking tools..."
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
	echo -e "[+] $tool"
done
if [ ${#uninstalled} -gt 0 ]; then
	echo "[⚠ ] some tools need to be installed!"
	exit 1
else
	sudo rm -rf /usr/share/raccoon 2>/dev/null
	sudo rm /usr/bin/raccoon 2>/dev/null

	chmod +x raccoon.sh
	sudo mkdir /usr/share/raccoon
	sudo cp banner.txt /usr/share/raccoon/
	sudo cp raccoon.sh /usr/bin/raccoon

	echo "[!] raccoon tool installed successfully!"
fi
