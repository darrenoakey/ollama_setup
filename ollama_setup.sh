#!/bin/zsh

# Define the variable name and value
OLLAMA_HOST="0.0.0.0:11434"

# Ollama executable path (VERIFY THIS!)
OLLAMA_EXECUTABLE="/Applications/Ollama.app/Contents/MacOS/ollama"  # ***ADJUST IF NEEDED***

# Create the plist file content (correctly formatted)
plist_content=$(cat <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.llama.ollama</string>
    <key>ProgramArguments</key>
    <array>
        <string>${OLLAMA_EXECUTABLE}</string>
        <string>serve</string>
    </array>
    <key>EnvironmentVariables</key>
    <dict>
        <key>OLLAMA_HOST</key>
        <string>${OLLAMA_HOST}</string>
    </dict>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
EOF
)

# Define the plist file path
plist_path="/Library/LaunchDaemons/com.llama.ollama.plist"

# Write the plist content to the file (requires sudo)
if ! echo "$plist_content" | sudo tee "$plist_path" > /dev/null; then
    echo "Error: Failed to write plist file."
    exit 1
fi

# Set proper permissions on the plist file (important!)
sudo chown root:wheel "$plist_path"
sudo chmod 644 "$plist_path"

# Validate the plist file syntax
if ! plutil "$plist_path" > /dev/null; then
    echo "Error: Invalid plist syntax. Check the file manually."
    sudo rm "$plist_path" # Remove the invalid file
    exit 1
fi

# Load the daemon (start ollama)
if ! sudo launchctl load "$plist_path"; then
    echo "Error: Failed to load daemon. Check console logs for details."
    exit 1
fi

# Optional: Check if the daemon is loaded
if launchctl list | grep com.llama.ollama > /dev/null; then
    echo "Ollama configured with OLLAMA_HOST=${OLLAMA_HOST}"
else
    echo "Error: Ollama daemon not found in launchctl list."
    exit 1
fi

exit 0