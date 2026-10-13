@tool
extends RefCounted

## Geometry helpers for confining a [PhantomCamera2D] to a union of axis-aligned rectangles.
##
## The union is baked into its maximal rectangles: rectangles inside the union
## that cannot grow in any direction without leaving it. Any camera view that
## fits inside the union fits inside at least one of them.

## Edge coordinates closer than this are treated as the same edge.
const EPSILON: float = 0.01


## Returns the maximal rectangles of the union of [param rects].
static func bake(rects: Array[Rect2]) -> Array[Rect2]:
	var maximal: Array[Rect2] = []
	if rects.is_empty(): return maximal

	var xs: PackedFloat64Array = _merged_edges(rects, Vector2.AXIS_X)
	var ys: PackedFloat64Array = _merged_edges(rects, Vector2.AXIS_Y)
	var columns: int = xs.size() - 1
	var rows: int = ys.size() - 1

	# Grid cell [column, row] is covered if its centre lies inside any rectangle.
	var covered: PackedByteArray = PackedByteArray()
	covered.resize(columns * rows)
	for row in rows:
		for column in columns:
			var center: Vector2 = Vector2(
				(xs[column] + xs[column + 1]) / 2,
				(ys[row] + ys[row + 1]) / 2
			)
			if _contains(rects, center):
				covered[row * columns + column] = 1

	# column_ok[column] = column is covered in every row from top to bottom.
	var column_ok: PackedByteArray = PackedByteArray()
	column_ok.resize(columns)
	for top in rows:
		column_ok.fill(1)
		for bottom in range(top, rows):
			for column in columns:
				if covered[bottom * columns + column] == 0:
					column_ok[column] = 0
			if not column_ok.has(1): break

			var column: int = 0
			while column < columns:
				if column_ok[column] == 0:
					column += 1
					continue
				var left: int = column
				while column < columns and column_ok[column] == 1:
					column += 1
				var right: int = column - 1

				if _row_covers(covered, columns, top - 1, left, right): continue
				if _row_covers(covered, columns, bottom + 1, left, right): continue
				maximal.append(Rect2(
					xs[left],
					ys[top],
					xs[right + 1] - xs[left],
					ys[bottom + 1] - ys[top]
				))

	return maximal


## Returns the position nearest to [param point] where a view of half size
## [param half_view] stays inside the [param maximal] rectangles, inset by
## [param margin] (left, top, right, bottom).[br]
## If the view fits nowhere, clamps against the bounding box the same way the
## single-rectangle limit does.
static func confine(point: Vector2, maximal: Array[Rect2], half_view: Vector2, margin: Vector4) -> Vector2:
	if maximal.is_empty(): return point

	var nearest: Vector2 = point
	var nearest_distance: float = INF
	for rect in maximal:
		var region: Rect2 = _shrink(rect, half_view, margin)
		if region.size.x < 0 or region.size.y < 0: continue

		var candidate: Vector2 = point.clamp(region.position, region.end)
		var distance: float = candidate.distance_squared_to(point)
		if distance == 0: return point
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate

	if nearest_distance < INF: return nearest

	var bounds: Rect2 = maximal[0]
	for rect in maximal:
		bounds = bounds.merge(rect)
	return Vector2(
		clampf(point.x, bounds.position.x + margin.x + half_view.x, bounds.end.x - margin.z - half_view.x),
		clampf(point.y, bounds.position.y + margin.y + half_view.y, bounds.end.y - margin.w - half_view.y)
	)


## Returns a path from [param from] to [param to] along which the view stays
## inside the [param maximal] rectangles: straight where it can, and along an
## edge where the edge blocks the way. When blocked, it moves along whichever
## axis gets further, then aims at [param to] again.[br]
## The path starts at the valid position nearest to [param from]. It ends
## short of [param to] if it gets stuck, such as at a hole in the union, and
## is empty if the view fits nowhere.
static func slide_path(from: Vector2, to: Vector2, maximal: Array[Rect2], half_view: Vector2, margin: Vector4) -> PackedVector2Array:
	const MAX_MOVES: int = 16
	var path: PackedVector2Array = PackedVector2Array()
	var regions: Array[Rect2] = reachable(maximal, half_view, margin)
	if regions.is_empty(): return path

	var point: Vector2 = _nearest(regions, from)
	path.append(point)
	for i in MAX_MOVES:
		var motion: Vector2 = to - point
		if motion.length() <= EPSILON:
			path[path.size() - 1] = to
			break

		var next: Vector2 = point + motion * _travel(regions, point, motion)
		if next.distance_to(point) <= EPSILON:
			var along_x: Vector2 = Vector2(motion.x, 0)
			var along_y: Vector2 = Vector2(0, motion.y)
			along_x *= _travel(regions, point, along_x)
			along_y *= _travel(regions, point, along_y)
			next = point + (along_x if along_x.length() >= along_y.length() else along_y)
		# Rounding can leave a move just outside.
		next = _nearest(regions, next)
		if next.distance_to(point) <= EPSILON: break
		point = next
		path.append(point)
	return path


## Returns the length of the polyline [param path].
static func path_length(path: PackedVector2Array) -> float:
	var length: float = 0
	for i in range(1, path.size()):
		length += path[i - 1].distance_to(path[i])
	return length


## Returns the point [param distance] along the polyline [param path],
## clamped to its ends. [param path] must not be empty.
static func path_point(path: PackedVector2Array, distance: float) -> Vector2:
	distance = maxf(distance, 0)
	for i in range(1, path.size()):
		var segment: float = path[i - 1].distance_to(path[i])
		if distance < segment:
			return path[i - 1].lerp(path[i], distance / segment)
		distance -= segment
	return path[path.size() - 1]


