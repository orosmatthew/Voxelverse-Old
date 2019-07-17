extends Spatial

var chunkPos = Vector3(0,0,0)
var noise = OpenSimplexNoise.new()
onready var game = get_tree().get_root().get_node("Game")
var mat = SpatialMaterial.new()
onready var chunkMutex = Mutex.new()
var meshNode
var staticNode
var blockDict = {}
var blockTypes = {0:{"top":Vector2(0,0),"bottom":Vector2(2,0),"left":Vector2(1,0),
					 "right":Vector2(1,0),"front":Vector2(1,0),"back":Vector2(1,0)},
				  1:{"top":Vector2(3,0),"bottom":Vector2(3,0),"left":Vector2(3,0),
					 "right":Vector2(3,0),"front":Vector2(3,0),"back":Vector2(3,0)},
				  2:{"top":Vector2(4,0),"bottom":Vector2(4,0),"left":Vector2(4,0),
				     "right":Vector2(4,0),"front":Vector2(4,0),"back":Vector2(4,0)},}

func _ready():
	var new_texture = ImageTexture.new()
	new_texture = load("res://textures/textures.png")
	new_texture.flags = 0
	mat.albedo_texture = new_texture
	mat.set_flag(SpatialMaterial.FLAG_DISABLE_AMBIENT_LIGHT,true)
	mat.set_metallic(0)
	mat.set_specular(0)
	mat.set_roughness(1)
	new_texture.set_flags(2)

func getTextureAtlasUVs(size,pos):
	#called in thread
	var offset = Vector2(pos.x/size.x,pos.y/size.y)
	var one = Vector2(offset.x+(1/size.x),offset.y+(1/size.y))
	var zero = Vector2(offset.x,offset.y)
	return [zero,one]

func getFace(orient,x,y,z,t=0):
	#called in thread
	var vertices = []
	var UVs = []
	var textureAtlasSize = Vector2(8,8)
	
	if orient == "top":
		var UVOffsets = getTextureAtlasUVs(textureAtlasSize,blockTypes[t]["top"])
		vertices.append(Vector3(x,1+y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(1+x,1+y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
	elif orient == "bottom":
		var UVOffsets = getTextureAtlasUVs(textureAtlasSize,blockTypes[t]["bottom"])
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(x,y,z))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(x,y,z))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
	elif orient == "left":
		var UVOffsets = getTextureAtlasUVs(textureAtlasSize,blockTypes[t]["left"])
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(x,1+y,z))
		vertices.append(Vector3(x,1+y,1+z))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
	elif orient == "right":
		var UVOffsets = getTextureAtlasUVs(textureAtlasSize,blockTypes[t]["right"])
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,1+y,z))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(1+x,1+y,1+z))
		vertices.append(Vector3(1+x,1+y,z))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
	elif orient == "front":
		var UVOffsets = getTextureAtlasUVs(textureAtlasSize,blockTypes[t]["front"])
		vertices.append(Vector3(x,y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		vertices.append(Vector3(1+x,y,1+z))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		vertices.append(Vector3(1+x,y,1+z))
		vertices.append(Vector3(x,1+y,1+z))
		vertices.append(Vector3(1+x,1+y,1+z))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
	elif orient == "back":
		var UVOffsets = getTextureAtlasUVs(textureAtlasSize,blockTypes[t]["back"])
		vertices.append(Vector3(1+x,y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,y,z))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		vertices.append(Vector3(x,y,z))
		vertices.append(Vector3(1+x,1+y,z))
		vertices.append(Vector3(x,1+y,z))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[1].y))
		UVs.append(Vector2(UVOffsets[0].x,UVOffsets[0].y))
		UVs.append(Vector2(UVOffsets[1].x,UVOffsets[0].y))
	return [vertices,UVs]

