#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <mpi.h>

// function to generate random float matrices
void generate_matrix(float* matrix, int rows, int cols) {
    for (int i = 0; i < rows * cols; i++) {
        matrix[i] = (float) rand() / (float) RAND_MAX;
    }
}

// function to print a matrix
void print_matrix(float* matrix, int rows, int cols) {
    for (int i = 0; i < rows; i++) {
        for (int j = 0; j < cols; j++) {
            printf("%f ", matrix[i * cols + j]);
        }
        printf("\n");
    }
}

// function to multiply two matrices
void matrix_multiply(float* A, float* B, float* C, int m, int n, int p) {
    for (int i = 0; i < m; i++) {
        for (int j = 0; j < p; j++) {
            float sum = 0.0;
            for (int k = 0; k < n; k++) {
                sum += A[i * n + k] * B[k * p + j];
            }
            C[i * p + j] = sum;
        }
    }
}

int main(int argc, char** argv) {
    int rank, size;
    MPI_Init(&argc, &argv);
    MPI_Comm_rank(MPI_COMM_WORLD, &rank);
    MPI_Comm_size(MPI_COMM_WORLD, &size);

    // check command line arguments
    if (argc != 4) {
        if (rank == 0) {
            printf("Usage: %s m n p\n", argv[0]);
            printf("  where m is the number of rows of matrix A,\n");
            printf("        n is the number of columns of matrix A and rows of matrix B,\n");
            printf("        p is the number of columns of matrix B,\n");
            printf("  and number of processes is specified by the environment variable MPI_COMM_WORLD_SIZE.\n");
        }
        MPI_Finalize();
        exit(1);
    }

    // read matrix dimensions from command line arguments
    int m = atoi(argv[1]);
    int n = atoi(argv[2]);
    int p = atoi(argv[3]);

    // allocate memory for matrices
    float* A = (float*) malloc(m * n * sizeof(float));
    float* B = (float*) malloc(n * p * sizeof(float));
    float* C = (float*) malloc(m * p * sizeof(float));

    // generate random matrices on process 0
    if (rank == 0) {
        srand(time(NULL));
        generate_matrix(A, m, n);
        generate_matrix(B, n, p);
    }

    // start timer
    double start_time = MPI_Wtime();

    // broadcast matrices to all processes
    MPI_Bcast(A, m * n, MPI_FLOAT, 0, MPI_COMM_WORLD);
    MPI_Bcast(B, n * p, MPI_FLOAT, 0, MPI_COMM_WORLD);

    // split rows of matrix A among processes
    int rows_per_process = m / size;
    float* local_A = (float*) malloc(rows_per_process * n * sizeof(float));
    MPI_Scatter(A, rows_per_process * n, MPI_FLOAT, local_A, rows_per_process * n, MPI_FLOAT, 0, MPI_COMM_WORLD);

    // allocate memory for local result matrix
    float* local_C = (float*) malloc(rows_per_process * p * sizeof(float));
    
    // perform local matrix multiplication
    matrix_multiply(local_A, B, local_C, rows_per_process, n, p);
    
    // gather results from all processes
    MPI_Gather(local_C, rows_per_process * p, MPI_FLOAT, C, rows_per_process * p, MPI_FLOAT, 0, MPI_COMM_WORLD);
    
    // stop timer
    double end_time = MPI_Wtime();
    
    // calculate execution time
    double execution_time = end_time - start_time;
    
    // print execution time on process 0
    //if (rank == 0) {
        printf("Execution time: %f seconds\n", execution_time);
    //}
    
    // free memory
    free(A);
    free(B);
    free(C);
    free(local_A);
    free(local_C);
    
    MPI_Finalize();
    return 0;
}