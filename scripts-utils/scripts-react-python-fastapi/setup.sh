#!/bin/bash

# Python Project Setup Script
# This script creates a virtual environment and installs dependencies using pip or uv.
# Works with any Python project that has a pyproject.toml, setup.py, or requirements.txt
# Supports: macOS, Linux

set -e  # Exit on error
set -u  # Exit on undefined variable
set -o pipefail  # Catch errors in pipes

# ============================================================================
# CONSTANTS & CONFIGURATION
# ============================================================================

readonly SCRIPT_VERSION="1.0.0"
readonly MIN_PYTHON_VERSION="3.10"
readonly PREFERRED_PYTHON_VERSION="3.14"

# Detect if running in interactive mode
if [ -t 0 ]; then
    INTERACTIVE=true
else
    INTERACTIVE=false
fi

# Color codes for better output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Get project root directory
readonly PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
readonly VENV_PATH="$PROJECT_ROOT/.venv"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Print formatted messages
print_header() {
    echo -e "${BOLD}${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_step() {
    echo -e "${MAGENTA}▶ $1${NC}"
}

# Error handler
error_exit() {
    print_error "$1"
    if [ -n "${2:-}" ]; then
        echo "" >&2
        echo "Details: $2" >&2
    fi
    echo "" >&2
    echo "Setup failed. Please check the error above and try again." >&2
    exit 1
}

# Cleanup handler
cleanup() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo "" >&2
        print_error "Setup interrupted or failed (exit code: $exit_code)" >&2
    fi
}

trap cleanup EXIT

# ============================================================================
# SYSTEM DETECTION
# ============================================================================

detect_os() {
    local os_name
    os_name="$(uname -s)"
    
    case "$os_name" in
        Darwin*)
            echo "macos"
            ;;
        Linux*)
            echo "linux"
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

get_os_info() {
    local os_type="$1"
    
    case "$os_type" in
        macos)
            local macos_version
            macos_version="$(sw_vers -productVersion 2>/dev/null || echo "unknown")"
            echo "macOS $macos_version ($(uname -m))"
            ;;
        linux)
            if [ -f /etc/os-release ]; then
                # shellcheck disable=SC1091
                . /etc/os-release
                echo "$NAME ${VERSION:-} ($(uname -m))"
            else
                echo "Linux ($(uname -m))"
            fi
            ;;
        *)
            echo "Unknown OS ($(uname -m))"
            ;;
    esac
}

# ============================================================================
# UV DETECTION & INSTALLATION
# ============================================================================

check_uv_installed() {
    command -v uv &> /dev/null
}

get_uv_path() {
    if check_uv_installed; then
        command -v uv
    else
        echo ""
    fi
}

install_uv() {
    local os_type="$1"
    
    print_step "Installing uv..."
    echo ""
    
    case "$os_type" in
        macos|linux)
            if ! command -v curl &> /dev/null; then
                error_exit "curl is required but not installed. Please install curl first."
            fi
            
            # Install uv using official installer
            if curl -LsSf https://astral.sh/uv/install.sh | sh; then
                print_success "uv installed successfully"
                
                # Add to PATH for current session
                export PATH="$HOME/.local/bin:$PATH"
                export PATH="$HOME/.cargo/bin:$PATH"
                
                # Verify installation
                if check_uv_installed; then
                    print_info "Location: $(get_uv_path)"
                    return 0
                else
                    print_warning "uv installed but not found in PATH. You may need to restart your shell."
                    print_info "Add to your shell profile: export PATH=\"\$HOME/.local/bin:\$PATH\""
                    return 1
                fi
            else
                error_exit "Failed to install uv"
            fi
            ;;
        *)
            error_exit "Unsupported operating system for automatic uv installation"
            ;;
    esac
}

# ============================================================================
# PYTHON DETECTION
# ============================================================================

