CC = gcc
CFLAGS = -g -Wall
TARGET = parser_201820682.out
OBJS = lex.yy.o parser.tab.o data_set.o

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) -o $@ $^ -lfl

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

parser.tab.c parser.tab.h:
	bison -d parser.y

lex.yy.c: parser.tab.h
	flex lex.l

clean:
	rm -f *.o
	rm -f lex.yy.c
	rm -f parser.tab.c
	rm -f parser.tab.h
	rm -f $(TARGET)