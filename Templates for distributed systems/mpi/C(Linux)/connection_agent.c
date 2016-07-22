#include <pthread.h>

pthread_mutex_t pt_MUTEX;
int CLIENT_COUNT=0;

void *doprocessing (void *socket)
{
	int n;
	char buffer[256];
	int* sock = (int*) socket; 
	bzero(buffer,256);
	n = read((*sock),buffer,255);
	if (n < 0){
		perror("ERROR reading from socket");
		pthread_exit(NULL);
	}
	printf("=====================================================================\n");
	printf("ROOT:: server get message: %s\n",buffer);
	printf("=====================================================================\n");
	//mpi processing
	
	n = write((*sock),"Hi client!",10);
	printf("Server:: answer was send\n");
	if (n < 0)
	{
		perror("ERROR writing to socket");
		pthread_exit(NULL);
	}
	int client_id;
	pthread_mutex_lock( &pt_MUTEX );
	client_id=CLIENT_COUNT++;
	pthread_mutex_unlock( &pt_MUTEX );
	printf("ROOT:: server close connection for client %3d\n",client_id);
	pthread_exit(NULL);
}

/**
 * Server routine
 **/
void server_start(int port, int work_node_count)
{ 
		int sockfd, newsockfd, portno, clilen;
		char buffer[256];
		struct sockaddr_in serv_addr, cli_addr;
		int n, pid;
	
		/* First call to socket() function */
		sockfd = socket(AF_INET, SOCK_STREAM, 0);
		if (sockfd < 0){
			perror("ERROR opening socket");
			exit(1);
		}

		/* Initialize socket structure */
		bzero((char *) &serv_addr, sizeof(serv_addr));
		portno = port;

		serv_addr.sin_family = AF_INET;
		serv_addr.sin_addr.s_addr = INADDR_ANY;
		serv_addr.sin_port = htons(portno);

		/* Now bind the host address using bind() call.*/
		if (bind(sockfd, (struct sockaddr *) &serv_addr, sizeof(serv_addr)) < 0)
		{
			perror("ERROR on binding");
			exit(1);
		}

	   /* Now start listening for the clients, here
	   * process will go in sleep mode and will wait
	   * for the incoming connection
	   */

		listen(sockfd,5);
		clilen = sizeof(cli_addr);
		printf("ROOT:: start listen clients\n");
		while (1)
		{
			printf("ROOT:: server waiting for client\n");
			newsockfd = accept(sockfd, (struct sockaddr *) &cli_addr, (socklen_t*)&clilen);
			if (newsockfd < 0)
			{
				perror("ERROR on accept");
				exit(1);
			}
			printf("ROOT:: client accept \n");
			/* Create child process */
			pthread_t clientThread;
			int rc = pthread_create(&clientThread, NULL, doprocessing, &newsockfd);
			if (rc)
			{
				perror("ERROR on new thread");
				exit(1);
			}
			
		} 
}
