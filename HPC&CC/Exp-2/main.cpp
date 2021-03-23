#define _CRT_SECURE_NO_WARNINGS
#include<iostream>
#include<mpi.h>
#include<cmath>
#include<cstdlib>
#include<ctime>
#include<cstdio>
#include<fstream>

using namespace std;

void initMatrixWithRV(double* A, int rows, int cols) {
    srand((unsigned)time(NULL));
    for (int i = 0; i < rows * cols; i++) {
        A[i] = (double)rand() / RAND_MAX;
    }
}
void matMultiplyWithSingleThread(double* A, double* B, double* matResult, int m, int p, int n) {
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < n; j++) {
            double temp = 0;
            for (int k = 0; k < p; k++) {
                temp += A[i * p + k] * B[k * n + j];
            }
            matResult[i * n + j] = temp;
        }
    }
}
int main(int argc, char* argv[]){
    int m = atoi(argv[1]), p = atoi(argv[2]), n = atoi(argv[3]);
    double globalTimeSum = 0.0;
    double* A = NULL , * B = NULL , * C = NULL;
    double* bA = NULL , * bC = NULL;

    int myrank, numprocs;
    double start, end;
    MPI_Init(&argc, &argv);  // 并行开始 
 
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    /*
        int MPI_Comm_size (MPI_Comm comm ,int* size )
        获得进程个数 size。保存到numprocs。
        指定一个通信子,也指定了一组共享该空间的进程, 这些进程组成该通信子的group（组）。
        获得通信子comm中规定的group包含的进程的数量。
    */
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank); 
    /* 
        MPI_Comm_rank (MPI_Comm comm ,int* rank)
        得到本进程在通信空间中的rank值,即在组中的逻辑编号，保存到myrank。
        该rank值为0到p-1间的整数,相当于进程的ID。
        一般而言，rank==0 的进程认为是主进程，在并行结束后串行代码仍可以在rank==0的进程上运行（如果需要）
    */
    int bm = m / numprocs; 

    bA = new double[bm * p];
    B = new double[p * n];
    bC = new double[bm * n];

    if (myrank == 0) {
        A = new double[m * p];
        C = new double[m * n];
        start = MPI_Wtime();
        initMatrixWithRV(A, m, p);
        initMatrixWithRV(B, p, n);
    }

    MPI_Barrier(MPI_COMM_WORLD);

    /* step 1: 数据分配 */
    MPI_Scatter(A, bm * p, MPI_DOUBLE, bA, bm * p, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Bcast(B, p * n, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    
    /* step 2: 并行计算C的各个分块 */
    matMultiplyWithSingleThread(bA, B, bC, bm, p, n);
    MPI_Barrier(MPI_COMM_WORLD);

    /* step 3: 汇总结果 */
    MPI_Gather(bC, bm * n, MPI_DOUBLE, C, bm * n, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    /* step 3-1: 解决历史遗留问题（多余的分块） */
    int remainRowsStartId = bm * numprocs;
    if (myrank == 0 && remainRowsStartId < m) {
        int remainRows = m - remainRowsStartId;
        matMultiplyWithSingleThread(A + remainRowsStartId * p, B, C + remainRowsStartId * n, remainRows, p, n);
    }

    delete[] bA;
    delete[] B;
    delete[] bC;

    if (myrank == 0) {
        end = MPI_Wtime();
        delete[] A;
        delete[] C;
        ofstream output; output.open("Data.dat",ios::app);
        output << numprocs <<' '<<  n <<' '<< end - start << endl;
    }

    MPI_Finalize(); // 并行结束
    return 0;
}
