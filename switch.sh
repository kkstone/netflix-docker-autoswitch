#!/bin/bash

source /etc/profile

# Variation
Region=
Hostname=
Time=$(date +"%Y/%m/%d %H:%M:%S")
Count=0
UA_Browser="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36"

function Start {
    echo -e " ------------------------------------------------------------------------------"
    echo -e " [${Time}] [Intro] Starting cron..."
    echo -e " [${Time}] [Intro] One-Click Automatically Change IP Script for Cloudflare-WARP"
    echo -e " [${Time}] [Intro] Version:2022-01-13-1"
    CheckRun
}

function Test_Netflix_Access {   
    local result1="$(curl -x socks5h://172.17.0.2:1080 --user-agent "${UA_Browser}" -fsL --write-out %{http_code} --output /dev/null --max-time 5 "https://www.netflix.com/title/81215567" 2>&1)"
    local result2="$(curl -x socks5h://172.17.0.2:1080 --user-agent "${UA_Browser}" -fs --max-time 10 --write-out %{redirect_url} --output /dev/null "https://www.netflix.com/title/80018499" | cut -d '/' -f4 | cut -d '-' -f1 2>&1)"
    if [[ "$result1" == "200" ]] && [[ "$result2" == "$Region" ]]; then
        echo -e " [${Time}] [Intro] Netflix is unlocked, exiting."
        rm -rf /var/run/nf_switch.run
        exit 0
    else
        echo -e " [${Time}] [Intro] Netflix is not unlock, unlocking..." 
        ChangeIP
    fi
}

function ChangeIP {
    systemctl restart docker
    let Count++
        sleep 10
    Test_Netflix_Access
}

function CheckRun {
    if [ -f "/var/run/nf_switch.run" ];then
        echo -e " [${Time}] [Error] Another unlocker is working, exiting."
        exit 0
    else
        touch /var/run/nf_switch.run
        Test_Netflix_Access
    fi
}

Start