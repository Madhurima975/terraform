#!/bin/bash

# Private key on jump server
KEY="~/id_rsa"

# Default username for Ubuntu EC2
USER="ubuntu"

# List of private IPs of your nodes
NODES=("10.0.1.186" "10.0.1.17" "10.0.1.50")

for IP in "${NODES[@]}"; do
  echo "------ Connecting to $IP ------"
  
  # Fetch system info
  ssh -i $KEY -o StrictHostKeyChecking=no $USER@$IP "uptime; df -h; free -m"
 
done
