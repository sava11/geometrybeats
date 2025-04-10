class_name CheckpointObject
extends Resource
@export var times:Array[float]
var played:=0
func can(gtime:float,max_time:float)->int:
	var loops:=0
	loops=(played-played%times.size())/times.size()
	for e in range(times.size()):
		if (gtime>=loops*max_time+times[played%times.size()]):
			played+=1
			return loops
	return -1
func reset_to(time:float,max_time:float):
	played=0
	var loops:=0
	loops=(played-played%times.size())/times.size()
	for e in range(times.size()):
		if (time>=loops*max_time+times[played%times.size()]):
			played+=1
	#print("reseted to: %d"%[played])
