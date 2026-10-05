#!/bin/bash

set -e

echo "🔧 Installing ThunderHost Premium MOTD..."

echo "🧹 Removing old MOTD completely..."

chmod -x /etc/update-motd.d/* 2>/dev/null || true

rm -f /etc/motd
rm -f /var/run/motd
rm -f /run/motd.dynamic

if [ -f /etc/default/motd-news ]; then
    sed -i 's/ENABLED=1/ENABLED=0/g' /etc/default/motd-news
fi

echo "⚙ Configuring PAM..."

cp /etc/pam.d/sshd /etc/pam.d/sshd.bak 2>/dev/null || true
cp /etc/pam.d/login /etc/pam.d/login.bak 2>/dev/null || true

sed -i '/pam_motd.so/d' /etc/pam.d/sshd
sed -i '/pam_motd.so/d' /etc/pam.d/login

sed -i '\|00-thunderhost|d' /etc/pam.d/sshd
sed -i '\|00-thunderhost|d' /etc/pam.d/login

echo "session optional pam_exec.so stdout /etc/update-motd.d/00-thunderhost" >> /etc/pam.d/sshd
echo "session optional pam_exec.so stdout /etc/update-motd.d/00-thunderhost" >> /etc/pam.d/login

echo "✨ Creating ThunderHost MOTD..."

cat << 'EOF' > /etc/update-motd.d/00-thunderhost
#!/bin/bash

GREEN="\e[38;5;82m"
CYAN="\e[38;5;51m"
BLUE="\e[38;5;39m"
MAGENTA="\e[38;5;213m"
YELLOW="\e[38;5;220m"
GRAY="\e[38;5;245m"
RESET="\e[0m"

HOSTNAME=$(hostname)
OS=$(grep PRETTY_NAME /etc/os-release | cut -d= -f2 | tr -d '"')
KERNEL=$(uname -r)
UPTIME=$(uptime -p | sed 's/up //')

CPU=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')

MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_USED=$(free -m | awk '/Mem:/ {print $3}')
MEM_PERC=$((MEM_USED * 100 / MEM_TOTAL))

DISK=$(df -h / | awk 'NR==2 {print $3 " / " $2 " (" $5 ")"}')

IP=$(hostname -I | awk '{print $1}')
USERS=$(who | wc -l)
PROCS=$(ps -e --no-headers | wc -l)

echo ""

echo -e "${MAGENTA}"

cat << "LOGO"
████████╗██╗  ██╗██╗   ██╗███╗   ██╗██████╗ ███████╗██████╗
╚══██╔══╝██║  ██║██║   ██║████╗  ██║██╔══██╗██╔════╝██╔══██╗
   ██║   ███████║██║   ██║██╔██╗ ██║██║  ██║█████╗  ██████╔╝
   ██║   ██╔══██║██║   ██║██║╚██╗██║██║  ██║██╔══╝  ██╔══██╗
   ██║   ██║  ██║╚██████╔╝██║ ╚████║██████╔╝███████╗██║  ██║
   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚═════╝ ╚══════╝╚═╝  ╚═╝
LOGO

echo -e "${RESET}"

echo -e "${GREEN}⚡ Welcome to ThunderHost${RESET}"
echo -e "${BLUE}High Performance • Reliable • Affordable Hosting${RESET}"
echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

printf "${CYAN}%-18s${RESET} %s\n" "Hostname:" "$HOSTNAME"
printf "${CYAN}%-18s${RESET} %s\n" "OS:" "$OS"
printf "${CYAN}%-18s${RESET} %s\n" "Kernel:" "$KERNEL"
printf "${CYAN}%-18s${RESET} %s\n" "Uptime:" "$UPTIME"
printf "${CYAN}%-18s${RESET} %s\n" "CPU Usage:" "$CPU"
printf "${CYAN}%-18s${RESET} %sMB / %sMB (${YELLOW}%s%%${RESET})\n" \
    "Memory:" "$MEM_USED" "$MEM_TOTAL" "$MEM_PERC"
printf "${CYAN}%-18s${RESET} %s\n" "Disk:" "$DISK"
printf "${CYAN}%-18s${RESET} %s\n" "Processes:" "$PROCS"
printf "${CYAN}%-18s${RESET} %s\n" "Users:" "$USERS"
printf "${CYAN}%-18s${RESET} %s\n" "IP:" "$IP"

echo -e "${GRAY}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

echo -e "${GREEN}Discord:${RESET}  https://discord.gg/YOUR_DISCORD"
echo -e "${GREEN}Website:${RESET}  https://your-domain.com"
echo -e "${MAGENTA}ThunderHost — Powering Your Infrastructure ⚡${RESET}"

echo ""
EOF

chmod +x /etc/update-motd.d/00-thunderhost

systemctl restart ssh 2>/dev/null || true

echo ""
echo "✅ ThunderHost MOTD Installed"
echo "🚫 Default MOTD disabled"
echo "⚡ Custom ThunderHost MOTD enabled"
echo "➡ Reconnect SSH to see changes"
