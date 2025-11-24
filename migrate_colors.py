#!/usr/bin/env python3
"""
Color Migration Script for MamaCare
Replaces hardcoded Color(hex: "...") with named colors from design system
"""

import re
import os
from pathlib import Path

# Color mapping dictionary
COLOR_MAP = {
    # Primary Colors
    '00BBA7': 'mamaCarePrimary',
    '009966': 'mamaCarePrimaryDark',
    '00C4B4': 'mamaCareTeal',
    '00A88F': 'mamaCareTealDark',
    
    # Text Colors
    '1F2937': 'mamaCareTextPrimary',
    '6B7280': 'mamaCareTextSecondary',
    '9CA3AF': 'mamaCareTextTertiary',
    '4B5563': 'mamaCareTextDark',
    
    # Background Colors
    'F9FAFB': 'mamaCareGrayLight',
    'F3F4F6': 'mamaCareGrayMedium',
    'E5E7EB': 'mamaCareGrayBorder',
    
    # Accent Colors
    'EC4899': 'mamaCarePink',
    'FCE7F3': 'mamaCarePinkLight',
    '8B5CF6': 'mamaCarePurple',
    'F97316': 'mamaCareOrange',
    'D946EF': 'mamaCareMagenta',
    'FEF2F2': 'mamaCareRedLight',
    'FFF7ED': 'mamaCareOrangeLight',
    'FDF4FF': 'mamaCarePurpleLight',
    '004D40': 'mamaCareDarkGreen',
    
    # Status Colors
    '3B82F6': 'mamaCareUpcoming',  # Also mamaCareBlue
    'F59E0B': 'mamaCareDue',
    'EF4444': 'mamaCareOverdue',
    '10B981': 'mamaCareCompleted',
    
    # Status Background Colors
    'DBEAFE': 'mamaCareUpcomingBg',
    'FEF3C7': 'mamaCareDueBg',
    'FEE2E2': 'mamaCareOverdueBg',
    'D1FAE5': 'mamaCareCompletedBg',
}

def replace_colors_in_file(filepath):
    """Replace Color(hex: "...") with named colors in a single file"""
    with open(filepath, 'r') as f:
        content = f.read()
    
    original_content = content
    replacements_made = 0
    
    # Replace each color
    for hex_code, color_name in COLOR_MAP.items():
        # Match Color(hex: "HEXCODE") - case insensitive hex
        pattern = rf'Color\(hex:\s*"{hex_code}"\)'
        replacement = f'.{color_name}'
        
        # Count replacements
        count = len(re.findall(pattern, content, re.IGNORECASE))
        if count > 0:
            content = re.sub(pattern, replacement, content, flags=re.IGNORECASE)
            replacements_made += count
            print(f"  {hex_code} -> {color_name}: {count} replacement(s)")
    
    # Only write if changes were made
    if content != original_content:
        with open(filepath, 'w') as f:
            f.write(content)
        return replacements_made
    
    return 0

def main():
    """Main function to process all Swift files"""
    views_dir = Path("/Users/udodirim/Desktop/Master's/Project/Mama-Care/Mama-Care/Views")
    
    if not views_dir.exists():
        print(f"Error: Views directory not found at {views_dir}")
        return
    
    # Find all Swift files
    swift_files = list(views_dir.rglob("*.swift"))
    
    # Exclude Colors.swift itself
    swift_files = [f for f in swift_files if f.name != "Colors.swift"]
    
    print(f"Found {len(swift_files)} Swift files to process\n")
    
    total_replacements = 0
    files_modified = 0
    
    for filepath in swift_files:
        print(f"\nProcessing: {filepath.name}")
        replacements = replace_colors_in_file(filepath)
        
        if replacements > 0:
            files_modified += 1
            total_replacements += replacements
            print(f"✅ Modified {filepath.name}: {replacements} replacements")
        else:
            print(f"⏭️  No changes needed")
    
    print(f"\n{'='*60}")
    print(f"Migration Complete!")
    print(f"Files modified: {files_modified}/{len(swift_files)}")
    print(f"Total replacements: {total_replacements}")
    print(f"{'='*60}")

if __name__ == "__main__":
    main()
