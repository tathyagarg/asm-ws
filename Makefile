# ============= Build Options ============= 
ASSEMBLER = nasm
LINKER = ld
FORMAT = elf64

# ============= Directories =============
SRC_DIR = src
OBJ_DIR = obj
BIN_DIR = bin

# ============= Files =============
SRC = server.asm
OBJ = $(SRC:.asm=.o)
BIN = server

all:
	$(ASSEMBLER) -f $(FORMAT) $(SRC_DIR)/$(SRC) -o $(OBJ_DIR)/$(OBJ)
	$(LINKER) $(OBJ_DIR)/$(OBJ) -o $(BIN_DIR)/$(BIN)

run:
	./$(BIN_DIR)/$(BIN)

clean:
	rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/$(BIN)
