#!/bin/bash

# Safe NPM Check Script
# Runs a series of safety checks before running the application

echo "🔍 Starting safety checks..."
echo ""

# Track issues found
ISSUES_FOUND=0
RECOMMENDATIONS=()

# Step 1: Install dependencies without running scripts
echo "📦 Step 1: Installing dependencies (without scripts)..."
if npm install --ignore-scripts; then
    echo "✅ Dependencies installed safely"
else
    echo "❌ Failed to install dependencies"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    RECOMMENDATIONS+=("Fix dependency installation issues")
fi
echo ""

# Step 2: Run security audit
echo "🔒 Step 2: Running security audit..."
if npm audit --production 2>&1 | tee /tmp/audit-output.txt; then
    echo "✅ Security audit complete - no vulnerabilities"
else
    echo "⚠️  Security vulnerabilities found"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    RECOMMENDATIONS+=("Run 'npm audit fix' to address vulnerabilities automatically")
    RECOMMENDATIONS+=("Review vulnerabilities with 'npm audit' for details")
fi
echo ""

# Step 3: Run TypeScript type checking
echo "📝 Step 3: Running TypeScript type check..."
if npm run typecheck; then
    echo "✅ Type check passed"
else
    echo "❌ Type check failed"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    RECOMMENDATIONS+=("Fix TypeScript type errors reported above")
fi
echo ""

# Step 4: Run linting
echo "🧹 Step 4: Running linter..."
if npm run lint; then
    echo "✅ Linting passed"
else
    echo "❌ Linting failed"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
    RECOMMENDATIONS+=("Fix linting errors with 'npm run lint' or 'npm run lint -- --fix'")
fi
echo ""

# Summary
echo "════════════════════════════════════════════════════════════════"
if [ $ISSUES_FOUND -eq 0 ]; then
    echo "✨ All safety checks passed successfully!"
    echo "You can now proceed to run the application."
else
    echo "⚠️  Found $ISSUES_FOUND issue(s) during safety checks"
    echo ""
    echo "📋 RECOMMENDATIONS:"
    for i in "${!RECOMMENDATIONS[@]}"; do
        echo "  $((i + 1)). ${RECOMMENDATIONS[$i]}"
    done
    echo ""
    echo "Please address the issues above before running the application."
    exit 1
fi
echo "════════════════════════════════════════════════════════════════"
