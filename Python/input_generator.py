import random
from pathlib import Path

def generate_hex_file(filename="A.hex", num_words=64, mean=7.5, std=2.0, seed=None):
    base_dir = Path(__file__).resolve().parent
    input_dir = base_dir / "inputs"
    input_dir.mkdir(exist_ok=True)

    file_path = input_dir / filename

    if seed is not None:
        random.seed(seed)

    with open(file_path, "w") as f:
        for _ in range(num_words):
            word = 0
            for i in range(16):
                # Gaussian using built-in random
                val = random.gauss(mean, std)

                # round and clamp to 4-bit
                val = int(round(val))
                val = max(0, min(15, val))

                word |= (val & 0xF) << (4 * i)

            f.write(f"{word:016X}\n")

    print(f"Generated file: {file_path}")

generate_hex_file("A.hex", num_words=64, mean=8, std=3, seed=42)
generate_hex_file("B.hex", num_words=64, mean=8, std=3, seed=42)