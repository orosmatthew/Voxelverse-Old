extends Reference

class_name ChunkHelper

enum Sides {
	FRONT,
	BACK,
	RIGHT,
	LEFT,
	TOP,
	BOTTOM
}

const ADJACENT_BLOCKS = {
	Sides.FRONT  : Vector3(0,0,1),
	Sides.BACK   : Vector3(0,0,-1),
	Sides.RIGHT  : Vector3(1,0,0),
	Sides.LEFT   : Vector3(-1,0,0),
	Sides.TOP    : Vector3(0,1,0),
	Sides.BOTTOM : Vector3(0,-1,0)
	}
	
const BLOCK_TYPES = {1:{Sides.TOP:Vector2(0,0),Sides.BOTTOM:Vector2(2,0),Sides.LEFT:Vector2(1,0),
				Sides.RIGHT:Vector2(1,0),Sides.FRONT:Vector2(1,0),Sides.BACK:Vector2(1,0)},
				2:{Sides.TOP:Vector2(3,0),Sides.BOTTOM:Vector2(3,0),Sides.LEFT:Vector2(3,0),
				Sides.RIGHT:Vector2(3,0),Sides.FRONT:Vector2(3,0),Sides.BACK:Vector2(3,0)},
				3:{Sides.TOP:Vector2(4,0),Sides.BOTTOM:Vector2(4,0),Sides.LEFT:Vector2(4,0),
				Sides.RIGHT:Vector2(4,0),Sides.FRONT:Vector2(4,0),Sides.BACK:Vector2(4,0)},
				4:{Sides.TOP:Vector2(5,0),Sides.BOTTOM:Vector2(5,0),Sides.LEFT:Vector2(5,0),
				Sides.RIGHT:Vector2(5,0),Sides.FRONT:Vector2(5,0),Sides.BACK:Vector2(5,0)},}

#takes in atlas position and returns coordinates for the uv positions on the atlas
static func _get_atlas_uv_coordinates(atlas_size: Vector2, atlas_position: Vector2):
	var offset = Vector2(atlas_position.x / atlas_size.x, atlas_position.y / atlas_size.y)
	var bottom_right = Vector2(offset.x + (1 / atlas_size.x), offset.y + (1 / atlas_size.y))
	var top_left = Vector2(offset.x, offset.y)
	var top_right = Vector2(offset.x + (1 / atlas_size.x), offset.y)
	var bottom_left = Vector2(offset.x, offset.y + (1 / atlas_size.y))
	return [top_left, top_right, bottom_left, bottom_right]

#takes in block type and side and returns uv coordinates for that side
static func get_cube_uvs(orient: int, type: int, texture_atlas_size: Vector2):
	var uv_array = []
	
	if orient == Sides.FRONT:
		var coordinates = _get_atlas_uv_coordinates(texture_atlas_size, BLOCK_TYPES[type][Sides.FRONT])
		uv_array = [
			coordinates[0],
			coordinates[3],
			coordinates[2],
			
			coordinates[1],
			coordinates[3],
			coordinates[0]
		]
	if orient == Sides.BACK:
		var coordinates = _get_atlas_uv_coordinates(texture_atlas_size, BLOCK_TYPES[type][Sides.BACK])
		uv_array = [
			coordinates[0],
			coordinates[1],
			coordinates[3],
			
			coordinates[0],
			coordinates[3],
			coordinates[2]
		]
	if orient == Sides.RIGHT:
		var coordinates = _get_atlas_uv_coordinates(texture_atlas_size, BLOCK_TYPES[type][Sides.RIGHT])
		uv_array = [
			coordinates[0],
			coordinates[1],
			coordinates[3],
			
			coordinates[3],
			coordinates[2],
			coordinates[0]
		]
	if orient == Sides.LEFT:
		var coordinates = _get_atlas_uv_coordinates(texture_atlas_size, BLOCK_TYPES[type][Sides.LEFT])
		uv_array = [
			coordinates[2],
			coordinates[1],
			coordinates[3],
			
			coordinates[2],
			coordinates[0],
			coordinates[1]
		]
	if orient == Sides.TOP:
		var coordinates = _get_atlas_uv_coordinates(texture_atlas_size, BLOCK_TYPES[type][Sides.TOP])
		uv_array = [
			coordinates[3],
			coordinates[0],
			coordinates[1],
			
			coordinates[3],
			coordinates[2],
			coordinates[0]
		]
	if orient == Sides.BOTTOM:
		var coordinates = _get_atlas_uv_coordinates(texture_atlas_size, BLOCK_TYPES[type][Sides.BOTTOM])
		uv_array = [
			coordinates[2],
			coordinates[0],
			coordinates[1],
			
			coordinates[2],
			coordinates[1],
			coordinates[3]
		]
		
	return uv_array
		
#takes in cube orientation and returns vertices to build that side
static func get_cube_vertices(orient: int):
	
	var vertice_array = []
	
	if orient == Sides.FRONT:
		vertice_array = [
			Vector3(0,1,1),
			Vector3(1,0,1),
			Vector3(0,0,1),
			
			Vector3(1,1,1),
			Vector3(1,0,1),
			Vector3(0,1,1),
		]
	elif orient == Sides.BACK:
		vertice_array = [
			Vector3(1,1,0),
			Vector3(0,1,0),
			Vector3(0,0,0),
			
			Vector3(1,1,0),
			Vector3(0,0,0),
			Vector3(1,0,0),
		]
	elif orient == Sides.RIGHT:
		vertice_array = [
			Vector3(1,1,1),
			Vector3(1,1,0),
			Vector3(1,0,0),
			
			Vector3(1,0,0),
			Vector3(1,0,1),
			Vector3(1,1,1),
		]
	elif orient == Sides.LEFT:
		vertice_array = [
			Vector3(0,0,0),
			Vector3(0,1,1),
			Vector3(0,0,1),
			
			Vector3(0,0,0),
			Vector3(0,1,0),
			Vector3(0,1,1),
		]
	elif orient == Sides.TOP:
		vertice_array = [
			Vector3(1,1,1),
			Vector3(0,1,0),
			Vector3(1,1,0),
			
			Vector3(1,1,1),
			Vector3(0,1,1),
			Vector3(0,1,0),
		]
	elif orient == Sides.BOTTOM:
		vertice_array = [
			Vector3(1,0,1),
			Vector3(1,0,0),
			Vector3(0,0,0),
			
			Vector3(1,0,1),
			Vector3(0,0,0),
			Vector3(0,0,1),
		]
	return vertice_array

