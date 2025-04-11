; test_crear.asm
org 100h

start:
    ; Crear archivo con INT 21h, AH=3Ch
    mov ah, 3Ch
    xor cx, cx             ; atributos normales
    lea dx, filename       ; dirección del nombre
    int 21h
    jc error               ; si falla, ir a error

    mov bx, ax             ; guardar handle

    ; Cerrar el archivo
    mov ah, 3Eh
    int 21h

exit:
    mov ah, 4Ch
    int 21h

error:
    jmp exit

filename db "testfile.txt", 0
