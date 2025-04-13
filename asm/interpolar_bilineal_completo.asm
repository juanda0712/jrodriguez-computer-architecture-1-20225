section .data
    input_filename  db 'input.img', 0
    output_filename db 'output.img', 0
    quadrant_filename db 'quadrant.img', 0
    expanded_filename db 'expanded.img', 0

    input_width     equ 390
    block_size      equ 97
    output_size     equ 193
    buffer          times 152100 db 0
    inblock         times 9409 db 0
    outblock        times 37249 db 0

%ifndef QUADRANT_NUMBER
    %define QUADRANT_NUMBER 7   ; Valor por defecto si no se pasa desde el script
%endif

section .text
    global _start

_start:
    ; --- Abrir input.img ---
    mov eax, 5
    mov ebx, input_filename
    mov ecx, 0
    int 0x80
    mov esi, eax

    ; --- Leer imagen completa ---
    mov eax, 3
    mov ebx, esi
    mov ecx, buffer
    mov edx, 152100
    int 0x80

    ; --- Cerrar input ---
    mov eax, 6
    mov ebx, esi
    int 0x80

    ; --- Calcular posición del cuadrante ---
    mov eax, QUADRANT_NUMBER
    dec eax
    mov ebx, 4
    xor edx, edx
    div ebx
    mov edi, eax              ; fila
    mov esi, edx              ; columna

    mov eax, edi
    imul eax, block_size
    imul eax, input_width
    mov ebx, esi
    imul ebx, block_size
    add eax, ebx
    mov ebp, eax              ; offset base en buffer

    ; --- Copiar cuadrante a inblock ---
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

    ; --- Copiar valores conocidos [2i][2j] a outblock ---
    xor ecx, ecx
.copy_known_rows:
    xor edx, edx
.copy_known_cols:
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
    jl .copy_known_cols
    inc ecx
    cmp ecx, block_size
    jl .copy_known_rows

    ; --- Guardar cuadrante original en quadrant.img ---
    mov eax, 5
    mov ebx, quadrant_filename
    mov ecx, 577        ; O_CREAT | O_WRONLY | O_TRUNC
    mov edx, 0644
    int 0x80
    mov esi, eax

    mov eax, 4
    mov ebx, esi
    mov ecx, inblock
    mov edx, 9409       ; 97x97
    int 0x80

    mov eax, 6
    mov ebx, esi
    int 0x80

    ; --- Guardar cuadrante expandido (sin interpolar) en expanded.img 
    mov eax, 5
    mov ebx, expanded_filename
    mov ecx, 577
    mov edx, 0644
    int 0x80
    mov esi, eax

    mov eax, 4
    mov ebx, esi
    mov ecx, outblock
    mov edx, 37249      ; 193x193
    int 0x80

    mov eax, 6
    mov ebx, esi
    int 0x80


    ; --- Interpolación horizontal [2i][2j+1] = promedio([2i][2j], [2i][2j+2]) ---
    xor ecx, ecx         ; i de 0 a 96
.h_rows:
    xor edx, edx         ; j de 0 a 95
.h_cols:
    ; índice base = (2*i * output_size) + (2*j)
    mov eax, ecx
    shl eax, 1
    imul eax, output_size
    mov esi, edx
    shl esi, 1
    add eax, esi         ; eax = índice base

    ; Obtener valores de [2i][2j] y [2i][2j+2]
    movzx ebx, byte [outblock + eax]
    movzx edi, byte [outblock + eax + 2]
    add ebx, edi
    shr ebx, 1
    mov [outblock + eax + 1], bl

    inc edx
    cmp edx, block_size - 1
    jl .h_cols
    inc ecx
    cmp ecx, block_size
    jl .h_rows

    ; --- Interpolación vertical [2i+1][2j] = promedio([2i][2j], [2i+2][2j]) ---
    xor ecx, ecx         ; i de 0 a 95
.v_rows:
    xor edx, edx         ; j de 0 a 96
.v_cols:
    ; índice base = (2*i * output_size) + (2*j)
    mov eax, ecx
    shl eax, 1
    imul eax, output_size
    mov esi, edx
    shl esi, 1
    add eax, esi         ; eax = índice base

    ; Obtener valores de [2i][2j] y [2i+2][2j]
    movzx ebx, byte [outblock + eax]
    movzx edi, byte [outblock + eax + (2 * output_size)]
    add ebx, edi
    shr ebx, 1
    mov [outblock + eax + output_size], bl

    inc edx
    cmp edx, block_size
    jl .v_cols
    inc ecx
    cmp ecx, block_size - 1
    jl .v_rows

    ; --- Interpolación diagonal 32-bit ---
    ; [2i+1][2j+1] = promedio([2i][2j], [2i][2j+2], [2i+2][2j], [2i+2][2j+2])

    xor ecx, ecx                  ; i (0 a block_size - 1)
.diag_rows:
    xor edx, edx              ; j (0 a block_size - 1)
.diag_cols:
    ; calcular índice base = (2i * output_size) + 2j
    mov eax, ecx              ; eax = i
    shl eax, 1                ; eax = 2i
    imul eax, output_size     ; eax = 2i * output_size
    mov ebx, edx              ; ebx = j
    shl ebx, 1                ; ebx = 2j
    add eax, ebx              ; eax = índice base [2i][2j]

    ; protección de seguridad
    cmp eax, 37246
    jae .skip_diag

    ; guardar índice base temporal en ebp
    mov ebp, eax

    ; leer 4 valores: A, B, C, D
    ; A = [2i][2j]
    movzx esi, byte [outblock + ebp]

    ; B = [2i][2j+2] → ebp + 2
    movzx eax, byte [outblock + ebp + 2]
    add esi, eax

    ; C = [2i+2][2j] → ebp + 2*output_size
    mov eax, output_size
    shl eax, 1                ; eax = 2 * output_size
    mov edi, ebp
    add edi, eax
    movzx eax, byte [outblock + edi]
    add esi, eax

    ; D = [2i+2][2j+2] → ebp + 2*output_size + 2
    add edi, 2
    movzx eax, byte [outblock + edi]
    add esi, eax

    ; promedio / 4
    shr esi, 2

    ; guardar en [2i+1][2j+1]
    mov eax, esi         ; copiar a eax para trabajar con el byte bajo
    and eax, 0xFF        ; asegurar que solo quede el byte bajo

    ; calcular índice destino
    mov ebx, ecx
    shl ebx, 1
    add ebx, 1           ; 2i + 1
    imul ebx, output_size

    mov edi, edx
    shl edi, 1
    add edi, 1           ; 2j + 1

    add ebx, edi         ; índice destino completo en ebx
    mov [outblock + ebx], al

.skip_diag:
    inc edx
    cmp edx, block_size - 1
    jl .diag_cols
    inc ecx
    cmp ecx, block_size - 1
    jl .diag_rows


_write_and_exit:
    ; --- Crear output.img ---
    mov eax, 5
    mov ebx, output_filename
    mov ecx, 577
    mov edx, 0644
    int 0x80
    mov esi, eax

    ; --- Escribir outblock en output.img ---
    mov eax, 4
    mov ebx, esi
    mov ecx, outblock
    mov edx, 37249
    int 0x80

    ; --- Cerrar archivo ---
    mov eax, 6
    mov ebx, esi
    int 0x80

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
