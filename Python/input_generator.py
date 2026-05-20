import random
import argparse
from pathlib import Path

def generate_hex_file(filename, num_words=64, mean=7.5, std=2.0):
    base_dir = Path(__file__).resolve().parent
    input_dir = base_dir / "inputs"
    input_dir.mkdir(exist_ok=True)
    file_path = input_dir / filename
    with open(file_path, "w") as f:
        for _ in range(num_words):
            word = 0
            for i in range(16):
                val = random.gauss(mean, std)
                val = int(round(val))
                val = max(0, min(15, val))
                word |= (val & 0xF) << (4 * i)
            f.write(f"{word:016X}\n")
    print(f"Generated file: {file_path}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", type=int, default=None)
    args = parser.parse_args()

    # Seed ONCE before both files — B continues from A's random state
    if args.seed is not None:
        random.seed(args.seed)

    generate_hex_file("A.hex", num_words=64, mean=8, std=3)
    generate_hex_file("B.hex", num_words=64, mean=8, std=3)
