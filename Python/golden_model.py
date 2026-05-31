from pathlib import Path
 
SCRIPT_DIR = Path(__file__).resolve().parent
INPUT_DIR = SCRIPT_DIR / "inputs"
OUTPUT_DIR = SCRIPT_DIR / "outputs"
OUTPUT_DIR.mkdir(exist_ok=True)
 
##########################################################################
#################### FUNCTION USED IN ALL CALCULATION ####################
##########################################################################
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
 
def write_matrix_packed_to_file(mat, width, f):
    for row in mat:
        packed = "".join(f"{x:0{width}X}" for x in reversed(row))
        f.write(f"{packed}\n")
 
def invert_words(words):
    MASK = 0xFFFFFFFFFFFFFFFF
    return [(~w) & MASK for w in words]
 
###############################################################
#################### Supporting Functions  ####################
###############################################################
 
def print_matrix_packed(mat, name, width):
    print(name)
    for row in mat:
        packed = "".join(f"{x:0{width}X}" for x in reversed(row))
        print(" ", packed)
    print()
 
def sign_extend_4(x):
    """Decode 4-bit two's complement nibble to signed int."""
    return x if x < 8 else x - 16
 
def sm4_to_int(x):
    """Decode 4-bit sign-magnitude nibble to signed int."""
    x &= 0xF
    sign = (x >> 3) & 1
    mag  = x & 0x7
    return -mag if sign else mag
 
def _pack_row_SE(row, bits=16):
    packed_elements = []
    for x in reversed(row):
        val = x & 0x3FFF
        if val & 0x2000:
            val |= 0xC000
        mask = (1 << bits) - 1
        hex_chars = bits // 4
        packed_elements.append(f"{val & mask:0{hex_chars}X}")
    return "".join(packed_elements)
 
def print_matrix_packed_SE(mat, name, bits):
    print(name)
    for row in mat:
        print(" ", _pack_row_SE(row, bits))
    print()
 
def write_matrix_packed_to_file_SE(mat, bits, f):
    for row in mat:
        f.write(_pack_row_SE(row, bits) + "\n")
 
#####################################################################################
#################### MATMUL CALCULATION FOR Different Encodings  ####################
#####################################################################################
 
def matmul_hw_TC_TC(A, B, C):
    """Both A and B decoded as 4-bit two's complement."""
    Y = [[0] * 4 for _ in range(4)]
    for i in range(4):
        for j in range(4):
            acc = C[i][j] & 0x3FFF
            for k in range(4):
                a = sign_extend_4(A[i][k])
                b = sign_extend_4(B[k][j])
                acc += a * b
            acc &= 0x3FFF
            Y[i][j] = acc
    return Y
 
def matmul_hw_SM_TC(A, B, C):
    """Both A and B decoded as 4-bit sign-magnitude.
    SM input -> multiply-accumulate -> TC output (result naturally in TC).
    """
    Y = [[0] * 4 for _ in range(4)]
    for i in range(4):
        for j in range(4):
            acc = C[i][j] & 0x3FFF
            for k in range(4):
                a = sm4_to_int(A[i][k])
                b = sm4_to_int(B[k][j])
                acc += a * b
            acc &= 0x3FFF
            Y[i][j] = acc
    return Y
 
####################################################
#################### MAIN CODE  ####################
####################################################
 
def run_mode(mode, A_words, B_words):
    NUM_LARGE_ROUNDS = 64
    NUM_SMALL_ROUNDS = 8
 
    for times in range(2):
        filename = OUTPUT_DIR / f"Golden_Model_Out_{mode}_{times}.hex"
        with open(filename, "w") as f:
            for large_round in range(NUM_LARGE_ROUNDS):
                print(f"[{mode}] LARGE ROUND {large_round}")
                C = [[0] * 4 for _ in range(4)]
                a_block = (large_round // 8) * 8
                b_block = (large_round % 8) * 8
 
                for small_round in range(NUM_SMALL_ROUNDS):
                    a_idx = a_block + small_round
                    b_idx = b_block + small_round
 
                    A = unpack_64_to_4x4(A_words[a_idx])
                    B = unpack_64_to_4x4(B_words[b_idx])
 
                    if mode == "TC_TC":
                        Y = matmul_hw_TC_TC(A, B, C)
                    else:  # SM_TC
                        Y = matmul_hw_SM_TC(A, B, C)
 
                    C = [row[:] for row in Y]
 
                print_matrix_packed_SE(Y, "Y", 16)
                write_matrix_packed_to_file_SE(Y, 16, f)
 
        A_words = invert_words(A_words)
        B_words = invert_words(B_words)
 
def main():
    run_mode("TC_TC", load_hex_file("A_TC.hex"), load_hex_file("B_TC.hex"))
    run_mode("SM_TC", load_hex_file("A_SM.hex"), load_hex_file("B_SM.hex"))
 
if __name__ == "__main__":
    main()
