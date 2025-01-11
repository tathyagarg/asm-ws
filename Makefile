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
BIN ?= server
ASMFLAGS = -f elf64
ASM_OPTIMIZE = -O3

PYTHON = python3.13
PYTHON_FILE = src/routing/dynamic.py

TEMPLATES_DIR ?= templates

RESPONSES_DIR = $(TEMPLATES_DIR)/post_responses

CC = gcc
POST_BIN = $(TEMPLATES_DIR)/post_responses/bin

# ============= Configurations =============
PORT = `cat PORT` # Random number because im quirky
ERR_LOG ?= tmp/err.log
OUT_LOG ?= tmp/out.log

.PHONY: all
all: req dyn responses asm run

.PHONY: req
req:
	mkdir -p $(TEMPLATES_DIR)/post_responses/bin
	mkdir -p tmp
	mkdir -p $(OBJ_DIR)
	mkdir -p $(BIN_DIR)
	touch $(ERR_LOG)
	touch $(OUT_LOG)

asm:
	$(ASSEMBLER) $(SRC_DIR)/$(SRC) -o $(OBJ_DIR)/$(OBJ) $(ASMFLAGS) $(ASM_OPTIMIZE)
	$(ASSEMBLER) $(SRC_DIR)/$(ROUTING) -o $(OBJ_DIR)/$(ROUTING_OBJ) $(ASMFLAGS) $(ASM_OPTIMIZE)
	$(LINKER) $(OBJ_DIR)/$(ROUTING_OBJ) $(OBJ_DIR)/$(OBJ) -o $(BIN_DIR)/$(BIN)

run:
	./$(BIN_DIR)/$(BIN) $(PORT) > $(OUT_LOG) 2> $(ERR_LOG)&

.PHONY: clean
clean:
	rm -f $(OBJ_DIR)/*.o $(BIN_DIR)/$(BIN)

dyn:
	$(PYTHON) $(PYTHON_FILE) $(TEMPLATES_DIR)

responses:
ifneq ("$(wildcard $(RESPONSES_DIR)/*.c)", "")
	for src_file in "$(RESPONSES_DIR)"/*.c; do\
		$(CC) $$src_file -o $(POST_BIN)/$$(basename $$src_file .c).o -O3;\
	done
endif

kill:
	pkill -9 -x $(BIN)
