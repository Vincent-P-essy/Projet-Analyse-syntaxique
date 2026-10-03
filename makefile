
CC=gcc
CFLAGS=-Wall
LDFLAGS=-Wall
EXEC=tpcas
SRC=src/
BIN=bin/
OBJ=obj/

.PHONY: all clean mrproper

all: $(BIN)$(EXEC)

$(BIN)$(EXEC): $(OBJ)tree.o $(OBJ)tpcas.tab.o $(OBJ)lex.yy.o | $(BIN)
	$(CC) -o $@ $^ $(LDFLAGS)

$(SRC)tpcas.tab.c $(SRC)tpcas.tab.h: $(SRC)tpcas.y
	bison -o $(SRC)tpcas.tab.c -d $<

$(SRC)lex.yy.c: $(SRC)tpcas.lex $(SRC)tpcas.tab.h
	flex -o $@ $<

$(OBJ)tree.o: $(SRC)tree.c $(SRC)tree.h | $(OBJ)
	$(CC) -o $@ -c $< $(CFLAGS)

$(OBJ)%.o: $(SRC)%.c | $(OBJ)
	$(CC) -o $@ -c $< $(CFLAGS)

clean:
	rm -f $(SRC)lex.yy.c $(SRC)tpcas.tab.c $(SRC)tpcas.tab.h $(OBJ)*.o

mrproper: clean
	rm -f $(BIN)$(EXEC)

$(BIN) $(OBJ):
	mkdir -p $@
