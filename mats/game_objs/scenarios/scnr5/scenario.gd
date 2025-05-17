extends Scenario


func _on_action_activated(track: int, time: float) -> void:
	if track==0:
		$act/grid_summon.spawn=true
	if track==1:
		var patterns := [
			# 1) Вертикальная линия (длина 6)
			[
				Vector2(0,0), Vector2(0,1), Vector2(0,2),
				Vector2(0,3), Vector2(0,4), Vector2(0,5)
			],

			# 2) Горизонтальная линия (длина 6)
			[
				Vector2(0,0), Vector2(1,0), Vector2(2,0),
				Vector2(3,0), Vector2(4,0), Vector2(5,0)
			],

			# 3) Квадрат 2×2
			[
				Vector2(0,0), Vector2(1,0),
				Vector2(0,1), Vector2(1,1)
			],

			# 4) «Г»-образная (угол) форма 3×3
			[
				Vector2(0,0), Vector2(0,1), Vector2(0,2),
				Vector2(1,0), Vector2(2,0)
			],

			# 5) «Т»-образная (центр + три внизу)
			[
				Vector2(1,0),
				Vector2(0,1), Vector2(1,1), Vector2(2,1)
			],

			# 6) Крест (плюс)
			[
				Vector2(1,0),
				Vector2(0,1), Vector2(1,1), Vector2(2,1),
				Vector2(1,2)
			],

			# 7) Зигзаг (S-образная)
			[
				Vector2(1,0), Vector2(2,0),
				Vector2(0,1), Vector2(1,1)
			],

			# 8) Диагональ 4
			[
				Vector2(0,0), Vector2(1,1),
				Vector2(2,2), Vector2(3,3)
			],

			# 9) «L» длиннее (4 по вертикали + 2 вправо внизу)
			[
				Vector2(0,0), Vector2(0,1), Vector2(0,2), Vector2(0,3),
				Vector2(1,3), Vector2(2,3)
			],

			# 10) П-образная рамка 3×3
			[
				Vector2(0,0), Vector2(1,0), Vector2(2,0),
				Vector2(0,1),				Vector2(2,1),
				Vector2(0,2), Vector2(1,2), Vector2(2,2)
			]
		]
		var cur_pattern=patterns[fnc.rnd.randi_range(0,patterns.size()-1)]
		$act/grid_summon.summon_pattern(cur_pattern)
	if track==2:
		$act/PreSpawner.global_position = get_rand_pos()
		$act/PreSpawner.spawn=true
	if track==3:
		$act/SideSpawner.create_hit_box()


func _on_track_started() -> void:
	pass