check_python_version() {
    local python_cmd="$1"
    local required_version="$2"
    
    if command -v "$python_cmd" &> /dev/null; then
        local version
        version=$("$python_cmd" -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
        
        # Compare versions
        if [ "$(printf '%s\n' "$required_version" "$version" | sort -V | head -n1)" = "$required_version" ]; then
            echo "$version"
            return 0
        fi
    fi
    return 1
}

find_best_python() {
    local min_version="$1"
    
    # Try preferred version first
    for py_cmd in "python${PREFERRED_PYTHON_VERSION}" "python3.14" "python3"; do
        if version=$(check_python_version "$py_cmd" "$min_version" 2>/dev/null); then
            echo "$py_cmd|$version"
            return 0
        fi
    done
    
    # Try other Python 3 versions
    for py_cmd in python3.13 python3.12 python3.11 python3.10 python python3; do
        if version=$(check_python_version "$py_cmd" "$min_version" 2>/dev/null); then
            echo "$py_cmd|$version"
            return 0
        fi
    done
    
    return 1
}

# ============================================================================
# VIRTUAL ENVIRONMENT FUNCTIONS
# ============================================================================

check_venv_exists() {
    [ -d "$VENV_PATH" ] && [ -f "$VENV_PATH/bin/python" ]
}

check_venv_valid() {
    if [ -d "$VENV_PATH" ]; then
        if [ -f "$VENV_PATH/bin/python" ]; then
            # Try to execute python to ensure it's functional
            if "$VENV_PATH/bin/python" --version &> /dev/null; then
                return 0
            else
                print_warning ".venv exists but Python executable is corrupted"
                return 1
            fi
        else
            print_warning ".venv directory exists but appears invalid"
            return 1
        fi
    fi
    return 1
}

activate_venv() {
    # Check if already activated
    if [ -n "${VIRTUAL_ENV:-}" ] && [ "$VIRTUAL_ENV" = "$VENV_PATH" ]; then
        return 0
    fi
    
    if [ -f "$VENV_PATH/bin/activate" ]; then
        # shellcheck disable=SC1091
        source "$VENV_PATH/bin/activate"
        return 0
    else
        print_error "Failed to find activation script in .venv"
        return 1
    fi
}

get_venv_info() {
    if check_venv_valid; then
        activate_venv
        local py_version py_path
        py_version=$(python --version 2>&1)
        py_path=$(command -v python)
        echo "$py_version|$py_path"
        return 0
    fi
    return 1
}

# ============================================================================
# USER INTERACTION FUNCTIONS
# ============================================================================

ask_yes_no() {
    local prompt="$1"
    local default="${2:-n}"
    local reply
    
    # Non-interactive mode: use default
    if [ "$INTERACTIVE" = false ]; then
        [[ $default =~ ^[Yy]$ ]]
        return $?
    fi
    
    if [ "$default" = "y" ]; then
        prompt="$prompt (Y/n): "
    else
        prompt="$prompt (y/N): "
    fi
    
    read -r -p "$prompt" reply
    reply=${reply:-$default}
    
    [[ $reply =~ ^[Yy]$ ]]
}

select_package_manager() {
    local uv_available="$1"
    local os_type="$2"
    
    # Non-interactive mode: prefer uv if available, else pip
    if [ "$INTERACTIVE" = false ]; then
        if [ "$uv_available" = "true" ]; then
            echo "uv"
        else
            echo "pip"
        fi
        return 0
    fi
    
    # Display to stderr so it's visible when function output is captured
    echo "" >&2
    print_header "📦 Package Manager Selection" >&2
    echo "" >&2
    
    if [ "$uv_available" = "true" ]; then
        print_success "uv is installed: $(get_uv_path)" >&2
        print_info "uv is 10-100x faster than pip for package installation" >&2
    else
        print_warning "uv is not installed" >&2
        print_info "uv is a modern, fast Python package manager (10-100x faster than pip)" >&2
    fi
    
    echo "" >&2
    echo "Choose your package manager:" >&2
    echo -e "  ${BOLD}1)${NC} uv      ${GREEN}(recommended - blazingly fast)${NC}" >&2
    echo -e "  ${BOLD}2)${NC} pip     ${BLUE}(standard Python package manager)${NC}" >&2
    echo "" >&2
    
    local choice
    read -r -p "Enter your choice (1 or 2) [default: 1]: " choice
    choice=${choice:-1}
    
    case "$choice" in
        1)
            if [ "$uv_available" = "false" ]; then
                echo "" >&2
                if ask_yes_no "uv is not installed. Install it now?" "y"; then
                    if install_uv "$os_type"; then
                        echo "uv"
                    else
                        print_warning "uv installation failed. Falling back to pip" >&2
                        echo "pip"
                    fi
                else
                    print_warning "Falling back to pip" >&2
                    echo "pip"
                fi
            else
                echo "uv"
            fi
            ;;
        2)
            echo "pip"
            ;;
        *)
            print_warning "Invalid choice. Defaulting to pip" >&2
            echo "pip"
            ;;
    esac
}

