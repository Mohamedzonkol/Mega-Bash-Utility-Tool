#!/bin/bash

COLOR_RESET="\033[0m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_CYAN="\033[1;36m"
COLOR_MAGENTA="\033[1;35m"
text="Enjoy Man"

#########################  Check and Install Rofi  #########################
check_and_install_rofi() {
    if ! command -v rofi &>/dev/null; then
        echo -e "${COLOR_RED}Rofi is not installed. Installing it now...${COLOR_RESET}"
        if sudo apt update && sudo apt install -y rofi; then
            echo -e "${COLOR_GREEN}Rofi installed successfully!${COLOR_RESET}"
        else
            echo -e "${COLOR_RED}Failed to install Rofi. Please install it manually.${COLOR_RESET}"
            exit 1
        fi
    fi
}

#########################  Display Banner  #############################
show_banner() {
    echo -e "${COLOR_GREEN}"
    local message="Welcome to the Mega Bash Utility!"
    echo
    for ((i = 0; i < ${#message}; i++)); do
        echo -n "${message:i:1}"
        sleep 0.05
    done
    echo -e "${COLOR_RESET}"
    echo -e "${COLOR_BLUE}-------------------------------------------------------"
    echo " Explore tools for monitoring, managing, and optimizing!"
    echo "-------------------------------------------------------${text}"
}

#########################  Display Menu  ###############################
show_menu() {
    options="System Information\nDisk Usage\nNetwork Statistics\nCPU Usage Monitor\nReal-Time Process Viewer\nDisk Cleanup\nSystem Health Check\nFile Explorer\nUser Management\nGenerate Logs\nFun ASCII Art\nYouTube Downloader\nalias generator\nExit"
    choice=$(echo -e "$options" | rofi -dmenu -p "Choose an option:")
    case $choice in
        "System Information") system_info ;;
        "Disk Usage") disk_usage ;;
        "Network Statistics") network_stats ;;
        "CPU Usage Monitor") cpu_usage_monitor ;;
        "Real-Time Process Viewer") real_time_process_viewer ;;
        "Disk Cleanup") disk_cleanup ;;
        "System Health Check") system_health_check ;;
        "File Explorer") file_explorer ;;
        "User Management") user_management ;;
        "Generate Logs") generate_logs ;;
        "Fun ASCII Art") ascii_art ;;
        "YouTube Downloader") yt_downloader ;;
        "alias generator") alias_generator ;;
        "Exit") 
            echo -e "${COLOR_RED}Exiting... Goodbye!${COLOR_RESET}"
            exit 0
            ;;
        *) echo -e "${COLOR_RED}Invalid option. Please try again.${COLOR_RESET}" ;;
    esac
}

#########################  System Information  ###########################
system_info() {
    echo -e "${COLOR_CYAN}Fetching System Information...${COLOR_RESET}"
    sleep 1
    info=$(cat <<EOF
Hostname: $(hostname)
Uptime: $(uptime -p)
OS: $(grep '^PRETTY_NAME' /etc/os-release | cut -d= -f2 | tr -d '\"')
Kernel Version: $(uname -r)
CPU Load: $(top -bn1 | grep 'load average' | awk '{print $10 $11 $12}')
RAM Usage: $(free -h | grep Mem | awk '{print $3 " / " $2}')
EOF
)
    echo "$info" | rofi -dmenu -p "System Information"
    echo -e "${COLOR_GREEN}System Information Loaded Successfully!${COLOR_RESET}"
}

#############################  Disk Usage  ################################
disk_usage() {
    echo -e "${COLOR_CYAN}Analyzing Disk Usage...${COLOR_RESET}"
    sleep 2
    disk_usage_info=$(df -h --output=source,size,used,avail,pcent | column -t)
    echo "$disk_usage_info" | rofi -dmenu -p "Disk Usage"
    echo -e "${COLOR_GREEN}Disk Usage Analysis Complete!${COLOR_RESET}"
}

#########################  Network Statistics  #############################
# Function: Show Network Statistics
network_stats() {
    echo -e "${COLOR_CYAN}Fetching Network Statistics...${COLOR_RESET}"
    sleep 1
    net_stats=$(cat <<EOF
Active Connections: $(netstat -ant | grep ESTABLISHED | wc -l)
Top Bandwidth Consumers:
EOF
)
    if command -v iftop &>/dev/null; then
        net_stats+="\n(Launching iftop... Press Q to quit)"
        echo "$net_stats" | rofi -dmenu -p "Network Statistics"
        sudo iftop
    else
        net_stats+="\n${COLOR_RED}iftop is not installed. Use 'sudo apt install iftop' for real-time data.${COLOR_RESET}"
        echo -e "$net_stats" | rofi -dmenu -p "Network Statistics"
    fi
    echo -e "${COLOR_GREEN}Network Stats Loaded Successfully!${COLOR_RESET}"
}

