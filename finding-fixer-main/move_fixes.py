#!/usr/bin/env python3
import os
import re

# Set your target directory here
target_directory = "./output"

# Iterate through all .py files in the given directory
for file in os.listdir(target_directory):
    if file.endswith(".sh"):
        print(f"Notice: Looking in {file}...")
        file_path = os.path.join(target_directory, file)

        # Read the file and look for the "Finding:" comment line
        with open(file_path, "r") as f:
            content = f.readlines()
        
        for line in content:
            # Search for the "Finding:" pattern
            match = re.search(r"#\s*Finding:\s*([\w.]+)", line)
            if match:
                finding = match.group(1)

                # Create the directory if it doesn't exist
                new_directory = os.path.join(target_directory, finding)
                os.makedirs(new_directory, exist_ok=True)

                # Move the file to the new directory
                new_file_path = os.path.join(new_directory, file)
                print(f"Notice: Moving {file} to {new_file_path}")
                os.rename(file_path, new_file_path)

                # Stop searching for "Finding:" in the current file
                break
