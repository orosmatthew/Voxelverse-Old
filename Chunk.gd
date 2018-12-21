extends Spatial

var chunkPos = Vector3(0,0,0)
var chunkBlockDict
var blockList = []
var update = false
var noise = OpenSimplexNoise.new()
onready var game = get_tree().get_root().get_node("Game")
var threadN
var new_texture = ImageTexture.new()
var mat = SpatialMaterial.new()
var mutex
func _ready():
	mutex = Mutex.new()
	#var mat = load("res://SpatialMaterial.tres")
	mat.albedo_texture = new_texture
	#mat.set_flag(SpatialMaterial.FLAG_USE_VERTEX_LIGHTING,true)
	mat.set_flag(SpatialMaterial.FLAG_DISABLE_AMBIENT_LIGHT,true)
	mat.set_metallic(0)
	mat.set_specular(0)
	mat.set_roughness(1)
	#mat.set_feature(SpatialMaterial.FEATURE_AMBIENT_OCCLUSION,true)
	new_texture.load("res://textures/textures.png")
	new_texture.set_flags(2)
	#noise.seed = 1
	noise.octaves = 1
	noise.period = 20
	noise.persistence = 0.3


func getFace(orient,x,y,z):
	var vertices = []#PoolVector3Array()
	var UVs = []#PoolVector2Array()
	if orient == "top":
		vertices.append(Vector3(x,1+y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
		UVs.append(Vector2(0,1))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(1+x,1+y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(1,0))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,1))
	elif orient == "bottom":
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(x,y,z))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
		UVs.append(Vector2(0,1))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(x,y,z))
		UVs.append(Vector2(1,0))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,1))
	elif orient == "left":
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(1,0))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(x,1+y,z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
	elif orient == "right":
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,1+y,z))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(1,0))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,1+y,1+z))
		vertices.append(Vector3(1+x,1+y,z))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
	elif orient == "front":
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		vertices.append(Vector3(1+x,y,1+z))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,1))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		vertices.append(Vector3(1+x,1+y,1+z))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
	elif orient == "back":
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,y,z))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,1))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,1+y,z))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
	return [vertices,UVs]

func updateChunk(a):
	#update = true

	calcChunk(blockList,true)

	#thread.start(self,"renderChunk",blockList,true)
	#calcChunk(blockList,true)

func calcChunk(orderList,up=false):
	#var mutex = Mutex.new()

	var vertices = []
	var UVs = []
	var tempDict = {}
	var adjCheckList = {}

	for order in orderList:
		var x = order[0]
		var y = order[1]
		var z = order[2]
		tempDict[Vector3(x,y,z)] = {}

	var adjChunkList = {"top":false,"bottom":false,
						"front":false,"back":false,
						"right":false,"left":false}
	var adjChunkPos = {"top":Vector3(chunkPos.x,chunkPos.y+1,chunkPos.z),"bottom":Vector3(chunkPos.x,chunkPos.y-1,chunkPos.z),
						"front":Vector3(chunkPos.x,chunkPos.y,chunkPos.z+1),"back":Vector3(chunkPos.x,chunkPos.y,chunkPos.z-1),
						"right":Vector3(chunkPos.x+1,chunkPos.y,chunkPos.z),"left":Vector3(chunkPos.x-1,chunkPos.y,chunkPos.z)}
	var adjChunkCheckList = []
	
	for b in tempDict:
		var x = b.x
		var y = b.y
		var z = b.z
		var adjNameList = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adjNameList:
			if not adjNameList[n] in tempDict:
				if not game.blockMemory.existBlock(Vector3(adjNameList[n][0]+(chunkPos[0]*16),adjNameList[n][1]+(chunkPos[1]*16),adjNameList[n][2]+(chunkPos[2]*16))):
					var returnStuff = getFace(n,x,y,z)
					for i in returnStuff[0]:
						vertices.append(i)
					for i in returnStuff[1]:
						UVs.append(i)
				else:
					adjChunkList[n] = true
	mutex.lock()
	game.blockMemory.makeRegion(chunkPos)
	game.blockMemory.makeChunk(chunkPos)
	blockList = orderList

	for b in tempDict:
		game.blockMemory.setBlockData(Vector3(b[0]+(chunkPos[0]*16),b[1]+(chunkPos[1]*16),b[2]+(chunkPos[2]*16)),{})
		game.blockMemory.setBlockData(Vector3(b[0]+(chunkPos[0]*16),b[1]+(chunkPos[1]*16),b[2]+(chunkPos[2]*16)),tempDict[b])
	if up==false:
		for a in adjChunkList:
			if adjChunkList[a]==true:
				if game.blockMemory.existChunk(adjChunkPos[a]):
					#pass
					if not str(adjChunkPos[a].x)+" "+str(adjChunkPos[a].y)+" "+str(adjChunkPos[a].z) in game.updateQueue:
						game.updateQueue.append(str(adjChunkPos[a].x)+" "+str(adjChunkPos[a].y)+" "+str(adjChunkPos[a].z))
					##game.get_node("Chunks").get_node(str(adjChunkPos[a].x)+" "+str(adjChunkPos[a].y)+" "+str(adjChunkPos[a].z)).updateChunk()

	#call_deferred('renderChunk',vertices, UVs)#(vertices,UVs)
	mutex.unlock()

	renderChunk(vertices,UVs,up)
	#call_deferred('renderChunk',vertices,UVs)#renderChunk(vertices, UVs)

func renderChunk(vertices, UVs,up=false):

	var mutex = Mutex.new()
	

	var testMesh = MeshInstance.new()
	var tmpMesh = Mesh.new()


	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)

	for v in vertices.size(): 
		st.add_uv(UVs[v])
		st.add_vertex(vertices[v])
	st.generate_normals()
	#mutex.lock()
	st.commit(tmpMesh)
	testMesh.set_mesh(tmpMesh)
	testMesh.set_name("mesh")
	#mutex.unlock()
	mutex.lock()
	if up == true:
		if has_node("mesh"):
			get_node("mesh").queue_free()
	#call_deferred("add_child",testMesh)
	add_child(testMesh)
	mutex.unlock()

	#game.thread.call_deferred('wait_to_finish')
	#self.add_child(testMesh)

func generateChunk(a):
	#print("called")

	var list = []
	var n = 0
	self.global_transform[3][0] = chunkPos[0]*16
	self.global_transform[3][1] = chunkPos[1]*16 
	self.global_transform[3][2] = chunkPos[2]*16

	for i in range(16):
		for j in range(16):
			for k in range(16):
				#if rand_range(0,1)>0.8:
				n = noise.get_noise_3d(i+(chunkPos[0]*16),j+(chunkPos[1]*16),k+(chunkPos[2]*16))
				n/=2
				n+=0.5
				var thresh = pow(0.925,(j+(chunkPos[1]*16)))
				if n < thresh:
				#if n > 0.2:
					list.append([i,j,k])
	#if not thread.is_active():
		#thread.start(self,"renderChunk",list)
	#thread.start(self,"calcChunk",list)

	calcChunk(list)
	