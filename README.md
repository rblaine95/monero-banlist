# Monero Ban List

This is my personal, daily updating, mirror of the blocklists at `gui.xmr.pm`

#### Upstream
* [https://gui.xmr.pm/files/block.txt](https://gui.xmr.pm/files/block.txt)
* [https://gui.xmr.pm/files/block_tor.txt](https://gui.xmr.pm/files/block_tor.txt)

To use, download the blocklist of your choice and use the `--ban-list /path/to/block.txt` `monerod` argument

Or add `ban-list=/path/to/block.txt` to your `bitmonero.conf` file

#### Download Links:
* Github Pages:
  * [https://rblaine95.github.io/monero-banlist/block.txt](https://rblaine95.github.io/monero-banlist/block.txt)
  * [https://rblaine95.github.io/monero-banlist/block_tor.txt](https://rblaine95.github.io/monero-banlist/block_tor.txt)

#### Tips
If you want to tip me, thank you  
Monero: `83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh`  
![XMR Address](https://api.qrserver.com/v1/create-qr-code/?data=83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh&amp;size=150x150 "83TeC9hCsZjjUcvNVH6VD64FySQ2uTbgw6ETfzNJa51sJaM6XL4NParSNsKqEQN4znfpbtVj84smigtLBtT1AW6BTVQVQGh")

Otherwise, please tip the [Monero Developers](https://github.com/monero-project/monero#supporting-the-project) or the [CCS](https://ccs.getmonero.org/donate/)

---
### Automated Monero Banlist Updater
This script automates the process of keeping your Monero node's banlist up to date. It downloads the latest list, compares it with your current one, and only restarts the daemon if changes are detected.
#### The Universal Script
Create a file (e.g., `/usr/local/bin/update-monero-banlist.sh`) and paste the following code.

**Note**: Check the **CONFIGURATION** section below the script to adapt it to your specific environment (Docker or Native).
```bash
#!/bin/bash

# ==============================================================================
# CONFIGURATION - ADJUST THESE SETTINGS
# ==============================================================================

# 1. The URL of the banlist
BANLIST_URL="https://raw.githubusercontent.com/rblaine95/monero-banlist/refs/heads/master/block.txt"

# 2. Where to save the banlist (Adjust this path!)
#    - For Docker: Use the path on your HOST machine (e.g., in your monero volume)
#    - For Native: Usually /home/youruser/.bitmonero/ban_list.txt
TARGET_FILE="/path/to/your/monero/ban_list.txt"

# 3. Choose your restart method (Comment/Uncomment the one you need)
#    METHOD A: For Docker users (monerod = Name of your container)
RESTART_CMD="/usr/bin/docker restart monerod"

#    METHOD B: For Native/Systemd users
# RESTART_CMD="/usr/bin/systemctl restart monero.service"

# ==============================================================================
# SCRIPT LOGIC (No need to change anything below this line)
# ==============================================================================

TEMP_FILE="/tmp/monero_banlist_new.txt"

echo "$(date): Checking for updates..."

# 1. Download the list
if ! /usr/bin/curl -s -o "$TEMP_FILE" "$BANLIST_URL" || [ ! -s "$TEMP_FILE" ]; then
    echo "ERROR: Download failed or file is empty."
    rm -f "$TEMP_FILE"
    exit 1
fi

# 2. Compare content (Skip if TARGET_FILE does not exist yet)
if [ -f "$TARGET_FILE" ] && cmp -s "$TEMP_FILE" "$TARGET_FILE"; then
    echo "INFO: List is already up to date. No restart needed."
    rm "$TEMP_FILE"
    exit 0
fi

# 3. Apply update
echo "INFO: New banlist detected. Updating..."
# Create directory if it doesn't exist
mkdir -p "$(dirname "$TARGET_FILE")"
mv "$TEMP_FILE" "$TARGET_FILE"

# Ensure the file is readable by the Monero daemon (Docker or Native)
chmod 644 "$TARGET_FILE"

# 4. Restart Node
echo "INFO: Executing restart: $RESTART_CMD"
if $RESTART_CMD > /dev/null 2>&1; then
    echo "SUCCESS: Monero node updated and restarted."
else
    echo "ERROR: Restart failed. Check your permissions or service/container name."
    exit 1
fi
```
#### Installation & Setup
**1. Preparation**
Make the script executable after saving:
```bash
sudo chmod +x /usr/local/bin/update-monero-banlist.sh
```
**2. Node Configuration**
Your Monero node needs to know it should use a banlist. Add this line to your `bitmonero.conf`:
```
ban-list=/path/to/your/ban_list.txt
```
**Docker Users**: Ensure the `ban-list` path in your `.conf` file points to the location **inside** the container, while the `TARGET_FILE` in the script points to the location on your **host** machine.

**3. Automate with Cron**
To run this update automatically (e.g., every day at midnight), add a cronjob:
* Open crontab: `sudo crontab -e`
* Add this line:
```bash
0 0 * * * /usr/local/bin/update-monero-banlist.sh > /dev/null 2>&1
```
#### Troubleshooting
* **Permissions**: The script should be run as `root` (via crontab) to ensure it has permission to restart services or containers.
* **Paths**: Double-check that `TARGET_FILE` matches the location your Monero daemon actually reads.
* **First Run**: On the first run, the script will always perform a restart because it needs to create the initial `ban_list.txt` file.
