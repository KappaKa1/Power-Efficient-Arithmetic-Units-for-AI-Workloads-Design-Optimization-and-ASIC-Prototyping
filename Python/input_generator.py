'''
# Input Generator that produces SM and TC individually with mean = 0, std =3
import random
import argparse
from pathlib import Path
 
SCRIPT_DIR = Path(__file__).resolve().parent
INPUT_DIR = SCRIPT_DIR / "inputs"
INPUT_DIR.mkdir(exist_ok=True)
 
def encode_tc(val):
    """Clamp to [-8,7] and encode as 4-bit two's complement nibble."""
    val = max(-8, min(7, val))
    return val & 0xF
 
def encode_sm(val):
    """Clamp to [-7,7] and encode as 4-bit sign-magnitude nibble."""
    val = max(-7, min(7, val))
    sign = 1 if val < 0 else 0
    return (sign << 3) | abs(val)
 
def generate_hex_file(filename, num_words=64, mean=0, std=3, encoding="TC"):
    file_path = INPUT_DIR / filename
    with open(file_path, "w") as f:
        for _ in range(num_words):
            word = 0
            for i in range(16):
                val = int(round(random.gauss(mean, std)))
                if encoding == "TC":
                    nibble = encode_tc(val)
                else:  # SM
                    nibble = encode_sm(val)
                word |= (nibble & 0xF) << (4 * i)
            f.write(f"{word:016X}\n")
    print(f"Generated: {file_path} (encoding={encoding}, mean={mean}, std={std})")
 
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Input generator for TC and SM hex files")
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument("--mean", type=float, default=0)
    parser.add_argument("--std",  type=float, default=3)
    args = parser.parse_args()
 
    if args.seed is not None:
        random.seed(args.seed)
 
    generate_hex_file("A_TC.hex", mean=args.mean, std=args.std, encoding="TC")
    generate_hex_file("B_TC.hex", mean=args.mean, std=args.std, encoding="TC")
    generate_hex_file("A_SM.hex", mean=args.mean, std=args.std, encoding="SM")
    generate_hex_file("B_SM.hex", mean=args.mean, std=args.std, encoding="SM")
'''
import random
import argparse
from pathlib import Path
 
SCRIPT_DIR = Path(__file__).resolve().parent
INPUT_DIR = SCRIPT_DIR / "inputs"
INPUT_DIR.mkdir(exist_ok=True)
 
def sign_extend_4(x):
    return x if x < 8 else x - 16
 
def encode_tc(val):
    """Clamp to [-8,7] and encode as 4-bit two's complement nibble."""
    val = max(-8, min(7, val))
    return val & 0xF
 
def encode_sm(val):
    """Clamp to [-7,7] and encode as 4-bit sign-magnitude nibble.
    -8 is not representable in SM, so it gets clamped to -7.
    """
    val = max(-7, min(7, val))
    sign = 1 if val < 0 else 0
    return (sign << 3) | abs(val)
 
def generate_hex_files(filename_tc, filename_sm, num_words=64, mean=0, std=3):
    """Generate TC and SM hex files from the same Gaussian draws.
    TC is the master: sample v ~ N(mean, std), encode as TC and SM separately.
    Both files represent identical decoded values, just different bit patterns.
    """
    with open(INPUT_DIR / filename_tc, "w") as f_tc, \
         open(INPUT_DIR / filename_sm, "w") as f_sm:
        for _ in range(num_words):
            word_tc = 0
            word_sm = 0
            for i in range(16):
                val = int(round(random.gauss(mean, std)))
                val = max(-8, min(7, val))        # TC range is master
                tc_nibble = encode_tc(val)
                sm_nibble = encode_sm(val)        # same val, re-encoded as SM
                word_tc |= (tc_nibble & 0xF) << (4 * i)
                word_sm |= (sm_nibble & 0xF) << (4 * i)
            f_tc.write(f"{word_tc:016X}\n")
            f_sm.write(f"{word_sm:016X}\n")
    print(f"Generated: {INPUT_DIR / filename_tc} and {INPUT_DIR / filename_sm} (mean={mean}, std={std})")
 
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Input generator: TC is master, SM derived from same values")
    parser.add_argument("--seed", type=int, default=None)
    parser.add_argument("--mean", type=float, default=0)
    parser.add_argument("--std",  type=float, default=3)
    args = parser.parse_args()
 
    if args.seed is not None:
        random.seed(args.seed)
 
    generate_hex_files("A_TC.hex", "A_SM.hex", mean=args.mean, std=args.std)
    generate_hex_files("B_TC.hex", "B_SM.hex", mean=args.mean, std=args.std)
