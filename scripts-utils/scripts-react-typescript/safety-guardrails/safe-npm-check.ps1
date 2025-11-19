# Safe NPM Check Script for Windows PowerShell
# Runs a series of safety checks before running the application

Write-Host "🔍 Starting safety checks..." -ForegroundColor Cyan
Write-Host ""

# Track issues found
$IssuesFound = 0
$Recommendations = @()

# Step 1: Install dependencies without running scripts
Write-Host "📦 Step 1: Installing dependencies (without scripts)..." -ForegroundColor Yellow
try {
    $installOutput = npm install --ignore-scripts 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Dependencies installed safely" -ForegroundColor Green
    } else {
        throw "Installation failed"
    }
} catch {
    Write-Host "❌ Failed to install dependencies" -ForegroundColor Red
    $IssuesFound++
    $Recommendations += "Fix dependency installation issues"
}
Write-Host ""

# Step 2: Run security audit
Write-Host "🔒 Step 2: Running security audit..." -ForegroundColor Yellow
try {
    $auditOutput = npm audit --production 2>&1
    Write-Host $auditOutput
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Security audit complete - no vulnerabilities" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Security vulnerabilities found" -ForegroundColor Yellow
        $IssuesFound++
        $Recommendations += "Run 'npm audit fix' to address vulnerabilities automatically"
        $Recommendations += "Review vulnerabilities with 'npm audit' for details"
    }
} catch {
    Write-Host "⚠️  Security audit encountered an error" -ForegroundColor Yellow
    $IssuesFound++
    $Recommendations += "Check npm audit output for details"
}
Write-Host ""

# Step 3: Run TypeScript type checking
Write-Host "📝 Step 3: Running TypeScript type check..." -ForegroundColor Yellow
try {
    $typecheckOutput = npm run typecheck 2>&1
    Write-Host $typecheckOutput
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Type check passed" -ForegroundColor Green
    } else {
        Write-Host "❌ Type check failed" -ForegroundColor Red
        $IssuesFound++
        $Recommendations += "Fix TypeScript type errors reported above"
    }
} catch {
    Write-Host "❌ Type check failed" -ForegroundColor Red
    $IssuesFound++
    $Recommendations += "Fix TypeScript type errors reported above"
}
Write-Host ""

# Step 4: Run linting
Write-Host "🧹 Step 4: Running linter..." -ForegroundColor Yellow
try {
    $lintOutput = npm run lint 2>&1
    Write-Host $lintOutput
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Linting passed" -ForegroundColor Green
    } else {
        Write-Host "❌ Linting failed" -ForegroundColor Red
        $IssuesFound++
        $Recommendations += "Fix linting errors with 'npm run lint' or 'npm run lint -- --fix'"
    }
} catch {
    Write-Host "❌ Linting failed" -ForegroundColor Red
    $IssuesFound++
    $Recommendations += "Fix linting errors with 'npm run lint' or 'npm run lint -- --fix'"
}
Write-Host ""

# Summary
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
if ($IssuesFound -eq 0) {
    Write-Host "✨ All safety checks passed successfully!" -ForegroundColor Green
    Write-Host "You can now proceed to run the application." -ForegroundColor Green
} else {
    Write-Host "⚠️  Found $IssuesFound issue(s) during safety checks" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📋 RECOMMENDATIONS:" -ForegroundColor Yellow
    for ($i = 0; $i -lt $Recommendations.Count; $i++) {
        Write-Host "  $($i + 1). $($Recommendations[$i])" -ForegroundColor White
    }
    Write-Host ""
    Write-Host "Please address the issues above before running the application." -ForegroundColor Yellow
    exit 1
}
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Cyan
