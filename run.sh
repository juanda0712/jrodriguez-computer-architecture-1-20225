#!/bin/bash

echo "============================"
echo "       Ejecutando"
echo "============================"

# Pedir número de cuadrante
read -p "📌 Ingrese número de cuadrante (1-16): " quadrant

# Validar entrada
if ! [[ "$quadrant" =~ ^[1-9]$|^1[0-6]$ ]]; then
  echo "❌ Cuadrante inválido. Debe ser un número entre 1 y 16."
  exit 1
fi

# Crear carpetas si no existen
mkdir -p build input output

# Compilar el ensamblador con la constante del cuadrante
echo "🔧 Compilando con cuadrante $quadrant..."
nasm -f elf32 -DQUADRANT_NUMBER=$quadrant asm/interpolar_bilineal_completo.asm -o build/interpolar_bilineal_completo.o
ld -m elf_i386 -o build/interpolar_bilineal_completo build/interpolar_bilineal_completo.o

# Generar imagen de entrada si no existe
if [ ! -f input/input.img ]; then
  echo "🖼️ Generando input.img aleatoria..."
  dd if=/dev/urandom of=input/input.img bs=1 count=152100 status=none
fi

# Preparar archivos temporales
cp input/input.img input.img
truncate -s 152100 output.img
truncate -s 152100 quadrant.img
truncate -s 152100 expanded.img

# Ejecutar programa ensamblador
echo "🚀 Ejecutando binario..."
./build/interpolar_bilineal_completo

# Mover resultado a carpeta output
mv output.img output/output.img
mv quadrant.img output/quadrant.img
mv expanded.img output/expanded.img
rm input.img 

echo "✅ Listo. Imagenes generadas en output/"

# Visualización con Python
echo "🖼️ Visualizando imágenes..."
python3 python/visualize.py $quadrant

