import numpy as np
import math
import matplotlib.pyplot as plt

x, y, z =  [], [], []
z = np.linspace(-2, 100, 1000)
for i in z:
    x.append(i)
    y.append(np.sqrt(i**3+7))
    x.append(i)
    y.append(-np.sqrt(i ** 3 + 7))

fig = plt.figure()
ax = fig.add_subplot()
ax.scatter(x, y)
plt.show()