; extraer_cuadrante.asm - Extrae un cuadrante de 97x97 de una imagen de 390x390
section .data
    input_filename  db 'input.img', 0
    output_filename db 'output.img', 0
    input_width     equ 390
    block_size      equ 97              ; tamaño de cada cuadrante
    quadrant_number equ 10               ; cambia esto para extraer otro cuadrante (1-16)
    buffer          times 152100 db 0   ; imagen completa 390x390
    outbuffer       times 9409 db 0     ; cuadrante extraído 97x97

section .text
    global _start

_start:
    ; === Abrir input.img ===
    mov eax, 5          ; sys_open
    mov ebx, input_filename
    mov ecx, 0          ; O_RDONLY
    int 0x80
    test eax, eax
    js _exit
    mov esi, eax        ; input_fd

    ; === Leer imagen completa (390x390) ===
    mov eax, 3
    mov ebx, esi
    mov ecx, buffer
    mov edx, 152100
    int 0x80

    ; Cerrar input
    mov eax, 6
    mov ebx, esi
    int 0x80

    ; === Calcular posición del cuadrante ===
    mov eax, quadrant_number
    dec eax                 ; cuadrantes empiezan en 0
    mov ebx, 4
    xor edx, edx
    div ebx                 ; eax = fila, edx = columna
    mov edi, eax            ; fila
    mov esi, edx            ; columna

    ; edi = fila, esi = columna
    mov eax, edi
    imul eax, block_size
    imul eax, input_width   ; eax = offset vertical
    mov ebx, esi
    imul ebx, block_size    ; ebx = offset horizontal
    add eax, ebx            ; eax = offset inicial del cuadrante
    mov ebp, eax            ; guardar offset base

    ; === Copiar cuadrante al buffer de salida ===
    xor ecx, ecx            ; fila local (0..96)
.next_row:
    mov edx, 0
    mov edi, ecx
    imul edi, input_width   ; desplazamiento vertical = fila * 390
    add edi, ebp            ; desplazamiento total de esta fila
    mov esi, buffer
    add esi, edi            ; dirección origen

    mov edi, ecx
    imul edi, block_size    ; offset destino en outbuffer
    add edi, outbuffer      ; dirección destino

    mov edx, block_size     ; cantidad a copiar (97 bytes)
.rep:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec edx
    jnz .rep

    inc ecx
    cmp ecx, block_size
    jl .next_row

    ; === Crear output.img ===
    mov eax, 5
    mov ebx, output_filename
    mov ecx, 577            ; O_CREAT | O_WRONLY | O_TRUNC
    mov edx, 0644
    int 0x80
    mov esi, eax            ; output_fd

    ; === Escribir cuadrante ===
    mov eax, 4
    mov ebx, esi
    mov ecx, outbuffer
    mov edx, 9409
    int 0x80

    ; Cerrar output
    mov eax, 6
    mov ebx, esi
    int 0x80

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
