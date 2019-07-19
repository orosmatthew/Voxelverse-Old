extends Node

var thread_chunking = Thread.new()

var generation_seed = 0
var player_chunk = Vector3(0,0,0)
var chunk_dict = {}
var exit_loop = false
var chunk_queue = []
var gen_queue = []
var player_pos = Vector3(0,0,0)
var player_block_pos = Vector3(0,0,0)
var player_chunk_pos = Vector3(0,0,0)
var chunk_manager_init = false


onready var gen_mutex = Mutex.new()
onready var player_raycast = get_node("Player/Camera/RayCast")

func _ready():
	randomize()
	generation_seed = randi()
	thread_chunking.start(self,'chunking',thread_chunking)


func chunking(thread):
	var t = Timer.new()
	while true:
		var r = gen_mutex.try_lock()
		if r!=ERR_BUSY:
			if len(gen_queue)>0:
				var c = gen_queue[0]
				gen_queue.remove(0)
				gen_mutex.unlock()
				c.generate_chunk(thread)
			elif len(gen_queue)==0:
				gen_mutex.unlock()
			else:
				gen_mutex.unlock()
				

			


func _process(delta):

	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	player_pos = get_node("Player").global_transform[3]
	player_chunk = Vector3(floor(player_pos[0]/16.0),floor(player_pos[1]/16.0),floor(player_pos[2]/16.0))
	player_block_pos = Vector3(floor(player_pos[0]),floor(player_pos[1]),floor(player_pos[2]))
	player_chunk_pos = Vector3(int(player_block_pos.x)%16,
									int(player_block_pos.y)%16,
									int(player_block_pos.z)%16)
	
	var block_exist = false
	var break_block_pos = Vector3(0,0,0)
	var place_block_pos = Vector3(0,0,0)
	if player_raycast.get_collider()!=null:
		block_exist = true
		var raycast_pos = player_raycast.get_collision_point()
		var raycast_norm = player_raycast.get_collision_normal()
		raycast_pos+=Vector3(-0.5,-0.5,-0.5)
		if abs(raycast_norm.x)==1:
			break_block_pos.z = int(round(raycast_pos.z))
			place_block_pos.z = int(round(raycast_pos.z))
			break_block_pos.y = int(round(raycast_pos.y))
			place_block_pos.y = int(round(raycast_pos.y))
			if raycast_norm.x>0:
				break_block_pos.x = int(floor(raycast_pos.x))
				place_block_pos.x = int(floor(raycast_pos.x))+1
			else:
				break_block_pos.x = int(ceil(raycast_pos.x))
				place_block_pos.x = int(ceil(raycast_pos.x))-1
		if abs(raycast_norm.y)==1:
			break_block_pos.z = int(round(raycast_pos.z))
			place_block_pos.z = int(round(raycast_pos.z))
			break_block_pos.x = int(round(raycast_pos.x))
			place_block_pos.x = int(round(raycast_pos.x))
			if raycast_norm.y>0:
				break_block_pos.y = int(floor(raycast_pos.y))
				place_block_pos.y = int(floor(raycast_pos.y))+1
			else:
				break_block_pos.y = int(ceil(raycast_pos.y))
				place_block_pos.y = int(ceil(raycast_pos.y))-1
		if abs(raycast_norm.z)==1:
			break_block_pos.x = int(round(raycast_pos.x))
			place_block_pos.x = int(round(raycast_pos.x))
			break_block_pos.y = int(round(raycast_pos.y))
			place_block_pos.y = int(round(raycast_pos.y))
			if raycast_norm.z>0:
				break_block_pos.z = int(floor(raycast_pos.z))
				place_block_pos.z = int(floor(raycast_pos.z))+1
			else:
				break_block_pos.z = int(ceil(raycast_pos.z))
				place_block_pos.z = int(ceil(raycast_pos.z))-1
	
	
	var break_block_chunk = Vector3(floor(break_block_pos[0]/16.0),floor((break_block_pos[1])/16.0),floor(break_block_pos[2]/16.0))
	var break_block_block_pos = Vector3(floor(break_block_pos[0]),floor(break_block_pos[1]),floor(break_block_pos[2]))
	var break_block_chunk_pos = Vector3(int(break_block_block_pos.x)%16,
										int(break_block_block_pos.y)%16,
										int(break_block_block_pos.z)%16)
	if break_block_chunk_pos.x<0:
		break_block_chunk_pos.x=16+break_block_chunk_pos.x
	if break_block_chunk_pos.y<0:
		break_block_chunk_pos.y=16+break_block_chunk_pos.y
	if break_block_chunk_pos.z<0:
		break_block_chunk_pos.z=16+break_block_chunk_pos.z
		
	var place_block_chunk = Vector3(floor(place_block_pos[0]/16.0),floor((place_block_pos[1])/16.0),floor(place_block_pos[2]/16.0))
	var place_block_block_pos = Vector3(floor(place_block_pos[0]),floor(place_block_pos[1]),floor(place_block_pos[2]))
	var place_block_chunk_pos = Vector3(int(place_block_block_pos.x)%16,
										int(place_block_block_pos.y)%16,
										int(place_block_block_pos.z)%16)
	if place_block_chunk_pos.x<0:
		place_block_chunk_pos.x=16+place_block_chunk_pos.x
	if place_block_chunk_pos.y<0:
		place_block_chunk_pos.y=16+place_block_chunk_pos.y
	if place_block_chunk_pos.z<0:
		place_block_chunk_pos.z=16+place_block_chunk_pos.z
	
	if block_exist:
		get_node("SelectBox").show()
		get_node("SelectBox").transform[3] = break_block_pos+Vector3(0.5,0.5,0.5)
	else:
		get_node("SelectBox").hide()

	
	if Input.is_action_just_pressed("break"):
		if block_exist:
			chunk_dict[break_block_chunk].remove_block(break_block_chunk_pos)
	if Input.is_action_just_pressed("place"):
		if block_exist:
			chunk_dict[place_block_chunk].place_block(place_block_chunk_pos,1)
	chunk_manager()
	
	
	
