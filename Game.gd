extends Node

var threadChunkManager = Thread.new()
var threadChunking = Thread.new()
var genSeed = 0
var playerChunk = Vector3(0,0,0)
var chunkDict = {}
var exitLoop = false
var chunkQueue = []
var playerPosition = Vector3(0,0,0)
var playerPositionInChunk = Vector3(0,0,0)
onready var mutex = Mutex.new()
var count = 0
onready var rayCast = get_node("Player/Camera/RayCast")

func _ready():
	randomize()
	genSeed = randi()
	threadChunkManager.start(self,'chunkManager')
	threadChunking.start(self,'chunking')


func chunking(a):
	var exit = exitLoop
	while(exit==false):
		var r = mutex.try_lock()
		if r!=ERR_BUSY:
			var c = claimChunkQueue()
			mutex.unlock()
			if c!=null:
				if c[1] == null:
					placeChunk(c[0])
				else:
					chunkDict[c[0]].removeBlock(c[1])
		exit = exitLoop
		

func addChunkQueue(pos, vect=null):
	if vect==null:
		chunkQueue.append([pos, vect])
	else:
		chunkQueue.insert(0,[pos, vect])
	
func resetQueue():
	chunkQueue = []
	
func claimChunkQueue():
	if len(chunkQueue)!=0:
		var temp = chunkQueue[0]
		chunkQueue.remove(0)
		return temp
	else:
		return null

func _process(delta):
	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	var playerPos = get_node("Player").global_transform[3]
	playerChunk = Vector3(floor(playerPos[0]/16.0),floor(playerPos[1]/16.0),floor(playerPos[2]/16.0))
	playerPosition = Vector3(floor(playerPos[0]),floor(playerPos[1]),floor(playerPos[2]))
	playerPositionInChunk = Vector3(int(playerPosition.x)%16,
									int(playerPosition.y)%16,
									int(playerPosition.z)%16)
	
	#var breakBlockPos = get_node("Player").global_transform[3]+Vector3(0,-2,0)
	
	var placeBlockPos = Vector3(0,0,0)
	var breakBlockThere = false
	var breakBlockPos = Vector3(0,0,0)
	if rayCast.get_collider()!=null:
		breakBlockThere = true
		var pos = rayCast.get_collision_point()
		var norm = rayCast.get_collision_normal()
		pos+=Vector3(-0.5,-0.5,-0.5)
		if abs(norm.x)==1:
			breakBlockPos.z = int(round(pos.z))
			placeBlockPos.z = int(round(pos.z))
			breakBlockPos.y = int(round(pos.y))
			placeBlockPos.y = int(round(pos.y))
			if norm.x>0:
				breakBlockPos.x = int(floor(pos.x))
				placeBlockPos.x = int(floor(pos.x))+1
			else:
				breakBlockPos.x = int(ceil(pos.x))
				placeBlockPos.x = int(ceil(pos.x))-1
		if abs(norm.y)==1:
			breakBlockPos.z = int(round(pos.z))
			placeBlockPos.z = int(round(pos.z))
			breakBlockPos.x = int(round(pos.x))
			placeBlockPos.x = int(round(pos.x))
			if norm.y>0:
				breakBlockPos.y = int(floor(pos.y))
				placeBlockPos.y = int(floor(pos.y))+1
			else:
				breakBlockPos.y = int(ceil(pos.y))
				placeBlockPos.y = int(ceil(pos.y))-1
		if abs(norm.z)==1:
			breakBlockPos.x = int(round(pos.x))
			placeBlockPos.x = int(round(pos.x))
			breakBlockPos.y = int(round(pos.y))
			placeBlockPos.y = int(round(pos.y))
			if norm.z>0:
				breakBlockPos.z = int(floor(pos.z))
				placeBlockPos.z = int(floor(pos.z))+1
			else:
				breakBlockPos.z = int(ceil(pos.z))
				placeBlockPos.z = int(ceil(pos.z))-1

	
	var breakBlockChunk = Vector3(floor(breakBlockPos[0]/16.0),floor((breakBlockPos[1])/16.0),floor(breakBlockPos[2]/16.0))
	var breakBlockPosition = Vector3(floor(breakBlockPos[0]),floor(breakBlockPos[1]),floor(breakBlockPos[2]))
	var breakBlockPositionInChunk = Vector3(int(breakBlockPosition.x)%16,
										int(breakBlockPosition.y)%16,
										int(breakBlockPosition.z)%16)
	if breakBlockPositionInChunk.x<0:
		breakBlockPositionInChunk.x=16+breakBlockPositionInChunk.x
	if breakBlockPositionInChunk.y<0:
		breakBlockPositionInChunk.y=16+breakBlockPositionInChunk.y
	if breakBlockPositionInChunk.z<0:
		breakBlockPositionInChunk.z=16+breakBlockPositionInChunk.z
		
	var placeBlockChunk = Vector3(floor(placeBlockPos[0]/16.0),floor((placeBlockPos[1])/16.0),floor(placeBlockPos[2]/16.0))
	var placeBlockPosition = Vector3(floor(placeBlockPos[0]),floor(placeBlockPos[1]),floor(placeBlockPos[2]))
	var placeBlockPositionInChunk = Vector3(int(placeBlockPosition.x)%16,
										int(placeBlockPosition.y)%16,
										int(placeBlockPosition.z)%16)
	if placeBlockPositionInChunk.x<0:
		placeBlockPositionInChunk.x=16+placeBlockPositionInChunk.x
	if placeBlockPositionInChunk.y<0:
		placeBlockPositionInChunk.y=16+placeBlockPositionInChunk.y
	if placeBlockPositionInChunk.z<0:
		placeBlockPositionInChunk.z=16+placeBlockPositionInChunk.z
	
	if breakBlockThere:
		get_node("SelectBox").show()
		get_node("SelectBox").transform[3] = breakBlockPosition+Vector3(0.5,0.5,0.5)
	else:
		get_node("SelectBox").hide()
	
	if Input.is_action_just_pressed("reset"):
		exitLoop = true
		threadChunkManager.wait_to_finish()
		threadChunking.wait_to_finish()
		get_tree().reload_current_scene()
	if Input.is_action_just_pressed("break"):
		#addChunkQueue(breakBlockChunk, breakBlockPositionInChunk)
		if breakBlockThere:
			chunkDict[breakBlockChunk].removeBlock(breakBlockPositionInChunk)
	if Input.is_action_just_pressed("place"):
		if breakBlockThere:
			chunkDict[placeBlockChunk].placeBlock(placeBlockPositionInChunk)
