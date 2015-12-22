arch ?= i386
iso := build/os-$(arch).iso
kernel := build/kernel-$(arch).bin

.PHONY: all clean run iso

all: $(kernel)

clean:
	@rm -rf build

run: $(iso)
	@qemu-system-i386 -hda $(iso)

iso: $(iso)

$(iso): $(kernel)
	@mkdir -p build/isofiles/boot/grub
	@cp $(kernel) build/isofiles/boot/kernel.bin
	@cp grub.cfg build/isofiles/boot/grub
	@grub-mkrescue -o $(iso) build/isofiles 2> /dev/null
	@rm -r build/isofiles

$(kernel):
	@mkdir build
	@nasm -f elf -o build/start.o source/start.asm
	@dmd -O -release -m32 -boundscheck=off -c source/kmain.d -ofbuild/kmain.o
	@ld --gc-section -m elf_i386 -T source/linker.ld -o $(kernel) build/start.o build/kmain.o

