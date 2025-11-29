#!/bin/bash

# Full-Stack Development Server Launcher
# Generic script to run React frontend + Python backend projects
# Customize the configuration section below for your specific project

set -u  # Exit on undefined variable
set -o pipefail  # Catch errors in pipes
# Note: Not using 'set -e' to allow graceful handling of background processes

# ============================================================================
# CONFIGURATION - Customize these for your project
# ============================================================================

readonly BACKEND_DIR="backend"
readonly FRONTEND_DIR="frontend"
readonly BACKEND_PORT="8000"
readonly FRONTEND_PORT="5173"
readonly PYTHON_MAIN="app.main:app"  # Format: module.path:app_instance

# ============================================================================
# CONSTANTS
# ============================================================================

# Color codes
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

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
    echo -e "${BLUE}▶ $1${NC}"
}

error_exit() {
    print_error "$1"
    if [ -n "${2:-}" ]; then
        echo "" >&2
        echo "Details: $2" >&2
    fi
    exit 1
}

check_port_available() {
    local port=$1
    if command -v lsof &> /dev/null; then
        if lsof -Pi :"$port" -sTCP:LISTEN -t >/dev/null 2>&1; then
            return 1
        fi
    elif command -v netstat &> /dev/null; then
        if netstat -an | grep -q ":$port.*LISTEN"; then
            return 1
        fi
    fi
    return 0
}

