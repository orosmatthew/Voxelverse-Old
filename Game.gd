extends Node

var thread_chunking = Thread.new()
var thread_chunk_manager = Thread.new()
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
var chunk_queue_mutex = Mutex.new()
var delete_list_mutex = Mutex.new()
var chunk_dict_mutex = Mutex.new()
var noise = OpenSimplexNoise.new()

onready var chunk_mutex = Mutex.new()
onready var player_raycast = get_node("Player/Camera/RayCast")

func _ready():
	randomize()
	generation_seed = randi()
	thread_chunking.start(self,"chunking",null)
	thread_chunk_manager.start(self,"chunk_manager",null)
	#generate_world()
			
func chunking(a):
	while true:
		var r = chunk_queue_mutex.try_lock()
		if r!=ERR_BUSY:
			if len(chunk_queue)>0:
				var c = chunk_queue[0]
				chunk_queue.remove(0)
				chunk_queue_mutex.unlock()
				
				
				var chunk = place_chunk(c)
		
				if chunk!=null:
					call_deferred("done_chunk_loading",chunk)
				
			else:
				chunk_queue_mutex.unlock()
				OS.delay_msec(500)
			
func done_chunk_loading(chunk):
	get_node("Chunks").add_child(chunk)
	chunk_dict_mutex.lock()
	chunk_dict[chunk.chunk_pos] = chunk
	chunk_dict_mutex.unlock()
	
	chunk.global_transform[3][0] = chunk.chunk_pos[0]*8
	chunk.global_transform[3][1] = chunk.chunk_pos[1]*8 
	chunk.global_transform[3][2] = chunk.chunk_pos[2]*8

func _process(delta):

	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	player_pos = get_node("Player").global_transform[3]
	player_chunk = Vector3(floor(player_pos[0]/8.0),floor(player_pos[1]/8.0),floor(player_pos[2]/8.0))
	player_block_pos = Vector3(floor(player_pos[0]),floor(player_pos[1]),floor(player_pos[2]))
	player_chunk_pos = Vector3(int(player_block_pos.x)%8,
									int(player_block_pos.y)%8,
									int(player_block_pos.z)%8)
	
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
	
	
	var break_block_chunk = Vector3(floor(break_block_pos[0]/8.0),floor((break_block_pos[1])/8.0),floor(break_block_pos[2]/8.0))
	var break_block_block_pos = Vector3(floor(break_block_pos[0]),floor(break_block_pos[1]),floor(break_block_pos[2]))
	var break_block_chunk_pos = Vector3(int(break_block_block_pos.x)%8,
										int(break_block_block_pos.y)%8,
										int(break_block_block_pos.z)%8)
	if break_block_chunk_pos.x<0:
		break_block_chunk_pos.x=8+break_block_chunk_pos.x
	if break_block_chunk_pos.y<0:
		break_block_chunk_pos.y=8+break_block_chunk_pos.y
	if break_block_chunk_pos.z<0:
		break_block_chunk_pos.z=8+break_block_chunk_pos.z
		
	var place_block_chunk = Vector3(floor(place_block_pos[0]/8.0),floor((place_block_pos[1])/8.0),floor(place_block_pos[2]/8.0))
	var place_block_block_pos = Vector3(floor(place_block_pos[0]),floor(place_block_pos[1]),floor(place_block_pos[2]))
	var place_block_chunk_pos = Vector3(int(place_block_block_pos.x)%8,
										int(place_block_block_pos.y)%8,
										int(place_block_block_pos.z)%8)
	if place_block_chunk_pos.x<0:
		place_block_chunk_pos.x=8+place_block_chunk_pos.x
	if place_block_chunk_pos.y<0:
		place_block_chunk_pos.y=8+place_block_chunk_pos.y
	if place_block_chunk_pos.z<0:
		place_block_chunk_pos.z=8+place_block_chunk_pos.z
	
	if block_exist:
		get_node("SelectBox").show()
		get_node("SelectBox").transform[3] = break_block_pos+Vector3(0.5,0.5,0.5)
	else:
		get_node("SelectBox").hide()

	if Input.is_action_just_pressed("break"):
		if block_exist:
			chunk_dict_mutex.lock()
			chunk_dict[break_block_chunk].remove_block(break_block_chunk_pos)
			chunk_dict_mutex.unlock()
	if Input.is_action_just_pressed("place"):
		if block_exist:
			chunk_dict_mutex.lock()
			chunk_dict[place_block_chunk].place_block(place_block_chunk_pos,1)
			chunk_dict_mutex.unlock()

func local_to_global(pos, chunk_pos):
	var global_pos = Vector3()
	global_pos.x = (chunk_pos.x * 8) + pos.x
	global_pos.y = (chunk_pos.y * 8) + pos.y
	global_pos.z = (chunk_pos.z * 8) + pos.z
	return global_pos
	
	
func global_to_local(pos):
	
	var local_pos = Vector3(int(pos.x)%8,
							int(pos.y)%8,
							int(pos.z)%8)
	
	if local_pos.x<0:
		local_pos.x=8+local_pos.x
	if local_pos.y<0:
		local_pos.y=8+local_pos.y
	if local_pos.z<0:
		local_pos.z=8+local_pos.z
		
	return local_pos

