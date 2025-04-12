import numpy as np
import matplotlib.pyplot as plt
import os

#img = np.fromfile("output/output.img", dtype=np.uint8).reshape((193, 193))
#img = np.fromfile("output/output.img", dtype=np.uint8).reshape((390, 390))
#print("Valor mínimo:", img.min(), "Valor máximo:", img.max())
data = np.fromfile("output/output.img", dtype=np.uint8)
print(len(data))  # ¿Es exactamente 37249?


#plt.imshow(img, cmap='gray')
#plt.title("Píxeles conocidos [2i][2j]")
#plt.show()
import numpy as np
import matplotlib.pyplot as plt

img = np.fromfile("output/output.img", dtype=np.uint8).reshape((193, 193))
plt.imshow(img, cmap='gray')
plt.title("Interpolación horizontal")
plt.show()
