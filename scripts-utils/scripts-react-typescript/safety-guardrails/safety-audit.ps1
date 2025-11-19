# Safety Audit Script v2.0 for PowerShell
# Enhanced security scanning for Node.js/TypeScript projects
# Exit codes: 0=safe, 1=critical issues, 2=high severity, 3=warnings only

$ErrorActionPreference = "Stop"

# Counters for findings
$CRITICAL_COUNT = 0
$HIGH_COUNT = 0
$MEDIUM_COUNT = 0
$LOW_COUNT = 0

# Output formatting functions
function Log-Critical {
    param([string]$Message)
    Write-Host "[CRITICAL] $Message" -ForegroundColor Red
    $script:CRITICAL_COUNT++
}

function Log-High {
    param([string]$Message)
    Write-Host "[HIGH] $Message" -ForegroundColor Red
    $script:HIGH_COUNT++
}

function Log-Medium {
    param([string]$Message)
    Write-Host "[MEDIUM] $Message" -ForegroundColor Yellow
    $script:MEDIUM_COUNT++
}

function Log-Low {
    param([string]$Message)
    Write-Host "[LOW] $Message" -ForegroundColor Yellow
    $script:LOW_COUNT++
}

function Log-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Cyan
}

function Log-Success {
    param([string]$Message)
    Write-Host "[OK] $Message" -ForegroundColor Green
}

# Check for required tools
function Check-Dependencies {
    $missingTools = @()
    
    $tools = @('node', 'npm')
    foreach ($tool in $tools) {
        if (-not (Get-Command $tool -ErrorAction SilentlyContinue)) {
            $missingTools += $tool
        }
    }
    
    if ($missingTools.Count -gt 0) {
        Write-Host "ERROR: Missing required tools: $($missingTools -join ', ')" -ForegroundColor Red
        Write-Host "Install them and try again."
        exit 1
    }
}

# Determine project structure
function Get-SourceDirs {
    $dirs = @()
    $possibleDirs = @('src', 'server', 'client', 'app', 'lib')
    
    foreach ($dir in $possibleDirs) {
        if (Test-Path $dir -PathType Container) {
            $dirs += $dir
        }
    }
    
    return $dirs
}

Write-Host "======================================================================"
Write-Host "  Security Audit v2.0 - Enhanced Static Analysis"
Write-Host "======================================================================"
Write-Host ""

# Pre-flight checks
Log-Info "Checking dependencies..."
Check-Dependencies
Log-Success "All required tools available"
Write-Host ""

# Step 1: Validate package.json exists
Write-Host "=== Step 1: Package Manifest Validation ==="
if (-not (Test-Path "package.json")) {
    Log-Critical "package.json not found in current directory"
    exit 1
}
Log-Success "package.json found"

# Validate JSON syntax
try {
    $packageJson = Get-Content "package.json" -Raw | ConvertFrom-Json
    Log-Success "package.json is valid JSON"
} catch {
    Log-Critical "package.json contains invalid JSON"
    exit 1
}
Write-Host ""

# Step 2: Check for dangerous install scripts
Write-Host "=== Step 2: Install Script Security ==="
Log-Info "Scanning for dangerous install hooks..."

$dangerousScriptKeys = @('install', 'preinstall', 'postinstall', 'prepare')
$foundDangerousScripts = $false

if ($packageJson.scripts) {
    foreach ($key in $dangerousScriptKeys) {
        if ($packageJson.scripts.PSObject.Properties.Name -contains $key) {
            $scriptValue = $packageJson.scripts.$key
            Log-High "Found install/prepare script that runs automatically:"
            Write-Host "  $key`: $scriptValue"
            $foundDangerousScripts = $true
            
            # Check for dangerous commands in scripts
            if ($scriptValue -match "(curl|wget|bash -c|sh -c|eval|node -e|python -c|Invoke-WebRequest|Invoke-Expression|iwr|iex)") {
                Log-Critical "Script contains command injection risk: $key"
            }
            
            # Check for network operations
            if ($scriptValue -match "(http://|https://|ftp://)") {
                Log-High "Script makes network requests: $key"
            }
        }
    }
}

