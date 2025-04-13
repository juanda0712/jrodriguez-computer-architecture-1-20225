import numpy as np
import matplotlib.pyplot as plt
import os
import sys

def cargar_imagen(ruta, ancho=None, alto=None):
    with open(ruta, 'rb') as f:
        data = np.frombuffer(f.read(), dtype=np.uint8)

    total_bytes = len(data)

    if ancho is None or alto is None:
        lado = int(np.sqrt(total_bytes))
        if lado * lado != total_bytes:
            raise ValueError(f"No se puede inferir una forma cuadrada para {ruta}. Tamaño: {total_bytes}")
        ancho = alto = lado

    return data.reshape((alto, ancho))

def dibujar_cuadrante(ax, cuadrante, ancho_total, alto_total):
    filas, columnas = 4, 4
    ancho_c = ancho_total // columnas
    alto_c = alto_total // filas

    fila = (cuadrante - 1) // columnas
    columna = (cuadrante - 1) % columnas

    x = columna * ancho_c
    y = fila * alto_c

    rect = plt.Rectangle((x, y), ancho_c, alto_c, edgecolor='red', facecolor='none', linewidth=2)
    ax.add_patch(rect)

if __name__ == "__main__":
    cuadrante = int(sys.argv[1]) if len(sys.argv) > 1 else 1
    
    input_img = cargar_imagen('input/input.img', 390, 390)
    output_img = cargar_imagen('output/output.img', 193, 193)
    inblock_img = cargar_imagen('output/quadrant.img', 97, 97)
    outblock_preinterp_img = cargar_imagen('output/expanded.img', 193, 193)

    fig, axs = plt.subplots(2, 2, figsize=(10, 10))

    axs[0, 0].imshow(input_img, cmap='gray')
    axs[0, 0].set_title('Input (con cuadrante)')
    axs[0, 0].axis('off')
    dibujar_cuadrante(axs[0, 0], cuadrante, 390, 390)

    axs[0, 1].imshow(inblock_img, cmap='gray')
    axs[0, 1].set_title('Cuadrante original (97x97)')
    axs[0, 1].axis('off')

    axs[1, 0].imshow(outblock_preinterp_img, cmap='gray')
    axs[1, 0].set_title('Cuadrante ampliado sin interpolar (193x193)')
    axs[1, 0].axis('off')

    axs[1, 1].imshow(output_img, cmap='gray')
    axs[1, 1].set_title('Output interpolado (193x193)')
    axs[1, 1].axis('off')

    plt.tight_layout()
    plt.show()
