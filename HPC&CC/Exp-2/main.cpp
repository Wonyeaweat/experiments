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
    MPI_Init(&argc, &argv);  // ���п�ʼ 
 
    MPI_Comm_size(MPI_COMM_WORLD, &numprocs);
    /*
        int MPI_Comm_size (MPI_Comm comm ,int* size )
        ��ý��̸��� size�����浽numprocs��
        ָ��һ��ͨ����,Ҳָ����һ�鹲��ÿռ�Ľ���, ��Щ������ɸ�ͨ���ӵ�group���飩��
        ���ͨ����comm�й涨��group�����Ľ��̵�������
    */
    MPI_Comm_rank(MPI_COMM_WORLD, &myrank); 
    /* 
        MPI_Comm_rank (MPI_Comm comm ,int* rank)
        �õ���������ͨ�ſռ��е�rankֵ,�������е��߼���ţ����浽myrank��
        ��rankֵΪ0��p-1�������,�൱�ڽ��̵�ID��
        һ����ԣ�rank==0 �Ľ�����Ϊ�������̣��ڲ��н������д����Կ�����rank==0�Ľ��������У������Ҫ��
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

    /* step 1: ���ݷ��� */
    MPI_Scatter(A, bm * p, MPI_DOUBLE, bA, bm * p, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    MPI_Bcast(B, p * n, MPI_DOUBLE, 0, MPI_COMM_WORLD);
    
    /* step 2: ���м���C�ĸ����ֿ� */
    matMultiplyWithSingleThread(bA, B, bC, bm, p, n);
    MPI_Barrier(MPI_COMM_WORLD);

    /* step 3: ���ܽ�� */
    MPI_Gather(bC, bm * n, MPI_DOUBLE, C, bm * n, MPI_DOUBLE, 0, MPI_COMM_WORLD);

    /* step 3-1: �����ʷ�������⣨����ķֿ飩 */
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

    MPI_Finalize(); // ���н���
    return 0;
}
