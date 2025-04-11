from PIL import Image
import numpy as np

# Abrir la imagen PNG
img = Image.open("input.png").convert("L")  # Convertir a escala de grises
img = img.resize((390, 390))  # Asegurarse de tamaño correcto (si aplica)

# Convertir a arreglo NumPy
data = np.array(img, dtype=np.uint8)

# Guardar como archivo raw (.img) sin cabecera
with open("input.img", "wb") as f:
    f.write(data.tobytes())

print("✅ Imagen convertida a input.img con tamaño correcto (390x390 = 152100 bytes)")
