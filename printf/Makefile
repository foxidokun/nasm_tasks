BUILD_OUT = /tmp/main.o
LINK_OUT = /tmp/main

run: build link execute

build: 
	nasm -f elf64 main.nasm -o $(BUILD_OUT)

link:
	ld $(BUILD_OUT) -o $(LINK_OUT)

execute:
	echo "PROG RESULT" && echo "############" && $(LINK_OUT)
	
debug: build link
	edb --run $(LINK_OUT)