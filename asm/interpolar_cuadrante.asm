; interpolar_cuadrante.asm - Interpolación bilineal completa de un cuadrante (193x193)
section .data
    input_filename  db 'input.img', 0
    output_filename db 'output.img', 0
    input_width     equ 390
    block_size      equ 97              ; tamaño del cuadrante original
    output_size     equ 193             ; 2*97 - 1
    quadrant_number equ 7               ; selecciona el cuadrante (1 a 16)
    buffer          times 152100 db 0   ; imagen completa
    inblock         times 9409 db 0     ; cuadrante original
    outblock        times 37249 db 0    ; cuadrante interpolado

section .text
    global _start

_start:
    ; === Abrir input.img ===
    mov eax, 5
    mov ebx, input_filename
    mov ecx, 0
    int 0x80
    mov esi, eax

    ; === Leer imagen completa ===
    mov eax, 3
    mov ebx, esi
    mov ecx, buffer
    mov edx, 152100
    int 0x80

    ; === Cerrar input ===
    mov eax, 6
    mov ebx, esi
    int 0x80

    ; === Calcular posición del cuadrante ===
    mov eax, quadrant_number
    dec eax
    mov ebx, 4
    xor edx, edx
    div ebx         ; eax = fila, edx = columna
    mov edi, eax    ; fila
    mov esi, edx    ; columna

    mov eax, edi
    imul eax, block_size
    imul eax, input_width
    mov ebx, esi
    imul ebx, block_size
    add eax, ebx
    mov ebp, eax    ; offset base

    ; === Copiar cuadrante a inblock ===
    xor ecx, ecx
.copy_row:
    mov edx, 0
    mov edi, ecx
    imul edi, input_width
    add edi, ebp
    mov esi, buffer
    add esi, edi

    mov edi, ecx
    imul edi, block_size
    add edi, inblock

    mov edx, block_size
.copy_px:
    mov al, [esi]
    mov [edi], al
    inc esi
    inc edi
    dec edx
    jnz .copy_px

    inc ecx
    cmp ecx, block_size
    jl .copy_row

    ; === Interpolación bilineal ===

    ; Copiar píxeles conocidos
    xor ecx, 0
.known_rows:
    xor edx, 0
.known_cols:
    mov eax, ecx
    imul eax, block_size
    add eax, edx
    mov al, [inblock + eax]

    mov ebx, ecx
    shl ebx, 1
    mov edi, edx
    shl edi, 1
    imul ebx, output_size
    add ebx, edi

    mov [outblock + ebx], al

    inc edx
    cmp edx, block_size
    jl .known_cols
    inc ecx
    cmp ecx, block_size
    jl .known_rows

    ; Interpolar horizontal (entre columnas)
    xor ecx, 0
.h_rows:
    xor edx, 0
.h_cols:
    mov eax, ecx
    shl eax, 1
    imul eax, output_size

    mov ebx, edx
    shl ebx, 1

    mov al, [outblock + eax + ebx]
    mov dl, [outblock + eax + ebx + 2]
    add al, dl
    shr ax, 1
    mov [outblock + eax + ebx + 1], al

    inc edx
    cmp edx, block_size - 1
    jl .h_cols
    inc ecx
    cmp ecx, block_size
    jl .h_rows

    ; Interpolar vertical (entre filas)
    xor ecx, 0
.v_rows:
    xor edx, 0
.v_cols:
    mov eax, ecx
    shl eax, 1
    imul eax, output_size
    add eax, edx
    shl edx, 1

    mov al, [outblock + eax]
    mov dl, [outblock + eax + (output_size * 2)]
    add al, dl
    shr ax, 1
    mov [outblock + eax + output_size], al

    inc edx
    cmp edx, output_size
    jl .v_cols
    inc ecx
    cmp ecx, block_size - 1
    jl .v_rows

    ; Interpolar centro (4 vecinos)
    xor ecx, 0
.c_rows:
    xor edx, 0
.c_cols:
    ; Base = (2i+1)*W + (2j+1)
    mov eax, ecx
    shl eax, 1
    add eax, 1
    imul eax, output_size

    mov ebx, edx
    shl ebx, 1
    add ebx, 1
    add eax, ebx

    ; vecinos
    mov al, [outblock + eax - output_size - 1]
    mov bl, [outblock + eax - output_size + 1]
    add al, bl
    mov bl, [outblock + eax + output_size - 1]
    add al, bl
    mov bl, [outblock + eax + output_size + 1]
    add al, bl
    shr ax, 2
    mov [outblock + eax], al

    inc edx
    cmp edx, block_size - 1
    jl .c_cols
    inc ecx
    cmp ecx, block_size - 1
    jl .c_rows

    ; === Escribir output.img ===
    mov eax, 5
    mov ebx, output_filename
    mov ecx, 577
    mov edx, 0644
    int 0x80
    mov esi, eax

    mov eax, 4
    mov ebx, esi
    mov ecx, outblock
    mov edx, 37249
    int 0x80

    mov eax, 6
    mov ebx, esi
    int 0x80

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
