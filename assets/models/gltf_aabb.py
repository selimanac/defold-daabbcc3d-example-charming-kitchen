#!/usr/bin/env python3
import os
import sys
import json
import glob

def calc_size(min_vals, max_vals):
    """Calculate the mesh size along each axis."""
    return [max_vals[i] - min_vals[i] for i in range(len(min_vals))]

def calc_center(min_vals, max_vals):
    """Calculate the AABB center position."""
    return [(min_vals[i] + max_vals[i]) / 2 for i in range(len(min_vals))]

def process_gltf_file(file_path):
    """
    Process a single glTF file:
      - Read the JSON.
      - Retrieve the first accessor.
      - Compute the mesh size, AABB, and offset from origin.
    Returns a dictionary containing size, AABB, and offset.
    """
    try:
        with open(file_path, 'r') as f:
            data = json.load(f)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

    # Ensure there's at least one accessor with min/max values
    if "accessors" not in data or len(data["accessors"]) == 0:
        print(f"Warning: No accessors found in {file_path}")
        return None

    accessor = data["accessors"][0]
    if "min" not in accessor or "max" not in accessor:
        print(f"Warning: Accessor missing min or max in {file_path}")
        return None

    min_vals = accessor["min"]
    max_vals = accessor["max"]
    
    size = calc_size(min_vals, max_vals)
    center = calc_center(min_vals, max_vals)  # Compute center of AABB
    offset = center  # Since origin is (0,0,0), offset = center

    return {
        "size": size,
        "aabb": {
            "min": min_vals,
            "max": max_vals
        },
        "offset": offset
    }

def main():
    if len(sys.argv) < 3:
        print("Usage: python process_gltf_offsets.py <input_folder> <output_file.json>")
        sys.exit(1)

    input_folder = sys.argv[1]
    output_file = sys.argv[2]

    # Get all .gltf files in the input folder.
    gltf_files = glob.glob(os.path.join(input_folder, "*.gltf"))
    if not gltf_files:
        print("No glTF files found in the specified folder.")
        sys.exit(0)

    results = {}

    for gltf_file in gltf_files:
        mesh_data = process_gltf_file(gltf_file)
        if mesh_data is not None:
            # Use the file name (without folder path) as the key.
            file_name = os.path.basename(gltf_file)
            name_without_ext = os.path.splitext(file_name)[0]
            results[name_without_ext] = mesh_data
            print(f"Processed {file_name}: size = {mesh_data['size']}, offset = {mesh_data['offset']}")

    # Write results to the output JSON file.
    try:
        with open(output_file, 'w') as out_f:
            json.dump(results, out_f, indent=4)
        print(f"Results written to {output_file}")
    except Exception as e:
        print(f"Error writing output file: {e}")

if __name__ == '__main__':
    main()
