arch ?= i386
target := $(arch)-unknown-linux-gnu
iso := build/os-$(arch).iso
kernel := build/kernel-$(arch).bin

dflags = \
	-betterC \
	-c \
	-disable-red-zone \
	-mtriple=$(target) \
	-nodefaultlib \
	-nogc \
	-release \
	-relocation-model=static

.PHONY: all clean run iso

all: $(kernel)

clean:
	@rm -rf build

run: $(iso)
	@qemu-system-i386 -drive format=raw,file=$(iso)

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
	@ldc2 -of=build/kmain.o $(dflags) source/kmain.d
	@ld -nostdlib -nodefaultlibs -n --gc-section -m elf_i386 -T source/linker.ld -o $(kernel) build/start.o build/kmain.o

