
# Prompt for BORG_REPO path
read -p "Enter where you want BORG_REPO path to be (e.g., /mnt/borg-repo or ssh://username@host:/path/to/repo): " BORG_REPO_PATH
if [[ -z "$BORG_REPO_PATH" ]]; then
    error_exit "BORG_REPO path cannot be empty."
fi
export BORG_REPO="$BORG_REPO_PATH"

# Prompt for BORG_PASSPHRASE
read -s -p "Enter BORG_PASSPHRASE (input will be hidden): " BORG_PASSPHRASE
echo
if [[ -z "$BORG_PASSPHRASE" ]]; then
    error_exit "BORG_PASSPHRASE cannot be empty."
fi
export BORG_PASSPHRASE

# Confirm the input before proceeding
echo "You have entered the following:"
echo "BORG_REPO: $BORG_REPO"
echo "BORG_PASSPHRASE: (hidden)"
read -p "Is this information correct? (y/n): " CONFIRM
if [[ "$CONFIRM" != "y" ]]; then
    error_exit "Installation aborted by user."
fi

# Initialize Borg repository if it doesn't exist
if ! borg list :: >/dev/null 2>&1; then
    echo "Initializing Borg repository at $BORG_REPO..."
    if ! borg init --encryption=repokey; then
        error_exit "Failed to initialize Borg repository."
    fi
else
    echo "Borg repository already exists at $BORG_REPO."
fi
