import numpy as np
import matplotlib.pyplot as plt
import os

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

# Cargar input (390x390)
input_img = cargar_imagen('input/input.img', 390, 390)

# Cargar output (tamaño inferido automáticamente)
output_img = cargar_imagen('output/output.img')

# Visualizar ambas
plt.figure(figsize=(8, 4))

plt.subplot(1, 2, 1)
plt.imshow(input_img, cmap='gray')
plt.title('Input')
plt.axis('off')

plt.subplot(1, 2, 2)
plt.imshow(output_img, cmap='gray')
plt.title('Output')
plt.axis('off')

plt.tight_layout()
plt.show()