## Returns the camera-centre regions of the [param maximal] rectangles the view
## fits in. A region can have zero width or height.
static func reachable(maximal: Array[Rect2], half_view: Vector2, margin: Vector4) -> Array[Rect2]:
	var regions: Array[Rect2] = []
	for rect in maximal:
		var region: Rect2 = _shrink(rect, half_view, margin)
		if region.size.x >= 0 and region.size.y >= 0:
			regions.append(region)
	return regions


## Whether part of the union can never be shown, because it only lies in
## [param maximal] rectangles that are too small for the view.
static func has_unreachable(maximal: Array[Rect2], half_view: Vector2, margin: Vector4) -> bool:
	var fitting: Array[Rect2] = []
	var too_small: Array[Rect2] = []
	for rect in maximal:
		var region: Rect2 = _shrink(rect, half_view, margin)
		if region.size.x < 0 or region.size.y < 0:
			too_small.append(rect)
		else:
			fitting.append(rect)
	if too_small.is_empty(): return false

	var xs: PackedFloat64Array = _merged_edges(maximal, Vector2.AXIS_X)
	var ys: PackedFloat64Array = _merged_edges(maximal, Vector2.AXIS_Y)
	for row in ys.size() - 1:
		for column in xs.size() - 1:
			var center: Vector2 = Vector2(
				(xs[column] + xs[column + 1]) / 2,
				(ys[row] + ys[row + 1]) / 2
			)
			if _contains(too_small, center) and not _contains(fitting, center):
				return true
	return false


## Whether [param xform] keeps rectangles axis-aligned: rotated by a multiple
## of 90 degrees and not skewed. Scale and flips are allowed.
static func is_axis_aligned(xform: Transform2D) -> bool:
	const TOLERANCE: float = 0.001
	var x: Vector2 = xform.x.normalized()
	var y: Vector2 = xform.y.normalized()
	return (absf(x.y) < TOLERANCE and absf(y.x) < TOLERANCE) \
		or (absf(x.x) < TOLERANCE and absf(y.y) < TOLERANCE)


## The point inside [param regions] nearest to [param point].
static func _nearest(regions: Array[Rect2], point: Vector2) -> Vector2:
	var nearest: Vector2 = point
	var nearest_distance: float = INF
	for region in regions:
		var candidate: Vector2 = point.clamp(region.position, region.end)
		var distance: float = candidate.distance_squared_to(point)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest = candidate
	return nearest


## How far [param point] can move along [param motion] while staying inside
## [param regions], as a fraction from 0 to 1. Gaps up to [constant EPSILON]
## long are crossed.
static func _travel(regions: Array[Rect2], point: Vector2, motion: Vector2) -> float:
	if motion == Vector2.ZERO: return 0
	var slack: float = EPSILON / motion.length()
	var reached: float = 0
	var extended: bool = true
	while extended and reached < 1:
		extended = false
		for region in regions:
			var span: Vector2 = _span(region, point, motion)
			if span.x <= reached + slack and span.y > reached:
				reached = span.y
				extended = true
	return minf(reached, 1)


## The part of the segment from [param point] to [param point] + [param motion]
## inside [param rect], as fractions (start, end) clipped to 0..1.
## Empty when start > end. On an axis the segment does not move along,
## [param point] may be up to [constant EPSILON] outside.
static func _span(rect: Rect2, point: Vector2, motion: Vector2) -> Vector2:
	var span: Vector2 = Vector2(0, 1)
	for axis in 2:
		if motion[axis] == 0:
			if point[axis] < rect.position[axis] - EPSILON or point[axis] > rect.end[axis] + EPSILON:
				return Vector2(1, 0)
			continue
		var low: float = (rect.position[axis] - point[axis]) / motion[axis]
		var high: float = (rect.end[axis] - point[axis]) / motion[axis]
		span.x = maxf(span.x, minf(low, high))
		span.y = minf(span.y, maxf(low, high))
	return span


## Whether [param point] lies inside any of [param rects], within [constant EPSILON].
static func _contains(rects: Array[Rect2], point: Vector2) -> bool:
	for rect in rects:
		if rect.grow(EPSILON).has_point(point): return true
	return false


## The camera-centre region of [param rect]. Its size is negative on an axis
## where the view does not fit.
static func _shrink(rect: Rect2, half_view: Vector2, margin: Vector4) -> Rect2:
	var low: Vector2 = rect.position + half_view + Vector2(margin.x, margin.y)
	var high: Vector2 = rect.end - half_view - Vector2(margin.z, margin.w)
	return Rect2(low, high - low)


## Sorted rectangle edge coordinates along [param axis], with values closer
## than [constant EPSILON] merged into the first one.
static func _merged_edges(rects: Array[Rect2], axis: int) -> PackedFloat64Array:
	var values: PackedFloat64Array = PackedFloat64Array()
	for rect in rects:
		values.append(rect.position[axis])
		values.append(rect.end[axis])
	values.sort()

	var merged: PackedFloat64Array = PackedFloat64Array()
	for value in values:
		if merged.is_empty() or value - merged[merged.size() - 1] > EPSILON:
			merged.append(value)
	return merged


## Whether every cell of [param row] between columns [param left] and
## [param right] is covered. Rows outside the grid are never covered.
static func _row_covers(covered: PackedByteArray, columns: int, row: int, left: int, right: int) -> bool:
	if row < 0 or row * columns >= covered.size(): return false
	for column in range(left, right + 1):
		if covered[row * columns + column] == 0: return false
	return true