# ============================================================================
# DEPENDENCY INSTALLATION FUNCTIONS
# ============================================================================

find_dependency_file() {
    if [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
        echo "pyproject.toml|$PROJECT_ROOT"
    elif [ -f "$PROJECT_ROOT/setup.py" ]; then
        echo "setup.py|$PROJECT_ROOT"
    elif [ -f "$PROJECT_ROOT/requirements.txt" ]; then
        echo "requirements.txt|$PROJECT_ROOT"
    elif [ -d "$PROJECT_ROOT/backend" ] && [ -f "$PROJECT_ROOT/backend/pyproject.toml" ]; then
        echo "pyproject.toml|$PROJECT_ROOT/backend"
    elif [ -d "$PROJECT_ROOT/backend" ] && [ -f "$PROJECT_ROOT/backend/requirements.txt" ]; then
        echo "requirements.txt|$PROJECT_ROOT/backend"
    else
        echo ""
    fi
}

install_dependencies() {
    local package_manager="$1"
    local dep_info
    
    dep_info=$(find_dependency_file)
    
    if [ -z "$dep_info" ]; then
        print_warning "No dependency file found (pyproject.toml, setup.py, or requirements.txt)"
        print_info "Skipping dependency installation"
        return 0
    fi
    
    local dep_file dep_path
    dep_file=$(echo "$dep_info" | cut -d'|' -f1)
    dep_path=$(echo "$dep_info" | cut -d'|' -f2)
    
    print_step "Installing dependencies from $dep_file"
    echo ""
    
    cd "$dep_path" || error_exit "Failed to change to $dep_path"
    
    case "$dep_file" in
        pyproject.toml|setup.py)
            if [ "$package_manager" = "uv" ]; then
                # Try with dev dependencies first, fall back to regular install
                if ! uv pip install -e ".[dev]" 2>/dev/null; then
                    if ! uv pip install -e .; then
                        cd "$PROJECT_ROOT"
                        error_exit "Failed to install dependencies from $dep_file" "Check if $dep_file is valid"
                    fi
                fi
            else
                python -m pip install --upgrade pip setuptools wheel || print_warning "Failed to upgrade pip/setuptools"
                if ! pip install -e ".[dev]" 2>/dev/null; then
                    if ! pip install -e .; then
                        cd "$PROJECT_ROOT"
                        error_exit "Failed to install dependencies from $dep_file" "Check if $dep_file is valid"
                    fi
                fi
            fi
            ;;
        requirements.txt)
            if [ "$package_manager" = "uv" ]; then
                if ! uv pip install -r requirements.txt; then
                    cd "$PROJECT_ROOT"
                    error_exit "Failed to install dependencies from requirements.txt" "Check if requirements.txt is valid"
                fi
            else
                python -m pip install --upgrade pip || print_warning "Failed to upgrade pip"
                if ! pip install -r requirements.txt; then
                    cd "$PROJECT_ROOT"
                    error_exit "Failed to install dependencies from requirements.txt" "Check if requirements.txt is valid"
                fi
            fi
            ;;
    esac
    
    cd "$PROJECT_ROOT" || print_warning "Failed to return to project root"
    print_success "Dependencies installed successfully"
}

# ============================================================================
# MAIN SETUP FLOW
# ============================================================================

