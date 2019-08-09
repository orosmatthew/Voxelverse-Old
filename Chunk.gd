extends Spatial

var chunk_pos = Vector3(0,0,0)
var noise = OpenSimplexNoise.new()
onready var game = get_tree().get_root().get_node("Game")
var mat = SpatialMaterial.new()
var mesh_node
var chunk_mesh
var block_class
var static_node
var temp_dict_2 = {}
var block_dict = {}
var blocks =  {}
var count = 0

var adjacent_blocks = {
	Side.front  : Vector3(0,0,1),
	Side.back   : Vector3(0,0,-1),
	Side.right  : Vector3(1,0,0),
	Side.left   : Vector3(-1,0,0),
	Side.top    : Vector3(0,1,0),
	Side.bottom : Vector3(0,-1,0),
	}

var block_types = {0:{"top":Vector2(0,0),"bottom":Vector2(2,0),"left":Vector2(1,0),
					 "right":Vector2(1,0),"front":Vector2(1,0),"back":Vector2(1,0)},
				  1:{"top":Vector2(3,0),"bottom":Vector2(3,0),"left":Vector2(3,0),
					 "right":Vector2(3,0),"front":Vector2(3,0),"back":Vector2(3,0)},
				  2:{"top":Vector2(4,0),"bottom":Vector2(4,0),"left":Vector2(4,0),
				     "right":Vector2(4,0),"front":Vector2(4,0),"back":Vector2(4,0)},
				  3:{"top":Vector2(5,0),"bottom":Vector2(5,0),"left":Vector2(5,0),
				     "right":Vector2(5,0),"front":Vector2(5,0),"back":Vector2(5,0)},}


enum Side {
	front,
	back,
	right,
	left,
	top,
	bottom
}

func _ready():
	mat = load("res://TextureMaterial.tres")

func get_texture_atlas_uvs(size,pos):
	var offset = Vector2(pos.x/size.x,pos.y/size.y)
	var one = Vector2(offset.x+(1/size.x),offset.y+(1/size.y))
	var zero = Vector2(offset.x,offset.y)
	return [zero,one]



func get_cube_vertices(orient):
	
	var vertice_array = []
	
	if orient==Side.front:
		vertice_array = [
			Vector3(0,1,1),
			Vector3(1,0,1),
			Vector3(0,0,1),
			
			Vector3(1,1,1),
			Vector3(1,0,1),
			Vector3(0,1,1),
		]
	elif orient==Side.back:
		vertice_array = [
			Vector3(1,1,0),
			Vector3(0,1,0),
			Vector3(0,0,0),
			
			Vector3(1,1,0),
			Vector3(0,0,0),
			Vector3(1,0,0),
		]
	elif orient==Side.right:
		vertice_array = [
			Vector3(1,1,1),
			Vector3(1,1,0),
			Vector3(1,0,0),
			
			Vector3(1,0,0),
			Vector3(1,0,1),
			Vector3(1,1,1),
		]
	elif orient==Side.left:
		vertice_array = [
			Vector3(0,0,0),
			Vector3(0,1,1),
			Vector3(0,0,1),
			
			Vector3(0,0,0),
			Vector3(0,1,0),
			Vector3(0,1,1),
		]
	elif orient==Side.top:
		vertice_array = [
			Vector3(1,1,1),
			Vector3(0,1,0),
			Vector3(1,1,0),
			
			Vector3(1,1,1),
			Vector3(0,1,1),
			Vector3(0,1,0),
		]
	elif orient==Side.bottom:
		vertice_array = [
			Vector3(1,0,1),
			Vector3(1,0,0),
			Vector3(0,0,0),
			
			Vector3(1,0,1),
			Vector3(0,0,0),
			Vector3(0,0,1),
		]
	return vertice_array
		
	
func update_chunk(update_blocks=null):
	
	if update_blocks==null:
		update_blocks = block_dict.keys()
	for block in update_blocks:
		if not block in block_dict:
			continue
		block_dict[block]["v"] = []
		
		var x = block.x
		var y = block.y
		var z = block.z
		for s in adjacent_blocks:
			if not block_dict.has((adjacent_blocks[s]+block)):
				var vertices = get_cube_vertices(s)
		
				for v in vertices:
		
					var v2 = v
					v2.x+=x
					v2.y+=y
					v2.z+=z
					block_dict[block]["v"].append(v2)

	render_chunk()
	gen_chunk_collision()
	display_chunk()


func display_chunk():
	
	add_child(chunk_mesh)





func get_face(orient,x,y,z,t=0):
	var vertices = []
	var uvs = []
	var texture_atlas_size = Vector2(8,8)
	
	if orient == "top":
		var uv_offsets = get_texture_atlas_uvs(texture_atlas_size,block_types[t]["top"])
		print(uv_offsets)
		vertices.append(Vector3(x,1+y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,1+y,1+z))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(1+x,1+y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
	elif orient == "bottom":
		var uv_offsets = get_texture_atlas_uvs(texture_atlas_size,block_types[t]["bottom"])
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(x,y,z))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(x,y,z))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
	elif orient == "left":
		var uv_offsets = get_texture_atlas_uvs(texture_atlas_size,block_types[t]["left"])
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(x,1+y,1+z))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(x,1+y,z))
		vertices.append(Vector3(x,1+y,1+z))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
	elif orient == "right":
		var uv_offsets = get_texture_atlas_uvs(texture_atlas_size,block_types[t]["right"])
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,1+y,z))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,1+y,1+z))
		vertices.append(Vector3(1+x,1+y,z))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
	elif orient == "front":
		var uv_offsets = get_texture_atlas_uvs(texture_atlas_size,block_types[t]["front"])
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		vertices.append(Vector3(1+x,y,1+z))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		vertices.append(Vector3(1+x,1+y,1+z))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
	elif orient == "back":
		var uv_offsets = get_texture_atlas_uvs(texture_atlas_size,block_types[t]["back"])
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,y,z))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,1+y,z))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[1].y))
		uvs.append(Vector2(uv_offsets[0].x,uv_offsets[0].y))
		uvs.append(Vector2(uv_offsets[1].x,uv_offsets[0].y))
	return [vertices,uvs]

