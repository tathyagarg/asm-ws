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

CC = gcc
C_SRC = src/routing/dynamic.c
C_BIN = dynamic
CFLAGS = -Wall -Wextra -Werror -std=c99 -pedantic
C_OPTIMIZE = -O0

# ============= Configurations =============
PORT = 57309  # Random number because im quirky

all:
	clear
	$(ASSEMBLER) $(SRC_DIR)/$(SRC) -o $(OBJ_DIR)/$(OBJ) $(ASMFLAGS) $(ASM_OPTIMIZE)
	$(ASSEMBLER) $(SRC_DIR)/$(ROUTING) -o $(OBJ_DIR)/$(ROUTING_OBJ) $(ASMFLAGS) $(ASM_OPTIMIZE)
	$(LINKER) $(OBJ_DIR)/$(ROUTING_OBJ) $(OBJ_DIR)/$(OBJ) -o $(BIN_DIR)/$(BIN)

run:
	./$(BIN_DIR)/$(BIN) $(PORT)

clean:
	rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/$(BIN)

c:
	$(CC) $(C_SRC) -o $(BIN_DIR)/$(C_BIN) $(CFLAGS) $(C_OPTIMIZE)

runc:
	$(BIN_DIR)/$(C_BIN)	
