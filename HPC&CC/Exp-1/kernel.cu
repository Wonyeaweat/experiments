#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <device_functions.h>
#include <iostream>
#include <ctime>
using namespace std;

const int MAX_THREAD_NUM = 256;
 // �����СΪ MATRIX_SIZE * MATRIX_SIZE
const int MAX_MATRIX_SIZE = 1024;
// �����鶨��Ϊȫ�֣�������ջ�ڷ������ڴ�
int MATRIX_SIZE;
int THREAD_NUM = 50;
float A[MAX_MATRIX_SIZE * MAX_MATRIX_SIZE], B[MAX_MATRIX_SIZE * MAX_MATRIX_SIZE], C[MAX_MATRIX_SIZE * MAX_MATRIX_SIZE];
float* gpu_A, * gpu_B, * gpu_C;

/* ��ӡGPU�豸��Ϣ */
void printDeviceProps(const cudaDeviceProp* deviceProp) {

    cout << "�豸�Կ��ͺţ� " << deviceProp->name << endl;
    cout << "�豸ȫ���ڴ���������MBΪ��λ���� " << deviceProp->totalGlobalMem / 1024 / 1024 << endl;
    cout << "�豸��һ���߳̿飨Block���п��õ�������ڴ棨��KBΪ��λ���� " << deviceProp->sharedMemPerBlock / 1024 << endl;
    cout << "�豸��һ���߳̿飨Block���ֿ��õ�32λ�Ĵ��������� " << deviceProp->regsPerBlock << endl;
    cout << "�豸��һ���߳̿飨Block���ɰ���������߳������� " << deviceProp->maxThreadsPerBlock << endl;
    cout << "�豸�ļ��㹦�ܼ���Compute Capability���İ汾�ţ� " << deviceProp->major << "." << deviceProp->minor << endl;
    cout << "�豸�϶ദ������������ " << deviceProp->multiProcessorCount << endl;
}

/* CUDA ��ʼ�� */
bool initCUDA() {
    int count, i;
    cudaDeviceProp prop;

    cudaGetDeviceCount(&count); 

    if (0 == count) {
        fprintf(stderr, "There is no device.\n");
        return false;
    }

    for (i = 0; i < count; i++) {
        if (cudaGetDeviceProperties(&prop, i) == cudaSuccess) {
            if (prop.major >= 1) {
                break;
            }
        }
    }

    if (i == count) {
        fprintf(stderr, "There is no device.\n");
        return false;
    }

    cudaSetDevice(i);

   // printDeviceProps(&prop);

    return true;
}

/* �����ά���飬ʹ��һά����洢 */
void generateMatrix(float* mat, int size) {
    int i, j;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            mat[i * size + j] = rand() %100;
        }
    }
}

/* ��ӡ���� */
void printMatrix(float* mat, int size) {
    int i, j;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            printf("%f ", mat[i * size + j]);
        }
        printf("\n");
    }
    printf("\n");
}

// kernel������ʵ�־���˷�
__global__ static void matrixMultiplication(const float* A, const float* B, float* C, int size, int threadnum) {
    // ��ǰ�߳�����Block�ı�ţ���0��ʼ��
    const int block_id = blockIdx.x;
    //�����̱߳�ţ���0��ʼ��
    const int thread_id = threadIdx.x;
    int i;
    int index, row, column;
    float s;

    // ��ǰ�߳�ȫ����������Block�ڵ��߳�������
    index = block_id * threadnum + thread_id;

    /* ��ǰ�߳̽�����C[row][column] */
    row = index / size;
    column = index % size;

    s = 0.0f;
    if (row < size && column < size) {
        // A[row][0], A[row][1], A[row][2] ... A[row][size]
        // B[0]column], B[1][column], B[2][column] ... B[size][column]
        for (i = 0; i < size; i++) {
            s += A[row * size + i] * B[i * size + column];
        }
        C[row * size + column] = s;
    }
}

void serial(const float* a, const float* b, float* c, int size) {
    memset(c, 0, sizeof(c));
    int i, j, k;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            for (k = 0; k < size; k++) {
                c[i * size + j] += a[i * size + k] * b[k * size + j];
            }
        }
    }
}
int main(void) {

    FILE* file = fopen("data.dat", "w");
    if (!initCUDA()) {
        return 0;
    }
    const int tot = 1024;
    for (int cnt = 0; cnt < tot; cnt++) {

        THREAD_NUM = 1 + (1 + rand()) % MAX_THREAD_NUM;
        MATRIX_SIZE = 1 + (THREAD_NUM + rand()) % MAX_MATRIX_SIZE;
        system("cls");
        printf("[ %d / %d ] \n",1+cnt,tot);
        const int block_num = (MATRIX_SIZE * MATRIX_SIZE + THREAD_NUM - 1) / THREAD_NUM;
        int i, j;
    
        /* �����¼�����¼ʱ��*/
        cudaEvent_t start, stop ;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        cudaEventRecord(start, 0);

        /* �������� */
        generateMatrix(A, MATRIX_SIZE);
        generateMatrix(B, MATRIX_SIZE);

        /* �����Դ� */
        cudaMalloc((void**)&gpu_A, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE);
        cudaMalloc((void**)&gpu_B, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE);
        cudaMalloc((void**)&gpu_C, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE);

        /* ����������ڴ濽�����Դ� */
        cudaMemcpy(gpu_A, A, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE, cudaMemcpyHostToDevice);
        cudaMemcpy(gpu_B, B, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE, cudaMemcpyHostToDevice);

        // ִ��kernel����
        matrixMultiplication <<< block_num, THREAD_NUM, 0 >>> (gpu_A, gpu_B, gpu_C, MATRIX_SIZE, THREAD_NUM);

        // ��������Դ濽�������ڴ�
        cudaMemcpy(C, gpu_C, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE, cudaMemcpyDeviceToHost);

        /* �ͷ��Դ�ռ� */
        cudaFree(gpu_A);
        cudaFree(gpu_B);
        cudaFree(gpu_C);

        /* ��¼����ʱ�� */
        cudaEventRecord(stop, 0);
        cudaEventSynchronize(stop);
        float elapsedTime;
        cudaEventElapsedTime(&elapsedTime, start, stop);


        

        //printf("Matrix size: [%d * %d] * [%d * %d] \n ", MATRIX_SIZE, MATRIX_SIZE, MATRIX_SIZE, MATRIX_SIZE);
        //printf("Time used: %f ms\n ",elapsedTime);

        /* Optional */
        //printMatrix(A, MATRIX_SIZE);
        //printMatrix(B, MATRIX_SIZE);
        //printMatrix(C, MATRIX_SIZE);
    

        /* Serial Matrix Multiply Algo */
    
        
    
        double SerialStart, SerialEnd;
        SerialStart = (double)clock();
        //cout << SerialStart << endl;
        serial(A, B, C, MATRIX_SIZE);
        SerialEnd = (double)clock();
        printf("Time used: %lf ms\n ", SerialEnd-SerialStart);
    
        fprintf(file, "%d %d %d %f %f \n", cnt, THREAD_NUM, MATRIX_SIZE, elapsedTime, SerialEnd - SerialStart);
    
    }
    
    system("pause");
    // return 0;
}