func calcChunk(orderList):
	#to be called in thread
	var vertices = []
	var UVs = []
	var tempDict = {}

	var adjCheckList = {}

	for order in orderList:
		var x = order[0][0]
		var y = order[0][1]
		var z = order[0][2]
		var t = order[1]
		tempDict[Vector3(x,y,z)] = load("res://Blocks/Block.gd").new()

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
		var t = tempDict[b].type
		var adjNameList = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adjNameList:
			if not adjNameList[n] in tempDict:
				var returnStuff = getFace(n,x,y,z,t)
				tempDict[b].vertices.append(returnStuff[0])
				tempDict[b].UVs.append(returnStuff[1])
	
	chunkMutex.lock()
	for b in tempDict:
		blockDict[Vector3(b[0],b[1],b[2])] = tempDict[b]
	chunkMutex.unlock()


func renderChunk():
	#called in main thread
	self.global_transform[3][0] = chunkPos[0]*16
	self.global_transform[3][1] = chunkPos[1]*16 
	self.global_transform[3][2] = chunkPos[2]*16
	
	chunkMutex.lock()
	var vertices = []
	var UVs = []
	for b in blockDict:
		for v in blockDict[b].vertices:
			for v1 in v:
				vertices.append(v1)
		for u in blockDict[b].UVs:
			for u1 in u:
				UVs.append(u1)
	if len(vertices)==0 or len(UVs)==0:
		return
	chunkMutex.unlock()
	var testMesh = MeshInstance.new()
	var tmpMesh = Mesh.new()


	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	st.set_material(mat)
	
	
	for v in vertices.size(): 
		st.add_uv(UVs[v])
		st.add_vertex(vertices[v])
	st.generate_normals()
	
	st.commit(tmpMesh)
	testMesh.set_mesh(tmpMesh)
	testMesh.set_name("mesh")

	
	add_child(testMesh)
	meshNode=testMesh

	
	
func genChunkCollision():
	#called in main thread
	var collVerts = []
	chunkMutex.lock()
	for b in blockDict:
		for v in blockDict[b].collisionVertices:
			for v1 in v:
				collVerts.append(v1)
	chunkMutex.unlock()
	if len(collVerts)==0:
		return
	
	var sB = StaticBody.new()
	sB.set_name("StaticBody")
	add_child(sB)
	staticNode=sB
	var cS = CollisionShape.new()
	sB.add_child(cS)
	var cPS = ConcavePolygonShape.new()
	cPS.set_faces(collVerts)

	cS.set_shape(cPS)


func placeBlock(pVect,type):
	#called on main thread
	chunkMutex.lock()
	if pVect in blockDict:
		return
	blockDict[pVect] = {"type":type}
	
	var x = pVect.x
	var y = pVect.y
	var z = pVect.z
	var adjNameList = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}
	
	var orderList = [[pVect,type]]
	for a in adjNameList:
		if adjNameList[a] in blockDict:
			orderList.append([adjNameList[a],blockDict[adjNameList[a]]["type"]])
		
	
	var vertices = []
	var UVs = []
	var tempDict = {}

	var adjCheckList = {}

	for order in orderList:
		x = order[0][0]
		y = order[0][1]
		z = order[0][2]
		var t = order[1]
		tempDict[Vector3(x,y,z)] = {"type":t}

	var adjChunkList = {"top":false,"bottom":false,
						"front":false,"back":false,
						"right":false,"left":false}
	var adjChunkPos = {"top":Vector3(chunkPos.x,chunkPos.y+1,chunkPos.z),"bottom":Vector3(chunkPos.x,chunkPos.y-1,chunkPos.z),
						"front":Vector3(chunkPos.x,chunkPos.y,chunkPos.z+1),"back":Vector3(chunkPos.x,chunkPos.y,chunkPos.z-1),
						"right":Vector3(chunkPos.x+1,chunkPos.y,chunkPos.z),"left":Vector3(chunkPos.x-1,chunkPos.y,chunkPos.z)}

	var adjChunkCheckList = []
	
	for b in tempDict:
		tempDict[b]["vertices"] = []
		tempDict[b]["UVs"] = []
		x = b.x
		y = b.y
		z = b.z
		var t = tempDict[b]["type"]
		adjNameList = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adjNameList:
			if not adjNameList[n] in blockDict:
				var returnStuff = getFace(n,x,y,z,t)
				tempDict[b]['vertices'].append(returnStuff[0])
				tempDict[b]['UVs'].append(returnStuff[1])
	
	for b in tempDict:
		blockDict[Vector3(b[0],b[1],b[2])] = tempDict[b]
	if meshNode!=null:
		meshNode.queue_free()
	chunkMutex.unlock()
	renderChunk()

	chunkMutex.lock()
	for b in blockDict:
		blockDict[b].collisionVertices = blockDict[b].vertices
	chunkMutex.unlock()
	if staticNode!=null:
		staticNode.queue_free()
	genChunkCollision()

