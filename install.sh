#!/usr/bin/env bash

set -e

if [[ $EUID -ne 0 ]]; then
    echo "Please run as root:"
    echo "sudo bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/niksdot/sfetch/main/install.sh)\""
    exit 1
fi

cat > /usr/local/bin/sfetch <<'EOF'
#!/usr/bin/env bash

# ==========================
# sfetch
# ==========================

# ---------- Distro ----------
if [[ -f /etc/os-release ]]; then
    . /etc/os-release
    DISTRO="$PRETTY_NAME"
else
    DISTRO="$(uname -s)"
fi

# ---------- Uptime ----------
UPTIME_SEC=$(cut -d. -f1 /proc/uptime)

DAYS=$((UPTIME_SEC / 86400))
HOURS=$(((UPTIME_SEC % 86400) / 3600))
MINUTES=$(((UPTIME_SEC % 3600) / 60))

if (( DAYS > 0 )); then
    UPTIME="${DAYS}d ${HOURS}h ${MINUTES}min"
elif (( HOURS > 0 )); then
    UPTIME="${HOURS}h ${MINUTES}min"
else
    UPTIME="${MINUTES}min"
fi

# ---------- Disk ----------
read DISK_TOTAL DISK_USED <<< $(df -BG / | awk 'NR==2 {gsub(/G/,"",$2); gsub(/G/,"",$3); print $2, $3}')
DISK_PERCENT=$((DISK_USED * 100 / DISK_TOTAL))

# ---------- RAM ----------
MEM_TOTAL=$(awk '/MemTotal/ {print $2}' /proc/meminfo)
MEM_AVAILABLE=$(awk '/MemAvailable/ {print $2}' /proc/meminfo)

MEM_USED=$((MEM_TOTAL - MEM_AVAILABLE))
RAM_PERCENT=$(((MEM_USED * 100 + MEM_TOTAL / 2) / MEM_TOTAL))

RAM_USED_GB=$(awk "BEGIN {printf \"%.0f\", $MEM_USED/1024/1024}")
RAM_TOTAL_GB=$(awk "BEGIN {printf \"%.0f\", $MEM_TOTAL/1024/1024}")

echo "distro :: $DISTRO"
echo "uptime :: $UPTIME"
echo "disk :: ${DISK_USED}Gb / ${DISK_TOTAL}Gb (${DISK_PERCENT}%)"
echo "ram :: ${RAM_USED_GB}Gb / ${RAM_TOTAL_GB}Gb (${RAM_PERCENT}%)"
EOF

chmod +x /usr/local/bin/sfetch

echo "sfetch installed successfully!"
echo "Run: sfetch"