func placeChunk(c):
	if not c in chunkDict:
		#mutex.lock()
		var chunk = load("res://Chunk.tscn").instance()
		chunk.chunkPos = c
		chunk.set_name(str(c.x)+" "+str(c.y)+" "+str(c.z))
		get_node("Chunks").add_child(chunk)
		#mutex.unlock()
		chunk.generateChunk(null)
		#mutex.lock()
		chunkDict[c] = chunk
		#mutex.unlock()
		
		
func chunkManager(a):
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
	var chunkNum = pow(15,2)#15
	var done = false
	var initChunk = false
	var deleteList = []
	chunkOn.x = playerChunk.x
	chunkOn.z = playerChunk.z

	while exit == false:
		exit = self.exitLoop
		mutex.lock()
		#if len(deleteList)!=0:
			#chunkDict[deleteList[0]].call_deferred('queue_free')
			#chunkDict[deleteList[0]].queue_free()
			#chunkDict.erase(deleteList[0])
			#deleteList.remove(0)
		mutex.unlock()
		if done == false:
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

			mutex.lock()
			for c in chunkList:
				addChunkQueue(c)
			
			for c in chunkDict:
				if not c in chunkList:
					#chunkDict[c].call_deferred('queue_free')
					#chunkDict[c].queue_free()
					deleteList.append(c)

			mutex.unlock()
		
					
			done = true
		elif not (prevPlayerChunk.x==playerChunk.x and prevPlayerChunk.z==playerChunk.z):
			done = false
			mutex.lock()
			resetQueue()
			mutex.unlock()
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
			
			
			
		