func place_chunk(c):
	chunk_dict_mutex.lock()
	if not c in chunk_dict:
		chunk_dict_mutex.unlock()
		var chunk = load("res://Chunk.tscn").instance()
		chunk.chunk_pos = c
		chunk.set_name(str(c.x)+" "+str(c.y)+" "+str(c.z))
		chunk.generate_chunk(generation_seed, self)
		return chunk
	else:
		chunk_dict_mutex.unlock()


func query_block(pos, disk):
	
	var chunk_pos = Vector3(floor(pos.x/8.0),floor(pos.y/8.0),floor(pos.z/8.0))
	
	pos = global_to_local(pos)
	
	chunk_dict_mutex.lock()
	if chunk_pos in chunk_dict:
		if pos in chunk_dict[chunk_pos].block_dict:
			var r = chunk_dict[chunk_pos].block_dict[pos]
			chunk_dict_mutex.unlock()
			return r
			
		else:
			chunk_dict_mutex.unlock()
			return null
	else:
		chunk_dict_mutex.unlock()
		return null
	chunk_dict_mutex.unlock()

func get_save_string(d):
	var save_dict = {}
	for i in range(8):
		for j in range(8):
			for k in range(8):
				if d.has(Vector3(i,j,k)) == true:
					save_dict[Vector3(i,j,k)] = d[Vector3(i,j,k)]["t"]
				else:
					save_dict[Vector3(i,j,k)] = 0
	
	var save_string = ""
	
	for i in range(8):
		var line = ""
		for j in range(8):
			for k in range(8):
				line+=(str(save_dict[Vector3(i,j,k)])+" ")
		save_string += (line+"\n")
	
	return save_string
		


func generate_world():
	for x1 in range(32):
		for y1 in range(4):
			for z1 in range(32):
				var x = x1-16
				var z = z1-16
				var y = y1
				noise.seed = generation_seed
				noise.octaves = 3
				noise.period = 25
				noise.persistence = 0.3
				var block_dict = {}
				var n
				
				for i in range(8):
					for j in range(8):
						for k in range(8):
							n = noise.get_noise_3d((i+(x*8)),(j+(y*8)),(k+(z*8)))
							n/=2
							n+=0.5
							#0.955
							var thresh = pow(0.955,(j+(y*8)))
							if n < thresh:
								if (j+(y*8))<14:
									block_dict[Vector3(i,j,k)] = {"t":3}
								else:
									block_dict[Vector3(i,j,k)] = {"t":1}
							elif (j+(y*8))<12:
								
								block_dict[Vector3(i,j,k)] = {"t":4}
				
				var save_string = get_save_string(block_dict)
				
				var chunk_pos_string = str(x)+" "+str(y)+" "+str(z)
			
				var file = File.new()
				file.open("res://world/"+chunk_pos_string+".dat", File.WRITE)
				file.store_string(save_string)
				file.close()




func chunk_manager(a):

	var exit = false
	var copied = false
	var chunk_list_copy = []
	var chunk_list = []
	var prev_player_chunk = Vector3(0,0,0)
	var vert_count = 0
	var vert_num = 8
	var dir = 0
	var count = 0
	var num = 1
	var twice = false
	var chunk_on = Vector3(0,0,0)
	var count_chunks = 0
	var chunk_num = pow(32,2)#32
	var done = false
	var init_chunk = false
	var delete_list = []
	var change_queue = false
	var change_delete_list = false
	var prev_chunk_list = chunk_list
	
	while true:
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
			done = true
		
		elif not (prev_player_chunk.x==player_chunk.x and prev_player_chunk.z==player_chunk.z):
			done = false
			copied = false
			chunk_list_copy = []
			prev_chunk_list = chunk_list
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
			change_queue=false
			change_delete_list = false
		
		
		
		var r1 = delete_list_mutex.try_lock()
		if r1 != ERR_BUSY:
			if len(delete_list)!=0:
				var end = 0
				chunk_dict_mutex.lock()
				while len(delete_list)!=0:
					if delete_list[0] in chunk_dict:
						chunk_dict[delete_list[0]].call_deferred("queue_free")
						end+=1
					chunk_dict.erase(delete_list[0])
					delete_list.remove(0)
					if end >= 3:
						break
				chunk_dict_mutex.unlock()
			delete_list_mutex.unlock()
			
		if done==true:
			OS.delay_msec(100)
			
		if done==true and change_queue == false and change_delete_list == true:
			var r = chunk_queue_mutex.try_lock()
			if r != ERR_BUSY:
				chunk_queue = []
				for c in chunk_list:
					var chunk_pos_string = str(c.x)+" "+str(c.y)+" "+str(c.z)
					var file2Check = File.new()
					if file2Check.file_exists("res://world/"+chunk_pos_string+".dat"):
						chunk_queue.append(c)
				
				chunk_queue_mutex.unlock()
				change_queue = true

		if done==true and change_delete_list == false:

			var r = delete_list_mutex.try_lock()
			if r != ERR_BUSY:
				for c in prev_chunk_list:
					if not c in chunk_list:
						if not c in delete_list:
							delete_list.append(c)
				for c in chunk_list:
					if c in delete_list:
						delete_list.erase(c)
				delete_list_mutex.unlock()
				change_delete_list = true

				
		
			
			
			
			

		

	

			
			
		
