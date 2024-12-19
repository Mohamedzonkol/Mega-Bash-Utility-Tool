#!/bin/bash

COLOR_RESET="\033[0m"
COLOR_GREEN="\033[1;32m"
COLOR_BLUE="\033[1;34m"
COLOR_YELLOW="\033[1;33m"
COLOR_RED="\033[1;31m"
COLOR_CYAN="\033[1;36m"
COLOR_MAGENTA="\033[1;35m"
text="Enjoy Man"




#########################  install missing tools dynamically  #############################
check_and_install_tool() {
    local tool=$1
    local package=$2
    if ! command -v "$tool" &>/dev/null; then
        echo -e "${COLOR_YELLOW}$tool is not installed. Installing now...${COLOR_RESET}"
        if sudo apt update && sudo apt install -y "$package"; then
            echo -e "${COLOR_GREEN}$tool installed successfully!${COLOR_RESET}"
        else
            echo -e "${COLOR_RED}Failed to install $tool. Please install it manually.${COLOR_RESET}"
            return 1
        fi
    fi
    return 0
}
#########################   Spinner animation  #############################

spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while ps -p $pid &>/dev/null; do
        for char in $(echo "$spinstr" | fold -w1); do
            echo -ne "$char\r"
            sleep $delay
        done
    done
    echo -ne " \r"
}
#########################  Display Banner  #############################
show_animated_banner() {
    echo -e "${COLOR_MAGENTA}"
    local message="Welcome to the Mega Bash Utility!"
    for ((i = 0; i < ${#message}; i++)); do
        echo -n "${message:i:1}"
        sleep 0.03
    done
    echo -e "\n${COLOR_BLUE}--------------------------------------------"
    echo -e " Explore tools for monitoring, managing, and optimizing! "
    echo -e "--------------------------------------------${COLOR_RESET}\n"
    sleep 1
}
#########################  Display Menu  ###############################
show_menu() {
    echo -e "${COLOR_CYAN}Generating Menu...${COLOR_RESET}" | spinner &
    sleep 1
    clear

    options=(
        "System Information"
        "Disk Usage"
        "Network Statistics"
        "CPU Usage Monitor"
        "Real-Time Process Viewer"
        "Disk Cleanup"
        "System Health Check"
        "File Explorer"
        "User Management"
        "Generate Logs"
        "Fun ASCII Art"
        "YouTube Downloader"
        "Alias Generator"
        "Exit"
    )

    PS3="Select an option: "
    select choice in "${options[@]}"; do
        case $REPLY in
            1) system_info ;;
            2) disk_usage ;;
            3) network_stats ;;
            4) cpu_usage_monitor ;;
            5) real_time_process_viewer ;;
            6) disk_cleanup ;;
            7) system_health_check ;;
            8) file_explorer ;;
            9) user_management ;;
            10) generate_logs ;;
            11) ascii_art ;;
            12) yt_downloader ;;
            13) alias_generator ;;
            14) echo -e "${COLOR_RED}Exiting... Goodbye!${COLOR_RESET}"; exit 0 ;;
            *) echo -e "${COLOR_RED}Invalid option. Please try again.${COLOR_RESET}" ;;
        esac
    done
}

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
post_operation_quit_check() {
    echo -e "${COLOR_MAGENTA}Press q to quit or any other key to continue:${COLOR_RESET}"
    read -r input
    if [[ "$input" == "q" ]]; then
        echo -e "${COLOR_RED}Exiting the program. Goodbye!${COLOR_RESET}"
        exit 0
    fi
}

