#include <stdio.h>
#include <time.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include "mpi.h"

int main(int argc, char *argv[])
{
  MPI_Comm gridComm; //������������ ������������.
  MPI_Status status;
  int dims[2]; // ���������� ����������� �������.
  int periodic[2]; // ������������� �����.
  int reorder = 1; // ������������� ���������.
  int q = 3; 
  int ndims = 2; // ����������� ����.
  int maxdims = 2; // ����� ���������.
  int coordinates[2]; //������. �����. ��������.
  int gridRank; //���� ��������.
  //int coords[2];

  if (argc > 1)
		q = atoi(argv[1]);

  MPI_Comm row_comm;
   dims[0] = dims[1] = q;
  periodic[0] = periodic[1] = 1; //������������� ����� -- ������.
  //coords[0] = 0; coords[1] = 1;
  MPI_Init(&argc, &argv);
  MPI_Cart_create(MPI_COMM_WORLD, ndims, dims, periodic, reorder, &gridComm);
  MPI_Comm_rank(gridComm, &gridRank);
  MPI_Cart_coords(gridComm, gridRank, maxdims, coordinates);

  int source, dest;
  MPI_Cart_shift(gridComm, 0, 1, &source, &dest);
    
  char charRank = gridRank + '0';
  char buf1[10] = "hello";
  buf1[5] = charRank;
  //char b[2];
  //itoa(gridRank, b, 10);
  //char cr[1];
  //cr[0] = charRank;
  char buf2[10];// = "hello";// + charRank;
  //buf2[5] = charRank;
  //strcat(buf2, &cr[1]);
  //strcat(buf2, (gridRank + '0'));
  //strcat(buf2, b);
  //MPI_Sendrecv(buf1, 10, MPI_CHAR, source, 123, buf2, 10, MPI_CHAR, dest, 123, gridComm, &status);
  MPI_Sendrecv(buf1, 10, MPI_CHAR, dest, 123, buf2, 10, MPI_CHAR, source, 123, gridComm, &status);

  printf("Process #%i, coord [%i, %i]; src(%i), dest(%i) send{%s}, recv{%s}\n", gridRank, coordinates[0], coordinates[1], source, dest, buf1, buf2);

  //printf("Source: %i, dest: %d", source, dest);

  MPI_Finalize();
  return 0;
}