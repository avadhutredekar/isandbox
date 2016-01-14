import numpy as np

def readPolygon(fileName="polyg1.txt"):
	f = open(fileName,'r')
	out = f.readlines() # will append in the list out
	amount = out[0]
	x = np.float32([])
	y = np.float32([])
	for i in range(1, len(out)):#line in out:
		array =  out[i].split()
		x = np.append(x, [np.float32(array[0])])
		y = np.append(y, [np.float32(array[1])])
	x = np.append(x, x[0] )
	y = np.append(y, y[0] )
	return (x, y, np.int32([amount]))

def swap( a, b ):
	return ( b, a )

def area( a, b, c ):
	return (b[0] - a[0]) * (c[1] - a[1]) - (b[1] - a[1]) * (c[0] - a[0]) 

def intersect_1( a, b, c, d ):
	if a > b:
		( a, b ) = swap( a, b )
	if c > d:
		( c, d ) = swap( c, d )
	return max( a, c ) <= min( b, d )

def intersect( a, b, c, d ):
	return intersect_1( a[0], b[0], c[0], d[0]) and intersect_1( a[1], b[1], c[1], d[1] ) and area( a, b, c) * area( a, b, d ) <= 0 and area( c, d, a ) * area( c, d, b ) <= 0

def generate_polygons1( dimension ):
	count = 5
	x = np.float32([])#np.float32([np.random.uniform(low=1, high=dimension)])
	#x = np.float32([1,3,3,1, 1,3,3,2,1, 6,7,8,8,7,6, 4,5,6,5, 6]) * dimension/10
	y = np.float32([])#np.float32([np.random.uniform(low=1, high=dimension)])
	#y = np.float32([1,1,3,3, 6,4,7,8,7, 3,2,2,5,5,4, 7,5,7,8, 8]) * dimension/10
	
	#pol = np.int32([4, 9, 15, 19])
	#return (x, y, pol)

	while count > len( x ):
		_x = np.random.uniform(low=1, high=dimension)
		_y = np.random.uniform(low=1, high=dimension)

		flag = True
		for i in range(1, len(x) - 1):
			prev_x = x[len(x)-1]
			prev_y = y[len(x)-1]
			if intersect([x[i-1],y[i-1]], [x[i], y[i]], [prev_x, prev_y], [_x,_y]):
				flag = False
				break
		if flag:
			print("(%s, %s)" % (_x, _y))
			x = np.append(x, [_x])
			y = np.append(y, [_y])
		if len( x ) == count:
			for i in range(1, len(x) - 1):
				if intersect([x[i-1],y[i-1]], [x[i], y[i]], [x[0], y[0]], [_x,_y]):
					count += 1

	#print("%s \n%s" % (x, y))
	#for i in range(0, count):

	pol = np.int32([count])
	return (x, y, pol)


def generate_polygonss( dimension ):
	x = np.int32([np.random.uniform(low=dimension/6, high=dimension/4)])
	y = np.int32([np.random.uniform(low=dimension/6, high=dimension)])
	a = dimension/12
	b = dimension/11
	while True:
		_x = x[len(x)-1]
		_y = y[len(x)-1]
		_x += np.random.randint(low=a, high=b)
		_y += np.random.randint(low=-b, high=b)
		if (dimension - 10) > _x and (dimension - 10) > _y:
			x = np.append(x, [_x])
			y = np.append(y, [_y])
		else:
			break
	x = np.append(x, [_x])
	y = np.append(y, [_y - dimension/6])
	# = f == False
	while True:
		_x = x[len(x)-1]
		_y = y[len(x)-1] 
		_x -= np.random.randint(low=a, high=b)
		_y += np.random.randint(low=-b, high=b)

		flag = True
		for i in range(1, len(x) - 1):
			prev_x = x[len(x)-1]
			prev_y = y[len(x)-1]
			if intersect([x[i-1],y[i-1]], [x[i], y[i]], [prev_x, prev_y], [_x,_y]):
				flag = False
				break
		if flag:		
			x = np.append(x, [_x])
			y = np.append(y, [_y])
			if x[0] >= _x or y[0] >= _y:
				break

	x = np.append(x, [x[0] + 1])
	y = np.append(y, [y[0] + 1])
	#print(x)
	#print(y)
	print("points %s" % len( x ))
	return (x.astype(np.float32, copy=False), y.astype(np.float32, copy=False), np.int32([len( x ) - 1]))


def generate_polygons( dimension ):
	x = np.int32([np.random.uniform(low=dimension/100, high=dimension/4)])
	y = np.int32([np.random.uniform(low=dimension/100, high=dimension/4)])
	a = dimension/12
	b = dimension/11
	f = True
	while True:
		_x = x[len(x)-1]
		_y = y[len(x)-1]
		a = np.random.randint(low=a, high=b)
		if f:	
			_x += a
		else:
			_y += a
		if (dimension - 10) > _x and (dimension - 10) > _y:
			#print("(%s, %s)" % (_x, _y))
			f = f == False
			x = np.append(x, [_x])
			y = np.append(y, [_y])
		else:
			break
	# = f == False
	while True:
		_x = x[len(x)-1]
		_y = y[len(x)-1] 
		a = np.random.randint(low=a, high=b)
		if f:
			_x -= a
		else:
			_y -= a

		flag = True
		for i in range(1, len(x) - 1):
			prev_x = x[len(x)-1]
			prev_y = y[len(x)-1]
			if intersect([x[i-1],y[i-1]], [x[i], y[i]], [prev_x, prev_y], [_x,_y]):
				flag = False
				break
		if flag:
			#print("(%s, %s)" % (_x, _y))
			
			x = np.append(x, [_x])
			y = np.append(y, [_y])
		f = f == False
		if x[0] >= _x or y[0] >= _y:
			break

	x = np.append(x, [x[0] + 1])
	y = np.append(y, [y[0] + 1])
	#print(x)
	#print(y)
	print("points %s" % len( x ))
	return (x.astype(np.float32, copy=False), y.astype(np.float32, copy=False), np.int32([len( x ) - 1]))