func removeBlock(pVect):
	#called in main thread
	chunkMutex.lock()
	if not pVect in blockDict:
		return
	blockDict.erase(pVect)
	var x = pVect.x
	var y = pVect.y
	var z = pVect.z
	var adjNameList = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}
	
	var orderList = []
	for a in adjNameList:
		if adjNameList[a] in blockDict:
			orderList.append([adjNameList[a],blockDict[adjNameList[a]]["type"]])
		
	
	var vertices = []
	var UVs = []
	var tempDict = {}

	var adjCheckList = {}

	for order in orderList:
		x = order[0][0]
		y = order[0][1]
		z = order[0][2]
		var t = order[1]
		tempDict[Vector3(x,y,z)] = {"type":t}

	var adjChunkList = {"top":false,"bottom":false,
						"front":false,"back":false,
						"right":false,"left":false}
	var adjChunkPos = {"top":Vector3(chunkPos.x,chunkPos.y+1,chunkPos.z),"bottom":Vector3(chunkPos.x,chunkPos.y-1,chunkPos.z),
						"front":Vector3(chunkPos.x,chunkPos.y,chunkPos.z+1),"back":Vector3(chunkPos.x,chunkPos.y,chunkPos.z-1),
						"right":Vector3(chunkPos.x+1,chunkPos.y,chunkPos.z),"left":Vector3(chunkPos.x-1,chunkPos.y,chunkPos.z)}

	var adjChunkCheckList = []
	
	for b in tempDict:
		tempDict[b]["vertices"] = []
		tempDict[b]["UVs"] = []
		x = b.x
		y = b.y
		z = b.z
		var t = tempDict[b]["type"]
		adjNameList = {"top":Vector3(x,y+1,z),"bottom":Vector3(x,y-1,z),
						"front":Vector3(x,y,z+1),"back":Vector3(x,y,z-1),
						"right":Vector3(x+1,y,z),"left":Vector3(x-1,y,z)}

		for n in adjNameList:
			if not adjNameList[n] in blockDict:
				var returnStuff = getFace(n,x,y,z,t)
				tempDict[b]['vertices'].append(returnStuff[0])
				tempDict[b]['UVs'].append(returnStuff[1])
	
	for b in tempDict:
		blockDict[Vector3(b[0],b[1],b[2])] = tempDict[b]
	if meshNode!=null:
		meshNode.queue_free()
	chunkMutex.unlock()
	renderChunk()

	chunkMutex.lock()
	for b in blockDict:
		blockDict[b].collisionVertices = blockDict[b].vertices
	chunkMutex.unlock()
	if staticNode!=null:
		staticNode.queue_free()
	genChunkCollision()

func generateChunk(a):
	#to be called in thread
	
	var list = []
	var n = 0

	noise.seed = game.get("genSeed")
	noise.octaves = 3
	noise.period = 25
	noise.persistence = 0.3
	for i in range(16):
		for j in range(16):
			for k in range(16):
				n = noise.get_noise_3d((i+(chunkPos[0]*16)),(j+(chunkPos[1]*16)),(k+(chunkPos[2]*16)))
				n/=2
				n+=0.5
				var thresh = pow(0.95,(j+(chunkPos[1]*16)))
				if n < thresh:
					list.append([[i,j,k],0])

	calcChunk(list)
	chunkMutex.lock()
	for b in blockDict:
		blockDict[b].collisionVertices = blockDict[b].vertices
	chunkMutex.unlock()
	game.renderQueueMutex.lock()
	game.renderQueue.append(self)
	game.renderQueueMutex.unlock()

	