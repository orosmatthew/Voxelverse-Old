extends Spatial

var chunkPos = Vector3(0,0,0)
var chunkBlockDict
var blockList = []
var thread = Thread.new()
var update = false

onready var game = get_tree().get_root().get_node("Game")
func _ready():
	pass

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

func updateChunk():
	#update = true
	if has_node("mesh"):
		get_node("mesh").free()
	calcChunk(blockList,true)

	#thread.start(self,"renderChunk",blockList,true)
	#calcChunk(blockList,true)

func calcChunk(orderList,up=false):
	var mutex = Mutex.new()

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
	for b in tempDict:
		var x = b.x
		var y = b.y
		var z = b.z
		
		var adjNameList = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}
		for n in adjNameList:
			if not adjNameList[n] in tempDict:
				if not game.blockMemory.existBlock(Vector3(adjNameList[n][0]+(chunkPos[0]*4),adjNameList[n][1]+(chunkPos[1]*8),adjNameList[n][2]+(chunkPos[2]*4))):
					vertices+=getFace(n,x,y,z)[0]
					UVs+=getFace(n,x,y,z)[1]
				else:
					adjChunkList[n] = true
	

	game.blockMemory.makeRegion(chunkPos)
	game.blockMemory.makeChunk(chunkPos)
	blockList = orderList

	for b in tempDict:
		game.blockMemory.setBlockData(Vector3(b[0]+(chunkPos[0]*4),b[1]+(chunkPos[1]*8),b[2]+(chunkPos[2]*4)),{})
		game.blockMemory.setBlockData(Vector3(b[0]+(chunkPos[0]*4),b[1]+(chunkPos[1]*8),b[2]+(chunkPos[2]*4)),tempDict[b])
	if up==false:
		for a in adjChunkList:
			if adjChunkList[a]==true:
				if game.blockMemory.existChunk(adjChunkPos[a]):
					game.updateQueue.append(str(adjChunkPos[a].x)+" "+str(adjChunkPos[a].y)+" "+str(adjChunkPos[a].z))
					#game.get_node("Chunks").get_node(str(adjChunkPos[a].x)+" "+str(adjChunkPos[a].y)+" "+str(adjChunkPos[a].z)).updateChunk()
	
	#call_deferred('renderChunk',vertices, UVs)#(vertices,UVs)
	renderChunk(vertices,UVs)
	#call_deferred('renderChunk',vertices,UVs)#renderChunk(vertices, UVs)

func renderChunk(vertices, UVs):
	var mutex = Mutex.new()
	
	var new_texture = ImageTexture.new()
	new_texture.load("res://texture.png")
	new_texture.set_flags(2)

	var testMesh = MeshInstance.new()
	var tmpMesh = Mesh.new()

	var mat = SpatialMaterial.new()
	
	mat.albedo_texture = new_texture

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)

	for v in vertices.size(): 
		st.add_uv(UVs[v])
		st.add_vertex(vertices[v])

	st.commit(tmpMesh)
	testMesh.set_mesh(tmpMesh)
	testMesh.set_name("mesh")
	call_deferred("add_child",testMesh)
	#self.add_child(testMesh)

func _process(delta):
	pass
	"""
	if update == true:
		if not thread.is_active():
			if has_node("mesh"):
				get_node("mesh").free()
			thread.start(self,"calcChunk",blockList,true)
			update = false
	"""
func generateChunk():
	var list = []
	self.global_transform[3][0] = chunkPos[0]*4
	self.global_transform[3][1] = chunkPos[1]*8
	self.global_transform[3][2] = chunkPos[2]*4
	for i in range(4):
		for j in range(8):
			for k in range(4):
				if rand_range(0,1) > 0.1:
					list.append([i,j,k])
	#if not thread.is_active():
		#thread.start(self,"renderChunk",list)
	#thread.start(self,"calcChunk",list)
	calcChunk(list)
	