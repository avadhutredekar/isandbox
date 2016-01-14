# -*- coding: utf-8 -*-
import numpy as np
from pycuda import driver, compiler, gpuarray, tools, curandom
import pycuda.autoinit

import numpy
import numpy.linalg as la
import sys

import datetime
import time
from pprint import pprint
from draw import *
from generator import *

def graph( mod ):
	readPolygon()
	init = mod.get_function("init")
	deinit = mod.get_function("deinit")
	graph_viz = mod.get_function("graph_viz")
	graph_viz1 = mod.get_function("graph_viz1")
	get_graph_viz = mod.get_function("get_graph_viz")
	dijkstra = mod.get_function("dijkstra")
	dijkstra1 = mod.get_function("dijkstra1")
	dijkstra2 = mod.get_function("dijkstra2")
	isEmpty = mod.get_function("isEmpty")
	dPrint = mod.get_function("dPrint")
	spm = mod.get_function("spm")
	spm1 = mod.get_function("spm1")
	floyd = mod.get_function("floyd")
	floyd1 = mod.get_function("floyd1")
	floyd2 = mod.get_function("floyd2")
	get_floyd = mod.get_function("get_floyd_result")
	get_floyd2 = mod.get_function("get_floyd2_result")


	for i in range(0,1):

		dimension = np.int32([30])
		(x, y, pol) = readPolygon()#generate_polygonss( dimension[0] )
		points_count = np.int32([len(x)])
		print("dimension = %s" % dimension[0])
		print("count points = %s" % points_count[0])
		pol_len = np.int32([len(pol)])	
		
		
		blockX, blockY = (20, 20)
		gridX = dimension[0]/blockX 
		if dimension[0]%blockX > 0:
			gridX+=1
		gridY = dimension[0]/blockY
		if dimension[0]%blockY > 0:
			gridY+=1

		gr_viz_result = np.zeros((points_count[0], points_count[0]), np.float32)
		spt_result = np.zeros(points_count[0], np.int32)
		smp_result = np.zeros((dimension[0], dimension[0]), np.float32)
		floyd_result = np.zeros((points_count[0], points_count[0]), np.float32)
		floyd_result2 = np.zeros((points_count[0], points_count[0]), np.float32)
		distances = np.zeros(points_count[0], np.float32)
		empty = np.zeros(1, np.float32)

		start1 = time.time()

		start = time.time()
		init(driver.In(x), driver.In(y), driver.In(points_count), 
				driver.In(pol), driver.In(pol_len), driver.In(dimension), grid=(1,1), block=(1,1,1))
		print("init = %s seconds" % (time.time() - start))
		

		if True:
			blockX, blockY = (20, 20)
			gridX = points_count[0]/blockX 
			if points_count[0]%blockX > 0:
				gridX+=1
			gridY = points_count[0]/blockY
			if points_count[0]%blockY > 0:
				gridY+=1
			start = time.time()
			graph_viz(grid=(gridX,gridY), block=(blockX,blockY,1))
			get_graph_viz(driver.Out(gr_viz_result), grid=(1,1), block=(1,1,1))
			##print(gr_viz_result)
			print("viz = %s seconds" % (time.time() - start))

			#start = time.time()
			#graph_viz1(grid=(1,1), block=(1,1,1))
			#get_graph_viz(driver.Out(gr_viz_result), grid=(1,1), block=(1,1,1))
			##print(gr_viz_result)
			#print("viz1 = %s seconds" % (time.time() - start))
		
		if True:
			start = time.time()
			dijkstra(driver.Out(spt_result), driver.Out(distances), grid=(1,1),block=(1,1,1))
			#print(distances)
			print("spt cpu = %s seconds" % (time.time() - start))

		if True:
			block = 100
			grid = points_count[0]/block
			if points_count[0]%block > 0:
				grid+=1

			start = time.time()
			empty[0] = 1;
			index = 0
			while empty[0] > 0:
			#for i in range(1,50):
				index = index+1
				dijkstra1(grid=(grid,1), block=(block,1,1))
				dijkstra2(grid=(grid,1), block=(block,1,1))
				isEmpty(driver.Out(empty), grid=(1,1),block=(1,1,1))
			#dPrint(grid=(1,1),block=(1,1,1))
			print("index %s" % (index))
			print("spt gpu = %s seconds" % (time.time() - start))

		if False:
			blockX, blockY = (20, 20)
			gridX = dimension[0]/blockX 
			if dimension[0]%blockX > 0:
				gridX+=1
			gridY = dimension[0]/blockY
			if dimension[0]%blockY > 0:
				gridY+=1
			start = time.time()
			spm(driver.Out(smp_result), grid=(gridX,gridY), block=(blockX,blockY,1))
			#spm1(driver.Out(smp_result), grid=(1,1), block=(1,1,1))
			print("spm =  %s" % (time.time() - start))

		if False:
			start = time.time()
			floyd(grid=(1,1), block=(min(32, points_count[0]*1),min(32, points_count[0]*1),1))
			get_floyd(driver.Out(floyd_result), grid=(1,1), block=(1, 1, 1))
			print("floyd = %s" % (time.time() - start))
			#print(floyd_result[len(x)-1])

		if False:
			blockX, blockY = (15, 15)
			gridX = points_count[0]/blockX 
			if points_count[0]%blockX > 0:
				gridX+=1
			gridY = points_count[0]/blockY
			if points_count[0]%blockY > 0:
				gridY+=1
			start = time.time()
			for k in range(0, len(x)):
				floyd2(grid=(gridX,gridY), block=(blockX, blockY, 1))
			get_floyd2(driver.Out(floyd_result2), grid=(1,1), block=(1, 1, 1))
			print("floyd optimize = %s" % (time.time() - start))
			#print(floyd_result2[len(x)-1])

		start = time.time()
		#floyd1(driver.Out(floyd_result), grid=(1,1), block=(1,1,1))
		#print("floyd = %s" % (time.time() - start))
		#print(floyd_result[len(x)-1])
		#print("time = %s seconds" % (time.time() - start1))

		deinit(grid=(1,1), block=(1,1,1))
		drawGraph(dimension, x, y, pol, gr_viz_result, spt_result, smp_result)




	#gr_viz_result = gr_viz.get()
	#spt_result = spt.get()
	#smp_result = spm_index.get()

	#print(spt_result)
	#init(grid=(1,1), block=(1,1,1))
	#dest = numpy.zeros_like(a)


def main():
	mod = compiler.SourceModule(
		open("module.cu").read(), keep=False, no_extern_c=True)
	
	graph(mod)


if __name__ == "__main__":
    main()

	#numpy.random.randn(5000).astype(numpy.float32)
	#dest = numpy.zeros_like(a)