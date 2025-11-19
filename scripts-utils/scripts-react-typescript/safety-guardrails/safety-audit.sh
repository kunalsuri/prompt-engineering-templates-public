#!/bin/bash
# Safety Audit Script v2.0
# Enhanced security scanning for Node.js/TypeScript projects
# Exit codes: 0=safe, 1=critical issues, 2=high severity, 3=warnings only

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters for findings
CRITICAL_COUNT=0
HIGH_COUNT=0
MEDIUM_COUNT=0
LOW_COUNT=0

# Output formatting functions
log_critical() {
    echo -e "${RED}[CRITICAL]${NC} $1"
    ((CRITICAL_COUNT++))
}

log_high() {
    echo -e "${RED}[HIGH]${NC} $1"
    ((HIGH_COUNT++))
}

log_medium() {
    echo -e "${YELLOW}[MEDIUM]${NC} $1"
    ((MEDIUM_COUNT++))
}

log_low() {
    echo -e "${YELLOW}[LOW]${NC} $1"
    ((LOW_COUNT++))
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[OK]${NC} $1"
}

# Check for required tools
check_dependencies() {
    local missing_tools=()
    
    for tool in jq grep find file; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [ ${#missing_tools[@]} -ne 0 ]; then
        echo -e "${RED}ERROR: Missing required tools: ${missing_tools[*]}${NC}"
        echo "Install them and try again."
        exit 1
    fi
}

# Determine project structure
detect_source_dirs() {
    local dirs=()
    for dir in src server client app lib; do
        if [ -d "$dir" ]; then
            dirs+=("$dir")
        fi
    done
    echo "${dirs[@]}"
}

echo "======================================================================"
echo "  Security Audit v1.0 - Enhanced Static Analysis"
echo "======================================================================"
echo ""

# Pre-flight checks
log_info "Checking dependencies..."
check_dependencies
log_success "All required tools available"
echo ""

# Step 1: Validate package.json exists
echo "=== Step 1: Package Manifest Validation ==="
if [ ! -f package.json ]; then
    log_critical "package.json not found in current directory"
    exit 1
fi
log_success "package.json found"

# Validate JSON syntax
if ! jq empty package.json 2>/dev/null; then
    log_critical "package.json contains invalid JSON"
    exit 1
fi
log_success "package.json is valid JSON"
echo ""

# Step 2: Check for dangerous install scripts
echo "=== Step 2: Install Script Security ==="
log_info "Scanning for dangerous install hooks..."

DANGEROUS_SCRIPTS=$(jq -r '.scripts | to_entries[] | select(.key | test("^(pre|post)?install$|^prepare$")) | "\(.key): \(.value)"' package.json 2>/dev/null || echo "")

if [ -n "$DANGEROUS_SCRIPTS" ]; then
    log_high "Found install/prepare scripts that run automatically:"
    echo "$DANGEROUS_SCRIPTS" | while IFS= read -r line; do
        echo "  $line"
        
        # Check for dangerous commands in scripts
        if echo "$line" | grep -qE "(curl|wget|bash -c|sh -c|eval|node -e|python -c)"; then
            log_critical "Script contains command injection risk: $line"
        fi
        
        # Check for network operations
        if echo "$line" | grep -qE "(http://|https://|ftp://)"; then
            log_high "Script makes network requests: $line"
        fi
    done
else
    log_success "No automatic install scripts found"
fi

# Check all scripts for suspicious patterns
ALL_SCRIPTS=$(jq -r '.scripts | to_entries[] | "\(.key): \(.value)"' package.json 2>/dev/null || echo "")
if [ -n "$ALL_SCRIPTS" ]; then
    echo "$ALL_SCRIPTS" | while IFS= read -r line; do
        if echo "$line" | grep -qE "(rm -rf /|sudo |chmod 777)"; then
            log_critical "Dangerous system command in script: $line"
        fi
    done
fi
echo ""

# Step 3: Dependency validation
echo "=== Step 3: Dependency Analysis ==="
log_info "Analyzing package dependencies..."

# Check for typosquatting patterns (common legitimate packages)
LEGIT_PACKAGES=("react" "express" "lodash" "axios" "moment" "webpack" "typescript" "eslint" "prettier")
jq -r '.dependencies // {} | keys[]' package.json 2>/dev/null | while IFS= read -r pkg; do
    for legit in "${LEGIT_PACKAGES[@]}"; do
        # Check for similar names (basic check)
        if [[ "$pkg" =~ ^${legit}[^a-z] ]] || [[ "$pkg" =~ [^a-z]${legit}$ ]]; then
            log_high "Possible typosquatting: '$pkg' (similar to '$legit')"
        fi
    done
    
    # Check for suspicious package names
    if [[ "$pkg" =~ (test|temp|tmp|demo)[0-9]+$ ]] || [[ "$pkg" =~ ^[0-9] ]]; then
        log_medium "Suspicious package name pattern: '$pkg'"
    fi
done

# Count total dependencies
TOTAL_DEPS=$(jq -r '(.dependencies // {} | length) + (.devDependencies // {} | length)' package.json)
log_info "Total dependencies: $TOTAL_DEPS"

if [ "$TOTAL_DEPS" -gt 100 ]; then
    log_medium "Large number of dependencies ($TOTAL_DEPS) increases attack surface"
fi

# Check for lockfile
if [ -f package-lock.json ]; then
    log_success "package-lock.json found (good for reproducibility)"
elif [ -f yarn.lock ]; then
    log_success "yarn.lock found (good for reproducibility)"
elif [ -f pnpm-lock.yaml ]; then
    log_success "pnpm-lock.yaml found (good for reproducibility)"
else
    log_medium "No lockfile found - dependency versions not pinned"
fi
echo ""

# Step 4: Source code security patterns
echo "=== Step 4: Source Code Security Scan ==="
SOURCE_DIRS=($(detect_source_dirs))

if [ ${#SOURCE_DIRS[@]} -eq 0 ]; then
    log_info "No standard source directories found, skipping source scan"
else
    log_info "Scanning directories: ${SOURCE_DIRS[*]}"
    
    # Dangerous patterns with context
    log_info "Checking for high-risk patterns..."
    
    # Command execution
    for dir in "${SOURCE_DIRS[@]}"; do
        if grep -rn "child_process\.\(exec\|spawn\|execFile\)" "$dir" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -v "node_modules"; then
            log_high "Found child_process usage (command execution risk) in $dir"
        fi
        
        # Eval usage
        if grep -rn "\beval\s*(" "$dir" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -v "node_modules"; then
            log_critical "Found eval() usage (code injection risk) in $dir"
        fi
        
        # Dynamic require with variables
        if grep -rn "require\s*(\s*[^'\"]\|require\s*(\s*\`" "$dir" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -v "node_modules"; then
            log_high "Found dynamic require() with variables (injection risk) in $dir"
        fi
        
        # File system writes
        if grep -rn "fs\.write\|fs\.appendFile\|fs\.unlink\|fs\.rmdir" "$dir" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -v "node_modules" | grep -v "// safe:" | grep -v "/* safe"; then
            log_medium "Found filesystem write operations in $dir"
        fi
    done
    
    log_success "Source code pattern scan complete"
fi
echo ""

# Step 5: Secret detection
echo "=== Step 5: Secret & Credential Scan ==="
log_info "Scanning for exposed secrets..."

# Common secret patterns
SECRET_PATTERNS=(
    "api[_-]?key['\"]?\s*[:=]\s*['\"][A-Za-z0-9_-]{20,}['\"]"
    "secret[_-]?key['\"]?\s*[:=]\s*['\"][A-Za-z0-9_-]{20,}['\"]"
    "password['\"]?\s*[:=]\s*['\"][^'\"]{8,}['\"]"
    "token['\"]?\s*[:=]\s*['\"][A-Za-z0-9_-]{20,}['\"]"
    "auth[_-]?token['\"]?\s*[:=]\s*['\"][A-Za-z0-9_-]{20,}['\"]"
    "aws[_-]?access[_-]?key"
    "AKIA[0-9A-Z]{16}"
    "sk_live_[0-9a-zA-Z]{24,}"
    "AIza[0-9A-Za-z_-]{35}"
)

SECRET_FOUND=false
for pattern in "${SECRET_PATTERNS[@]}"; do
    if grep -rn -E "$pattern" . --include="*.{ts,tsx,js,jsx,json,env}" --exclude-dir=node_modules 2>/dev/null; then
        log_critical "Potential hardcoded secret detected (pattern: ${pattern:0:30}...)"
        SECRET_FOUND=true
    fi
done

if [ "$SECRET_FOUND" = false ]; then
    log_success "No obvious hardcoded secrets found"
fi

# Check for .env files with actual values (not .env.example)
if [ -f .env ]; then
    log_medium "Found .env file - ensure it's in .gitignore"
    if git check-ignore .env &>/dev/null; then
        log_success ".env is properly ignored by git"
    else
        log_high ".env is NOT in .gitignore - risk of secret exposure!"
    fi
fi
echo ""

# Step 6: Binary and suspicious file detection
echo "=== Step 6: Suspicious File Detection ==="
log_info "Scanning for unexpected binary or executable files..."

SUSPICIOUS_FILES_FOUND=false

# Check for actual binaries (not just extensions)
while IFS= read -r -d '' file; do
    if file "$file" | grep -qE "(executable|binary|compiled)"; then
        log_high "Suspicious executable file: $file"
        SUSPICIOUS_FILES_FOUND=true
    fi
done < <(find . -type f \( -name "*.exe" -o -name "*.dll" -o -name "*.bin" -o -name "*.so" -o -name "*.dylib" \) -not -path "*/node_modules/*" -print0 2>/dev/null)

# Check for shell scripts outside expected locations
while IFS= read -r -d '' file; do
    if [[ ! "$file" =~ ^\./(scripts|tools|bin|\.git|safety-guardrails)/ ]]; then
        log_medium "Unexpected shell script: $file"
        SUSPICIOUS_FILES_FOUND=true
    fi
done < <(find . -type f \( -name "*.sh" -o -name "*.ps1" -o -name "*.bat" \) -not -path "*/node_modules/*" -print0 2>/dev/null)

# Check for hidden executables
if find . -type f -name ".*" -not -path "*/node_modules/*" -not -path "*/.git/*" | xargs -I {} file {} 2>/dev/null | grep -qE "(executable|binary)"; then
    log_high "Hidden executable files detected"
    SUSPICIOUS_FILES_FOUND=true
fi

if [ "$SUSPICIOUS_FILES_FOUND" = false ]; then
    log_success "No suspicious files detected"
fi
echo ""

# Step 7: Configuration security
echo "=== Step 7: Configuration Security Check ==="

# Check TypeScript strict mode
if [ -f tsconfig.json ]; then
    if jq -e '.compilerOptions.strict == true' tsconfig.json &>/dev/null; then
        log_success "TypeScript strict mode enabled"
    else
        log_low "TypeScript strict mode not enabled (recommended for safety)"
    fi
fi

# Check for CORS misconfigurations
if grep -rn "cors.*origin.*\*" "${SOURCE_DIRS[@]}" --include="*.{ts,tsx,js,jsx}" 2>/dev/null | grep -v "node_modules"; then
    log_medium "Wildcard CORS origin detected (security risk in production)"
fi

log_success "Configuration check complete"
echo ""

# Final Summary
echo "======================================================================"
echo "  Audit Summary"
echo "======================================================================"
echo ""
echo -e "Findings by severity:"
echo -e "  ${RED}CRITICAL: $CRITICAL_COUNT${NC}"
echo -e "  ${RED}HIGH:     $HIGH_COUNT${NC}"
echo -e "  ${YELLOW}MEDIUM:   $MEDIUM_COUNT${NC}"
echo -e "  ${YELLOW}LOW:      $LOW_COUNT${NC}"
echo ""

# Determine exit code and recommendation
if [ $CRITICAL_COUNT -gt 0 ]; then
    echo -e "${RED}❌ AUDIT FAILED${NC}"
    echo "Critical security issues detected. DO NOT PROCEED until resolved."
    echo ""
    echo "Recommended actions:"
    echo "  1. Review all CRITICAL findings above"
    echo "  2. Remove or fix dangerous code patterns"
    echo "  3. Re-run audit after fixes"
    exit 1
elif [ $HIGH_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  AUDIT COMPLETED WITH HIGH SEVERITY ISSUES${NC}"
    echo "High-severity issues found. Review carefully before proceeding."
    echo ""
    echo "Recommended actions:"
    echo "  1. Review all HIGH findings above"
    echo "  2. Assess risk for your specific use case"
    echo "  3. Fix issues or document acceptance of risk"
    exit 2
elif [ $MEDIUM_COUNT -gt 0 ]; then
    echo -e "${YELLOW}⚠️  AUDIT PASSED WITH WARNINGS${NC}"
    echo "Medium-severity issues found. Consider addressing before production."
    echo ""
    echo "Safe to proceed with: npm install --ignore-scripts"
    exit 3
else
    echo -e "${GREEN}✅ AUDIT PASSED${NC}"
    echo "No critical issues detected. Safe to proceed with npm install --ignore-scripts"
    echo ""
    echo "Next steps:"
    echo "  1. npm install --ignore-scripts"
    echo "  2. npm audit --production"
    echo "  3. npm run typecheck"
    echo "  4. npm run lint"
    exit 0
fi
