class_name GridSummon
extends Node2D

@export var add_to: NodePath
@export var spawn: bool = false
@export var shout_time: float = 0.2
@export var noise:FastNoiseLite
@export var grid_size: Vector2 = Vector2(1280, 720)
@export_range(1, 99, 1, "or_greater") var rows: int = 10
@export_range(1, 99, 1, "or_greater") var columns: int = 10
@export_range(0.001, 99, 0.001, "or_greater") var seed_change_interval:=1.0
@export var curve: Curve
@export_range(0.001, 99, 0.001, "or_greater") var deletion_timer: float = 1.5


var _time_acc: float = 0.0
var _change_seed_time_acc: float = 0.0

var offset:= Vector2(8, 8)
var grid:Vector2
var total_offset:Vector2
var cell_size:Vector2

func _ready() -> void:
	var offset = Vector2(8, 8)
	var grid = Vector2(rows, columns)
	# учитываем отступы по периметру: (rows + 1) * offset
	var total_offset = offset * (grid + Vector2.ONE)
	# размер одной ячейки
	var cell_size = (grid_size - total_offset) / grid

func _physics_process(delta: float) -> void:
	if _change_seed_time_acc>=seed_change_interval:
		noise.seed+=1
	if add_to!=null and spawn and _time_acc>=shout_time:
		# Сразу сбросим флаг и таймер
		_time_acc = 0.0
	
		# Выбираем случайную ячейку
		var ix = fnc.rnd.randi_range(0, rows - 1)
		var iy = fnc.rnd.randi_range(0, columns - 1)
		var cell_idx = Vector2(ix, iy)
		if noise.get_noise_2dv(cell_idx)+1>=1:
			_create_cell(cell_idx)
	_time_acc += delta
	_change_seed_time_acc += delta

func summon_pattern(pattern: Array):
	# 1) Вычисляем границы паттерна
	var xs = pattern.map(func(p): return p.x)
	var ys = pattern.map(func(p): return p.y)
	var min_x = xs.min(); var max_x = xs.max()
	var min_y = ys.min(); var max_y = ys.max()
	var pat_w = max_x - min_x + 1
	var pat_h = max_y - min_y + 1

	var ori_x = fnc.rnd.randi_range(0, rows - pat_w)
	var ori_y = fnc.rnd.randi_range(0, columns - pat_h)
	var origin = Vector2(ori_x, ori_y)

	# 3) Спавним ячейки
	for cell in pattern:
		var idx = origin + cell  # индекс в сетке
		_create_cell(idx)


func _create_cell(cell_idx: Vector2):
	# Расчёты для сетки (offset, размер клетки)
	var offset = Vector2(8, 8)
	var grid   = Vector2(rows, columns)
	var total_offset = offset * (grid + Vector2.ONE)
	var cell_size = (grid_size - total_offset) / grid

	# Настройка HitBox и формы
	var scn = HitBox.new()
	scn.oneshout = true
	scn.collision_layer = 8
	scn.curve = curve
	scn.deletion_timer = deletion_timer

	var col = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = cell_size  # размер вокселя :contentReference[oaicite:6]{index=6}
	col.shape = rect
	scn.add_child(col)

	# Позиционирование по глобальным координатам:
	scn.global_position = global_position \
		+ offset \
		+ (cell_size + offset) * cell_idx \
		+ cell_size * 0.5

	get_node(add_to).add_child(scn)
