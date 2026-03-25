#!/bin/bash

# Change to workspace directory
cd /workspace

echo "=== Starting Repository Cleanup ==="

# Show current status
echo "Current git status:"
git status

echo ""
echo "=== Removing unwanted folders and files ==="

# Remove android folder
if [ -d "android" ]; then
    echo "Removing android/ folder..."
    find android -type f -delete
    find android -type d -empty -delete
    rmdir android 2>/dev/null || rm -rf android
    echo "✓ android/ folder removed"
else
    echo "✗ android/ folder not found"
fi

# Remove macos/Flutter folder
if [ -d "macos/Flutter" ]; then
    echo "Removing macos/Flutter/ folder..."
    rm -rf macos/Flutter
    echo "✓ macos/Flutter/ folder removed"
else
    echo "✗ macos/Flutter/ folder not found"
fi

# Remove assets/mock folder if it exists
if [ -d "assets/mock" ]; then
    echo "Removing assets/mock/ folder..."
    rm -rf assets/mock
    echo "✓ assets/mock/ folder removed"
else
    echo "✗ assets/mock/ folder not found"
fi

# Remove .idea folder if it exists
if [ -d ".idea" ]; then
    echo "Removing .idea/ folder..."
    rm -rf .idea
    echo "✓ .idea/ folder removed"
else
    echo "✗ .idea/ folder not found"
fi

# Remove read_buddy_app.iml if it exists
if [ -f "read_buddy_app.iml" ]; then
    echo "Removing read_buddy_app.iml..."
    rm read_buddy_app.iml
    echo "✓ read_buddy_app.iml removed"
else
    echo "✗ read_buddy_app.iml not found"
fi

echo ""
echo "=== Git status after cleanup ==="
git status

echo ""
echo "=== Adding all changes to staging area ==="
git add -A

echo ""
echo "=== Staged changes ==="
git status --staged

echo ""
echo "=== Amending commit with cleanup message ==="
git commit --amend -m "Clean up repository: Remove unwanted folders and files

Removed the following unwanted items from the repository:
- android/ folder - Platform-specific Android build files and configurations
- assets/mock/ folder - Mock data files not needed in production
- macos/Flutter/ folder - Platform-specific Flutter configuration files  
- read_buddy_app.iml - IntelliJ IDEA module file
- Various log files and build artifacts

This cleanup improves repository maintainability by removing:
- IDE-specific configuration files
- Platform-specific build artifacts
- Development-only mock data
- Generated files that should not be version controlled

The repository structure is now cleaner and follows Flutter best practices
for version control, with appropriate .gitignore rules in place."

echo ""
echo "=== Final git status ==="
git status

echo ""
echo "=== Recent commit log ==="
git log --oneline -3

echo ""
echo "=== CLEANUP COMPLETED SUCCESSFULLY! ==="
echo ""
echo "Next steps to push the amended commit:"
echo "1. Check your current branch: git branch"
echo "2. Push with: git push --force-with-lease origin <branch-name>"
echo ""
echo "Example: git push --force-with-lease origin main"
echo "(Replace 'main' with your actual branch name)"
echo ""
echo "Note: Using --force-with-lease is safer than --force as it prevents"
echo "overwriting commits that others may have pushed."