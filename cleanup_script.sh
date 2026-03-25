#!/bin/bash

# Script to remove unwanted folders and files from the repository

echo "Starting cleanup of unwanted folders and files..."

# Check current git status
echo "Current git status:"
git status

# Remove remaining android folder contents
echo "Removing remaining android folder contents..."
if [ -d "android" ]; then
    echo "Removing android folder completely..."
    rm -rf android
fi

# Remove any remaining assets/mock folder
if [ -d "assets/mock" ]; then
    echo "Removing assets/mock folder..."
    rm -rf assets/mock
fi

# Remove any remaining macos/Flutter folder
if [ -d "macos/Flutter" ]; then
    echo "Removing macos/Flutter folder..."
    rm -rf macos/Flutter
fi

# Remove .idea folder if it exists
if [ -d ".idea" ]; then
    echo "Removing .idea folder..."
    rm -rf .idea
fi

# Check git status after removal
echo "Git status after removal:"
git status

# Add all changes to staging (including deletions)
echo "Adding all changes to staging area..."
git add -A

# Show what will be committed
echo "Changes to be committed:"
git status --staged

# Amend the last commit with proper message
echo "Amending commit with cleanup message..."
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

echo "Cleanup completed successfully!"
echo "Final git status:"
git status

echo ""
echo "=== NEXT STEPS ==="
echo "To push the amended commit to your remote branch, run:"
echo "git push --force-with-lease origin <your-branch-name>"
echo ""
echo "Replace <your-branch-name> with your actual branch name."
echo "Use --force-with-lease for safer force pushing."