# ============= Build Options ============= 
ASSEMBLER = nasm
LINKER = ld

# ============= Directories =============
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# ============= Files =============
SRC = server.asm
ROUTING = routing/routing.asm
OBJ = $(SRC:.asm=.o)
ROUTING_OBJ = routing.o
BIN = server
ASMFLAGS = -f elf64
ASM_OPTIMIZE = -O0

PYTHON = python3.13
PYTHON_FILE = src/routing/dynamic.py

RESPONSES_DIR = templates/post_responses

CC = gcc
CFLAGS = -Wall -Wextra -Werror -Wno-unused-parameter -Wno-unused-variable -Wno-unused-function -Wno-unused-but-set-variable -Wno-unused-value -Wno-unused-label -Wno-unused-result -Wno-unused-local-typedefs
COPT = -O3
POST_BIN = templates/post_responses/bin

# ============= Configurations =============
PORT = `cat PORT` # Random number because im quirky

all: dyn responses asm run

asm:
	$(ASSEMBLER) $(SRC_DIR)/$(SRC) -o $(OBJ_DIR)/$(OBJ) $(ASMFLAGS) $(ASM_OPTIMIZE)
	$(ASSEMBLER) $(SRC_DIR)/$(ROUTING) -o $(OBJ_DIR)/$(ROUTING_OBJ) $(ASMFLAGS) $(ASM_OPTIMIZE)
	$(LINKER) $(OBJ_DIR)/$(ROUTING_OBJ) $(OBJ_DIR)/$(OBJ) -o $(BIN_DIR)/$(BIN)

run:
	./$(BIN_DIR)/$(BIN) $(PORT)

clean:
	rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/$(BIN)

dyn:
	$(PYTHON) $(PYTHON_FILE)

responses:
	for src_file in "$(RESPONSES_DIR)"/*.c; do\
		$(CC) $(CFLAGS) $(COPT) -c $$src_file -o $(POST_BIN)/$$(basename $$src_file .c).o;\
	done

