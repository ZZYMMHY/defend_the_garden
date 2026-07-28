class_name WaveDirector
extends Node

signal wave_started(index: int, total: int)
signal countdown_changed(seconds: int)
signal spawn_requested(kind: String, spawn_slot: int)
signal all_waves_cleared
signal state_changed(label: String)

const WAVES := [
	[
		{"kind": "walker", "count": 5},
	],
	[
		{"kind": "walker", "count": 6},
		{"kind": "runner", "count": 3},
	],
	[
		{"kind": "walker", "count": 6},
		{"kind": "runner", "count": 4},
		{"kind": "bruiser", "count": 2},
	],
]

var active := false
var wave_index := -1
var state := "idle"
var _countdown := 0.0
var _spawn_timer := 0.0
var _spawn_queue: Array[String] = []
var _last_countdown_value := -1
var _spawn_serial := 0


func start() -> void:
	if active:
		return
	active = true
	wave_index = -1
	_begin_countdown(3.5)


func stop() -> void:
	active = false
	state = "idle"


func get_wave_count() -> int:
	return WAVES.size()


func get_total_enemy_count() -> int:
	var total := 0
	for wave in WAVES:
		for entry in wave:
			total += int(entry["count"])
	return total


func _process(delta: float) -> void:
	if not active:
		return
	match state:
		"countdown":
			_process_countdown(delta)
		"spawning":
			_process_spawning(delta)
		"clearing":
			if get_tree().get_node_count_in_group("zombies") == 0:
				if wave_index >= WAVES.size() - 1:
					active = false
					state = "complete"
					state_changed.emit("GARDEN SECURED")
					all_waves_cleared.emit()
				else:
					_begin_countdown(4.0)


func _process_countdown(delta: float) -> void:
	_countdown -= delta
	var displayed := maxi(0, ceili(_countdown))
	if displayed != _last_countdown_value:
		_last_countdown_value = displayed
		countdown_changed.emit(displayed)
	if _countdown <= 0.0:
		_start_wave()


func _process_spawning(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer > 0.0:
		return
	if _spawn_queue.is_empty():
		state = "clearing"
		state_changed.emit("CLEAR THE WAVE")
		return
	var kind := String(_spawn_queue.pop_front())
	spawn_requested.emit(kind, _spawn_serial % 4)
	_spawn_serial += 1
	_spawn_timer = 0.72


func _begin_countdown(duration: float) -> void:
	state = "countdown"
	_countdown = duration
	_last_countdown_value = -1
	state_changed.emit("NEXT WAVE")


func _start_wave() -> void:
	wave_index += 1
	_spawn_queue.clear()
	for entry in WAVES[wave_index]:
		for _enemy_index in int(entry["count"]):
			_spawn_queue.append(String(entry["kind"]))
	_spawn_queue.shuffle()
	state = "spawning"
	_spawn_timer = 0.1
	wave_started.emit(wave_index + 1, WAVES.size())
	state_changed.emit("WAVE %d" % (wave_index + 1))
