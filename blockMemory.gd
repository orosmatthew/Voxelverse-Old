extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var blockMemoryDict = {}


func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	pass



func makeRegion(chunkPos):
	var x1 = floor(chunkPos.x/64)
	var y1 = floor(chunkPos.y/64)
	var z1 = floor(chunkPos.z/64)
	if not Vector3(x1,y1,z1) in blockMemoryDict:
		blockMemoryDict[Vector3(x1,y1,z1)] = {}


func makeChunk(chunkPos):
	var x1 = floor(chunkPos.x/64)
	var y1 = floor(chunkPos.y/64)
	var z1 = floor(chunkPos.z/64)
	if Vector3(x1,y1,z1) in blockMemoryDict:
		blockMemoryDict[Vector3(x1,y1,z1)][chunkPos] = {}
		return true
	else:
		return false

func existChunk(chunkPos):
	var x1 = floor(chunkPos.x/64)
	var y1 = floor(chunkPos.y/64)
	var z1 = floor(chunkPos.z/64)
	if Vector3(x1,y1,z1) in blockMemoryDict:
		if chunkPos in blockMemoryDict[Vector3(x1,y1,z1)]:
			return true
		else:
			return false
	else:
		return false

func existBlock(blockPos):
	var x1 = floor(blockPos.x/1024)
	var x2 = floor(blockPos.x/16)
	var y1 = floor(blockPos.y/1024)
	var y2 = floor(blockPos.y/16)
	var z1 = floor(blockPos.z/1024)
	var z2 = floor(blockPos.z/16)
	if existChunk(Vector3(x2,y2,z2)):
		if blockPos in blockMemoryDict[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)]:
			return true
		else:
			return false
	else:
		return false

func setBlockData(blockPos,data):
	var x1 = int(floor(blockPos.x/1024))
	var x2 = int(floor(blockPos.x/16))
	var y1 = int(floor(blockPos.y/1024))
	var y2 = int(floor(blockPos.y/16))
	var z1 = int(floor(blockPos.z/1024))
	var z2 = int(floor(blockPos.z/16))
	if existChunk(Vector3(x2,y2,z2)):
		blockMemoryDict[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][blockPos] = data
		return true
	else:
		return false
		
func getBlockData(blockPos):
	var x1 = int(floor(blockPos.x/1024))
	var x2 = int(floor(blockPos.x/16))
	var y1 = int(floor(blockPos.y/1024))
	var y2 = int(floor(blockPos.y/16))
	var z1 = int(floor(blockPos.z/1024))
	var z2 = int(floor(blockPos.z/6))
	if existChunk(Vector3(x2,y2,z2)):
		if blockPos in blockMemoryDict[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)]:
			return blockMemoryDict[Vector3(x1,y1,z1)][Vector3(x2,y2,z2)][blockPos]
		else:
			return null
	else:
		return null
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
