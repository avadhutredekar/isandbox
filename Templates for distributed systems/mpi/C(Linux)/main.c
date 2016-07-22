/*
 * main.c
 * 
 * Copyright 2015 nikita <nikita@ubuntu>
 * 
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <mpi.h>
#include <netdb.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>
#include "connection_agent.c"

//MPI based server
#define PORT 5001

int slave_routine(int procRank);

int main(int argc, char* argv[]){

	int procNum, procRank, recvRank;

	MPI_Status Status;
	MPI_Init(&argc, &argv);

	MPI_Comm_size(MPI_COMM_WORLD, &procNum);
	MPI_Comm_rank(MPI_COMM_WORLD, &procRank);

	if( procRank == 0 ){
		server_start(PORT, procNum-1);
	}
	else{
		slave_routine(procRank);
	}
	MPI_Finalize();
	return 0;
} 

int slave_routine(int procRank)
{
	printf("Slave %d: working\n", procRank);
	return 0;
}






