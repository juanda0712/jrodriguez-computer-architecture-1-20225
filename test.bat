
@echo off
:: Compilar código ASM
nasm -f bin asm\test.asm -o dosbox\test.com

dosbox-x -c "mount C .\dosbox" -c "C:" -c "test.com" 
