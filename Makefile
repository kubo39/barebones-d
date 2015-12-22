arch ?= i386
kernel := build/kernel-$(arch).bin

.PHONY: all clean

all: $(kernel)

clean:
	@rm build/*

$(kernel):
	@nasm -f elf -o build/start.o source/start.asm
	@dmd -O -release -m32 -boundscheck=off -c source/kmain.d -ofbuild/kmain.o
	@ld --gc-section -m elf_i386 -T source/linker.ld -o $(kernel) build/start.o build/kmain.o

