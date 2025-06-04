#!/bin/bash

# Function to display help menu
display_help() {
  echo "Usage: $0 [OPTIONS]"
  echo ""
  echo "Scan SSL certificates for specified domains or IP addresses and display detailed information."
  echo ""
  echo ""
  echo "Options:"
  echo ""
  echo "  -h, --help              Display this help message and exit."
  echo ""
  echo "  -d, --domain <domain>   Specify a single domain to scan (e.g., example.com)."
  echo ""
  echo "  -f, --file <file>       Specify a file containing a list of domains or IP addresses (one per line)."
  echo ""
  echo "  -p, --port <port>       Specify the port to connect to (default: 443)."
  echo ""
  echo "" 
  echo "Examples:"
  echo ""
  echo "  $0 -d example.com"
  echo "" 
  echo "  $0 -f domains.txt"
  echo ""
  echo "  $0 --help"
  echo ""
}

# Function to scan a single domain/IP and extract certificate information
scan_certificate() {
  local target="$1"
  local port="$2"

  echo "Scanning: $target:$port"
  echo "--------------------------------------------------"

  # Get certificate details using openssl
  cert_details=$(echo | openssl s_client -servername "$target" -connect "$target":"$port" 2>/dev/null | openssl x509 -noout -text)

  if [ -z "$cert_details" ]; then
    echo "  Error: Unable to retrieve certificate information."
  else
    echo "$cert_details"
  fi

  echo "--------------------------------------------------"
  echo ""
}

# --- Main script logic ---

# Initialize variables
domain=""
file=""
port="443"

# Parse command-line options
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    -h|--help)
      display_help
      exit 0
      ;;
    -d|--domain)
      domain="$2"
      shift
      ;;
    -f|--file)
      file="$2"
      shift
      ;;
    -p|--port)
      port="$2"
      shift
      ;;
    *)
      echo "Error: Invalid option '$1'."
      display_help
      exit 1
      ;;
  esac
  shift
done

# Check if required tools are installed
if ! command -v openssl > /dev/null; then
  echo "Error: openssl is not installed. Please install it to run this script."
  exit 1
fi

# Perform scanning based on input
if [ -n "$domain" ]; then
  scan_certificate "$domain" "$port"
elif [ -n "$file" ]; then
  if [ -f "$file" ]; then
    while IFS= read -r line; do
      scan_certificate "$line" "$port"
    done < "$file"
  else
    echo "Error: File '$file' not found."
    exit 1
  fi
else
  echo "Error: Please specify a domain (-d) or a file with domains (-f)."
  display_help
  exit 1
fi
