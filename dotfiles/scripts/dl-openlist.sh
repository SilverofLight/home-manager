#!/bin/bash

# Download script with -o option support (wget version)
# Usage: ./dl-openlist.sh <url> [-o <output_filename>]
# require: openlist

urldecode() {
    local url="$1"
    local decoded=""
    local i=0
    local len=${#url}

    while [ $i -lt $len ]; do
        char="${url:$i:1}"
        if [ "$char" = "%" ] && [ $((i+2)) -lt $len ]; then
            hex="${url:$((i+1)):2}"
            char=$(printf "\\x$hex")
            i=$((i+3))
        else
            i=$((i+1))
        fi
        decoded="$decoded$char"
    done

    echo "$decoded"
}

url=""
output_file=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -o|--output)
            if [[ $# -ge 2 ]]; then
                output_file="$2"
                shift 2
            else
                echo "Error: -o requires a filename argument"
                exit 1
            fi
            ;;
        -h|--help)
            echo "Usage: $0 <url> [-o <output_filename>]"
            echo "  <url>: URL to download from"
            echo "  -o, --output: Specify output filename (optional)"
            echo "  -h, --help: Show this help message"
            exit 0
            ;;
        *)
            if [[ -z "$url" ]]; then
                url="$1"
            else
                echo "Error: Too many arguments. Only one URL is allowed."
                echo "Usage: $0 <url> [-o <output_filename>]"
                exit 1
            fi
            shift
            ;;
    esac
done

if [[ -z "$url" ]]; then
    echo "Error: URL is required"
    echo "Usage: $0 <url> [-o <output_filename>]"
    exit 1
fi

if [[ -z "$output_file" ]]; then
    echo "Enter output filename (press Enter to use default from URL):"
    read -r user_input
    if [[ -n "$user_input" ]]; then
        output_file="$user_input"
    fi
fi

if [[ -z "$output_file" ]]; then
    filename=$(basename "$url")
    filename=${filename%%\?*}
    filename=${filename%%\#*}
    output_file=$(urldecode "$filename")
fi

echo "Downloading from: $url"
echo "Output file: $output_file"

wget \
    --user-agent='pan.baidu.com' \
    --content-disposition \
    -O "$output_file" \
    "$url"

status=$?

if [[ $status -eq 0 ]]; then
    echo "Download completed successfully: $output_file"
else
    echo "Download failed! (exit code: $status)"
    exit 1
fi
