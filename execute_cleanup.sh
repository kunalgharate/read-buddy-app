#!/bin/bash

# Navigate to workspace
cd /workspace

echo "=== CURRENT GIT STATUS ==="
git status

echo ""
echo "=== CURRENT COMMIT LOG ==="
git log --oneline -5

echo ""
echo "=== CHECKING FOR FILES TO BE CLEANED ==="

# Check if android folder exists
if [ -d "android" ]; then
    echo "✓ android/ folder exists and will be removed"
    ls -la android/ | head -10
else
    echo "✗ android/ folder does not exist"
fi

# Check if assets/mock folder exists
if [ -d "assets/mock" ]; then
    echo "✓ assets/mock/ folder exists and will be removed"
    ls -la assets/mock/
else
    echo "✗ assets/mock/ folder does not exist"
fi

# Check if macos/Flutter folder exists
if [ -d "macos/Flutter" ]; then
    echo "✓ macos/Flutter/ folder exists and will be removed"
    ls -la macos/Flutter/
else
    echo "✗ macos/Flutter/ folder does not exist"
fi

# Check if .idea folder exists
if [ -d ".idea" ]; then
    echo "✓ .idea/ folder exists and will be removed"
else
    echo "✗ .idea/ folder does not exist"
fi

echo ""
echo "=== RUNNING CLEANUP SCRIPT ==="
bash cleanup_script.sh