extends Node
#var thread = Thread.new()
#var blockMemory = {Vector3(0,0,0):{Vector3(0,0,0):{}}}
onready var blockMemory = load("res://blockMemory.gd").new()
var updateQueue = []
var thread = Thread.new()
var threadUpdate = Thread.new()
var prevTime
var printed = false
func _ready():
	threadUpdate.start(self,'chunking')
	prevTime = OS.get_ticks_msec()
"""
Vector3 to UV
0,0 = 0,1
1,0 = 0,0
0,1 = 1,1
1,1 = 1,0
"""

	
var offz = 0
var offx = 0
var offy = 0
var playerChunk = Vector3(0,0,0)
#var chunkQueue = []
func _process(delta):
	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	#if thread.is_active() == false:
	var playerPos = get_node("Player").global_transform[3]
	playerChunk = Vector3(int(playerPos[0]/16),int(playerPos[1]/16),int(playerPos[2]/16))
	if Input.is_action_just_pressed("save"):
		# Open a file
		print("Done")
		var file = File.new()
		if file.open("res://saved_game.txt", File.WRITE) != 0:
		    print("Error opening file")
		    return
		
		# Save the dictionary as JSON (or whatever you want, JSON is convenient here because it's built-in)
		file.store_line(to_json(blockMemory.blockMemoryDict))
		file.close()
#var count = 3
func chunking(a):
	var mutex = Mutex.new()
	var exit = false
	while exit == false:
		#if len(updateQueue)==0:

		if offy<8:
			if offx<8:
				if offz<8:
					prevTime = OS.get_ticks_msec()
					var chunk = load("res://Chunk.tscn").instance()
					mutex.lock()
					get_node("Chunks").add_child(chunk)
					mutex.unlock()
					chunk.chunkPos = Vector3(offx,offy,offz)
					chunk.set_name(str(offx)+" "+str(offy)+" "+str(offz))
					chunk.generateChunk(null)
					#print(OS.get_ticks_msec()-prevTime)
					#thread.start(chunk,'generateChunk')
					#thread.start(self,'printStuff')
					offz+=1
				else:
					offx+=1
					offz=0
			else:
				offz = 0
				offx = 0
				offy+=1
		else:
			if len(updateQueue==0):
				exit = true
				

		"""
		else:
			get_node("Chunks").get_node(updateQueue[0]).updateChunk()
			mutex.lock()
			updateQueue.remove(0)
			mutex.unlock()
		"""
func _physics_process(delta):
	#while count>0:
	pass
	
	
