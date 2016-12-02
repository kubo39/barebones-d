global start
extern kmain        ; Allow kmain() to be called from the assembly code
extern start_ctors, end_ctors, start_dtors, end_dtors

MODULEALIGN        equ        1<<0
MEMINFO            equ        1<<1
FLAGS              equ        MODULEALIGN | MEMINFO
MAGIC              equ        0xe85250d6
CHECKSUM           equ        -(MAGIC + FLAGS)


section .text
    align 4

multiboot:
header_start:
    dd MAGIC                     ; magic number (multiboot 2)
    dd 0                         ; architecture 0 (protected mode i386)
    dd header_end - header_start ; header length
    ; checksum
    dd 0x100000000 - (MAGIC + 0 + (header_end - header_start))

    ; insert optional multiboot tags here

    ; required end tag
    dw 0    ; type
    dw 0    ; flags
    dd 8    ; size
header_end:

STACKSIZE equ 0x4000  ; 16 KiB if you're wondering

static_ctors_loop:
   mov ebx, start_ctors
   jmp .test
.body:
   call [ebx]
   add ebx,4
.test:
   cmp ebx, end_ctors
   jb .body

start:
    mov esp, STACKSIZE+stack

    push eax
    push ebx

    call kmain

static_dtors_loop:
   mov ebx, start_dtors
   jmp .test
.body:
   call [ebx]
   add ebx,4
.test:
   cmp ebx, end_dtors
   jb .body


cpuhalt:
    hlt
    jmp cpuhalt

section .bss
align 32

stack:
    resb      STACKSIZE