main() {
    # Display header
    echo ""
    print_header "═══════════════════════════════════════════════════════════"
    print_header "   🐍 Python Project Setup Script v${SCRIPT_VERSION}"
    print_header "═══════════════════════════════════════════════════════════"
    echo ""
    
    # Detect operating system
    print_step "Detecting system environment..."
    local os_type
    os_type=$(detect_os)
    
    if [ "$os_type" = "unknown" ]; then
        error_exit "Unsupported operating system. This script supports macOS and Linux only."
    fi
    
    local os_info
    os_info=$(get_os_info "$os_type")
    print_info "Operating System: $os_info"
    print_info "Project Root: $PROJECT_ROOT"
    echo ""
    
    # Check if uv is installed
    print_step "Checking for uv installation..."
    local uv_available="false"
    if check_uv_installed; then
        uv_available="true"
        local uv_version
        uv_version=$(uv --version 2>/dev/null || echo "unknown")
        print_success "uv found: $uv_version"
        print_info "Location: $(get_uv_path)"
    else
        print_info "uv is not installed"
    fi
    echo ""

    # Check if virtual environment already exists
    print_step "Checking for existing virtual environment..."
    if check_venv_valid; then
        local venv_info py_version py_path
        venv_info=$(get_venv_info)
        py_version=$(echo "$venv_info" | cut -d'|' -f1)
        py_path=$(echo "$venv_info" | cut -d'|' -f2)
        
        print_success "Virtual environment (.venv) already exists"
        print_info "$py_version"
        print_info "Location: $py_path"
        echo ""
        
        if ask_yes_no "Do you want to reinstall dependencies?" "n"; then
            echo ""
            local package_manager
            package_manager=$(select_package_manager "$uv_available" "$os_type")
            echo ""
            print_step "Reinstalling dependencies with $package_manager..."
            install_dependencies "$package_manager"
        else
            echo ""
            print_success "Setup complete! Virtual environment is ready to use."
            print_info "Run 'source .venv/bin/activate' to activate it"
            exit 0
        fi
    else
        print_info "No valid virtual environment found"
        echo ""
        
        # Select package manager
        local package_manager
        package_manager=$(select_package_manager "$uv_available" "$os_type")
        echo ""
        
        # Find or install Python
        print_step "Finding suitable Python installation..."
        local python_info python_cmd python_version
        
        if [ "$package_manager" = "uv" ]; then
            # Use uv to manage Python
            print_info "Checking for Python ${PREFERRED_PYTHON_VERSION} with uv..."
            
            if uv python list 2>/dev/null | grep -q "$PREFERRED_PYTHON_VERSION"; then
                print_success "Python ${PREFERRED_PYTHON_VERSION} found"
            else
                echo ""
                print_step "Installing Python ${PREFERRED_PYTHON_VERSION} via uv..."
                uv python install "$PREFERRED_PYTHON_VERSION"
                print_success "Python ${PREFERRED_PYTHON_VERSION} installed"
            fi
            
            python_cmd="python"
            python_version="$PREFERRED_PYTHON_VERSION"
        else
            # Find system Python
            if python_info=$(find_best_python "$MIN_PYTHON_VERSION"); then
                python_cmd=$(echo "$python_info" | cut -d'|' -f1)
                python_version=$(echo "$python_info" | cut -d'|' -f2)
                print_success "Found $python_cmd (Python $python_version)"
                
                # Verify venv module is available
                if ! "$python_cmd" -m venv --help &> /dev/null; then
                    error_exit "Python venv module not available" "Please install python${python_version}-venv package or use uv instead"
                fi
            else
                error_exit "No suitable Python installation found (>= $MIN_PYTHON_VERSION required)" "Please install Python $MIN_PYTHON_VERSION or higher, or choose uv to auto-install Python"
            fi
        fi
        
        echo ""
        
        # Create virtual environment
        print_step "Creating virtual environment..."
        cd "$PROJECT_ROOT" || error_exit "Failed to change to project directory"
        
        if [ "$package_manager" = "uv" ]; then
            if ! uv venv --python "$PREFERRED_PYTHON_VERSION"; then
                error_exit "Failed to create virtual environment with uv" "Try running with pip option instead"
            fi
        else
            if ! "$python_cmd" -m venv .venv; then
                error_exit "Failed to create virtual environment" "Check if $python_cmd has venv module installed"
            fi
        fi
        
        print_success "Virtual environment created at: $VENV_PATH"
        echo ""
        
        # Activate virtual environment
        print_step "Activating virtual environment..."
        activate_venv
        
        local activated_py_version activated_py_path
        activated_py_version=$(python --version 2>&1)
        activated_py_path=$(command -v python)
        print_success "Virtual environment activated"
        print_info "$activated_py_version"
        print_info "Location: $activated_py_path"
        echo ""
        
        # Install dependencies
        install_dependencies "$package_manager"
    fi
    
    # Final summary
    echo ""
    print_header "═══════════════════════════════════════════════════════════"
    print_success "Setup Complete!"
    print_header "═══════════════════════════════════════════════════════════"
    echo ""
    echo "Next steps:"
    echo -e "  ${CYAN}•${NC} Activate the environment:"
    echo -e "    ${BOLD}source .venv/bin/activate${NC}"
    echo ""
    echo -e "  ${CYAN}•${NC} Your project dependencies are installed and ready"
    echo ""
    echo -e "  ${CYAN}•${NC} To deactivate later, simply run: ${BOLD}deactivate${NC}"
    echo ""
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

main "$@"
