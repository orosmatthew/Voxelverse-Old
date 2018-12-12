extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
var deltaSum = 0
var blockMemory = {}
var offx = 0
var offy = 0
var offz = 0
var cubeScene
onready var fps_label = get_node('fps_label')

func _ready():
	cubeScene = preload("res://Cube.tscn")
	#var test = load("res://test.py").new()
	

func _process(delta):
	get_node("fps_label").set_text(str(Engine.get_frames_per_second()))
	var list = []
	if offz<36:
		if offy <36:
			if offx < 36:
				for i in range(6):
					for j in range(6):
						for k in range(6):
							list.append([i+offx,offz+j,k+offy])
				build(list)
				offx+=6
			else:
				offy+=6
				offx=0
		else:
			offx = 0
			offy = 0
			offz+=6

		#build(list)
		list = []
		


func build(orderList):
	

	var tempDict = {} #tempDict acts like blockMemory but is just temp
	
	for order in orderList:
		var x = order[0]
		var y = order[1]
		var z = order[2]
		tempDict[Vector3(x,y,z)] = {"shown":false,"object":null,"adjacent":[]}
	for order in orderList:
		var x = order[0]
		var y = order[1]
		var z = order[2]
		
		var blockList = [[x,y,z+1],[x,y,z-1],[x-1,y,z],[x+1,y,z],[x,y-1,z],[x,y+1,z]]
		var blockNameList = ["top","bottom","front","back","right","left"]
		var nameCount = 0
		
		#iterate through blocks to see which ones have to be displayed and not
		for block in blockList:
			if Vector3(block[0],block[1],block[2]) in tempDict.keys():
				tempDict[Vector3(x,y,z)]['adjacent'].append(blockNameList[nameCount])
			nameCount += 1
		if len(tempDict[Vector3(x,y,z)]['adjacent']) >= 6:
			tempDict[Vector3(x,y,z)]["shown"] = false
		else:
			tempDict[Vector3(x,y,z)]["shown"] = true
	
	var dictHandlerList = []
	var renderList = []
	var blockMemoryCheckList = []
	
	#iterates through tempDict
	for item in tempDict:
		var x = item[0]
		var y = item[1]
		var z = item[2]
		var blockList = [[x,y,z+1],[x,y,z-1],[x-1,y,z],[x+1,y,z],[x,y-1,z],[x,y+1,z]]
		var blockNameList = ["top","bottom","front","back","right","left"]
		var oppositeNameList = ["bottom","top","back","front","left","right"]
		var checkArea = 0
		var nameCount = 0
		
		#iterates through shown blocks in tempDict to see if they need to be displayed using the blockMemoryHandler
		if tempDict[item]["shown"] == true:
			for block in blockList:
				if blockMemoryHandler("exist",block[0],block[1],block[2]) == true:
					if not blockNameList[nameCount] in tempDict[item]['adjacent']:
						tempDict[item]['adjacent'].append(blockNameList[nameCount])
						if not oppositeNameList[nameCount] in blockMemoryHandler("get",block[0],block[1],block[2],"adjacent"):
							dictHandlerList.append(["append",block[0],block[1],block[2],"adjacent",oppositeNameList[nameCount]])
						blockMemoryCheckList.append(block)
				nameCount +=1
			if len(tempDict[item]['adjacent']) >= 6:
				dictHandlerList.append(["set",x,y,z,"shown",false])
			else:
				renderList.append([x,y,z])
	
			
		else:
			dictHandlerList.append(["set",x,y,z,"shown",false])
		
		dictHandlerList.append(["set",x,y,z,"adjacent",tempDict[item]["adjacent"]])
		dictHandlerList.append(["set",x,y,z,"object",tempDict[item]["object"]])
	
   
	#sets blockMemory items
	for item in dictHandlerList:
		callv("blockMemoryHandler",item)
		
	#checks blocks in blockMemory to see if they need to be displayed
	for item in blockMemoryCheckList:
		if len(blockMemoryHandler("get",item[0],item[1],item[2],"adjacent")) >= 6:
			if blockMemoryHandler("get",item[0],item[1],item[2],"object") != null:
				dictHandlerList.append(["set",item[0],item[1],item[2],"object",null])
				blockMemoryHandler("get",item[0],item[1],item[2],"object").free()
				blockMemoryHandler("set",item[0],item[1],item[2],"object",null)
			blockMemoryHandler("set",item[0],item[1],item[2],"shown",false)
	
	#render displayed blocks
	for item in renderList:
		var x = item[0]
		var y = item[1]
		var z = item[2]
		if blockMemoryHandler("get",x,y,z,"object")==null:
			var cube = cubeScene.instance()
			add_child(cube)
			cube.set_translation(Vector3(x,y,z))
			cube.x = x
			cube.y = y
			cube.z = z
			blockMemoryHandler("set",x,y,z,"object",cube)
			blockMemoryHandler("set",x,y,z,"shown",true)





		
