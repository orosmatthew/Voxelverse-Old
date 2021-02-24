extends Spatial

var chunk_pos = Vector3(0,0,0)
var noise = OpenSimplexNoise.new()
var game
var chunk_mesh
var static_node
var block_dict = {}
var blocks =  {}
var texture_atlas_size = Vector2(8,8)
var mat = load("res://TextureMaterial.tres")

var chunk_helper: ChunkHelper

func _ready():
	pass
	
func update_chunk(update_blocks: Array = [], in_chunk_check: bool = false):
	
	if len(update_blocks) == 0:
		update_blocks = block_dict.keys()
		
	for block in update_blocks:
		if not block in block_dict:
			continue
		
		block_dict[block]["adjacent"] = []
		var x = block.x
		var y = block.y
		var z = block.z
		if in_chunk_check == false:
			for s in chunk_helper.ADJACENT_BLOCKS:
				if game.query_block(local_to_global(chunk_helper.ADJACENT_BLOCKS[s]+block), false) == null:
					block_dict[block]["adjacent"].append(s)
		else:
			for s in chunk_helper.ADJACENT_BLOCKS:
				if not block_dict.has((chunk_helper.ADJACENT_BLOCKS[s]+block)):
					block_dict[block]["adjacent"].append(s)

	render_chunk()
	gen_chunk_collision()
	display_chunk()
	

func local_to_global(pos):
	var global_pos = Vector3()
	global_pos.x = (chunk_pos.x * 8) + pos.x
	global_pos.y = (chunk_pos.y * 8) + pos.y
	global_pos.z = (chunk_pos.z * 8) + pos.z
	return global_pos

func display_chunk():
	
	add_child(chunk_mesh)


func render_chunk():
	if chunk_mesh!=null:
		chunk_mesh.free()
	var mesh_instance = MeshInstance.new()
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for b in block_dict:
		var block = block_dict[b]
		var vertices = []
		var uvs = []
		
		for a in block["adjacent"]:
			vertices += chunk_helper.get_cube_vertices(a)
			uvs += chunk_helper.get_cube_uvs(a, block["t"], texture_atlas_size)
			
		for i in vertices.size():
			surface_tool.add_uv(uvs[i])
			surface_tool.add_vertex(vertices[i]+b)

	surface_tool.generate_normals()
	surface_tool.set_material(mat)
	var m = surface_tool.commit()
	mesh_instance.set_mesh(m);
	mesh_instance.set_name("mesh")
	chunk_mesh = mesh_instance

func save_chunk():
	var save_string = get_save_string(block_dict)
				
	var chunk_pos_string = str(chunk_pos.x)+" "+str(chunk_pos.y)+" "+str(chunk_pos.z)

	var file = File.new()
	file.open("res://world/"+chunk_pos_string+".dat", File.WRITE)
	file.store_string(save_string)
	file.close()
	
	
func gen_chunk_collision():
	if static_node!=null:
		static_node.free()
	var collision_verts = []

	for b in block_dict:
		var vertices =  []
		for a in block_dict[b]["adjacent"]:
			vertices+=chunk_helper.get_cube_vertices(a)
		for v in vertices:
			collision_verts.append(v+b)
	if len(collision_verts)==0:
		return
	
	var static_body = StaticBody.new()
	static_body.set_name("StaticBody")
	add_child(static_body)
	static_node=static_body
	var collision_shape = CollisionShape.new()
	static_body.add_child(collision_shape)
	var concave_polygon_shape = ConcavePolygonShape.new()
	concave_polygon_shape.set_faces(collision_verts)
	
	collision_shape.set_shape(concave_polygon_shape)


func place_block(block_vect,type):
	block_dict[block_vect] = {"t":1}
	var update_blocks = [block_vect]
	for s in chunk_helper.ADJACENT_BLOCKS:
		update_blocks.append(block_vect+chunk_helper.ADJACENT_BLOCKS[s])
	update_chunk(update_blocks, true)
	save_chunk()

func remove_block(block_vect):
	block_dict.erase(block_vect)
	var update_blocks = [block_vect]
	for s in chunk_helper.ADJACENT_BLOCKS:
		update_blocks.append(block_vect+chunk_helper.ADJACENT_BLOCKS[s])
	update_chunk(update_blocks, true)
	save_chunk()


func get_save_string(d):
	var save_dict = {}
	for i in range(8):
		for j in range(8):
			for k in range(8):
				if d.has(Vector3(i,j,k)) == true:
					save_dict[Vector3(i,j,k)] = d[Vector3(i,j,k)]["t"]
				else:
					save_dict[Vector3(i,j,k)] = 0
	
	var save_string = ""
	
	for i in range(8):
		var line = ""
		for j in range(8):
			for k in range(8):
				line+=(str(save_dict[Vector3(i,j,k)])+" ")
		save_string += (line+"\n")
	
	return save_string
		

func generate_chunk(gen_seed: int, game_node: Node):
	
	chunk_helper = load("res://helpers/ChunkHelper.gd").new()
	
	game = game_node
	
	block_dict = {}
	
	var chunk_pos_string = str(chunk_pos.x)+" "+str(chunk_pos.y)+" "+str(chunk_pos.z)
	
	var file_open = File.new()
	file_open.open("res://world/"+chunk_pos_string+".dat", File.READ)
	var content = file_open.get_as_text()
	file_open.close()
	
	var lines = content.split("\n")
	var load_dict = {}
	
	for i in range(8):
		var line = lines[i]
		line = line.split(" ")
		for j in range(8):
			for k in range(8):
				load_dict[Vector3(i,j,k)] = int(line[j*8+k])
	
	for b in load_dict.keys():
		if load_dict[b] != 0:
			block_dict[b] = {"t":load_dict[b]}
			
	update_chunk([], true)
