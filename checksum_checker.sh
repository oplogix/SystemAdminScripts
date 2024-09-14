#!/bin/bash

# Function to display the help page
display_help() {
    echo "Usage: $0 <url> <expected_checksum> <destination>"
    echo
    echo "Downloads a file from the specified URL and validates its checksum using multiple algorithms."
    echo
    echo "Arguments:"
    echo "  <url>               The URL to download the file from."
    echo "  <expected_checksum> The expected checksum (can be SHA-256, SHA-1, or MD5)."
    echo "  <destination>       The path where the validated file should be saved."
    echo
    echo "Example:"
    echo "  $0 https://example.com/file.tar.gz fde06133d4aaf9e4d9dc9bcbd51a95b84061df0bb76ed66f330ccead161d9071 /path/to/save/file.tar.gz"
    exit 1
}

# Check if the user asked for help
if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
    display_help
fi

# Check if required arguments are provided
if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
    echo "Error: Missing arguments!"
    display_help
fi

# URL to download the file from
URL="$1"

# Expected checksum (SHA-256, SHA-1, or MD5)
EXPECTED_CHECKSUM="$2"

# Destination to save the file
DESTINATION="$3"

# Create a temporary file to store the downloaded content
TEMP_FILE=$(mktemp)

# Download the file to the temporary location
echo "Downloading file from $URL..."
curl -s -o "$TEMP_FILE" "$URL"

# Check if the file was successfully downloaded
if [ $? -ne 0 ]; then
    echo "Failed to download file from $URL."
    rm "$TEMP_FILE"
    exit 1
fi

# Calculate the checksums
SHA256_CHECKSUM=$(sha256sum "$TEMP_FILE" | awk '{ print $1 }')
SHA1_CHECKSUM=$(sha1sum "$TEMP_FILE" | awk '{ print $1 }')
MD5_CHECKSUM=$(md5sum "$TEMP_FILE" | awk '{ print $1 }')

# Compare each calculated checksum with the expected checksum
if [ "$SHA256_CHECKSUM" == "$EXPECTED_CHECKSUM" ] || [ "$SHA1_CHECKSUM" == "$EXPECTED_CHECKSUM" ] || [ "$MD5_CHECKSUM" == "$EXPECTED_CHECKSUM" ]; then
    echo "Checksum verified successfully. Moving file to $DESTINATION."
    mv "$TEMP_FILE" "$DESTINATION"
else
    echo "Checksum verification failed! Deleting the downloaded file."
    rm "$TEMP_FILE"
    exit 1
fi

# Clean up
echo "Download and checksum validation completed successfully."
exit 0
