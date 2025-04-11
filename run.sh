#!/bin/bash
echo "============================"
echo          "Ejecutando"
echo "============================"

mkdir -p build input output

nasm -f elf32 asm/extraer_cuadrante.asm -o build/extraer_cuadrante.o
ld -m elf_i386 -o build/extraer_cuadrante build/extraer_cuadrante.o

if [ ! -f input/input.img ]; then
  dd if=/dev/urandom of=input/input.img bs=1 count=152100
fi

cp input/input.img input.img
truncate -s 152100 output.img

./build/extraer_cuadrante

mv output.img output/output.img
rm input.img
echo "✔️ Listo. Imagen generada en output/output.img"

echo "✔️ Visualizando imagenes"
python3 visualize.py
