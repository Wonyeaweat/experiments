import random
import os

commandPrefix = " mpiexec -n "
processNumber = 16
fileAddress = " ../x64/Debug/Exp-2 "
m, p, n = 1000, 1000, 1000

for i in range(16):
    processNumber = i+1
    for j in range(10):
        m=p=n=random.randint(500,2048)
        command = commandPrefix + str(processNumber) + fileAddress + str(m) + " " + str(p) + " " + str(n)
        os.system(command)
        print("Now calculating:",i+1,"case:",j)


