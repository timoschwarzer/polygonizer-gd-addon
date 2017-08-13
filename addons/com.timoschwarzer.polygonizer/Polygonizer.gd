extends Reference

var resolution = 5
var margin = 0

var polygon = []
var trace_points = []

func scan(image):
	polygon = []
	trace_points = []
	
	var last_included = false
	
	# Top to bottom
	for x in range(0, image.get_width(), resolution + 1):
		last_included = false
		for y in range(0, image.get_height(), resolution + 1):
			if (image.get_pixel(x, y).a > 0.1):
				if (!last_included):
					trace_points.append(rp(x, y - resolution - margin))
					last_included = true
			else:
				if (last_included):
					trace_points.append(rp(x, y + resolution + margin))
					last_included = false
		
		if (last_included):
			trace_points.append(rp(x, image.get_height() + resolution + margin))
	
	# Left to right
	for y in range(0, image.get_height(), resolution + 1):
		last_included = false
		for x in range(0, image.get_width(), resolution + 1):
			if (image.get_pixel(x, y).a > 0.1):
				if (!last_included):
					trace_points.append(rp(x - resolution * 2 - margin, y))
					last_included = true
			else:
				if (last_included):
					trace_points.append(rp(x + resolution + margin, y))
					last_included = false
		
		if (last_included):
			trace_points.append(rp(image.get_width() + resolution + margin, y))
	
	trace_points.sort_custom(self, "point_compare")
	monotone_chain()
	return polygon

func rp(x, y):
	return Vector2(x, y)

func is_left_of_line(point, a, b):
	return ((a.x - b.x) * (point.y - a.y) - (b.y - a.y) * (point.x - a.x)) > 0

func distance_to_line(point, a, b):
	return abs((a.x - b.x) * (a.y - point.y) - (a.x - point.x) * (b.y - a.y)) / sqrt(pow(b.x - a.x, 2) + pow(b.y - a.y, 2))

func cross(a, b, c):
	return (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)

func point_compare(p1, p2):
	if (p1.x == p2.x):
		return p1.y - p2.y < 0
	else:
		return p1.x - p2.x < 0

func monotone_chain():
	polygon = []
	
	if (trace_points.size() > 1):
		var n = trace_points.size()
		var k = 0
		var hull = []
		for i in range(0, n * 2 - 1):
			hull.append(Vector2())
		
		for i in range(0, n - 1):
			while (k >= 2 && cross(hull[k - 2], hull[k - 1], trace_points[i]) <= 0):
				k -= 1
			hull[k] = trace_points[i]
			k += 1
		
		var t = k + 1
		for i in range(n - 2, 0, -1):
			while (k >= t && cross(hull[k - 2], hull[k - 1], trace_points[i]) <= 0):
				k -= 1
			hull[k] = trace_points[i]
			k += 1
		
		for i in range(0, k - 1):
			polygon.append(hull[i])
		
	else:
		polygon = trace_points