func calc_chunk(order_list):

	var vertices = []
	var uvs = []
	var temp_dict = {}

	var adj_check_list = {}

	for order in order_list:
		var x = order[0][0]
		var y = order[0][1]
		var z = order[0][2]
		var t = order[1]
		temp_dict[Vector3(x,y,z)] = {"type":t,"vertices":[],"uvs":[]}
		
	var adj_chunk_list = {"top":false,"bottom":false,
						"front":false,"back":false,
						"right":false,"left":false}
	var adj_chunk_pos = {"top":Vector3(chunk_pos.x,chunk_pos.y+1,chunk_pos.z),"bottom":Vector3(chunk_pos.x,chunk_pos.y-1,chunk_pos.z),
						"front":Vector3(chunk_pos.x,chunk_pos.y,chunk_pos.z+1),"back":Vector3(chunk_pos.x,chunk_pos.y,chunk_pos.z-1),
						"right":Vector3(chunk_pos.x+1,chunk_pos.y,chunk_pos.z),"left":Vector3(chunk_pos.x-1,chunk_pos.y,chunk_pos.z)}

	var adj_chunk_checklist = []
	
	
	
	
	for b in temp_dict:
		var x = b.x
		var y = b.y
		var z = b.z
		var t = temp_dict[b]["type"]
		var adj_name_list = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adj_name_list:
			if not adj_name_list[n] in temp_dict:
				var return_stuff = get_face(n,x,y,z,t)
				temp_dict[b]["vertices"].append(return_stuff[0])
				temp_dict[b]["uvs"].append(return_stuff[1])
	

	for b in temp_dict:
		block_dict[Vector3(b[0],b[1],b[2])] = temp_dict[b]


func render_chunk():
	if chunk_mesh!=null:
		chunk_mesh.free()
	var mesh_instance = MeshInstance.new()
	var surface_tool = SurfaceTool.new()
	
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	for b in block_dict:
		var block = block_dict[b]
		for v in block["v"]:
			surface_tool.add_vertex(v)
	surface_tool.generate_normals()
	surface_tool.set_material(mat)
	var m = surface_tool.commit()
	mesh_instance.set_mesh(m);
	mesh_instance.set_name("mesh")
	chunk_mesh = mesh_instance


"""
func render_chunk(in_thread=false):

	
	
	mat = load("res://TextureMaterial.tres")
	var vertices = []
	var uvs = []
	for b in block_dict:
		for v in block_dict[b]["vertices"]:
			for v1 in v:
				vertices.append(v1)
		for u in block_dict[b].uvs:
			for u1 in u:
				uvs.append(u1)
	if len(vertices)==0 or len(uvs)==0:
		return

	var mesh_instance = MeshInstance.new()
	var mesh = Mesh.new()


	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	surface_tool.set_material(mat)
	

	for v in vertices.size(): 
		surface_tool.add_color(Color(1, 1, 1))
		surface_tool.add_uv(uvs[v])
		surface_tool.add_vertex(vertices[v])
	surface_tool.generate_normals()
	
	surface_tool.commit(mesh)
	mesh_instance.set_mesh(mesh)
	mesh_instance.set_name("mesh")
	mesh_node=mesh_instance

	if in_thread==true:
		call_deferred('add_child',mesh_instance)
	else:
		add_child(mesh_instance)
	
"""
	
func gen_chunk_collision():
	if static_node!=null:
		static_node.free()
	var collision_verts = []

	for b in block_dict:
		for v in block_dict[b]["v"]:
			collision_verts.append(v)

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
	block_dict[block_vect] = {}
	var update_blocks = [block_vect]
	for s in adjacent_blocks:
		update_blocks.append(block_vect+adjacent_blocks[s])
	update_chunk(update_blocks)

func remove_block(block_vect):
	block_dict.erase(block_vect)
	var update_blocks = [block_vect]
	for s in adjacent_blocks:
		update_blocks.append(block_vect+adjacent_blocks[s])
	update_chunk(update_blocks)

func generate_chunk(a,gen_seed):

	var list = []
	var n = 0

	noise.seed = gen_seed
	noise.octaves = 3
	noise.period = 25
	noise.persistence = 0.3

	for i in range(16):
		for j in range(16):
			for k in range(16):
				n = noise.get_noise_3d((i+(chunk_pos[0]*16)),(j+(chunk_pos[1]*16)),(k+(chunk_pos[2]*16)))
				n/=2
				n+=0.5
				#0.955
				var thresh = pow(0.955,(j+(chunk_pos[1]*16)))
				if n < thresh:
					if (j+(chunk_pos[1]*16))<14:
						block_dict[Vector3(i,j,k)] = {}
						#list.append([[i,j,k],2])
					else:
						block_dict[Vector3(i,j,k)] = {}
						#list.append([[i,j,k],0])
				elif (j+(chunk_pos[1]*16))<12:
					block_dict[Vector3(i,j,k)] = {}
					#list.append([[i,j,k],3])


	update_chunk()

	#for b in block_dict:
		#block_dict[b]["collision_vertices"] = block_dict[b]["vertices"]
	
	#render_chunk()
	#gen_chunk_collision()
	

	