if (-not $foundDangerousScripts) {
    Log-Success "No automatic install scripts found"
}

# Check all scripts for suspicious patterns
if ($packageJson.scripts) {
    foreach ($script in $packageJson.scripts.PSObject.Properties) {
        $scriptValue = $script.Value
        if ($scriptValue -match "(rm -rf /|Remove-Item.*-Recurse.*-Force|sudo |chmod 777)") {
            Log-Critical "Dangerous system command in script: $($script.Name)"
        }
    }
}
Write-Host ""

# Step 3: Dependency validation
Write-Host "=== Step 3: Dependency Analysis ==="
Log-Info "Analyzing package dependencies..."

# Check for typosquatting patterns
$legitPackages = @('react', 'express', 'lodash', 'axios', 'moment', 'webpack', 'typescript', 'eslint', 'prettier')

if ($packageJson.dependencies) {
    foreach ($pkg in $packageJson.dependencies.PSObject.Properties.Name) {
        foreach ($legit in $legitPackages) {
            # Check for similar names (basic check)
            if ($pkg -match "^$legit[^a-z]" -or $pkg -match "[^a-z]$legit$") {
                Log-High "Possible typosquatting: '$pkg' (similar to '$legit')"
            }
        }
        
        # Check for suspicious package names
        if ($pkg -match "(test|temp|tmp|demo)\d+$" -or $pkg -match "^\d") {
            Log-Medium "Suspicious package name pattern: '$pkg'"
        }
    }
}

# Count total dependencies
$depCount = 0
if ($packageJson.dependencies) {
    $depCount += ($packageJson.dependencies.PSObject.Properties).Count
}
if ($packageJson.devDependencies) {
    $depCount += ($packageJson.devDependencies.PSObject.Properties).Count
}
Log-Info "Total dependencies: $depCount"

if ($depCount -gt 100) {
    Log-Medium "Large number of dependencies ($depCount) increases attack surface"
}

# Check for lockfile
if (Test-Path "package-lock.json") {
    Log-Success "package-lock.json found (good for reproducibility)"
} elseif (Test-Path "yarn.lock") {
    Log-Success "yarn.lock found (good for reproducibility)"
} elseif (Test-Path "pnpm-lock.yaml") {
    Log-Success "pnpm-lock.yaml found (good for reproducibility)"
} else {
    Log-Medium "No lockfile found - dependency versions not pinned"
}
Write-Host ""

# Step 4: Source code security patterns
Write-Host "=== Step 4: Source Code Security Scan ==="
$sourceDirs = Get-SourceDirs

