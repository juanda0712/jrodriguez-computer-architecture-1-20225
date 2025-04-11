#!/bin/bash
echo "============================"
echo "Ejecutando en Ubuntu 🚀"
echo "============================"

mkdir -p build input output

nasm -f elf32 asm/copiar.asm -o build/copiar.o
ld -m elf_i386 -o build/copiar build/copiar.o

if [ ! -f input/input.img ]; then
  dd if=/dev/urandom of=input/input.img bs=1 count=152100
fi

cp input/input.img input.img
truncate -s 152100 output.img

./build/copiar

mv output.img output/output.img
rm input.img
echo "✔️ Listo. Imagen generada en output/output.img"
