#!/bin/bash

RETROPIE_HOST="retropie"
RETROPIE_USR="pi"
RETROPIE_PASS="raspberry"

CMD="cd /home/pi/.uaeconfigmaker; python3 uae_config_maker.py"

echo "Updating registry may take a few minutes..."
sshpass -p "${RETROPIE_PASS}" ssh "${RETROPIE_USR}@${RETROPIE_HOST}" "${CMD}"
echo "Done"