if ($sourceDirs.Count -eq 0) {
    Log-Info "No standard source directories found, skipping source scan"
} else {
    Log-Info "Scanning directories: $($sourceDirs -join ', ')"
    
    Log-Info "Checking for high-risk patterns..."
    
    foreach ($dir in $sourceDirs) {
        # Command execution
        $childProcessFiles = Get-ChildItem -Path $dir -Recurse -Include *.ts,*.tsx,*.js,*.jsx -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch "node_modules" } |
            Select-String -Pattern "child_process\.(exec|spawn|execFile)" -ErrorAction SilentlyContinue
        
        if ($childProcessFiles) {
            Log-High "Found child_process usage (command execution risk) in $dir"
            $childProcessFiles | ForEach-Object { Write-Host "  $($_.Path):$($_.LineNumber)" -ForegroundColor Gray }
        }
        
        # Eval usage
        $evalFiles = Get-ChildItem -Path $dir -Recurse -Include *.ts,*.tsx,*.js,*.jsx -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch "node_modules" } |
            Select-String -Pattern "\beval\s*\(" -ErrorAction SilentlyContinue
        
        if ($evalFiles) {
            Log-Critical "Found eval() usage (code injection risk) in $dir"
            $evalFiles | ForEach-Object { Write-Host "  $($_.Path):$($_.LineNumber)" -ForegroundColor Gray }
        }
        
        # Dynamic require with variables
        $dynamicRequireFiles = Get-ChildItem -Path $dir -Recurse -Include *.ts,*.tsx,*.js,*.jsx -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch "node_modules" } |
            Select-String -Pattern "require\s*\(\s*[^'`"]|require\s*\(\s*\`" -ErrorAction SilentlyContinue
        
        if ($dynamicRequireFiles) {
            Log-High "Found dynamic require() with variables (injection risk) in $dir"
        }
        
        # File system writes
        $fsWriteFiles = Get-ChildItem -Path $dir -Recurse -Include *.ts,*.tsx,*.js,*.jsx -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -notmatch "node_modules" } |
            Select-String -Pattern "fs\.(write|appendFile|unlink|rmdir)" -ErrorAction SilentlyContinue |
            Where-Object { $_.Line -notmatch "// safe:|/\* safe" }
        
        if ($fsWriteFiles) {
            Log-Medium "Found filesystem write operations in $dir"
        }
    }
    
    Log-Success "Source code pattern scan complete"
}
Write-Host ""

# Step 5: Secret detection
Write-Host "=== Step 5: Secret & Credential Scan ==="
Log-Info "Scanning for exposed secrets..."

$secretPatterns = @(
    "api[_-]?key['\`"]?\s*[:=]\s*['\`"][A-Za-z0-9_-]{20,}['\`"]",
    "secret[_-]?key['\`"]?\s*[:=]\s*['\`"][A-Za-z0-9_-]{20,}['\`"]",
    "password['\`"]?\s*[:=]\s*['\`"][^'\`"]{8,}['\`"]",
    "token['\`"]?\s*[:=]\s*['\`"][A-Za-z0-9_-]{20,}['\`"]",
    "auth[_-]?token['\`"]?\s*[:=]\s*['\`"][A-Za-z0-9_-]{20,}['\`"]",
    "aws[_-]?access[_-]?key",
    "AKIA[0-9A-Z]{16}",
    "sk_live_[0-9a-zA-Z]{24,}",
    "AIza[0-9A-Za-z_-]{35}"
)

$secretFound = $false
foreach ($pattern in $secretPatterns) {
    $matches = Get-ChildItem -Recurse -Include *.ts,*.tsx,*.js,*.jsx,*.json,*.env -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "node_modules" } |
        Select-String -Pattern $pattern -ErrorAction SilentlyContinue
    
    if ($matches) {
        Log-Critical "Potential hardcoded secret detected (pattern: $($pattern.Substring(0, [Math]::Min(30, $pattern.Length)))...)"
        $secretFound = $true
    }
}

if (-not $secretFound) {
    Log-Success "No obvious hardcoded secrets found"
}

# Check for .env files
if (Test-Path ".env") {
    Log-Medium "Found .env file - ensure it's in .gitignore"
    
    try {
        git check-ignore .env 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            Log-Success ".env is properly ignored by git"
        } else {
            Log-High ".env is NOT in .gitignore - risk of secret exposure!"
        }
    } catch {
        Log-Medium "Could not verify .env git ignore status"
    }
}
Write-Host ""

# Step 6: Suspicious file detection
Write-Host "=== Step 6: Suspicious File Detection ==="
Log-Info "Scanning for unexpected binary or executable files..."

$suspiciousFilesFound = $false

# Check for executables
$exeFiles = Get-ChildItem -Recurse -Include *.exe,*.dll,*.bin,*.so,*.dylib -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -notmatch "node_modules" }

if ($exeFiles) {
    foreach ($file in $exeFiles) {
        Log-High "Suspicious executable file: $($file.FullName)"
        $suspiciousFilesFound = $true
    }
}

# Check for shell scripts outside expected locations
$scriptFiles = Get-ChildItem -Recurse -Include *.sh,*.ps1,*.bat -ErrorAction SilentlyContinue |
    Where-Object { 
        $_.FullName -notmatch "node_modules" -and
        $_.FullName -notmatch "(scripts|tools|bin|\.git|safety-guardrails)"
    }

if ($scriptFiles) {
    foreach ($file in $scriptFiles) {
        Log-Medium "Unexpected shell script: $($file.FullName)"
        $suspiciousFilesFound = $true
    }
}

if (-not $suspiciousFilesFound) {
    Log-Success "No suspicious files detected"
}
Write-Host ""

# Step 7: Configuration security
Write-Host "=== Step 7: Configuration Security Check ==="

# Check TypeScript strict mode
if (Test-Path "tsconfig.json") {
    try {
        $tsconfig = Get-Content "tsconfig.json" -Raw | ConvertFrom-Json
        if ($tsconfig.compilerOptions.strict -eq $true) {
            Log-Success "TypeScript strict mode enabled"
        } else {
            Log-Low "TypeScript strict mode not enabled (recommended for safety)"
        }
    } catch {
        Log-Low "Could not parse tsconfig.json"
    }
}

# Check for CORS misconfigurations
if ($sourceDirs.Count -gt 0) {
    $corsWildcard = Get-ChildItem -Path $sourceDirs -Recurse -Include *.ts,*.tsx,*.js,*.jsx -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -notmatch "node_modules" } |
        Select-String -Pattern "cors.*origin.*\*" -ErrorAction SilentlyContinue
    
    if ($corsWildcard) {
        Log-Medium "Wildcard CORS origin detected (security risk in production)"
    }
}

Log-Success "Configuration check complete"
Write-Host ""

# Final Summary
Write-Host "======================================================================"
Write-Host "  Audit Summary"
Write-Host "======================================================================"
Write-Host ""
Write-Host "Findings by severity:"
Write-Host "  CRITICAL: $CRITICAL_COUNT" -ForegroundColor $(if ($CRITICAL_COUNT -gt 0) { "Red" } else { "White" })
Write-Host "  HIGH:     $HIGH_COUNT" -ForegroundColor $(if ($HIGH_COUNT -gt 0) { "Red" } else { "White" })
Write-Host "  MEDIUM:   $MEDIUM_COUNT" -ForegroundColor $(if ($MEDIUM_COUNT -gt 0) { "Yellow" } else { "White" })
Write-Host "  LOW:      $LOW_COUNT" -ForegroundColor $(if ($LOW_COUNT -gt 0) { "Yellow" } else { "White" })
Write-Host ""

# Determine exit code and recommendation
if ($CRITICAL_COUNT -gt 0) {
    Write-Host "❌ AUDIT FAILED" -ForegroundColor Red
    Write-Host "Critical security issues detected. DO NOT PROCEED until resolved."
    Write-Host ""
    Write-Host "Recommended actions:"
    Write-Host "  1. Review all CRITICAL findings above"
    Write-Host "  2. Remove or fix dangerous code patterns"
    Write-Host "  3. Re-run audit after fixes"
    exit 1
} elseif ($HIGH_COUNT -gt 0) {
    Write-Host "⚠️  AUDIT COMPLETED WITH HIGH SEVERITY ISSUES" -ForegroundColor Yellow
    Write-Host "High-severity issues found. Review carefully before proceeding."
    Write-Host ""
    Write-Host "Recommended actions:"
    Write-Host "  1. Review all HIGH findings above"
    Write-Host "  2. Assess risk for your specific use case"
    Write-Host "  3. Fix issues or document acceptance of risk"
    exit 2
} elseif ($MEDIUM_COUNT -gt 0) {
    Write-Host "⚠️  AUDIT PASSED WITH WARNINGS" -ForegroundColor Yellow
    Write-Host "Medium-severity issues found. Consider addressing before production."
    Write-Host ""
    Write-Host "Safe to proceed with: npm install --ignore-scripts"
    exit 3
} else {
    Write-Host "✅ AUDIT PASSED" -ForegroundColor Green
    Write-Host "No critical issues detected. Safe to proceed with npm install --ignore-scripts"
    Write-Host ""
    Write-Host "Next steps:"
    Write-Host "  1. npm install --ignore-scripts"
    Write-Host "  2. npm audit --production"
    Write-Host "  3. npm run typecheck"
    Write-Host "  4. npm run lint"
    exit 0
}
