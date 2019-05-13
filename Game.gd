extends Node

var threadChunkManager = Thread.new()
var threadChunking = Thread.new()
var genSeed = 0
var playerChunk = Vector3(0,0,0)
var chunkDict = {}
var exitLoop = false
var chunkQueue = []
onready var mutex = Mutex.new()

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
			var c = claimChunkQueue(null)
			mutex.unlock()
			if c!=null:
				placeChunk(c)
		exit = exitLoop
		

func addChunkQueue(pos):
	chunkQueue.append(pos)
	
func resetQueue(a):
	chunkQueue = []
	
func claimChunkQueue(a):
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
	if Input.is_action_just_pressed("reset"):
		exitLoop = true
		threadChunkManager.wait_to_finish()
		threadChunking.wait_to_finish()
		get_tree().reload_current_scene()
		
		
func placeChunk(c):
	if not c in chunkDict:
		mutex.lock()
		var chunk = load("res://Chunk.tscn").instance()
		chunk.chunkPos = c
		chunk.set_name(str(c.x)+" "+str(c.y)+" "+str(c.z))
		get_node("Chunks").add_child(chunk)
		mutex.unlock()
		chunk.generateChunk(null)
		mutex.lock()
		chunkDict[c] = chunk
		mutex.unlock()
		
		
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
	var chunkNum = pow(15,2)
	var done = false
	var initChunk = false
	chunkOn.x = playerChunk.x
	chunkOn.z = playerChunk.z

	while exit == false:
		exit = self.exitLoop
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
			var deleteList = []
			for c in chunkDict:
				if not c in chunkList:
					chunkDict[c].free()
					deleteList.append(c)
			for c in deleteList:
				chunkDict.erase(c)
			mutex.unlock()
		
					
			done = true
		elif not (prevPlayerChunk.x==playerChunk.x and prevPlayerChunk.z==playerChunk.z):
			done = false
			mutex.lock()
			resetQueue(null)
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
			
			
			
		