#!/usr/bin/env python3
import os
import sys
import glob

# Defold .model file template
MODEL_TEMPLATE = '''mesh: "{mesh_path}"
name: "{name}"
materials {{
  name: "tiny_treats_1"
  material: "/components/materials/model.material"
  textures {{
    sampler: "tex0"
    texture: "/assets/textures/tiny_treats_texture_1.png"
  }}
}}
'''

# Defold .go file template
GO_TEMPLATE = '''components {{
  id: "{name}"
  component: "{model_path}"
}}
'''

# Defold .factory file template
FACTORY_TEMPLATE = '''prototype: "{go_path}"
'''

# Defold factories.go file template
FACTORIES_GO_TEMPLATE = '''{factories_content}
'''

def generate_files(gltf_file, model_output_folder, go_output_folder, factory_output_folder):
    """Generate .model, .go, and .factory files based on the glTF file name."""
    file_name = os.path.basename(gltf_file)
    name_without_ext = os.path.splitext(file_name)[0]

    # Paths for output files
    model_file_name = f"{name_without_ext}.model"
    go_file_name = f"{name_without_ext}.go"
    factory_file_name = f"{name_without_ext}.factory"

    model_path = os.path.join(model_output_folder, model_file_name)
    go_path = os.path.join(go_output_folder, go_file_name)
    factory_path = os.path.join(factory_output_folder, factory_file_name)

    # Defold relative paths
    model_defold_path = f"/components/models/props/{model_file_name}"
    mesh_defold_path = f"/assets/models/{file_name}"
    go_defold_path = f"/components/gameobjects/props/{go_file_name}"
    factory_defold_path = f"/components/factories/props/{factory_file_name}"

    # Create file contents
    model_content = MODEL_TEMPLATE.format(mesh_path=mesh_defold_path, name=name_without_ext)
    go_content = GO_TEMPLATE.format(name=name_without_ext, model_path=model_defold_path)
    factory_content = FACTORY_TEMPLATE.format(go_path=go_defold_path)

    # Write .model file
    with open(model_path, 'w') as f:
        f.write(model_content)
    print(f"Created {model_path}")

    # Write .go file
    with open(go_path, 'w') as f:
        f.write(go_content)
    print(f"Created {go_path}")

    # Write .factory file
    with open(factory_path, 'w') as f:
        f.write(factory_content)
    print(f"Created {factory_path}")

    return name_without_ext, factory_defold_path

def generate_factories_go(factory_files, output_folder):
    """Generate a single factories.go file containing all .factory references."""
    factories_content = "\n".join(
        f'components {{\n  id: "{name}"\n  component: "{factory_path}"\n}}'
        for name, factory_path in factory_files
    )

    factories_go_path = os.path.join(output_folder, "gameobjects/prop_factories.go")
    factories_go_content = FACTORIES_GO_TEMPLATE.format(factories_content=factories_content)

    with open(factories_go_path, 'w') as f:
        f.write(factories_go_content)
    print(f"Created {factories_go_path}")

def main():
    if len(sys.argv) < 3:
        print("Usage: python generate_defold_files.py <gltf_folder> <output_folder>")
        sys.exit(1)

    gltf_folder = sys.argv[1]
    output_folder = sys.argv[2]

    # Define separate folders for each type
    model_output_folder = os.path.join(output_folder, "models/props")
    go_output_folder = os.path.join(output_folder, "gameobjects/props")
    factory_output_folder = os.path.join(output_folder, "factories/props")

    # Ensure output folders exist
    os.makedirs(model_output_folder, exist_ok=True)
    os.makedirs(go_output_folder, exist_ok=True)
    os.makedirs(factory_output_folder, exist_ok=True)

    # Find all .gltf files
    gltf_files = glob.glob(os.path.join(gltf_folder, "*.gltf"))
    if not gltf_files:
        print("No glTF files found in the specified folder.")
        sys.exit(0)

    factory_files = []

    for gltf_file in gltf_files:
        name, factory_path = generate_files(gltf_file, model_output_folder, go_output_folder, factory_output_folder)
        factory_files.append((name, factory_path))

    # Generate the factories.go file
    generate_factories_go(factory_files, output_folder)

    print("All files generated successfully!")

if __name__ == '__main__':
    main()
