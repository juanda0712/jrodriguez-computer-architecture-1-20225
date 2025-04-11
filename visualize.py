import numpy as np
import matplotlib.pyplot as plt

def cargar_imagen(ruta, tam=390):
    with open(ruta, 'rb') as f:
        data = np.frombuffer(f.read(), dtype=np.uint8)
    return data.reshape((tam, tam))  # Se asume imagen cuadrada 390x390

# Cargar las dos imágenes
input_img = cargar_imagen('input/input.img')
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
plt.savefig('resultado.png')  # También se guarda por si se quiere incluir en el informe
print("✅ Imagen guardada como resultado.png")
