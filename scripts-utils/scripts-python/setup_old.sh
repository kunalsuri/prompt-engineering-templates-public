#!/bin/bash

echo "Searching for Python installations..."
echo ""

# Array to store Python paths and versions
declare -a PYTHON_PATHS
declare -a PYTHON_VERSIONS
index=0

# Function to add Python installation
add_python() {
    local path=$1
    if [ -x "$path" ]; then
        local version=$($path --version 2>&1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
        if [ -n "$version" ]; then
            PYTHON_PATHS[$index]=$path
            PYTHON_VERSIONS[$index]=$version
            ((index++))
        fi
    fi
}

# Search common locations
# Homebrew installations
if command -v brew &> /dev/null; then
    BREW_PREFIX=$(brew --prefix)
    for py in "$BREW_PREFIX"/bin/python3*; do
        [ -f "$py" ] && add_python "$py"
    done
fi

# System Python
add_python "/usr/bin/python3"

# pyenv installations
if command -v pyenv &> /dev/null; then
    while IFS= read -r py_version; do
        add_python "$HOME/.pyenv/versions/$py_version/bin/python3"
    done < <(pyenv versions --bare 2>/dev/null)
fi

# Check /usr/local/bin
for py in /usr/local/bin/python3*; do
    [ -f "$py" ] && add_python "$py"
done

# Remove duplicates based on actual path (follow symlinks)
declare -a UNIQUE_PATHS
declare -a UNIQUE_VERSIONS
for i in "${!PYTHON_PATHS[@]}"; do
    real_path=$(readlink -f "${PYTHON_PATHS[$i]}" 2>/dev/null || realpath "${PYTHON_PATHS[$i]}" 2>/dev/null || echo "${PYTHON_PATHS[$i]}")
    duplicate=false
    for unique in "${UNIQUE_PATHS[@]}"; do
        unique_real=$(readlink -f "$unique" 2>/dev/null || realpath "$unique" 2>/dev/null || echo "$unique")
        if [ "$real_path" = "$unique_real" ]; then
            duplicate=true
            break
        fi
    done
    if [ "$duplicate" = false ]; then
        UNIQUE_PATHS+=("${PYTHON_PATHS[$i]}")
        UNIQUE_VERSIONS+=("${PYTHON_VERSIONS[$i]}")
    fi
done

# Display found Python installations
if [ ${#UNIQUE_PATHS[@]} -eq 0 ]; then
    echo "❌ No Python installations found!"
    exit 1
fi

echo "Found ${#UNIQUE_PATHS[@]} Python installation(s):"
echo ""
for i in "${!UNIQUE_PATHS[@]}"; do
    echo "[$((i+1))] Python ${UNIQUE_VERSIONS[$i]}"
    echo "    Path: ${UNIQUE_PATHS[$i]}"
    echo ""
done

# Get user choice
while true; do
    read -p "Select Python version [1-${#UNIQUE_PATHS[@]}]: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#UNIQUE_PATHS[@]}" ]; then
        PYTHON_PATH="${UNIQUE_PATHS[$((choice-1))]}"
        PYTHON_VERSION="${UNIQUE_VERSIONS[$((choice-1))]}"
        break
    else
        echo "Invalid selection. Please enter a number between 1 and ${#UNIQUE_PATHS[@]}"
    fi
done

echo ""
echo "Selected: Python $PYTHON_VERSION"
echo "Path: $PYTHON_PATH"
echo ""

# Create virtual environment
echo "Creating virtual environment..."
$PYTHON_PATH -m venv .venv

# Activate virtual environment
echo "Activating virtual environment..."
source .venv/bin/activate

# Upgrade pip
echo "Upgrading pip..."
pip install --upgrade pip

echo "✓ Virtual environment created and activated successfully!"
echo ""
echo "To activate the environment in the future, run: source .venv/bin/activate"
echo ""
echo "📌 VS Code Setup:"
echo "1. Press Cmd+Shift+P (or Ctrl+Shift+P on Windows/Linux)"
echo "2. Type 'Python: Select Interpreter'"
echo "3. Choose the interpreter from .venv/bin/python"
echo ""
echo "Or click on the Python version in the bottom-right status bar to select interpreter."
echo ""

# Try to trigger VS Code interpreter selection if code command is available
if command -v code &> /dev/null; then
    echo "Attempting to open interpreter selector in VS Code..."
    code --command python.setInterpreter "$(pwd)/.venv/bin/python"
fi
