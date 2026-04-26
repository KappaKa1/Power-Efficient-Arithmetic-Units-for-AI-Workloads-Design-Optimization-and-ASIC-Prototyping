from pathlib import Path

SCRIPT_DIR = Path(__file__).resolve().parent
INPUT_DIR = SCRIPT_DIR / "inputs"
OUTPUT_DIR = SCRIPT_DIR / "outputs"

OUTPUT_DIR.mkdir(exist_ok=True)

def load_hex_file(filename):
    words = []
    path = INPUT_DIR / filename

    with open(path, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            words.append(int(line, 16))

    return words

def unpack_64_to_4x4(word64):
    nibbles = [(word64 >> (4 * i)) & 0xF for i in range(16)]
    return [nibbles[r * 4:(r + 1) * 4] for r in range(4)]

def matmul_hw(A, B, C):
    """
    Matches your current hardware behavior:
      - A and B treated as unsigned 4-bit
      - accumulation uses lower 13 bits
      - output bit[13] forced high => 0x2000
    """
    Y = [[0] * 4 for _ in range(4)]
    for i in range(4):
        for j in range(4):
            acc = C[i][j] & 0x1FFF
            for k in range(4):
                acc += A[i][k] * B[k][j]
            acc &= 0x1FFF
            Y[i][j] = 0x0000 | acc
    return Y

def print_matrix_packed(mat, name, width):
    print(name)
    for row in mat:
        packed = "".join(f"{x:0{width}X}" for x in reversed(row))
        print(" ", packed)
    print()

def write_matrix_packed_to_file(mat, width, f):
    for row in mat:
        packed = "".join(f"{x:0{width}X}" for x in reversed(row))
        f.write(f"{packed}\n")

def invert_words(words):
    MASK = 0xFFFFFFFFFFFFFFFF  # 64-bit mask
    return [(~w) & MASK for w in words]

A_words = load_hex_file("A.hex")
B_words = load_hex_file("B.hex")

NUM_LARGE_ROUNDS = 64
NUM_SMALL_ROUNDS = 8

for times in range(2):
    filename = OUTPUT_DIR / f"Golden_Model_Out_{times}.hex"

    with open(filename, "w") as f:
        for large_round in range(NUM_LARGE_ROUNDS):
            print(f"LARGE ROUND {large_round}")

            C = [[0] * 4 for _ in range(4)]

            a_block = (large_round // 8) * 8
            b_block = (large_round % 8) * 8

            for small_round in range(NUM_SMALL_ROUNDS):
                a_idx = a_block + small_round
                b_idx = b_block + small_round

                A_word = A_words[a_idx]
                B_word = B_words[b_idx]

                A = unpack_64_to_4x4(A_word)
                B = unpack_64_to_4x4(B_word)
                Y = matmul_hw(A, B, C)

                C = [row[:] for row in Y]

            print_matrix_packed(Y, "Y", 4)
            write_matrix_packed_to_file(Y, 4, f)

    # invert AFTER finishing file
    A_words = invert_words(A_words)
    B_words = invert_words(B_words)
