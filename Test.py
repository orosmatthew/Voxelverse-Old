from godot import exposed, export
from godot.bindings import *
from godot.globals import *
import math


@exposed
class test(Node):
	deltaSum = 0
	blockMemory = {}
	offx = 0
	offy = 0
	offz = 0
	renderCount = 1
	def _process(self,delta):
		#if self.deltaSum>=0.1:
		list = []
		if self.offz<32:
			if self.offy <32:
				if self.offx < 32:
					for i in range(4):
						for j in range(4):
							for k in range(4):
								list.append([i+self.offx,self.offz+j,k+self.offy])
					self.offx+=4
				else:
					self.offy+=4
					self.offx=0
			else:
				self.offx=0
				self.offy=0
				self.offz+=4
			self.build(list)
		#print(len(self.get_node("Instancer").get_children()))
		#self.deltaSum=0
		#self.deltaSum+=delta
		
				
		
	def render(self,x,y,z):
		#set owner variables
		#cubeScene = ResourceLoader.load("res://Cube.tscn", 'PackedScene', False)
		#cube = cubeScene.instance(0)
		#self.get_node("Instancer").add_child(cube)
		#cube.set_name(str(str(x)+" "+str(y)+" "+str(z)))
		#cube.set_translation(Vector3(x,y,z))
		#cube.x = x
		#cube.y = y
		#cube.z = z
		#count+=1
		
		self.get_node("Instancer").place(x,y,z)#.placeQueue.append([x,y,z])#
		#print(self.renderCount)
		self.renderCount+=1
		#function for displaying a cube

		#self.blockMemoryHandler("set",x,y,z,'object',cube)
		self.blockMemoryHandler("set",x,y,z,'shown',True)

	def build(self,orderList):
		tempDict = {} #tempDict acts like blockMemory but is just temp
		
		for order in orderList:
			x,y,z = order
			tempDict[(x,y,z)] = {"shown":False,"object":None,"adjacent":[]}
		for order in orderList:
			x,y,z = order
			
			blockList = [[x,y,z+1],[x,y,z-1],[x-1,y,z],[x+1,y,z],[x,y-1,z],[x,y+1,z]]
			blockNameList = ["top","bottom","front","back","right","left"]
			nameCount = 0
			
			#iterate through blocks to see which ones have to be displayed and not
			for block in blockList:
				if tuple(block) in tempDict.keys():
					tempDict[(x,y,z)]['adjacent'].append(blockNameList[nameCount])
				nameCount += 1
			if len(tempDict[(x,y,z)]['adjacent']) >= 6:
				tempDict[(x,y,z)]["shown"] = False
			else:
				tempDict[(x,y,z)]["shown"] = True
		
		dictHandlerList = []
		renderList = []
		blockMemoryCheckList = []
		
		#iterates through tempDict
		for item in tempDict:
			x,y,z = item
			blockList = [[x,y,z+1],[x,y,z-1],[x-1,y,z],[x+1,y,z],[x,y-1,z],[x,y+1,z]]
			blockNameList = ["top","bottom","front","back","right","left"]
			oppositeNameList = ["bottom","top","back","front","left","right"]
			checkArea = 0
			nameCount = 0
			
			#iterates through shown blocks in tempDict to see if they need to be displayed using the blockMemoryHandler
			if tempDict[item]["shown"] == True:
				for block in blockList:
					if self.blockMemoryHandler("exist",*block) == True:
						if not blockNameList[nameCount] in tempDict[item]['adjacent']:
							tempDict[item]['adjacent'].append(blockNameList[nameCount])
							if not oppositeNameList[nameCount] in self.blockMemoryHandler("get",*block,"adjacent"):
								dictHandlerList.append(["append",*block,"adjacent",oppositeNameList[nameCount]])
							blockMemoryCheckList.append(tuple(block))
					nameCount +=1
				if len(tempDict[item]['adjacent']) >= 6:
					dictHandlerList.append(["set",x,y,z,"shown",False])
				else:
					renderList.append([x,y,z])
		
				
			else:
				dictHandlerList.append(["set",x,y,z,"shown",False])
			
			dictHandlerList.append(["set",x,y,z,"adjacent",tempDict[item]["adjacent"]])
			dictHandlerList.append(["set",x,y,z,"object",tempDict[item]["object"]])
		
	   
		#sets blockMemory items
		for item in dictHandlerList:
			self.blockMemoryHandler(*item)
			
		#checks blocks in blockMemory to see if they need to be displayed
		for item in blockMemoryCheckList:
			if len(self.blockMemoryHandler("get",*item,"adjacent")) >= 6:
				dictHandlerList.append(["set",*item,"object",None])
				self.get_node("Instancer").delete(item[0],item[1],item[2])
				#self.blockMemoryHandler("get",*item,"object").free()
				self.blockMemoryHandler("set",*item,"object",None)
				self.blockMemoryHandler("set",*item,"shown",False)
		
		#render displayed blocks
		for item in renderList:
			self.render(*item)
			
	def blockMemoryHandler(self,option,x,y,z,key=None,value=None):
		#the chunks the blockMemory Dictionary are separated into
		x1 = (int(math.floor(x/128)))
		x2 = (int(math.floor(x/8)))
		y1 = (int(math.ceil(y/128)))
		y2 = (int(math.ceil(y/8)))
		
		#the varius options the function uses
		if option == "append":
			if not (x1,y1) in self.blockMemory.keys():
				self.blockMemory[(x1,y1)] = {}
			if not (x2,y2) in self.blockMemory[(x1,y1)].keys():
				self.blockMemory[(x1,y1)][(x2,y2)] = {} 
			if not (x,y,z) in self.blockMemory[(x1,y1)][(x2,y2)].keys():
				self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)] = {}	
			self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)][key].append(value)
		
		if option == "remove":
			if not (x1,y1) in self.blockMemory.keys():
				self.blockMemory[(x1,y1)] = {}
			if not (x2,y2) in self.blockMemory[(x1,y1)].keys():
				self.blockMemory[(x1,y1)][(x2,y2)] = {}	 
			if not (x,y,z) in self.blockMemory[(x1,y1)][(x2,y2)].keys():
				self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)] = {}	
			self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)][key].remove(value)
		
		
		if option == "get":
			if (x1,y1) in self.blockMemory.keys():
				if (x2,y2) in self.blockMemory[(x1,y1)].keys():
					if (x,y,z) in self.blockMemory[(x1,y1)][(x2,y2)].keys():
						if key in self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)]:
							return self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)][key]
						else:
							return None
					else:
						return None
				else:
					return None
			else:
				return None
		
		if option == "delete":
			del self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)]
		
		if option == "set":
	
			if not (x1,y1) in self.blockMemory.keys():
				self.blockMemory[(x1,y1)] = {}
			if not (x2,y2) in self.blockMemory[(x1,y1)].keys():
				self.blockMemory[(x1,y1)][(x2,y2)] = {}  
			if not (x,y,z) in self.blockMemory[(x1,y1)][(x2,y2)].keys():
				self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)] = {}	   
			self.blockMemory[(x1,y1)][(x2,y2)][(x,y,z)][key] = value  
			
		if option == "exist":
			if (x1,y1) in self.blockMemory.keys():
				if (x2,y2) in self.blockMemory[(x1,y1)].keys():
					if (x,y,z) in self.blockMemory[(x1,y1)][(x2,y2)].keys():
						return True
					else:
						return False
				else:
					return False
			else:
				return False
