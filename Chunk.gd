extends Spatial

var chunk_pos = Vector3(0,0,0)
var noise = OpenSimplexNoise.new()
onready var game = get_tree().get_root().get_node("Game")
var mat = SpatialMaterial.new()
var mesh_node
var block_class
var static_node
var block_dict = {}
var block_types = {0:{"top":Vector2(0,0),"bottom":Vector2(2,0),"left":Vector2(1,0),
					 "right":Vector2(1,0),"front":Vector2(1,0),"back":Vector2(1,0)},
				  1:{"top":Vector2(3,0),"bottom":Vector2(3,0),"left":Vector2(3,0),
					 "right":Vector2(3,0),"front":Vector2(3,0),"back":Vector2(3,0)},
				  2:{"top":Vector2(4,0),"bottom":Vector2(4,0),"left":Vector2(4,0),
				     "right":Vector2(4,0),"front":Vector2(4,0),"back":Vector2(4,0)},
				  3:{"top":Vector2(5,0),"bottom":Vector2(5,0),"left":Vector2(5,0),
				     "right":Vector2(5,0),"front":Vector2(5,0),"back":Vector2(5,0)},}

func _ready():
	mat = load("res://TextureMaterial.tres")
	#var new_texture = ImageTexture.new()
	#new_texture = load("res://textures/textures.png")
	#new_texture.flags = 0
	#mat.albedo_texture = new_texture
	#mat.set_flag(SpatialMaterial.FLAG_DISABLE_AMBIENT_LIGHT,true)
	#mat.set_metallic(0)
	#mat.set_specular(0)
	#mat.set_roughness(0)
	#new_texture.set_flags(2)

func get_texture_atlas_uvs(size,pos):
	#called in thread
	var offset = Vector2(pos.x/size.x,pos.y/size.y)
	var one = Vector2(offset.x+(1/size.x),offset.y+(1/size.y))
	var zero = Vector2(offset.x,offset.y)
	return [zero,one]

func get_face(orient,x,y,z,t=0):
	#called in thread
	var vertices = []
	var uvs = []
	var texture_atlas_size = Vector2(8,8)
	
	if orient == "top":
		var uv_offsets = get_texture_atlas_uvs(texture_atlas_size,block_types[t]["top"])
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
	#to be called in thread
	var vertices = []
	var uvs = []
	var temp_dict = {}

	var adj_check_list = {}

	for order in order_list:
		var x = order[0][0]
		var y = order[0][1]
		var z = order[0][2]
		var t = order[1]
		#var bc = block_class.instance()
		#get_node("Blocks").call_deferred('add_child',bc)
		#temp_dict[Vector3(x,y,z)] = bc
		#temp_dict[Vector3(x,y,z)].type = t
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
		#var t = temp_dict[b].type
		var t = temp_dict[b]["type"]
		var adj_name_list = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adj_name_list:
			if not adj_name_list[n] in temp_dict:
				var return_stuff = get_face(n,x,y,z,t)
				#temp_dict[b].vertices.append(return_stuff[0])
				#temp_dict[b].uvs.append(return_stuff[1])
				temp_dict[b]["vertices"].append(return_stuff[0])
				temp_dict[b]["uvs"].append(return_stuff[1])
	

	for b in temp_dict:
		block_dict[Vector3(b[0],b[1],b[2])] = temp_dict[b]



func render_chunk(in_thread=false):
	#called in main thread
	self.global_transform[3][0] = chunk_pos[0]*16
	self.global_transform[3][1] = chunk_pos[1]*16 
	self.global_transform[3][2] = chunk_pos[2]*16
	

	var vertices = []
	var uvs = []
	for b in block_dict:
		#for v in block_dict[b].vertices:
		for v in block_dict[b]["vertices"]:
			for v1 in v:
				vertices.append(v1)
		for u in block_dict[b].uvs:
		#for u in block_dict[b]["uvs"]:
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
	
	
	
