extends Node

var blockMemory = {}

func _ready():
	place(0,0,0)

"""
Vector3 to UV
0,0 = 0,1
1,0 = 0,0
0,1 = 1,1
1,1 = 1,0
"""


func getFace(orient,x,y,z):
	var vertices = []#PoolVector3Array()
	var UVs = []#PoolVector2Array()
	if orient == "top":
		vertices.append(Vector3(0,1,0))
		vertices.append(Vector3(1,1,0))
		vertices.append(Vector3(0,1,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
		UVs.append(Vector2(0,1))
		vertices.append(Vector3(1,1,0))
		vertices.append(Vector3(1,1,1))
		vertices.append(Vector3(0,1,1))
		UVs.append(Vector2(1,0))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,1))
	elif orient == "bottom":
		pass
	elif orient == "left":
		vertices.append(Vector3(0,0,1))
		vertices.append(Vector3(0,0,0))
		vertices.append(Vector3(0,1,1))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(1,0))
		vertices.append(Vector3(0,0,0))
		vertices.append(Vector3(0,1,0))
		vertices.append(Vector3(0,1,1))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
	elif orient == "right":
		pass
	elif orient == "front":
		vertices.append(Vector3(0,0,1))
		vertices.append(Vector3(0,1,1))
		vertices.append(Vector3(1,0,1))
		UVs.append(Vector2(0,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,1))
		vertices.append(Vector3(1,0,1))
		vertices.append(Vector3(0,1,1))
		vertices.append(Vector3(1,1,1))
		UVs.append(Vector2(1,1))
		UVs.append(Vector2(0,0))
		UVs.append(Vector2(1,0))
	elif orient == "back":
		pass
		
	return [vertices,UVs]

func place(x,y,z):
	var new_texture = ImageTexture.new()
	new_texture.load("res://texture.png")
	new_texture.set_flags(2)
	var testMesh = MeshInstance.new()
	var tmpMesh = Mesh.new()
	var returnStuff = getFace("front",0,0,0)
	var returnStuff2 = getFace("top",0,0,0)
	var returnStuff3 = getFace("left",0,0,0)
	var returnStuff4 = getFace("back",0,0,0)
	var returnStuff5 = getFace("bottom",0,0,0)
	var returnStuff6 = getFace("right",0,0,0)
	var vertices = returnStuff[0]+returnStuff2[0]+returnStuff3[0]+returnStuff4[0]
	var UVs = returnStuff[1]+returnStuff2[1]+returnStuff3[1]+returnStuff4[1]
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
	self.add_child(testMesh)
	testMesh.set_translation(Vector3(x,y,z))
	#var cube = cubeScene.instance()
	#self.call_deferred("add_child", cube)

	#self.add_child(testMesh)
	testMesh.set_name(str(str(x)+" "+str(y)+" "+str(z)))



func _process(delta):
	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	
	"""
	var list = []
	if offz<1:
		if offy <1:
			if offx < 1:
				for i in range(8):
					for j in range(8):
						for k in range(8):
							list.append([i+offx,offz+j,k+offy])
				build(list)
				offx+=8
			else:
				offy+=8
				offx=0
		else:
			offx = 0
			offy = 0
			offz+=8

		#build(list)
		list = []
	
		"""
func build(orderList):
	var tempDict = {}
	var adjCheckList = {}
	
	for order in orderList:
		var x = order[0]
		var y = order[1]
		var z = order[2]
		tempDict[Vector3(x,y,z)] = {"adj":[],"shown":false}
	for b in tempDict:
		var x = b.x
		var y = b.y
		var z = b.z
		var adjNameList = {"top":Vector3(x,y,z+1),"bottom":Vector3(x,y,z-1),
						"front":Vector3(x-1,y,z),"back":Vector3(x+1,y,z),
						"right":Vector3(x,y-1,z),"left":Vector3(x,y+1,z)}
		for n in adjNameList:
			if adjNameList[n] in tempDict:
				tempDict[b]["adj"].append(n)
		if len(tempDict[b]["adj"])==6:
			for n in adjNameList:
				if blockMemoryHandler("exist", adjNameList[n]):
					adjCheckList[adjNameList[n]] = n
					if not n in tempDict[b]["adj"]:
						tempDict[b]["adj"].append(n)
		if len(tempDict[b]["adj"])==6:
			tempDict[b]["shown"] = false
		else:
			tempDict[b]["shown"] = true
			
	var mutex = Mutex.new()
	mutex.lock()
	for b in adjCheckList:
		blockMemoryHandler("append",b,"adj",adjCheckList[b])
		if len(blockMemoryHandler("get",b,"adj")) == 6:
			blockMemoryHandler("set",b,"shown",false)
	
	
	


func blockMemoryHandler(option,vectorPos,key=null,value=null):
	#the chunks the blockMemory Dictionary are separated into
	var x1 = int(floor(vectorPos.x/128))
	var x2 = int(floor(vectorPos.x/8))
	var y1 = int(floor(vectorPos.y/128))
	var y2 = int(floor(vectorPos.y/8))
	var z1 = int(floor(vectorPos.z/128))
	var z2 = int(floor(vectorPos.z/8))
	var x = vectorPos.x
	var y = vectorPos.y
	var z = vectorPos.z
	
	#the varius options the function uses
	if option == "append":
		if not Vector3(x1,y1,z1) in blockMemory:
			blockMemory[Vector3(x1,y1,z1)] = {}
		if not Vector3(x2,y2,z2) in blockMemory[Vector3(x1,y1,z1)]:
			blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)] = {} 
		if not Vector3(x,y,z) in blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)]:
			blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)] = {}	
		blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)][key].append(value)
	
	if option == "remove":
		if not Vector3(x1,y1,z1) in blockMemory:
			blockMemory[Vector3(x1,y1,z1)] = {}
		if not Vector3(x2,y2,z2) in blockMemory[Vector3(x1,y1,z1)]:
			blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)] = {}	 
		if not Vector3(x,y,z) in blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)]:
			blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)] = {}	
		blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)][key].erase(value)
	
	
	if option == "get":
		if Vector3(x1,y1,z1) in blockMemory:
			if Vector3(x2,y2,z2) in blockMemory[Vector3(x1,y1,z1)]:
				if Vector3(x,y,z) in blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)]:
					if key in blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)]:
						return blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)][key]
					else:
						return null
				else:
					return null
			else:
				return null
		else:
			return null
	
	if option == "delete":
		blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)].erase(Vector3(x,y,z))
	
	if option == "set":

		if not Vector3(x1,y1,z1) in blockMemory:
			blockMemory[Vector3(x1,y1,z1)] = {}
		if not Vector3(x2,y2,z2) in blockMemory[Vector3(x1,y1,z1)]:
			blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)] = {}  
		if not Vector3(x,y,z) in blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)]:
			blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)] = {}	   
		blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][Vector3(x,y,z)][key] = value  
		
	if option == "exist":
		if Vector3(x1,y1,z1) in blockMemory:
			if Vector3(x2,y2,z2) in blockMemory[Vector3(x1,y1,z1)]:
				if Vector3(x,y,z) in blockMemory[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)]:
					return true
				else:
					return false
			else:
				return false
		else:
			return false