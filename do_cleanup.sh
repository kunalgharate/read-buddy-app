#!/bin/bash

cd /workspace

echo "=== CURRENT GIT STATUS ==="
git status

echo ""
echo "=== REMOVING ANDROID FOLDER ==="
rm -rf android

echo ""
echo "=== REMOVING MACOS/FLUTTER FOLDER ==="
rm -rf macos/Flutter

echo ""
echo "=== REMOVING ASSETS/MOCK FOLDER IF EXISTS ==="
rm -rf assets/mock

echo ""
echo "=== REMOVING .IDEA FOLDER IF EXISTS ==="
rm -rf .idea

echo ""
echo "=== GIT STATUS AFTER CLEANUP ==="
git status

echo ""
echo "=== ADDING ALL CHANGES ==="
git add -A

echo ""
echo "=== STAGED CHANGES ==="
git status --staged

echo ""
echo "=== AMENDING COMMIT ==="
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
echo "=== FINAL STATUS ==="
git status

echo ""
echo "=== COMMIT LOG ==="
git log --oneline -3

echo ""
echo "=== CLEANUP COMPLETED ==="
echo "To push the amended commit, run:"
echo "git push --force-with-lease origin main"
echo "(Replace 'main' with your actual branch name)"