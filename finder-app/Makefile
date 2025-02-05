# Define compiler
CC := $(CROSS_COMPILE)gcc

# Define source and output files
SRC := writer.c
OBJ := writer.o
TARGET := writer

# Default target: Build the application
.PHONY: all
all: $(TARGET)

# Compilation rule
$(TARGET): $(OBJ)
	$(CC) -o $(TARGET) $(OBJ)

# Object file compilation rule
$(OBJ): $(SRC)
	$(CC) -c $(SRC) -o $(OBJ)

# Clean target: Remove compiled files
.PHONY: clean
clean:
	rm -f $(TARGET) $(OBJ)