func place_chunk(c):
	if not c in chunk_dict:
		var chunk = load("res://Chunk.tscn").instance()
		chunk.chunk_pos = c
		chunk.set_name(str(c.x)+" "+str(c.y)+" "+str(c.z))
		chunk.block_class = load("res://Block.tscn")
		chunk_dict[c] = chunk
		get_node("Chunks").add_child(chunk)
		
		gen_mutex.lock()
		gen_queue.append(chunk)
		gen_mutex.unlock()
		#chunk.generate_chunk(thread_chunking)

var exit = false
var copied = false
var chunk_list_copy = []
var chunk_list = []
var prev_player_chunk = Vector3(0,0,0)
var vert_count = 0
var vert_num = 4
var dir = 0
var count = 0
var num = 1
var twice = false
var chunk_on = Vector3(0,0,0)
var count_chunks = 0
var chunk_num = pow(15,2)#15
var done = false
var init_chunk = false
var delete_list = []

func chunk_manager():
	
	if len(chunk_queue)>0:
		var c = chunk_queue[0]
		chunk_queue.remove(0)
		place_chunk(c)
		
	
	if len(delete_list)!=0:
		if delete_list[0] in chunk_dict:
			chunk_dict[delete_list[0]].queue_free()
		chunk_dict.erase(delete_list[0])
		delete_list.remove(0)
	if done == false:
		while(count_chunks<chunk_num):
			if vert_count<vert_num:
				chunk_list.append(chunk_on)
				chunk_on.y+=1
				vert_count+=1
			else:
				vert_count = 0
				chunk_on.y = 0
				if count_chunks<chunk_num:
					count_chunks+=1
					count+=1
					if dir==0:
						chunk_on.z+=1
					if dir==1:
						chunk_on.x+=1
					if dir==2:
						chunk_on.z-=1
					if dir==3:
						chunk_on.x-=1
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
		for c in chunk_list:
			chunk_queue.append(c)
		
		for c in chunk_dict:
			if not c in chunk_list:
				delete_list.append(c)
		done = true
	elif not (prev_player_chunk.x==player_chunk.x and prev_player_chunk.z==player_chunk.z):
		done = false
		chunk_queue = []
		copied = false
		chunk_list_copy = []
		chunk_list = []
		prev_player_chunk = player_chunk
		vert_count = 0
		dir = 0
		count = 0
		num = 1
		twice = false
		chunk_on = Vector3(0,0,0)
		count_chunks = 0
		init_chunk = false
		chunk_on.x = player_chunk.x
		chunk_on.z = player_chunk.z

			
			
		