quit_check() {
    echo -e "${COLOR_MAGENTA}Press q to quit or any other key to proceed:${COLOR_RESET}"
    read -r input
    if [[ "$input" == "q" ]]; then
        echo -e "${COLOR_RED}Operation cancelled by user.${COLOR_RESET}"
        return 1
    fi
    return 0
}
#########################  System Information  ###########################
system_info() {
    echo -e "${COLOR_CYAN}Fetching System Information...${COLOR_RESET}"
    echo -e "${COLOR_CYAN}Fetching System Information...${COLOR_RESET}"
    sleep 1
    info=$(cat <<EOF
Hostname: $(hostname)
Uptime: $(uptime -p)
OS: $(grep '^PRETTY_NAME' /etc/os-release | cut -d= -f2 | tr -d '\"')
Kernel Version: $(uname -r)
CPU Load: $(top -bn1 | grep 'load average' | awk '{print $10 $11 $12}')
RAM Usage: $(free -h | grep Mem | awk '{print $3 " / " $2}')
Swap Usage: $(free -h | grep Swap | awk '{print $3 " / " $2}')
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
network_stats() {
    echo -e "${COLOR_CYAN}Fetching Network Statistics...${COLOR_RESET}"
    sleep 1
    net_stats=$(cat <<EOF
Active Connections: $(netstat -ant | grep ESTABLISHED | wc -l)
Top Bandwidth Consumers:
EOF
)
    check_and_install_tool "iftop" "iftop" || return
    if command -v iftop &>/dev/null; then
        net_stats+="\n(Launching iftop... Press Q to quit)"
        echo "$net_stats" | rofi -dmenu -p "Network Statistics"
        sudo iftop
        post_operation_quit_check

    else
        net_stats+="\n${COLOR_RED}iftop is not installed. Use 'sudo apt install iftop' for real-time data.${COLOR_RESET}"
        echo -e "$net_stats" | rofi -dmenu -p "Network Statistics"
        post_operation_quit_check

    fi
    echo -e "${COLOR_GREEN}Network Stats Loaded Successfully!${COLOR_RESET}"

}

############################  CPU Usage Monitor  #############################
cpu_usage_monitor() {
    echo -e "${COLOR_CYAN}Starting CPU Usage Monitor...${COLOR_RESET}"
    echo -e "${COLOR_YELLOW}Press Ctrl+C to exit.${COLOR_RESET}"
    
    echo -e "\033[1;33m"
    while true; do
        echo -ne "CPU Usage: $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')\r"
        sleep 4
        
        echo -e "\n${COLOR_MAGENTA}Press q to quit or any other key to continue monitoring:${COLOR_RESET}"
        read -t 5 -r input
        if [[ "$input" == "q" ]]; then
            echo -e "${COLOR_RED}Exiting CPU Usage Monitor.${COLOR_RESET}"
            break
        fi
    done
    echo -e "\033[0m"
}


#########################  Real-Time Process Viewer  ##########################
real_time_process_viewer() {
    echo -e "${COLOR_CYAN}Launching Real-Time Process Viewer...${COLOR_RESET}"
    while true; do
        process_list=$(ps aux --sort=-%mem | awk 'NR<=10{print $0}')
        echo -e "${COLOR_YELLOW}Top 10 Processes by Memory Usage:${COLOR_RESET}"
        echo "$process_list" | rofi -dmenu -p "Real-Time Process Viewer"

        echo -e "${COLOR_MAGENTA}Press q to quit or any other key to refresh the process list:${COLOR_RESET}"
        read -t 5 -r input
        if [[ "$input" == "q" ]]; then
            echo -e "${COLOR_RED}Exiting Real-Time Process Viewer.${COLOR_RESET}"
            break
        fi
    done
}

###############################  Disk Cleanup  ################################
disk_cleanup() {
    echo -e "${COLOR_CYAN}Running Disk Cleanup...${COLOR_RESET}"

    while true; do
        echo -e "${COLOR_YELLOW}Do you want to clear apt cache? (y/n/q):${COLOR_RESET}"
        read -r input
        if [[ "$input" == "q" ]]; then
            echo -e "${COLOR_RED}Cleanup operation aborted.${COLOR_RESET}"
            return
        elif [[ "$input" == "y" ]]; then
            echo -e "${COLOR_BLUE}Clearing apt cache...${COLOR_RESET}"
            sudo apt-get clean
            break
        elif [[ "$input" == "n" ]]; then
            break
        else
            echo -e "${COLOR_RED}Invalid input. Please enter y, n, or q.${COLOR_RESET}"
        fi
    done

    while true; do
        echo -e "${COLOR_YELLOW}Do you want to clear temporary files? (y/n/q):${COLOR_RESET}"
        read -r input
        if [[ "$input" == "q" ]]; then
            echo -e "${COLOR_RED}Cleanup operation aborted.${COLOR_RESET}"
            return
        elif [[ "$input" == "y" ]]; then
            echo -e "${COLOR_BLUE}Clearing temporary files...${COLOR_RESET}"
            rm -rf /tmp/*
            break
        elif [[ "$input" == "n" ]]; then
            break
        else
            echo -e "${COLOR_RED}Invalid input. Please enter y, n, or q.${COLOR_RESET}"
        fi
    done

    echo -e "${COLOR_GREEN}Disk Cleanup Complete!${COLOR_RESET}"
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
# File Explorer with Operations
file_explorer() {
    local directory=$(rofi -dmenu -p "Enter Directory:" <<< "$HOME")
    if [[ ! -d "$directory" ]]; then
        echo -e "${COLOR_RED}Invalid directory.${COLOR_RESET}"
        return
    fi

    local file=$(ls "$directory" | rofi -dmenu -p "Select File:")
    if [[ -z "$file" ]]; then
        echo -e "${COLOR_RED}No file selected.${COLOR_RESET}"
        return
    fi

    local operation=$(echo -e "View\nCopy\nDelete" | rofi -dmenu -p "Choose Operation:")
    case "$operation" in
        "View")
            xdg-open "$directory/$file" &
            ;;
        "Copy")
            local dest=$(rofi -dmenu -p "Copy To Directory:")
            cp "$directory/$file" "$dest"
            echo -e "${COLOR_GREEN}File copied successfully to $dest${COLOR_RESET}"
            ;;
        "Delete")
            rm "$directory/$file"
            echo -e "${COLOR_GREEN}File deleted successfully.${COLOR_RESET}"
            ;;
        *)
            echo -e "${COLOR_RED}Invalid operation.${COLOR_RESET}"
            ;;
    esac
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
    echo -e "\n"
    cat << "EOF"
       /\_/\  
      ( o.o ) 
       > ^ <  
    Mega Bash Utility Art! 🚀
EOF
    echo -e "${COLOR_GREEN}Art Loaded Successfully!${COLOR_RESET}"
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
    # Detect the current shell
    current_shell=$(basename "$SHELL")

    if [ "$current_shell" = "zsh" ]; then
      echo "alias $alias_name='$command'" >> ~/.zshrc
      source ~/.zshrc
      echo "Alias '$alias_name' added successfully to .zshrc."
    elif [ "$current_shell" = "bash" ]; then
      echo "alias $alias_name='$command'" >> ~/.bashrc
      source ~/.bashrc
      echo "Alias '$alias_name' added successfully to .bashrc."
    else
      echo "Unsupported shell: $current_shell. Please add the alias manually."
    fi
  else
    echo "Alias name or command cannot be empty."
  fi
}

###############################  Main Script  ###############################
clear
check_and_install_rofi
show_animated_banner
while true; do
    # echo
    show_menu
done