func blockMemoryHandler(option,x,y,z,key=null,value=null):
	#the chunks the blockMemory Dictionary are separated into
	var x1 = (int(floor(x/128)))
	var x2 = (int(floor(x/8)))
	var y1 = (int(ceil(y/128)))
	var y2 = (int(ceil(y/8)))
	
	#the varius options the function uses
	if option == "append":
		if not Vector2(x1,y1) in blockMemory.keys():
			blockMemory[Vector2(x1,y1)] = {}
		if not Vector2(x2,y2) in blockMemory[Vector2(x1,y1)].keys():
			blockMemory[Vector2(x1,y1)][Vector2(x2,y2)] = {} 
		if not Vector3(x,y,z) in blockMemory[Vector2(x1,y1)][Vector2(x2,y2)].keys():
			blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector2(x,y,z)] = {}	
		blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector3(x,y,z)][key].append(value)
	
	if option == "remove":
		if not Vector2(x1,y1) in blockMemory.keys():
			blockMemory[Vector2(x1,y1)] = {}
		if not Vector2(x2,y2) in blockMemory[Vector2(x1,y1)].keys():
			blockMemory[Vector2(x1,y1)][Vector2(x2,y2)] = {}	 
		if not Vector3(x,y,z) in blockMemory[Vector2(x1,y1)][Vector2(x2,y2)].keys():
			blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector3(x,y,z)] = {}	
		blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector3(x,y,z)][key].erase(value)
	
	
	if option == "get":
		if Vector2(x1,y1) in blockMemory.keys():
			if Vector2(x2,y2) in blockMemory[Vector2(x1,y1)].keys():
				if Vector3(x,y,z) in blockMemory[Vector2(x1,y1)][Vector2(x2,y2)].keys():
					if key in blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector3(x,y,z)]:
						return blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector3(x,y,z)][key]
					else:
						return null
				else:
					return null
			else:
				return null
		else:
			return null
	
	if option == "delete":
		blockMemory[Vector2(x1,y1)][Vector2(x2,y2)].erase(Vector3(x,y,z))
	
	if option == "set":

		if not Vector2(x1,y1) in blockMemory.keys():
			blockMemory[Vector2(x1,y1)] = {}
		if not Vector2(x2,y2) in blockMemory[Vector2(x1,y1)].keys():
			blockMemory[Vector2(x1,y1)][Vector2(x2,y2)] = {}  
		if not Vector3(x,y,z) in blockMemory[Vector2(x1,y1)][Vector2(x2,y2)].keys():
			blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector3(x,y,z)] = {}	   
		blockMemory[Vector2(x1,y1)][Vector2(x2,y2)][Vector3(x,y,z)][key] = value  
		
	if option == "exist":
		if Vector2(x1,y1) in blockMemory.keys():
			if Vector2(x2,y2) in blockMemory[Vector2(x1,y1)].keys():
				if Vector3(x,y,z) in blockMemory[Vector2(x1,y1)][Vector2(x2,y2)].keys():
					return true
				else:
					return false
			else:
				return false
		else:
			return false
