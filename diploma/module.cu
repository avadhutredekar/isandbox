#include <cuda.h>
#include <cuda_runtime.h>
#include <curand.h>
#include <curand_kernel.h>
#include <device_launch_parameters.h>
#include <device_functions.h>
#include <time.h>
#include <stdio.h>
#include <float.h>

extern "C"
{	
	struct Point {
		float x, y;
		int id;

		__device__ bool equal(Point &p) {
			return p.x==x && p.y==y;
		}
	};
	struct Line {
		Point p1;
		Point p2;
	};
	struct Polygon {
		Line *lines;
		int lines_count;
	};

enum {LEFT,  RIGHT,  BEYOND,  BEHIND, BETWEEN, ORIGIN, DESTINATION};
enum { INSIDE, OUTSIDE, BOUNDARY };   
enum { TOUCHING, CROSSING, INESSENTIAL }; 

	__device__  float gr_viz[100000000];//матрица смежности графа видимости размером point_len x point_len
	__device__  float gr_viz1[100000000];
	__device__  float distance[10000];
	__device__  bool visited[10000];

	__device__  bool mVisited[10000];
	__device__  float uDistance[10000];
	__device__  float cDistance[10000];

	__device__ Point *points;
	__device__ Polygon *polygons;
	__device__ int points_count;
	__device__ int polygons_count;
	__device__ int dimension;
	__device__ int k;

	__device__ __constant__ float MAX_VALUE = 1000000;
	
	__device__ __inline__ int pointInPolygon(Point &a);
	__device__ __inline__ bool isInsidePolygons2(float x1, float y1);
	__device__ __inline__ bool isInsidePolygons(Point &p);
	__device__ __inline__ bool isVisibleLine3(Point &p1, Point &p2);
	__device__ __inline__ bool isVisibleLine2(float &x1, float &y1, float &x2, float &y2);
	__device__ __inline__ bool isVisibleLine(Point &p1, Point &p2);
	__device__ __inline__ float evklid2(float x1, float y1, float x2, float y2);
	__device__ __inline__ float evklid(Point &p1, Point &p2);
	__device__ __inline__ bool intersect2(float &x1, float &y1, float &x2, float &y2,
										float &x3, float &y3, float &x4, float &y4);
	__device__ bool intersect(Point &a, Point &b, Point &c, Point &d);

	__global__ void deinit() {
		delete []points;
		delete []polygons[0].lines;
		delete []polygons;
	}

	__global__ void init(float *new_x, float *new_y, int *count, 
							int *p, int *p_len, int *d) {
		k = 0;
		dimension = d[0];
		points_count = count[0];
		points = new Point[points_count];
		polygons_count = p_len[0];
		polygons = new Polygon[polygons_count];
		

		for (int i = 0; i < points_count; i++) {
			points[i].x = new_x[i];
			points[i].y = new_y[i];
			points[i].id = i;

			distance[i] = MAX_VALUE;
			uDistance[i] = MAX_VALUE;
			cDistance[i] = MAX_VALUE;
			visited[i] = false;
			mVisited[i] = false;
		}

		uDistance[points_count-1] = 0;
		cDistance[points_count-1] = 0;
		mVisited[points_count-1] = true;

		int prev = 0;
		for (int i = 0; i < p_len[0]; i++) {
			int cur = p[i];
			int size = cur - prev;
			Line *lines = new Line[size];
			for (int j = 0; j < size; j++) {
				lines[j].p1 = points[prev + j];
				lines[j].p2 = points[prev + (j + 1) % size];
				//printf("	line %d, %d\n", prev + j, prev + (j + 1) % size);
			}

			polygons[i].lines = lines;
			polygons[i].lines_count = size;
			prev = p[i];
		}
	}

	__global__ void get_graph_viz(float *graph)
	{
		for (int i = 0; i < points_count; i++)
			for (int j=0; j < points_count; j++)
				graph[i*points_count+j] = gr_viz[i*points_count+j];
		//memcpy(graph, gr_viz, sizeof(float)*points_count*points_count);
	}

	__global__ void graph_viz()
	{
		unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
		unsigned int j = blockIdx.y * blockDim.y + threadIdx.y;
		int ind = i*points_count + j;
		int ind1 = j*points_count + i;

		if (i<j||ind >= points_count*points_count) {
			//printf("return %d, %d\n", i, j);
			return;
		}

		Point p1 = points[i];
		Point p2 = points[j];
		Point p;// = new Point();
		p.x = (p2.x + p1.x) / 2.0;
		p.y = (p2.y + p1.y) / 2.0;

		if (abs(p1.id - p2.id) <= 1) {
			gr_viz[ind1] = gr_viz1[ind1] = 
			gr_viz[ind] = gr_viz1[ind] = evklid(p1, p2);
		} else if (isVisibleLine3(p1, p2)) {
			gr_viz[ind1] = gr_viz1[ind1] = 
			gr_viz[ind] = gr_viz1[ind] = evklid(p1, p2);
		} else {
			gr_viz[ind1] = gr_viz1[ind1] = 
			gr_viz[ind] = gr_viz1[ind] = -1.0;
		}
//&& isInsidePolygons2((p2.x + p1.x) / 2.0, (p2.y + p1.y) / 2.0) && isInsidePolygons2((p2.x + 0.2*p1.x) / (1.0+0.2), (p2.y + 0.2*p1.y) / (1+0.2))
		//delete p;
	}

	__global__ void graph_viz1()
	{
		for (int i = 0; i < points_count; i++)
			for (int j = 0; j < points_count; j++) {
				int ind = i*points_count + j;
				int ind1 = j*points_count + i;

				if (i<j||ind >= points_count*points_count) {
					//printf("return %d, %d\n", i, j);
					continue;
				}

				Point p1 = points[i];
				Point p2 = points[j];
				Point p;// = new Point();
				p.x = (p2.x + p1.x) / 2.0;
				p.y = (p2.y + p1.y) / 2.0;

				if (abs(p1.id - p2.id) <= 1) {
					gr_viz[ind1] = gr_viz1[ind1] = 
					gr_viz[ind] = gr_viz1[ind] = evklid(p1, p2);
				} else if (isVisibleLine3(p1, p2)) {
					gr_viz[ind1] = gr_viz1[ind1] = 
					gr_viz[ind] = gr_viz1[ind] = evklid(p1, p2);
				} else {
					gr_viz[ind1] = gr_viz1[ind1] = 
					gr_viz[ind] = gr_viz1[ind] = MAX_VALUE;
				}
			}
//&& isInsidePolygons2((p2.x + p1.x) / 2.0, (p2.y + p1.y) / 2.0) && isInsidePolygons2((p2.x + 0.2*p1.x) / (1.0+0.2), (p2.y + 0.2*p1.y) / (1+0.2))
		//delete p;
	}

	__global__ void dijkstra1() {
		unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
		if (i >= points_count)
			return;
		if (mVisited[i]) {
			mVisited[i] = false;

			for (int j = 0; j < points_count; j++) {
				int index = i*points_count+j;
				if (j >= points_count)
					continue;
				if (gr_viz[index] > 0.0) {
					if (uDistance[i] > cDistance[j] + gr_viz[index])
						uDistance[i] = cDistance[j] + gr_viz[index];
				}
			}
		}
	}


	__global__ void dijkstra2() {
		unsigned int ind = blockIdx.x * blockDim.x + threadIdx.x;

		if (cDistance[ind] >= uDistance[ind]) {
			cDistance[ind] = uDistance[ind];
			mVisited[ind] = true;
		} 

		uDistance[ind] = cDistance[ind];
	}

	__global__ void isEmpty(float *check) {
		check[0] = 0;
		for (int i = 0; i < points_count; i++)
			if (uDistance[i] > distance[i]) {
				check[0] = 1;
				return;
			}
	}

	__global__ void dPrint() {
		printf("\nСтоимость пути из начальной вершины до остальных: \n");
		for (int i=0; i<points_count; i++) 
			printf("%d > %d = %f\n", points_count-1, i, uDistance[i]-distance[i]);
	}

	__global__ void dijkstra(int *index_from, float *distances) {
		int st = points_count - 1, index, u;
		float min;
		index_from[st] = st;
		distances[st] = distance[st] = 0;

		for (int i = 0; i < points_count - 1; i++) {
			min = MAX_VALUE;
			for (int j = 0; j < points_count; j++) 
				if (!visited[j] && distance[j] <= min) {
					min = distance[j];
					index = j;
				}
			u = index;
			visited[u] = true;
			for (int j = 0; j < points_count; j++) 
				if (!visited[j] && gr_viz[u*points_count+j]>0.1 && distance[u]<MAX_VALUE && (distance[u]+gr_viz[u*points_count+j] < distance[j])) {
					index_from[j] = u;
					distances[j] = distance[j] = distance[u] + gr_viz[u*points_count+j];
				}
		}

		printf("\nСтоимость пути из начальной вершины до остальных: \n");
		for (int i=0; i<points_count; i++) 
			if (distance[i] >= 0 || distance[i] < MAX_VALUE)
				printf("%d > %d = %f\n", st, i, distance[i]);
			else 
				printf("%d > %d = маршрут не доступен\n", st, i);

	}

	__global__ void spm1(float *indexes) {

		for (int i = 0; i < dimension; i++) {
			for (int j = 0; j < dimension; j++) {
				unsigned int index = i*dimension+j;
				float _x = (float)i;
				float _y = (float)j;
				float min_dis = MAX_VALUE;
				float value_dis;

				if(!isInsidePolygons2(_x, _y)) {
					indexes[index] = 0;
					continue;
				}

				for (int k = 0; k < points_count; k++) {					
					value_dis = distance[k] + evklid2(points[k].x, points[k].y, _x, _y);
					if (value_dis < min_dis && isVisibleLine2(_x, _y, points[k].x, points[k].y)) {
						min_dis = value_dis;
						indexes[index] = (float)points[k].id;
					}
				}
			}
		}
	}

	__global__ void spm(float *indexes) {
		unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
		unsigned int j = blockIdx.y * blockDim.y + threadIdx.y;
		unsigned int index = i*dimension+j;
		if (index >= dimension*dimension) {
			//printf("return %d, %d\n", i, j);
			return;
		}
		float _x = (float)i;
		float _y = (float)j;
		if(!isInsidePolygons2(_x, _y)) {
			indexes[i*dimension+j] = 0;
			return;
		}

		float min_dis = MAX_VALUE;
		float value_dis;
		for (int k = 0; k < points_count; k++) {					
			value_dis = distance[k] + evklid2(points[k].x, points[k].y, _x, _y);
			if (value_dis < min_dis && isVisibleLine2(_x, _y, points[k].x, points[k].y)) {
				min_dis = value_dis;
				indexes[index] = (float)points[k].id;
			}
		}
	}

	__global__ void floyd2() {

		unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
		unsigned int j = blockIdx.y * blockDim.y + threadIdx.y;

		if (i*points_count+j >= points_count*points_count)
			return;;
		float ij=gr_viz1[i*points_count+j], 
			ik=gr_viz1[i*points_count+k], 
			kj=gr_viz1[k*points_count+j];
		float result = 0;
		if (ik < 0 || kj < 0) 
			return;

		if (ij < 0)
			result = ik+kj;
		else
			result = min( ij, ik+kj );

		gr_viz1[i*points_count+j] = result;
		return;
		if (i == 0 && j == 0) {
			k++;
		}
	}

	__global__ void get_floyd2_result(float *matrix) {
		//unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
		//unsigned int j = blockIdx.y * blockDim.y + threadIdx.y;
		//memcpy(matrix, gr_viz1, sizeof(float)*points_count*points_count);
		for (int i = 0; i < points_count; i++)
			for (int j = 0; j < points_count; j++)
				matrix[i*points_count+j] = gr_viz1[i*points_count+j];
	}

	__global__ void floyd() {
		int index = (int)(((float)points_count / (float)min(32,points_count)) + 1);
		unsigned int index_x = index * threadIdx.x;
		unsigned int index_y = index * threadIdx.y;

		for (int k = 0; k < points_count; k++) {
					for (int i = index_x; i < index_x + index && i < points_count; i++) {
						for (int j = index_y; j < index_y + index && j < points_count; j++) {
							if (i*points_count+j >= points_count*points_count)
								continue;
							float ij=gr_viz[i*points_count+j], 
								ik=gr_viz[i*points_count+k], 
								kj=gr_viz[k*points_count+j];
							//matrix[i*points_count+j]=ij;
							float result = 0;
							if (ik < 0 || kj < 0) 
								continue;

							if (ij < 0)
								result = ik+kj;
							else
								result = min( ij, ik+kj );
							//matrix[i*points_count+j]=
							gr_viz[i*points_count+j] = result;
						}
					}
					__syncthreads();
		}
	}

	__global__ void get_floyd_result(float *matrix) {
		//unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
		//unsigned int j = blockIdx.y * blockDim.y + threadIdx.y;
		//memcpy(matrix, gr_viz, sizeof(float)*points_count*points_count);
		for (int i = 0; i < points_count; i++)
			for (int j = 0; j < points_count; j++)
				matrix[i*points_count+j] = gr_viz[i*points_count+j];
	}

	__global__ void floyd1(float *matrix) {
		//unsigned int i = blockIdx.x * blockDim.x + threadIdx.x;
		//unsigned int j = blockIdx.y * blockDim.y + threadIdx.y;
		//unsigned int index = i*points_count+j;
		
		for (int k = 0; k < points_count; k++)
			for (int i = 0; i < points_count; i++)
				for (int j = 0; j < points_count; j++) {
					float result = 0;
					if (gr_viz1[i*points_count+k] < 0 || gr_viz1[k*points_count+j] < 0) 
						continue;

					if (gr_viz1[i*points_count+j] < 0)
						result = gr_viz[i*points_count+k]+gr_viz1[k*points_count+j];
					else
						result = min( gr_viz1[i*points_count+j], gr_viz1[i*points_count+k]+gr_viz1[k*points_count+j]);
					gr_viz1[i*points_count+j] = matrix[i*points_count+j] = result;
				}
	}

	__device__ __inline__ bool pointInSegment(Point &t, Point &p1, Point &p2) {
		float k1 = (p1.x + p2.x) / p1.x;
		float k2 = (p1.x + p2.x) / p2.x;
		if (t.x < min(k1, k2) || t.x > max(k1, k2))
			return false;
		k1 = (p1.y + p2.y) / p1.y;
		k2 = (p1.y + p2.y) / p2.y;
		if (t.y < min(k1, k2) || t.y > max(k1, k2))
			return false;
		return true;
	}

	__device__ __inline__ bool pointInSegment2(float x3, float y3, float x1, float y1, float x2, float y2) {
		float k1 = (x1 + x2) / x1;
		float k2 = (x1 + x2) / x2;
		if (x3 < min(k1, k2) || x3 > max(k1, k2))
			return false;
		k1 = (y1 + y2) / y1;
		k2 = (y1 + y2) / y2;
		if (y3 < min(k1, k2) || y3 > max(k1, k2))
			return false;
		return true;
	}

	__device__ __inline__ bool isInsidePolygons2(float x1, float y1) {
		int inter_count = 0;
		float x2 = 0;
		float y2 = y1;

		for (int k = 0; k < polygons_count; k++) {
			Polygon polygon = polygons[k];
			inter_count = 0;
			for(int l = 0; l < polygon.lines_count; l++) {
				Line line = polygon.lines[l];					
				if (intersect2(x2, y2, x1, y1, line.p1.x, line.p1.y, line.p2.x, line.p2.y) )
					inter_count = 1 - inter_count;
				else if (pointInSegment2(x1, y1, line.p1.x, line.p1.y, line.p2.x, line.p2.y))
					return true;
			}
			if (inter_count == 1) {
				return true;
			}
		}
		return inter_count == 1;
	}

	__device__ __inline__ bool isInsidePolygons(Point &p1) {
		int inter_count = 0;
		Point *p2 = new Point();
		p2->x = 0;
		p2->y = p1.y;

		for (int k = 0; k < polygons_count; k++) {
			Polygon polygon = polygons[k];
			inter_count = 0;
			for(int l = 0; l < polygon.lines_count; l++) {
				Line line = polygon.lines[l];
				if (intersect(*p2, p1, line.p1, line.p2))
					inter_count = 1 - inter_count;
				else if (pointInSegment(p1, line.p1, line.p2))
					return true;
			}
			if (inter_count == 1) {
				delete p2;
				return true;
			}
		}
		delete p2;
		return inter_count == 1;
	}


	__device__ __inline__ bool isVisibleLine(Point &p1, Point &p2) {
		int diff_id = abs(p1.id - p2.id);
		for (int k = 0; k < polygons_count; k++) {
			Polygon polygon = polygons[k];
			if (diff_id > 1 && diff_id != polygon.lines_count - 1) {
				int id1 = p1.id - polygon.lines[0].p1.id;
				int id2 = p2.id - polygon.lines[0].p1.id;
				if ( id1 >= 0 && id2 >= 0 && id1 < polygon.lines_count && id2 < polygon.lines_count) {
					return false;
				}
			}

			for(int l = 0; l < polygon.lines_count; l++) {
				Line line = polygon.lines[l];
				if (p1.id!=line.p1.id && p2.id!=line.p1.id && p1.id!=line.p2.id && p2.id!=line.p2.id && 
					intersect(p1, p2, line.p1, line.p2)) {
						return false;
				}
			}
		}	
		return true;
	}

	__device__ __inline__ bool isVisibleLine2(float &x1, float &y1, float &x2, float &y2) {
		for (int k = 0; k < polygons_count; k++) {
			Polygon polygon = polygons[k];
			
			for(int l = 0; l < polygon.lines_count; l++) {
				Line line = polygon.lines[l];
				Point p3 = line.p1;
				Point p4 = line.p2;
				if (intersect2(x1, y1, x2, y2, p3.x, p3.y, p4.x, p4.y) && 
					!((x2 == p3.x && y2 == p3.y) || (x2 == p4.x && y2 == p4.y))) {
						return false;
				}
			}
		}	
		return true;
	}


	__device__ __inline__ bool leftSide(Point &p2, Point &p0, Point &p1)
	{
  		float sa = (p1.x - p0.x)*(p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y) ;
    	return sa > 0.0 ;
	}

	__device__ __inline__ int rightSide(Point &p2, Point &p0, Point &p1)
	{
  		float sa = (p1.x - p0.x)*(p2.y-p0.y)-(p1.y-p0.y)*(p2.x-p0.x); //(p1.x - p0.x)*(p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y) ;
    	return sa <= 0.0 ;
	}

	__device__ __inline__ bool isVisibleLine3( Point &p1, Point &p2 ) {

		int firstPoint = 0;
		int secondPoint = 0;
		Line l1, l2, l3, l4;
		for (int k = 0; k < polygons_count; k++) {
			Polygon polygon = polygons[k];
			
			for(int l = 0; l < polygon.lines_count; l++) {
				Line line = polygon.lines[l];
				Point p3 = line.p1;
				Point p4 = line.p2;
				if (intersect2(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x, p4.y) && 
					!((p2.id == p3.id) || (p2.id == p4.id) || (p1.id == p3.id) || (p1.id == p4.id))) {
						return false;
				}
				if ((p1.id == p3.id || p1.id == p4.id) && leftSide(p2, p3, p4)) {
					firstPoint++;
				}
				if ((p2.id == p3.id || p2.id == p4.id) && leftSide(p1, p3, p4)) {
					secondPoint++;
				}
						
			}
		}	
		if (firstPoint + secondPoint < 2)
			return true;
		float ratio = 11.0;
		float ratio1 = 0.1;
		return isInsidePolygons2((p2.x + ratio*p1.x) / (1.0+ratio), (p2.y + ratio*p1.y) / (1.0+ratio))
		&& isInsidePolygons2((p2.x + ratio1*p1.x) / (1.0+ratio1), (p2.y + ratio1*p1.y) / (1.0+ratio1));
	}

	__device__ __inline__ float evklid2(float x1, float y1, float x2, float y2) {
		float m1 = x1 - x2;
		float m2 = y1 - y2;
		return sqrt(m1*m1 + m2*m2);
	}

	__device__ __inline__ float evklid(Point &p1, Point &p2) {
		return sqrt(pow(p1.x - p2.x, 2) + pow(p1.y - p2.y, 2));
	}

	__device__ __inline__ void swap(float &a, float &b) {
		float c = a;
		a = b;
		b = c;
	}

	__inline__ __device__ float area2 (float &x1, float &y1, float &x2, float &y2, float &x3, float &y3) {
		return (x2 - x1) * (y3 - y1) - (y2 - y1) * (x3 - x1);
	}
	__inline__ __device__ float area (Point &a, Point &b, Point &c) {
		return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
	}
	 
	__inline__ __device__ bool intersect_1 (float a, float b, float c, float d) {
		if (a > b)  swap (a, b);
		if (c > d)  swap (c, d);
		return max(a,c) <= min(b,d);
	}

	__device__ __inline__ bool intersect2(float &x1, float &y1, float &x2, float &y2,
										float &x3, float &y3, float &x4, float &y4) {
		return 
			area2(x1, y1, x2, y2, x3, y3) * area2(x1, y1, x2, y2, x4, y4) <= 0
			&& area2(x3, y3, x4, y4, x1, y1) * area2(x3, y3, x4, y4, x2, y2) <= 0
			&& intersect_1 (x1, x2, x3, x4)
			&& intersect_1 (y1, y2, y3, y4);
	}
	 
	__device__ __inline__ bool intersect (Point &a, Point &b, Point &c, Point &d) {
		return intersect_1 (a.x, b.x, c.x, d.x)
			&& intersect_1 (a.y, b.y, c.y, d.y)
			&& area(a,b,c) * area(a,b,d) <= 0
			&& area(c,d,a) * area(c,d,b) <= 0;
	}



__device__ __inline__ int classify(Point &p2, Point &p0, Point &p1)
{
  float sa = (p1.x - p0.x)*(p2.y - p0.y) - (p2.x - p0.x) * (p1.y - p0.y);
  if (sa > 0.0)
    return LEFT;
  if (sa < 0.0)
    return RIGHT;
  if (((p1.x - p0.x) * (p2.x - p0.x)< 0.0) || ((p1.y - p0.y) * (p2.y - p0.y) < 0.0))
    return BEHIND;
  if (evklid2(p1.x - p0.x, p1.y - p0.y, p1.x - p0.x, p1.y - p0.y) < evklid2(p2.x - p0.x, p2.y - p0.y, p2.x - p0.x, p2.y - p0.y))
    return BEYOND;
  if (fabs(p0.x - p2.x) < 0.01 && fabs(p0.y - p2.y) < 0.01)
    return ORIGIN;
  if (fabs(p1.x - p2.x) < 0.01 && fabs(p1.y - p2.y) < 0.01)
    return DESTINATION;
  return BETWEEN;
}

__device__ __inline__ int edgeType(Point &a, Line &e)
{
  Point v = e.p1;
  Point w = e.p2;
  switch (classify(a, e.p1, e.p2)) {
    case LEFT:
      return ((v.y<a.y)&&(a.y<=w.y)) ? CROSSING : INESSENTIAL; 
    case RIGHT:
      return ((w.y<a.y)&&(a.y<=v.y)) ? CROSSING : INESSENTIAL; 
    case BETWEEN:
    case ORIGIN:
    case DESTINATION:
      return TOUCHING;
    default:
      return INESSENTIAL;
  }
}


__device__ __inline__ int pointInPolygon(Point &a)
{
	int parity = 0;
	Polygon polygon = polygons[0];
	for(int l = 0; l < polygon.lines_count; l++) {
		Line line = polygon.lines[l];
		switch (edgeType(a, line)) {
    		case TOUCHING:
    			return BOUNDARY;
    		case CROSSING:
    			parity = 1 - parity;
		}
	}

	return (parity ? INSIDE : OUTSIDE);
}
}
