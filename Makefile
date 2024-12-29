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
ROUTING = routing/routing.asm
OBJ = $(SRC:.asm=.o)
ROUTING_OBJ = routing.o
BIN = server

all:
	clear
	$(ASSEMBLER) -f $(FORMAT) $(SRC_DIR)/$(SRC) -o $(OBJ_DIR)/$(OBJ)
	$(ASSEMBLER) -f $(FORMAT) $(SRC_DIR)/$(ROUTING) -o $(OBJ_DIR)/$(ROUTING_OBJ)
	$(LINKER) $(OBJ_DIR)/$(ROUTING_OBJ) $(OBJ_DIR)/$(OBJ) -o $(BIN_DIR)/$(BIN)

run:
	./$(BIN_DIR)/$(BIN)

clean:
	rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/$(BIN)

c:
	gcc src/routing.c -o bin/routing
	./bin/routing