############################  CPU Usage Monitor  #############################
cpu_usage_monitor() {
    echo -e "${COLOR_CYAN}Starting CPU Usage Monitor...${COLOR_RESET}"
    while true; do
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print 100 - $8"%"}')
        echo -e "CPU Usage: $cpu_usage"
        sleep 1
    done | rofi -dmenu -p "CPU Usage Monitor"
}

#########################  Real-Time Process Viewer  ##########################
real_time_process_viewer() {
    echo -e "${COLOR_CYAN}Launching Real-Time Process Viewer...${COLOR_RESET}"
    while true; do
        process_list=$(ps aux --sort=-%mem | awk 'NR<=10{print $0}')
        echo "$process_list" | rofi -dmenu -p "Real-Time Process Viewer"
        sleep 2
    done
}

###############################  Disk Cleanup  ################################
disk_cleanup() {
    echo -e "${COLOR_CYAN}Running Disk Cleanup...${COLOR_RESET}"
    sleep 2
    echo "Clearing apt cache..."
    sudo apt-get clean
    echo "Clearing temporary files..."
    sudo rm -rf /tmp/*
    echo -e "${COLOR_GREEN}Disk Cleanup Completed!${COLOR_RESET}"
    echo -e "Disk Cleanup Completed!" | rofi -dmenu -p "Disk Cleanup"
}

############################  System Health Check  #############################
system_health_check() {
    echo -e "${COLOR_CYAN}Performing System Health Check...${COLOR_RESET}"
    sleep 2
    health_info=""

    echo "Checking CPU Temperature..."
    if command -v sensors &>/dev/null; then
        cpu_temp=$(sensors)
        health_info+="CPU Temperature:\n$cpu_temp\n"
    else
        health_info+="${COLOR_RED}Install 'lm-sensors' to monitor CPU temperature.${COLOR_RESET}\n"
    fi

    echo "Checking Disk Health..."
    if command -v smartctl &>/dev/null; then
        disk_health=$(sudo smartctl --all /dev/sda | grep -i health)
        health_info+="Disk Health:\n$disk_health\n"
    else
        health_info+="${COLOR_RED}Install 'smartmontools' to check disk health.${COLOR_RESET}\n"
    fi

    echo -e "$health_info" | rofi -dmenu -p "System Health Check"
    echo -e "${COLOR_GREEN}System Health Check Complete!${COLOR_RESET}"
}

###############################  File Explorer  ##################################
file_explorer() {
    echo -e "${COLOR_CYAN}Launching File Explorer...${COLOR_RESET}"
    directory=$(rofi -dmenu -p "Enter directory path (default: current directory):")
    directory=${directory:-$(pwd)}
    contents=$(ls -lh "$directory")
    echo "$contents" | rofi -dmenu -p "Contents of $directory"
    echo -e "${COLOR_GREEN}File Explorer Finished!${COLOR_RESET}"
}

###############################  User Management  #################################
user_management() {
    echo -e "${COLOR_CYAN}User Management:${COLOR_RESET}"
    options="List all users\nAdd a new user\nDelete a user"
    user_choice=$(echo -e "$options" | rofi -dmenu -p "Choose an option:")
    case $user_choice in
        "List all users")
            users=$(cut -d: -f1 /etc/passwd)
            echo "$users" | rofi -dmenu -p "All Users"
            ;;
        "Add a new user")
            new_user=$(rofi -dmenu -p "Enter the username to add:")
            if [ -n "$new_user" ]; then
                sudo adduser "$new_user"
            else
                echo -e "${COLOR_RED}Username cannot be empty.${COLOR_RESET}"
            fi
            ;;
        "Delete a user")
            del_user=$(rofi -dmenu -p "Enter the username to delete:")
            if [ -n "$del_user" ]; then
                sudo deluser "$del_user"
            else
                echo -e "${COLOR_RED}Username cannot be empty.${COLOR_RESET}"
            fi
            ;;
        *)
            echo -e "${COLOR_RED}Invalid option. Returning to main menu.${COLOR_RESET}"
            ;;
    esac
}

###############################  Generate Logs  ##################################
generate_logs() {
    echo -e "${COLOR_CYAN}Generating Logs...${COLOR_RESET}"
    sleep 1
    logs=$(cat <<EOF
System Logs:
$(dmesg | tail -n 10)

Auth Logs:
$(sudo tail -n 10 /var/log/auth.log)
EOF
)
    echo "$logs" | rofi -dmenu -p "Generated Logs"
    echo -e "${COLOR_GREEN}Logs Generated Successfully!${COLOR_RESET}"
}

###################################  ASCII Art  ###################################
ascii_art() {
    echo -e "${COLOR_MAGENTA}Enjoy some ASCII Art:${COLOR_RESET}"
    cat << "EOF"
       /\_/\  
      ( o.o ) 
       > ^ <  
EOF
    echo -e "${COLOR_MAGENTA}Bash Creativity Unleashed!${COLOR_RESET}"
}

###############################  YouTube Downloader  ###############################
yt_downloader() {
    # Check if yt-dlp is not installed
    if ! command -v yt-dlp &>/dev/null; then
        echo -e "${COLOR_RED}yt-dlp is not installed. Installing it now...${COLOR_RESET}"
        
        if sudo apt update && sudo apt install -y yt-dlp; then
            echo -e "${COLOR_GREEN}yt-dlp installed successfully via apt!${COLOR_RESET}"
        else
            # If apt fails, fall back to pipx
            if command -v pipx &>/dev/null; then
                echo -e "${COLOR_YELLOW}Attempting to install yt-dlp using pipx...${COLOR_RESET}"
                pipx install yt-dlp && echo -e "${COLOR_GREEN}yt-dlp installed successfully via pipx!${COLOR_RESET}" && return
            else
                echo -e "${COLOR_YELLOW}pipx not found. Setting up a virtual environment...${COLOR_RESET}"
                python3 -m venv yt-dlp-env
                source yt-dlp-env/bin/activate
                pip install yt-dlp
                echo -e "${COLOR_GREEN}yt-dlp installed successfully in a virtual environment.${COLOR_RESET}"
                deactivate
                return
            fi
        fi
    fi

    default_url="https://www.youtube.com/watch?v=dQw4w9WgXcQ" # Short video for testing

    # Enter URL of the YouTube video/playlist
    url=$(rofi -dmenu -p "Enter YouTube Video/Playlist URL (or press Enter for default test video):")
    if [ -z "$url" ]; then
        url="$default_url"
        echo -e "${COLOR_YELLOW}Using default test video link: $url${COLOR_RESET}"
    elif [[ ! "$url" =~ ^https?:// ]]; then
        echo -e "${COLOR_RED}Invalid URL. Please enter a valid YouTube link.${COLOR_RESET}"
        return
    fi

    # Ask the user for the directory to save the download
    directory=$(rofi -dmenu -p "Enter directory to save the videos (default is 'YTVids'):")
    directory="${directory:-YTVids}"  # Use default 'YTVids' if no input is provided

    # Check if the directory exists
    if [ ! -d "$directory" ]; then
        create_dir=$(rofi -dmenu -p "Directory '$directory' does not exist. Do you want to create it? (y/n):")
        if [[ "$create_dir" == "y" || "$create_dir" == "Y" ]]; then
            mkdir -p "$directory"
            echo "Created directory: $directory"
        else
            echo "Please provide a valid directory."
            return
        fi
    fi

    # Display download options
    choice=$(echo -e "1. Download Video Only\n2. Download Audio Only\n3. Download Both Video and Audio" | rofi -dmenu -p "Please choose a download option:")

    # Set the filename format
    filename="$directory/%(title)s.%(ext)s"

    # Download the video based on the user's choice
    case $choice in
        "1. Download Video Only")
            echo "Downloading video only..."
            yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" "$url" -o "$filename"
            ;;
        "2. Download Audio Only")
            echo "Downloading audio only..."
            yt-dlp -x --audio-format mp3 "$url" -o "$filename"
            ;;
        "3. Download Both Video and Audio")
            echo "Downloading both video and audio..."
            yt-dlp -f "bv*[ext=mp4]+ba[ext=m4a]/b[ext=mp4]" "$url" -o "$filename"
            ;;
        *)
            echo "Invalid choice. Exiting."
            exit 1
            ;;
    esac

    # Check if the download was successful
    if [ $? -eq 0 ]; then
        echo -e "${COLOR_GREEN}Download completed successfully!${COLOR_RESET}"
    else
        echo -e "${COLOR_RED}Download failed. Please check the URL and try again.${COLOR_RESET}"
    fi
}

############################## Alias Generator ##############################
alias_generator() {
 alias_name=$(rofi -dmenu -p "Enter alias name:")
command=$(rofi -dmenu -p "Enter command for alias:")

if [ -n "$alias_name" ] && [ -n "$command" ]; then
  if [ -n "$ZSH_VERSION" ];then
    echo "alias $alias_name='$command'" >> ~/.zshrc
    source ~/.zshrc
    echo "Alias '$alias_name' added successfully."
  elif [ -n "$BASH_VERSION" ];then
  echo "alias $alias_name='$command'" >> ~/.bashrc
  source ~/.bashrc
  echo "Alias '$alias_name' added successfully."

else
    echo "Alias name or command cannot be empty."
fi
fi
}

###############################  Main Script  ###############################
clear
check_and_install_rofi
show_banner

while true; do
    echo
    show_menu
done
