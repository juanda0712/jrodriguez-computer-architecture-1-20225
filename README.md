# Proyecto de Interpolación de Imágenes - Arquitectura de Computadores I

Este proyecto consiste en una aplicación de interpolación bilineal sobre imágenes RAW, desarrollado utilizando lenguaje ensamblador NASM (x86, 32 bits) junto con herramientas auxiliares en Python. Se ejecuta sobre un entorno Linux para aprovechar el acceso directo a archivos y memoria lineal.

## Autor

**Juan Rodríguez Montero**  
Correo: [juan.rodriguez@estudiantec.cr](mailto:juan.rodriguez@estudiantec.cr)  
Instituto Tecnológico de Costa Rica  
Escuela de Ingeniería en Computadores

---

## Herramientas Utilizadas

- **Lenguaje ensamblador:** NASM 2.15 (modo protegido, 32 bits)
- **Lenguaje de scripting:** Python 3.10
- **Sistema operativo:** Ubuntu 22.04 LTS

---

## Archivos Principales

- `interpolar_bilineal_completo.asm`: Código ensamblador que realiza la interpolación.
- `run.sh`: Script para ejecutar todo el flujo (compilación, entrada, procesamiento y visualizacion con visualize.py).
- `visualize.py`: Código Python para visualizar los resultados (cuadrante original, bloque intermedio, bloque interpolado).
- `input.img`: Imagen de entrada en formato RAW (390x390 píxeles, 8 bits por píxel).
- `output.img`: Resultado final interpolado (193x193 píxeles).
- `quadrant.img`: Bloque de pixeles base extraído (97x97 píxeles).
- `expanded.img`: Bloque de pixeles expandido pero sin interpolación (97x97 píxeles).

---

## Instrucciones de Uso

1. Clonar el repositorio o copiar los archivos a una carpeta en Linux.
2. Dar permisos de ejecución al script principal:
   ```bash
   chmod +x run.sh
3. Ejecutar:
   ```bash
   ./run.sh
4. Pedira ingresar un numero de cuadrante (1 a 16).