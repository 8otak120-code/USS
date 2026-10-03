#!/bin/bash
# ============================================
#  Ubuntu Environment Setup - Mobile Friendly
# ============================================

# --- Colors (mobile readable) ---
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

# --- Config file to remember choices ---
CONFIG_FILE="$HOME/.setup-ubuntu.conf"
touch "$CONFIG_FILE"

# ============================================
# Helper: print short, wrapped messages
# ============================================
say() { echo -e "${CYAN}$1${NC}"; }
ok()  { echo -e "${GREEN}✓ $1${NC}"; }
warn(){ echo -e "${YELLOW}⚠ $1${NC}"; }
err() { echo -e "${RED}✗ $1${NC}"; }

# Horizontal rule that fits phones
rule() { printf '%*s\n' "${COLUMNS:-40}" '' | tr ' ' '-'; }

# ============================================
# Save / read state so toggles persist
# ============================================
set_state() { 
    sed -i "/^$1=/d" "$CONFIG_FILE"
    echo "$1=$2" >> "$CONFIG_FILE"
}
get_state() {
    grep "^$1=" "$CONFIG_FILE" 2>/dev/null | cut -d= -f2
}

# ============================================
# Menu system
# ============================================
main_menu() {
    clear
    rule
    echo -e "${BOLD} Ubuntu Setup Menu${NC}"
    rule
    echo "1) System update"
    echo "2) Install essentials"
    echo "3) Dev tools"
    echo "4) Shell (zsh+oh-my-zsh)"
    echo "5) Toggle settings"
    echo "6) Show status"
    echo "7) Uninstall / reset"
    echo "0) Exit"
    rule
    read -p "Choose: " choice
    case $choice in
        1) do_update ;;
        2) do_essentials ;;
        3) do_devtools ;;
        4) do_shell ;;
        5) toggle_menu ;;
        6) show_status ;;
        7) do_reset ;;
        0) exit 0 ;;
        *) warn "Invalid"; sleep 1; main_menu ;;
    esac
}

# ============================================
# Feature: System update
# ============================================
do_update() {
    clear; rule; echo -e "${BOLD} System Update${NC}"; rule
    sudo apt update && sudo apt upgrade -y
    sudo apt autoremove -y
    ok "System updated"
    read -p "Press Enter..."
    main_menu
}

# ============================================
# Feature: Essentials (mobile-friendly tools)
# ============================================
do_essentials() {
    clear; rule; echo -e "${BOLD} Install Essentials${NC}"; rule
    PKGS=(curl wget git nano htop tmux tree unzip zip \
          ncdu bat ripgrep fd-find jq fzf)
    for p in "${PKGS[@]}"; do
        say "→ $p"
        sudo apt install -y "$p" >/dev/null 2>&1 \
            && ok "$p" || warn "$p failed"
    done
    set_state essentials done
    read -p "Press Enter..."
    main_menu
}

# ============================================
# Feature: Dev tools
# ============================================
do_devtools() {
    clear; rule; echo -e "${BOLD} Dev Tools${NC}"; rule
    echo "a) Node.js (nvm)"
    echo "b) Python (pip+venv)"
    echo "c) Docker"
    echo "d) All"
    echo "0) Back"
    read -p "Choose: " d
    case $d in
        a) install_node ;;
        b) install_python ;;
        c) install_docker ;;
        d) install_node; install_python; install_docker ;;
        0) main_menu ;;
    esac
    read -p "Press Enter..."
    main_menu
}

install_node() {
    say "Installing nvm + Node LTS..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install --lts && ok "Node installed"
}

install_python() {
    sudo apt install -y python3 python3-pip python3-venv
    ok "Python installed"
}

install_docker() {
    sudo apt install -y docker.io docker-compose
    sudo usermod -aG docker "$USER"
    ok "Docker installed (re-login for group)"
}

# ============================================
# Feature: Shell setup
# ============================================
do_shell() {
    clear; rule; echo -e "${BOLD} Shell Setup${NC}"; rule
    sudo apt install -y zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi
    chsh -s "$(which zsh)"
    set_state shell zsh
    ok "zsh + oh-my-zsh ready (logout to apply)"
    read -p "Press Enter..."
    main_menu
}

# ============================================
# Toggle menu (persistent settings)
# ============================================
toggle_menu() {
    clear; rule; echo -e "${BOLD} Toggles${NC}"; rule
    echo "1) Auto-update on login: $(get_state autoupdate || echo off)"
    echo "2) Compact prompts:      $(get_state compact || echo off)"
    echo "3) Aliases loaded:       $(get_state aliases || echo off)"
    echo "0) Back"
    read -p "Choose: " t
    case $t in
        1) toggle autoupdate ;;
        2) toggle compact ;;
        3) toggle aliases ;;
        0) main_menu ;;
    esac
    toggle_menu
}

toggle() {
    local k=$1 cur
    cur=$(get_state "$k")
    if [ "$cur" = "on" ]; then
        set_state "$k" off
        warn "$k → OFF"
        [ "$k" = "aliases" ] && remove_aliases
        [ "$k" = "compact" ] && remove_compact
    else
        set_state "$k" on
        ok "$k → ON"
        [ "$k" = "aliases" ] && add_aliases
        [ "$k" = "compact" ] && add_compact
    fi
    sleep 1
}

# ============================================
# Aliases (mobile typing = short commands)
# ============================================
ALIAS_BLOCK="# >>> setup-ubuntu aliases >>>"
add_aliases() {
    remove_aliases
    cat >> "$HOME/.bashrc" <<EOF
$ALIAS_BLOCK
alias ll='ls -lah'
alias gs='git status'
alias gc='git commit'
alias gp='git push'
alias ..='cd ..'
alias ...='cd ../..'
alias update='sudo apt update && sudo apt upgrade -y'
alias ports='ss -tulpn'
alias myip='curl -s ifconfig.me'
# <<< setup-ubuntu aliases <<<
EOF
}
remove_aliases() {
    sed -i "/$ALIAS_BLOCK/,/# <<< setup-ubuntu aliases <<</d" "$HOME/.bashrc"
}

# ============================================
# Compact prompt (great for phones)
# ============================================
COMPACT_BLOCK="# >>> setup-ubuntu compact >>>"
add_compact() {
    remove_compact
    cat >> "$HOME/.bashrc" <<EOF
$COMPACT_BLOCK
export PS1='\w \$ '
# <<< setup-ubuntu compact <<<
EOF
}
remove_compact() {
    sed -i "/$COMPACT_BLOCK/,/# <<< setup-ubuntu compact <<</d" "$HOME/.bashrc"
}

# ============================================
# Status view
# ============================================
show_status() {
    clear; rule; echo -e "${BOLD} Status${NC}"; rule
    echo "User:    $USER"
    echo "Shell:   $SHELL"
    echo "Distro:  $(lsb_release -ds 2>/dev/null)"
    rule
    echo "Toggles:"
    cat "$CONFIG_FILE" 2>/dev/null || echo "  (none)"
    rule
    read -p "Press Enter..."
    main_menu
}

# ============================================
# Reset
# ============================================
do_reset() {
    clear; rule; echo -e "${BOLD} Reset${NC}"; rule
    warn "Removes aliases, prompt tweaks, config"
    read -p "Type YES to confirm: " c
    if [ "$c" = "YES" ]; then
        remove_aliases; remove_compact
        rm -f "$CONFIG_FILE"
        ok "Reset complete"
    else
        warn "Cancelled"
    fi
    sleep 1
    main_menu
}

# ============================================
# Start
# ============================================
main_menu