func gen_chunk_collision():
	#called in main thread
	var collision_verts = []

	for b in block_dict:
		#for v in block_dict[b].collision_vertices:
		for v in block_dict[b]["collision_vertices"]:
			for v1 in v:
				collision_verts.append(v1)

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
	#called on main thread

	if block_vect in block_dict:
		return
	block_dict[block_vect] = {"type":type}
	
	var x = block_vect.x
	var y = block_vect.y
	var z = block_vect.z
	var adj_name_list = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}
	
	var order_list = [[block_vect,type]]
	for a in adj_name_list:
		if adj_name_list[a] in block_dict:
			order_list.append([adj_name_list[a],block_dict[adj_name_list[a]]["type"]])
		
	
	var vertices = []
	var uvs = []
	var temp_dict = {}

	var adjCheckList = {}

	for order in order_list:
		x = order[0][0]
		y = order[0][1]
		z = order[0][2]
		var t = order[1]
		temp_dict[Vector3(x,y,z)] = {"type":t}

	var adj_chunk_list = {"top":false,"bottom":false,
						"front":false,"back":false,
						"right":false,"left":false}
	var adj_chunk_pos = {"top":Vector3(chunk_pos.x,chunk_pos.y+1,chunk_pos.z),"bottom":Vector3(chunk_pos.x,chunk_pos.y-1,chunk_pos.z),
						"front":Vector3(chunk_pos.x,chunk_pos.y,chunk_pos.z+1),"back":Vector3(chunk_pos.x,chunk_pos.y,chunk_pos.z-1),
						"right":Vector3(chunk_pos.x+1,chunk_pos.y,chunk_pos.z),"left":Vector3(chunk_pos.x-1,chunk_pos.y,chunk_pos.z)}

	var adj_chunk_checklist = []
	
	for b in temp_dict:
		temp_dict[b]["vertices"] = []
		temp_dict[b]["uvs"] = []
		x = b.x
		y = b.y
		z = b.z
		var t = temp_dict[b]["type"]
		adj_name_list = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adj_name_list:
			if not adj_name_list[n] in block_dict:
				var return_stuff = get_face(n,x,y,z,t)
				temp_dict[b]['vertices'].append(return_stuff[0])
				temp_dict[b]['uvs'].append(return_stuff[1])
	
	for b in temp_dict:
		block_dict[Vector3(b[0],b[1],b[2])] = temp_dict[b]
	if mesh_node!=null:
		mesh_node.queue_free()

	render_chunk()


	for b in block_dict:
		block_dict[b].collision_vertices = block_dict[b].vertices

	if static_node!=null:
		static_node.queue_free()
	gen_chunk_collision()

func remove_block(block_vect):
	#called in main thread

	if not block_vect in block_dict:
		return
	block_dict.erase(block_vect)
	var x = block_vect.x
	var y = block_vect.y
	var z = block_vect.z
	var adj_name_list = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}
	
	var order_list = []
	for a in adj_name_list:
		if adj_name_list[a] in block_dict:
			order_list.append([adj_name_list[a],block_dict[adj_name_list[a]]["type"]])
		
	
	var vertices = []
	var uvs = []
	var temp_dict = {}

	var adj_check_list = {}

	for order in order_list:
		x = order[0][0]
		y = order[0][1]
		z = order[0][2]
		var t = order[1]
		temp_dict[Vector3(x,y,z)] = {"type":t}

	var adj_chunk_list = {"top":false,"bottom":false,
						"front":false,"back":false,
						"right":false,"left":false}
	var adj_chunk_pos = {"top":Vector3(chunk_pos.x,chunk_pos.y+1,chunk_pos.z),"bottom":Vector3(chunk_pos.x,chunk_pos.y-1,chunk_pos.z),
						"front":Vector3(chunk_pos.x,chunk_pos.y,chunk_pos.z+1),"back":Vector3(chunk_pos.x,chunk_pos.y,chunk_pos.z-1),
						"right":Vector3(chunk_pos.x+1,chunk_pos.y,chunk_pos.z),"left":Vector3(chunk_pos.x-1,chunk_pos.y,chunk_pos.z)}

	var adj_chunk_checklist = []
	
	for b in temp_dict:
		temp_dict[b]["vertices"] = []
		temp_dict[b]["uvs"] = []
		x = b.x
		y = b.y
		z = b.z
		var t = temp_dict[b]["type"]
		adj_name_list = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adj_name_list:
			if not adj_name_list[n] in block_dict:
				var return_stuff = get_face(n,x,y,z,t)
				temp_dict[b]['vertices'].append(return_stuff[0])
				temp_dict[b]['uvs'].append(return_stuff[1])
	
	for b in temp_dict:
		block_dict[Vector3(b[0],b[1],b[2])] = temp_dict[b]
	if mesh_node!=null:
		mesh_node.queue_free()

	render_chunk()


	for b in block_dict:
		block_dict[b].collision_vertices = block_dict[b].vertices

	if static_node!=null:
		static_node.queue_free()
	gen_chunk_collision()

func generate_chunk(a):
	#to be called in thread
	
	var list = []
	var n = 0

	noise.seed = game.get("generation_seed")
	noise.octaves = 3#3
	noise.period = 25
	noise.persistence = 0.3
	for i in range(16):
		for j in range(16):
			for k in range(16):
				n = noise.get_noise_3d((i+(chunk_pos[0]*16)),(j+(chunk_pos[1]*16)),(k+(chunk_pos[2]*16)))
				n/=2
				n+=0.5
				var thresh = pow(0.95,(j+(chunk_pos[1]*16)))
				if n < thresh:
					if (j+(chunk_pos[1]*16))<14:
						list.append([[i,j,k],2])
					else:
						list.append([[i,j,k],0])
				elif (j+(chunk_pos[1]*16))<12:
					list.append([[i,j,k],3])

	calc_chunk(list)

	#for b in block_dict:
		#block_dict[b].set_collision_vertices()
	for b in block_dict:
		block_dict[b]["collision_vertices"] = block_dict[b]["vertices"]
	
	render_chunk(true)
	#gen_chunk_collision(true)
	#call_deferred('render_chunk')
	call_deferred('gen_chunk_collision')
	
	a.call_deferred( 'wait_to_finish' )

	