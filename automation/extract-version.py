#!/usr/bin/env python3

import sys
import os
import subprocess
import tempfile
import re
from pathlib import Path

def extract_nsis_and_find_version(installer_path):
    """Extract version info from NSIS installer"""
    
    # First try to get version info from 7zz listing (faster)
    print(f"🔍 Checking installer metadata with 7zz...")
    try:
        result = subprocess.run([
            '7zz', 'l', installer_path
        ], capture_output=True, text=True)  # Don't use check=True since 7zz may return warnings
        
        # Look for ProductVersion in both stdout and stderr (7zz might put info in stderr)
        output = result.stdout + result.stderr
        version_match = re.search(r'ProductVersion:\s*(\d+\.\d+\.\d+(?:\.\d+)?)', output)
        if version_match:
            version = version_match.group(1)
            print(f"🎯 Found ProductVersion: {version}")
            return version
                    
    except FileNotFoundError:
        print("❌ 7zz not found. Install with: brew install sevenzip")
    
    # If that doesn't work, try full extraction
    with tempfile.TemporaryDirectory() as temp_dir:
        extract_dir = Path(temp_dir) / "extracted"
        
        print(f"🗜️  Extracting NSIS installer with 7zz...")
        
        # Try to extract with 7zz
        try:
            result = subprocess.run([
                '7zz', 'x', installer_path, f'-o{extract_dir}', '-y'
            ], capture_output=True, text=True, check=True)
            print(f"✅ Extraction successful")
        except subprocess.CalledProcessError as e:
            print(f"❌ 7zz extraction failed: {e}")
            return None
        except FileNotFoundError:
            print("❌ 7zz not found. Install with: brew install sevenzip")
            return None
        
        # Look for version info in extracted files
        print("🔍 Searching for version info in extracted files...")
        
        version_found = None
        
        # Search for .exe files in extracted content
        for exe_file in extract_dir.rglob("*.exe"):
            print(f"📁 Checking: {exe_file.name}")
            version = extract_version_with_exiftool(exe_file)
            if version and not version.startswith(('1.0.0', '6.0.0')):  # Skip generic versions
                version_found = version
                print(f"🎯 Found version in {exe_file.name}: {version}")
                break
        
        # Also search for version strings in all extracted files
        if not version_found:
            print("🔍 Searching for version strings in extracted files...")
            version_found = search_version_in_files(extract_dir)
                
        return version_found

def extract_version_with_exiftool(file_path):
    """Extract version using exiftool"""
    try:
        result = subprocess.run([
            'exiftool', str(file_path)
        ], capture_output=True, text=True, check=True)
        
        # Look for version patterns in exiftool output
        for line in result.stdout.split('\n'):
            if 'version' in line.lower():
                print(f"  exiftool: {line.strip()}")
                # Extract version number from line
                version_match = re.search(r'(\d+\.\d+\.\d+(?:\.\d+)?)', line)
                if version_match and not version_match.group(1).startswith(('1.0.0', '6.0.0')):
                    return version_match.group(1)
                    
    except (subprocess.CalledProcessError, FileNotFoundError):
        # exiftool not available or failed
        pass
    return None

def search_version_in_files(extract_dir):
    """Search for version patterns in extracted files"""
    version_patterns = [
        r'(\d+\.\d+\.\d+\.\d+)',  # 1.2.3.4
        r'(\d+\.\d+\.\d+)',       # 1.2.3
        r'[Vv]ersion[:\s]*(\d+\.\d+\.\d+)',
        r'Sunsama[:\s]*(\d+\.\d+\.\d+)',
    ]
    
    for file_path in extract_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix.lower() in ['.txt', '.ini', '.cfg', '.json', '.xml']:
            try:
                with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                    content = f.read()
                    
                for pattern in version_patterns:
                    matches = re.findall(pattern, content)
                    for match in matches:
                        if not match.startswith(('1.0.0', '6.0.0', '0.0.0')):
                            print(f"🎯 Found version in {file_path.name}: {match}")
                            return match
                            
            except Exception:
                continue
    
    return None

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python extract-version.py <path-to-installer>")
        sys.exit(1)
    
    installer_path = sys.argv[1]
    if not os.path.exists(installer_path):
        print(f"File not found: {installer_path}")
        sys.exit(1)
    
    print(f"Analyzing: {installer_path}")
    version = extract_nsis_and_find_version(installer_path)
    
    if version:
        print(f"\n🎉 Version found: {version}")
    else:
        print("\n❌ No version found")