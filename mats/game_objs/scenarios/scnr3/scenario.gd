extends Scenario
var right:=true
@onready var smnrc:=$act/snr_container
var saved_right:=true
var saved_smnrc_pos:Vector2
var saved_smnrc_rot_deg:=0
func _post_ready():
	saved_smnrc_pos=smnrc.global_position
func _post_physics_process(delta: float):
	if asp.is_playing():
		if int(smnrc.global_position.x)==int(get_size().x*int(right)):
			right=!right
		smnrc.global_position=smnrc.global_position.move_toward(
			Vector2(get_size().x*int(right),smnrc.global_position.y),200*delta)
		smnrc.rotation_degrees+=180*delta
	pass
func _action_activated(track:int,time:float):
	pass
	#if track==0:
		#var smn:Summoner=$act/Summoner
		#var pl=get_parent().get_node("player")
		#if pl!=null:
			#pl.globlal_position
		#else:
			#var glb_ang:=smn.angle+smn.global_rotation_degrees
			#var start_point:=smn.global_position+Vector2(
				#cos(deg_to_rad(glb_ang)),sin(deg_to_rad(glb_ang)))*smn.line_size/(1+int(smn.centered))
			#var end_point:=smn.global_position+Vector2(
				#cos(deg_to_rad(glb_ang-180)),sin(deg_to_rad(glb_ang-180)))*smn.line_size/(1+int(smn.centered))
		#var t=[[Vector2(0,0),0],[Vector2(1,1),-180],[Vector2(1,0),-180],[Vector2(0,1),0]]
		#step=(step+1+fnc._with_chance_ulti([0.8,0.2]))%t.size()
		#var p=t[step]
		#
		#smn.global_position=p[0]*get_size()#get_rand_pos()
		#if p[0].y==0:
			#smn.global_position.y+=smn.line_size/2
		#if p[0].y==1:
			#smn.global_position.y-=smn.line_size/2
		#smn.rotation_degrees=p[1]
			#smn.rotation_degrees
		
		#smn.spawn=true
func _level_ended(node:Scenario):pass


func _on_save_checkpoint_reached(id: int) -> void:
	saved_smnrc_pos=smnrc.global_position
	saved_smnrc_rot_deg=smnrc.global_rotation_degrees
	saved_right=right

func return_saved_data():
	right=saved_right
	smnrc.global_position=saved_smnrc_pos
	smnrc.global_rotation_degrees=saved_smnrc_rot_deg
