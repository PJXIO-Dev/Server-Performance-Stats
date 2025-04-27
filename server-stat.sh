#!/usr/bin/env zsh
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    os_type="Linux"
else
    echo "Unsupported OS: $OSTYPE. We only support Linux"
    echo -n "Press [Enter] to exit..."
    read
    exit 1
fi

echo "Running on $os_type"
# Function to print a header
print_header() {
    echo "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo "$1"
}

# OS Version
print_header "OS Version"
cat /etc/os-release | grep -E '^PRETTY_NAME' | cut -d '"' -f2

# Uptime
print_header "System Uptime"
uptime -p

# Load Average
print_header "Load Average (1, 5, 15 min)"
load_avg=$(uptime | awk -F'load average:' '{ print $2 }')
echo "$load_avg"

# Logged-in users
print_header "Currently Logged-in Users"
who

# Failed login attempts
print_header "Failed Login Attempts (last 24h)"
lastb | awk '$NF ~ /[0-9]{2}:[0-9]{2}/ {print}' | wc -l

# Total CPU usage
print_header "Total CPU Usage"
cpu_usage=$(grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$4+$5)} END {printf "%.2f", usage}')
echo "CPU Usage: $cpu_usage%"

# Total Memory usage
print_header "Total Memory Usage"
mem_usage=$(free -m | awk 'NR==2{printf "%.2f", $3*100/$2}')
used_mem=$(free -m | awk 'NR==2{print $3}')
total_mem=$(free -m | awk 'NR==2{print $2}')
echo "Memory Usage: ${used_mem}MB / ${total_mem}MB (${mem_usage}%)"

# Total Disk usage
print_header "Total Disk Usage"
disk_usage=$(df -h --total | grep total | awk '{print $5}')
disk_used=$(df -h --total | grep total | awk '{print $3}')
disk_total=$(df -h --total | grep total | awk '{print $2}')
echo "Disk Usage: $disk_used / $disk_total ($disk_usage)"

# Top 5 processes by CPU usage
print_header "Top 5 Processes by CPU Usage"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n 6

# Top 5 processes by Memory usage
print_header "Top 5 Processes by Memory Usage"
ps -eo pid,comm,%mem --sort=-%mem | head -n 6

# System Health Summary
print_header "System Health Summary"
health_status="GOOD AND HEALTHY :)"

if (( $(echo "$cpu_usage > 80.0" | bc -l) )); then
    health_status="MEOW WARNING ALERT: High CPU usage"
elif (( $(echo "$mem_usage > 80.0" | bc -l) )); then
    health_status="MEOW WARNING ALERT: High Memory usage"
elif [[ ${disk_usage%\%} -gt 85 ]]; then
    health_status="MEOW WARNING ALERT: High Disk usage"
fi

echo "System Health: $health_status"
echo -e "\nStats gathered successfully."

echo -n "Press [Enter] key to exit..."
read
