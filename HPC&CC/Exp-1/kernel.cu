#include <stdio.h>
#include <stdlib.h>
#include <cuda_runtime.h>
#include <device_launch_parameters.h>
#include <device_functions.h>
#include <iostream>
#include <ctime>
using namespace std;

const int MAX_THREAD_NUM = 256;
 // 矩阵大小为 MATRIX_SIZE * MATRIX_SIZE
const int MAX_MATRIX_SIZE = 1024;
// 将数组定义为全局，避免在栈内分配大块内存
int MATRIX_SIZE;
int THREAD_NUM = 50;
float A[MAX_MATRIX_SIZE * MAX_MATRIX_SIZE], B[MAX_MATRIX_SIZE * MAX_MATRIX_SIZE], C[MAX_MATRIX_SIZE * MAX_MATRIX_SIZE];
float* gpu_A, * gpu_B, * gpu_C;

/* 打印GPU设备信息 */
void printDeviceProps(const cudaDeviceProp* deviceProp) {

    cout << "设备显卡型号： " << deviceProp->name << endl;
    cout << "设备全局内存总量（以MB为单位）： " << deviceProp->totalGlobalMem / 1024 / 1024 << endl;
    cout << "设备上一个线程块（Block）中可用的最大共享内存（以KB为单位）： " << deviceProp->sharedMemPerBlock / 1024 << endl;
    cout << "设备上一个线程块（Block）种可用的32位寄存器数量： " << deviceProp->regsPerBlock << endl;
    cout << "设备上一个线程块（Block）可包含的最大线程数量： " << deviceProp->maxThreadsPerBlock << endl;
    cout << "设备的计算功能集（Compute Capability）的版本号： " << deviceProp->major << "." << deviceProp->minor << endl;
    cout << "设备上多处理器的数量： " << deviceProp->multiProcessorCount << endl;
}

/* CUDA 初始化 */
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

/* 构造二维数组，使用一维数组存储 */
void generateMatrix(float* mat, int size) {
    int i, j;
    for (i = 0; i < size; i++) {
        for (j = 0; j < size; j++) {
            mat[i * size + j] = rand() %100;
        }
    }
}

/* 打印矩阵 */
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

// kernel函数，实现矩阵乘法
__global__ static void matrixMultiplication(const float* A, const float* B, float* C, int size, int threadnum) {
    // 当前线程所在Block的编号（从0开始）
    const int block_id = blockIdx.x;
    //当期线程编号（从0开始）
    const int thread_id = threadIdx.x;
    int i;
    int index, row, column;
    float s;

    // 当前线程全局索引（非Block内的线程索引）
    index = block_id * threadnum + thread_id;

    /* 当前线程将计算C[row][column] */
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
    
        /* 创建事件，记录时间*/
        cudaEvent_t start, stop ;
        cudaEventCreate(&start);
        cudaEventCreate(&stop);
        cudaEventRecord(start, 0);

        /* 构建矩阵 */
        generateMatrix(A, MATRIX_SIZE);
        generateMatrix(B, MATRIX_SIZE);

        /* 分配显存 */
        cudaMalloc((void**)&gpu_A, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE);
        cudaMalloc((void**)&gpu_B, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE);
        cudaMalloc((void**)&gpu_C, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE);

        /* 将数组从主内存拷贝至显存 */
        cudaMemcpy(gpu_A, A, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE, cudaMemcpyHostToDevice);
        cudaMemcpy(gpu_B, B, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE, cudaMemcpyHostToDevice);

        // 执行kernel函数
        matrixMultiplication <<< block_num, THREAD_NUM, 0 >>> (gpu_A, gpu_B, gpu_C, MATRIX_SIZE, THREAD_NUM);

        // 将数组从显存拷贝至主内存
        cudaMemcpy(C, gpu_C, sizeof(float) * MATRIX_SIZE * MATRIX_SIZE, cudaMemcpyDeviceToHost);

        /* 释放显存空间 */
        cudaFree(gpu_A);
        cudaFree(gpu_B);
        cudaFree(gpu_C);

        /* 记录结束时间 */
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