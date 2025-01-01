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

# ============= Configurations =============
PORT = `cat PORT` # Random number because im quirky

all: dyn asm run

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
