import numpy as np
import matplotlib.pyplot as plt
f = open('data.dat','r')
data = f.readlines()
x ,y,z = [],[],[]
for tmp in data:
    tp = tmp.split()
    x.append(int(tp[0]))
    y.append(int(tp[1]))
    z.append(float(tp[2]))
ax = plt.subplot(111,projection='3d')
ax.scatter(x[:9],y[0:9],z[0:9],c='r')
ax.scatter(x[10:],y[10:],z[10:],c='b')

ax.set_xlabel("Thread Num")
ax.set_ylabel("Matrix Size")
ax.set_zlabel("Time used(s)")
plt.show()