kill_port_process() {
    local port=$1
    local process_name=$2
    
    if command -v lsof &> /dev/null; then
        local pids
        pids=$(lsof -ti tcp:"$port" 2>/dev/null || true)
        
        if [ -n "$pids" ]; then
            print_warning "Found existing process on port $port"
            echo "$pids" | while read -r pid; do
                if [ -n "$pid" ]; then
                    print_step "Killing process $pid..."
                    kill "$pid" 2>/dev/null || true
                    sleep 1
                    # Force kill if still running
                    if kill -0 "$pid" 2>/dev/null; then
                        kill -9 "$pid" 2>/dev/null || true
                    fi
                fi
            done
            print_success "Existing $process_name process stopped"
            # Wait a moment for port to be released
            sleep 1
            return 0
        fi
    fi
    return 1
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

echo ""
print_header "═══════════════════════════════════════════════════════════"
print_header "   🚀 Full-Stack Development Server"
print_header "═══════════════════════════════════════════════════════════"
echo ""

# Get project directories
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
readonly VENV_PATH="$PROJECT_ROOT/.venv"
readonly BACKEND_PATH="$PROJECT_ROOT/$BACKEND_DIR"
readonly FRONTEND_PATH="$PROJECT_ROOT/$FRONTEND_DIR"

# Change to project root
cd "$PROJECT_ROOT" || error_exit "Failed to change to project directory: $PROJECT_ROOT"

# Check if virtual environment exists
if [ ! -d "$VENV_PATH" ]; then
    print_error "Virtual environment (.venv) not found!"
    echo ""
    read -r -p "Would you like to run the setup script now? (y/n): " run_setup
    if [[ "$run_setup" =~ ^[Yy]$ ]]; then
        if [ -f "$SCRIPT_DIR/setup.sh" ]; then
            chmod +x "$SCRIPT_DIR/setup.sh"
            "$SCRIPT_DIR/setup.sh"
        else
            print_error "setup.sh not found in scripts directory"
            print_info "Please run the setup script first to create the virtual environment"
            exit 1
        fi
    else
        print_warning "Please run './scripts/setup.sh' to create the environment first"
        exit 1
    fi
fi

# Activate virtual environment
print_step "Activating virtual environment..."
if [ -f "$VENV_PATH/bin/activate" ]; then
    # shellcheck disable=SC1091
    source "$VENV_PATH/bin/activate" || error_exit "Failed to activate virtual environment"
    
    # Verify activation worked
    if [ -z "${VIRTUAL_ENV:-}" ]; then
        error_exit "Virtual environment activation failed" "VIRTUAL_ENV is not set"
    fi
else
    error_exit "Virtual environment activation script not found" "Expected at: $VENV_PATH/bin/activate"
fi

# Get Python info
PY_VERSION=$(python --version 2>&1 || echo "unknown")
PY_PATH=$(command -v python || echo "unknown")

print_success "Python Environment Active"
print_info "Version: $PY_VERSION"
print_info "Path: $PY_PATH"
echo ""

# 1. Check Prerequisites
print_header "[1/4] Checking Prerequisites"
echo ""

# Check for Node.js/npm
if ! command -v npm &> /dev/null; then
    print_error "npm is not installed"
    print_info "Please install Node.js and npm from: https://nodejs.org/"
    exit 1
fi
npm_version=$(npm --version 2>/dev/null)
print_success "npm found (v$npm_version)"

# Check if backend directory exists
if [ ! -d "$BACKEND_PATH" ]; then
    print_warning "Backend directory '$BACKEND_DIR' not found"
    print_info "This script expects a Python backend in the '$BACKEND_DIR' directory"
fi

# Check if frontend directory exists
if [ ! -d "$FRONTEND_PATH" ]; then
    print_warning "Frontend directory '$FRONTEND_DIR' not found"
    print_info "This script expects a React frontend in the '$FRONTEND_DIR' directory"
fi

echo ""

# 2. Setup Backend (if needed)
print_header "[2/4] Setting Up Backend"
echo ""

if [ -d "$BACKEND_PATH" ]; then
    # Check for .env file (optional, create template if doesn't exist)
    if [ ! -f "$BACKEND_PATH/.env" ]; then
        print_info "Creating .env template in $BACKEND_DIR/"
        cat > "$BACKEND_PATH/.env" << 'EOF'
# Backend Configuration
# Customize these variables for your project
DEBUG=true
LOG_LEVEL=INFO
EOF
    fi

    # Install/update Python dependencies
    print_step "Checking Python dependencies..."
    if command -v uv &> /dev/null; then
        cd "$BACKEND_PATH" || error_exit "Failed to change to backend directory"
        if ! uv pip install -e ".[dev]" -q 2>/dev/null; then
            if ! uv pip install -e . -q 2>/dev/null; then
                cd "$PROJECT_ROOT"
                print_warning "Failed to install backend dependencies with uv"
                print_info "You may need to install dependencies manually"
            else
                cd "$PROJECT_ROOT" || exit 1
                print_success "Backend dependencies installed (via uv)"
            fi
        else
            cd "$PROJECT_ROOT" || exit 1
            print_success "Backend dependencies installed (via uv)"
        fi
    else
        cd "$BACKEND_PATH" || error_exit "Failed to change to backend directory"
        if ! pip install -e ".[dev]" -q 2>/dev/null; then
            if ! pip install -e . -q 2>/dev/null; then
                cd "$PROJECT_ROOT"
                print_warning "Failed to install backend dependencies with pip"
                print_info "You may need to install dependencies manually"
            else
                cd "$PROJECT_ROOT" || exit 1
                print_success "Backend dependencies installed (via pip)"
            fi
        else
            cd "$PROJECT_ROOT" || exit 1
            print_success "Backend dependencies installed (via pip)"
        fi
    fi
else
    print_warning "Skipping backend setup (directory not found)"
fi

echo ""

# 3. Setup Frontend (if needed)
print_header "[3/4] Setting Up Frontend"
echo ""

if [ -d "$FRONTEND_PATH" ]; then
    if [ ! -d "$FRONTEND_PATH/node_modules" ]; then
        print_step "Installing Node.js dependencies..."
        cd "$FRONTEND_PATH" || error_exit "Failed to change to frontend directory"
        if npm install; then
            cd "$PROJECT_ROOT" || exit 1
            print_success "Frontend dependencies installed"
        else
            cd "$PROJECT_ROOT"
            print_warning "Failed to install frontend dependencies"
            print_info "You may need to run 'npm install' manually in the frontend directory"
        fi
    else
        print_success "Frontend dependencies already installed"
    fi
else
    print_warning "Skipping frontend setup (directory not found)"
fi

echo ""

# 4. Start Servers
print_header "[4/4] Starting Development Servers"
echo ""

# Display server URLs
print_info "Backend:  http://localhost:$BACKEND_PORT"
print_info "Frontend: http://localhost:$FRONTEND_PORT"
echo ""
print_warning "Press Ctrl+C to stop both servers"
echo ""

# Cleanup function for graceful shutdown
cleanup() {
    local exit_code=$?
    echo ""
    print_warning "Shutting down servers..."
    
    # Disable job control messages
    set +m
    
    # Kill all background jobs (cross-platform compatible)
    local pids
    pids=$(jobs -p 2>/dev/null || true)
    if [ -n "$pids" ]; then
        # Send SIGTERM first for graceful shutdown
        echo "$pids" | while read -r pid; do
            kill "$pid" 2>/dev/null || true
        done
        
        # Give processes time to terminate
        sleep 2
        
        # Force kill if still running
        pids=$(jobs -p 2>/dev/null || true)
        if [ -n "$pids" ]; then
            echo "$pids" | while read -r pid; do
                kill -9 "$pid" 2>/dev/null || true
            done
        fi
    fi
    
    print_success "Servers stopped"
    exit $exit_code
}

# Trap signals for cleanup
trap cleanup SIGINT SIGTERM EXIT

# Start Backend (if directory exists)
if [ -d "$BACKEND_PATH" ]; then
    # Check if backend port is available, if not, kill the process
    if ! check_port_available "$BACKEND_PORT"; then
        kill_port_process "$BACKEND_PORT" "backend"
    fi
    
    print_step "Starting Backend server..."
    cd "$BACKEND_PATH" || error_exit "Failed to change to backend directory"
    
    # Check if uvicorn is available
    if python -m uvicorn --version &> /dev/null; then
        python -m uvicorn "$PYTHON_MAIN" --reload --port "$BACKEND_PORT" --host 0.0.0.0 > /dev/null 2>&1 &
        BACKEND_PID=$!
        
        # Verify process started
        sleep 1
        if kill -0 "$BACKEND_PID" 2>/dev/null; then
            print_success "Backend running (PID: $BACKEND_PID) on port $BACKEND_PORT"
        else
            print_error "Backend failed to start"
            print_info "Check if '$PYTHON_MAIN' is correct in the configuration"
            BACKEND_PID=""
        fi
    else
        print_warning "uvicorn not found. Install it with: pip install uvicorn"
        print_info "Skipping backend server"
    fi
    
    cd "$PROJECT_ROOT" || exit 1
else
    print_warning "Backend directory not found, skipping backend server"
fi

# Wait for backend to initialize
if [ -n "${BACKEND_PID:-}" ]; then
    sleep 1
fi

echo ""

# Start Frontend (if directory exists)
if [ -d "$FRONTEND_PATH" ]; then
    # Check if frontend port is available, if not, kill the process
    if ! check_port_available "$FRONTEND_PORT"; then
        kill_port_process "$FRONTEND_PORT" "frontend"
    fi
    
    print_step "Starting Frontend development server..."
    cd "$FRONTEND_PATH" || error_exit "Failed to change to frontend directory"
    
    # Check if npm run dev command exists
    if npm run dev --help &> /dev/null || grep -q '"dev"' package.json 2>/dev/null; then
        npm run dev > /dev/null 2>&1 &
        FRONTEND_PID=$!
        
        # Verify process started
        sleep 1
        if kill -0 "$FRONTEND_PID" 2>/dev/null; then
            print_success "Frontend running (PID: $FRONTEND_PID) on port $FRONTEND_PORT"
        else
            print_error "Frontend failed to start"
            print_info "Check package.json for 'dev' script or run 'npm run dev' manually"
            FRONTEND_PID=""
        fi
    else
        print_warning "'npm run dev' script not found in package.json"
        print_info "Add a 'dev' script to package.json or start the server manually"
    fi
    
    cd "$PROJECT_ROOT" || exit 1
else
    print_warning "Frontend directory not found, skipping frontend server"
fi

echo ""

# Check if any servers started
if [ -z "${BACKEND_PID:-}" ] && [ -z "${FRONTEND_PID:-}" ]; then
    print_error "No servers were started successfully"
    print_info "Please check the errors above and fix any issues"
    exit 1
fi

print_header "═══════════════════════════════════════════════════════════"
print_success "Development servers are running!"
print_header "═══════════════════════════════════════════════════════════"
echo ""
print_info "Waiting for servers... (Press Ctrl+C to stop)"
echo ""

# Wait for all background processes
wait 2>/dev/null || true
