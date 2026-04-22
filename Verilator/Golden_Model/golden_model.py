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

def load_hex_file(filename):
    words = []
    with open(filename, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue  # skip empty lines / comments
            words.append(int(line, 16))
    return words

A_words = [
    0x0123456789ABCDEF,0xDDDDDDDDFFFFFFFD,0xCCCCFFFFCCCCFFFC,0xBBBBFFBBBBFFFFFB,
    0xAAAAAAFFFFAAFFFA,0x9999F9FF9FFFFFF9,0x8888F888F8FFFFF8,0x7777FF7FF7FFFFF7,
    0x666666666666FFF6,0x55555555FFFFFFF5,0x4444FFFF4444FFF4,0x3333FF3333FFFFF3,
    0x222222FFFF22FFF2,0x1111F1FF1FFFFFF1,0x0000F000F0FFFFF0,0xEEEEEEEEEEEEFFEF,
    0xDDDDDDDDFFFFFFEE,0xCCCCFFFFCCCCFFED,0xBBBBFFBBBBFFFFEC,0xAAAAAAFFFFAAFFEB,
    0x9999F9FF9FFFFFEA,0x8888F888F8FFFFE9,0x7777FF7FF7FFFFE8,0x666666666666FFE7,
    0x55555555FFFFFFE6,0x4444FFFF4444FFE5,0x3333FF3333FFFFE4,0x222222FFFF22FFE3,
    0x1111F1FF1FFFFFE2,0x0000F000F0FFFFE1,0xEEEEEEEEEEEEFFE0,0xDDDDDDDDFFFFFFDF,
    0xCCCCFFFFCCCCFFDE,0xBBBBFFBBBBFFFFDD,0xAAAAAAFFFFAAFFDC,0x9999F9FF9FFFFFDB,
    0x8888F888F8FFFFDA,0x7777FF7FF7FFFFD9,0x666666666666FFD8,0x55555555FFFFFFD7,
    0x4444FFFF4444FFD6,0x3333FF3333FFFFD5,0x222222FFFF22FFD4,0x1111F1FF1FFFFFD3,
    0x0000F000F0FFFFD2,0xEEEEEEEEEEEEFFD1,0xDDDDDDDDFFFFFFD0,0xCCCCFFFFCCCCFFCF,
    0xBBBBFFBBBBFFFFCE,0xAAAAAAFFFFAAFFCD,0x9999F9FF9FFFFFCC,0x8888F888F8FFFFCB,
    0x7777FF7FF7FFFFCA,0x666666666666FFC9,0x55555555FFFFFFC8,0x4444FFFF4444FFC7,
    0x3333FF3333FFFFC6,0x222222FFFF22FFC5,0x1111F1FF1FFFFFC4,0x0000F000F0FFFFC3,
    0xEEEEEEEEEEEEFFC2,0xDDDDDDDDFFFFFFC1,0xCCCCFFFFCCCCFFC0,0xBBBBFFBBBBFFFFBF
]

B_words = [
    0xAAAAAAFFFFAAFFBE,0x9999F9FF9FFFFFBD,0x8888F888F8FFFFBC,0x7777FF7FF7FFFFBB,
    0x666666666666FFBA,0x55555555FFFFFFB9,0x4444FFFF4444FFB8,0x3333FF3333FFFFB7,
    0x222222FFFF22FFB6,0x1111F1FF1FFFFFB5,0x0000F000F0FFFFB4,0xEEEEEEEEEEEEFFB3,
    0xDDDDDDDDFFFFFFB2,0xCCCCFFFFCCCCFFB1,0xBBBBFFBBBBFFFFB0,0xAAAAAAFFFFAAFFAF,
    0x9999F9FF9FFFFFAE,0x8888F888F8FFFFAD,0x7777FF7FF7FFFFAC,0x666666666666FFAB,
    0x55555555FFFFFFAA,0x4444FFFF4444FFA9,0x3333FF3333FFFFA8,0x222222FFFF22FFA7,
    0x1111F1FF1FFFFFA6,0x0000F000F0FFFFA5,0xEEEEEEEEEEEEFFA4,0xDDDDDDDDFFFFFFA3,
    0xCCCCFFFFCCCCFFA2,0xBBBBFFBBBBFFFFA1,0xAAAAAAFFFFAAFFA0,0x9999F9FF9FFFFF9F,
    0x8888F888F8FFFF9E,0x7777FF7FF7FFFF9D,0x666666666666FF9C,0x55555555FFFFFF9B,
    0x4444FFFF4444FF9A,0x3333FF3333FFFF99,0x222222FFFF22FF98,0x1111F1FF1FFFFF97,
    0x0000F000F0FFFF96,0xEEEEEEEEEEEEFF95,0xDDDDDDDDFFFFFF94,0xCCCCFFFFCCCCFF93,
    0xBBBBFFBBBBFFFF92,0xAAAAAAFFFFAAFF91,0x9999F9FF9FFFFF90,0x8888F888F8FFFF8F,
    0x7777FF7FF7FFFF8E,0x666666666666FF8D,0x55555555FFFFFF8C,0x4444FFFF4444FF8B,
    0x3333FF3333FFFF8A,0x222222FFFF22FF89,0x1111F1FF1FFFFF88,0x0000F000F0FFFF87,
    0xEEEEEEEEEEEEFF86,0xDDDDDDDDFFFFFF85,0xCCCCFFFFCCCCFF84,0xBBBBFFBBBBFFFF83,
    0xAAAAAAFFFFAAFF82,0x9999F9FF9FFFFF81,0x8888F888F8FFFF80,0x7777FF7FF7FFFF7F
]

NUM_LARGE_ROUNDS = 64
NUM_SMALL_ROUNDS = 8

with open("Golden_Model_Out.txt", "w") as f:
    for large_round in range(NUM_LARGE_ROUNDS):
        print(f"LARGE ROUND {large_round}")
    
        C = [[0] * 4 for _ in range(4)]  # reset every large round
    
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
