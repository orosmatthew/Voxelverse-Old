extends Node

#var blockMemory = {Vector3(0,0,0):{Vector3(0,0,0):{}}}
onready var blockMemory = load("res://blockMemory.gd").new()
var updateQueue = []
var thread = Thread.new()
var threadUpdate = Thread.new()
var threadRender = Thread.new()
var prevTime
var printed = false
var playerPrevChunk
var chunkObjDict = {}
var genSeed = 0
var chunkCount = 0

func _ready():
	randomize()
	genSeed = randi()
	threadUpdate.start(self,'chunking')
	prevTime = OS.get_ticks_msec()
	
"""
Vector3 to UV
0,0 = 0,1
1,0 = 0,0
0,1 = 1,1
1,1 = 1,0
"""

	

func chunkPhysics(a):
	print("physics")
	var prevPlayerChunk = playerChunk
	var done = false
	var physList = []
	var madeList = false
	var mutex = Mutex.new()
	var deltaMsec = 0
	while true:
		if prevPlayerChunk.x==playerChunk.x and prevPlayerChunk.z==playerChunk.z:# and deltaMsec > 500:
			if done == false:
				if blockMemory.existChunk(prevPlayerChunk)==true:
					if madeList == false:
						for b in blockMemory.getChunk(prevPlayerChunk):
							physList.append(b)
						madeList = true
					if len(physList)!=0:
						var staticScene = load("res://cubeStatic.tscn").instance()
						mutex.lock()
						get_node("Physics").add_child(staticScene)
						staticScene.global_transform[3][0] = (prevPlayerChunk.x*16)+physList[0].x
						staticScene.global_transform[3][1] = physList[0].y
						staticScene.global_transform[3][2] = (prevPlayerChunk.z*16)+physList[0].z
						mutex.unlock()
						physList.remove(0)
					else:
						done = true
		
			
		else:
			mutex.lock()
			for c in get_node("Physics").get_children():
				c.free()
			mutex.unlock()
			prevPlayerChunk = playerChunk
			done = false
			physList = []
			madeList = false
			deltaMsec = 0
			prevTime = OS.get_ticks_msec()
		#deltaMsec+=(OS.get_ticks_msec()-prevTime)

var playerChunk = Vector3(0,0,0)
#var chunkQueue = []

func _process(delta):

	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	var playerPos = get_node("Player").global_transform[3]
	playerChunk = Vector3(floor(playerPos[0]/16.0),floor(playerPos[1]/16.0),floor(playerPos[2]/16.0))
	if Input.is_action_just_pressed("save"):
		# Open a file
		print("Done")
		var file = File.new()
		if file.open("res://saved_game.txt", File.WRITE) != 0:
		    print("Error opening file")
		    return
		
		file.store_line(to_json(blockMemory.blockMemoryDict))
		file.close()
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()
func placeChunk(c):
	var mutex = Mutex.new()
	if not blockMemory.existChunk(c):
		var chunk = load("res://Chunk.tscn").instance()
		get_node("Chunks").add_child(chunk)
		chunkObjDict[c] = chunk
		chunk.chunkPos = c
		chunk.set_name(str(c.x)+" "+str(c.y)+" "+str(c.z))
		chunk.generateChunk(null)






func chunking(a):
	var mutex = Mutex.new()
	var exit = false
	var copied = false
	var chunkListCopy = []
	var chunkList = []
	var prevPlayerChunk = Vector3(0,0,0)
	var vertCount = 0
	var vertNum = 4
	var dir = 0
	var count = 0
	var num = 1
	var twice = false
	var chunkOn = Vector3(0,0,0)
	var countChunks = 0
	var chunkNum = pow(16,2)

	var initChunk = false
	chunkOn.x = playerChunk.x
	chunkOn.z = playerChunk.z

	while exit == false:
		if prevPlayerChunk.x==playerChunk.x and prevPlayerChunk.z==playerChunk.z:
			while(countChunks<chunkNum):
				if vertCount<vertNum:
					chunkList.append(chunkOn)
					chunkOn.y+=1
					vertCount+=1
				else:
					vertCount = 0
					chunkOn.y = 0
					if countChunks<chunkNum:
						countChunks+=1
						count+=1
						if dir==0:
							chunkOn.z+=1
						if dir==1:
							chunkOn.x+=1
						if dir==2:
							chunkOn.z-=1
						if dir==3:
							chunkOn.x-=1
						if count==num:
							count = 0
							if twice == true:
								num+=1
								twice = false
							else:
								twice = true
							if dir<3:
								dir+=1
							else:
								dir=0

			if copied == false:
				for i in chunkList:
					chunkListCopy.append(i)
				copied = true
			if len(chunkList)!=0:
				placeChunk(chunkList[0])
				chunkList.remove(0)
			
			for c in chunkObjDict:
				if not c in chunkListCopy:
					chunkObjDict[c].free()
					blockMemory.deleteChunk(c)
					chunkObjDict.erase(c)
			"""
			for child in get_node("Chunks").get_children():
				var strArr = child.get_name().split(" ")
				var childChunk = Vector3(int(strArr[0]),int(strArr[1]),int(strArr[2]))
				if not childChunk in chunkListCopy:
					child.free()
					blockMemory.deleteChunk(childChunk)
					break
			"""
		else:
			copied = false
			chunkListCopy = []
			chunkList = []
			prevPlayerChunk = playerChunk
			vertCount = 0
			dir = 0
			count = 0
			num = 1
			twice = false
			chunkOn = Vector3(0,0,0)
			countChunks = 0
			initChunk = false
			chunkOn.x = playerChunk.x
			chunkOn.z = playerChunk.z
		
func _physics_process(delta):
	pass
	
	
