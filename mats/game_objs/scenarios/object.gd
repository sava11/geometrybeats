class_name InfoObject
extends CheckpointObject
@export var pre_time:=0.0
func can(gtime:float,max_time:float)->int:
	var loops:=0
	loops=(played-played%times.size())/times.size()
	for e in range(times.size()):
		if (gtime>=loops*max_time+times[played%times.size()]-pre_time):
			played+=1
			return loops
	return -1
