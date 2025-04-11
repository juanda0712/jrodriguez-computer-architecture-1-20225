; copiar.asm - Copia un archivo binario (input.img → output.img)
section .data
    input_filename  db 'input.img', 0
    output_filename db 'output.img', 0
    buffer_size     equ 4096
    buffer          times buffer_size db 0

section .text
    global _start

_start:
    ; === Abrir input.img (lectura) ===
    mov eax, 5          ; sys_open
    mov ebx, input_filename
    mov ecx, 0          ; O_RDONLY
    int 0x80
    test eax, eax
    js _exit
    mov esi, eax        ; input_fd

    ; === Crear output.img (escritura) ===
    mov eax, 5          ; sys_open
    mov ebx, output_filename
    mov ecx, 577        ; O_CREAT | O_WRONLY | O_TRUNC = 0x241
    mov edx, 0644       ; permisos
    int 0x80
    test eax, eax
    js _exit
    mov edi, eax        ; output_fd

.copy_loop:
    ; === Leer del input ===
    mov eax, 3          ; sys_read
    mov ebx, esi        ; input_fd
    mov ecx, buffer
    mov edx, buffer_size
    int 0x80
    test eax, eax
    jle .close_files    ; fin de archivo o error
    mov ebp, eax        ; cantidad leída

    ; === Escribir al output ===
    mov eax, 4
    mov ebx, edi
    mov ecx, buffer
    mov edx, ebp
    int 0x80
    jmp .copy_loop

.close_files:
    ; Cerrar output
    mov eax, 6
    mov ebx, edi
    int 0x80

    ; Cerrar input
    mov eax, 6
    mov ebx, esi
    int 0x80

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
