; interpolar_base_debug.asm - Versión simplificada que:
;  • Extrae el cuadrante 97x97 (del cuadrante seleccionado de input.img 390x390)
;  • Copia los píxeles conocidos [2i][2j] en un buffer de salida de 193x193
;  • Para debugging, escribe el valor 100 en los primeros 20 bytes del buffer de salida
;  • Guarda output.img (de 37249 bytes)

section .data
    input_filename  db 'input.img', 0
    output_filename db 'output.img', 0
    input_width     equ 390              ; Ancho de la imagen completa
    block_size      equ 97               ; Tamaño del cuadrante original
    output_size     equ 193              ; Tamaño de la salida interpolada (2*97-1)
    quadrant_number equ 7                ; Cuadrante seleccionado (1 a 16)
    buffer          times 152100 db 0    ; Buffer para imagen completa (390x390)
    inblock         times 9409 db 0      ; Bloque extraído (97x97): 97*97
    outblock        times 37249 db 0     ; Bloque de salida: 193x193 (37249 bytes)

section .text
    global _start

_start:
    ; --- Abrir input.img ---
    mov eax, 5                  ; sys_open
    mov ebx, input_filename
    mov ecx, 0                  ; O_RDONLY
    int 0x80
    mov esi, eax                ; Guardar file descriptor de input

    ; --- Leer imagen completa ---
    mov eax, 3                  ; sys_read
    mov ebx, esi
    mov ecx, buffer
    mov edx, 152100             ; 390 * 390
    int 0x80

    ; --- Cerrar input ---
    mov eax, 6                  ; sys_close
    mov ebx, esi
    int 0x80

    ; --- Calcular posición del cuadrante ---
    mov eax, quadrant_number
    dec eax                   ; Se indexa desde 0
    mov ebx, 4
    xor edx, edx
    div ebx                   ; eax = fila, edx = columna
    mov edi, eax              ; fila
    mov esi, edx              ; columna

    ; Calcular offset base: offset = (fila * block_size * input_width) + (columna * block_size)
    mov eax, edi
    imul eax, block_size
    imul eax, input_width
    mov ebx, esi
    imul ebx, block_size
    add eax, ebx
    mov ebp, eax              ; ebp = offset base del cuadrante en buffer

    ; --- Copiar cuadrante a inblock ---
    xor ecx, ecx            ; ecx = 0 (fila)
.copy_row:
    mov edx, 0              ; edx = 0 (columna)
    mov edi, ecx
    imul edi, input_width   ; desplazamiento vertical en buffer
    add edi, ebp          ; desplazamiento total en buffer de input
    mov esi, buffer
    add esi, edi          ; dirección de origen en buffer

    mov edi, ecx
    imul edi, block_size    ; desplazamiento en inblock para la fila actual
    add edi, inblock        ; dirección destino en inblock

    mov edx, block_size     ; cantidad de píxeles a copiar (97)
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
    xor ecx, ecx           ; para filas en inblock (0 a 96)
.copy_known_rows:
    xor edx, edx           ; para columnas en inblock (0 a 96)
.copy_known_cols:
    mov eax, ecx
    imul eax, block_size   ; eax = (i * block_size)
    add eax, edx           ; eax = índice en inblock = i*97 + j
    mov al, [inblock + eax]

    ; Calcular la posición en outblock: (2*i, 2*j)
    mov ebx, ecx
    shl ebx, 1            ; 2*i
    mov edi, edx
    shl edi, 1            ; 2*j
    imul ebx, output_size ; cada fila de outblock tiene 'output_size' bytes
    add ebx, edi          ; índice = (2*i)*output_size + (2*j)
    mov [outblock + ebx], al

    inc edx
    cmp edx, block_size
    jl .copy_known_cols
    inc ecx
    cmp ecx, block_size
    jl .copy_known_rows

    

_write_and_exit:
    ; --- Crear output.img ---
    mov eax, 5
    mov ebx, output_filename
    mov ecx, 577          ; O_CREAT | O_WRONLY | O_TRUNC
    mov edx, 0644
    int 0x80
    mov esi, eax          ; file descriptor para output

    ; --- Escribir outblock en output.img ---
    mov eax, 4
    mov ebx, esi
    mov ecx, outblock
    mov edx, 37249        ; output_size * output_size = 193*193
    int 0x80

    ; --- Cerrar output ---
    mov eax, 6
    mov ebx, esi
    int 0x80

_exit:
    mov eax, 1
    xor ebx, ebx
    int 0x80
