class_name GardenHUD
extends Control

var dave_bar: ProgressBar
var core_bar: ProgressBar
var wave_label: Label
var state_label: Label
var enemy_label: Label
var sun_label: Label
var dash_label: Label
var message_panel: PanelContainer
var message_title: Label
var message_subtitle: Label
var _wave_pips: Array[ColorRect] = []


func _ready() -> void:
	name = "HUD"
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_build_hud()


func set_dave_health(current: float, maximum: float) -> void:
	dave_bar.max_value = maximum
	dave_bar.value = current


func set_core_health(current: float, maximum: float) -> void:
	core_bar.max_value = maximum
	core_bar.value = current


func set_wave(index: int, total: int) -> void:
	wave_label.text = "WAVE %d / %d" % [index, total]
	for pip_index in _wave_pips.size():
		_wave_pips[pip_index].color = (
			Color("#f7c95d") if pip_index < index else Color("#53666c")
		)


func set_state(text: String) -> void:
	state_label.text = text


func set_countdown(seconds: int) -> void:
	if seconds > 0:
		state_label.text = "WAVE IN %d" % seconds


func set_enemy_count(count: int) -> void:
	enemy_label.text = "ZOMBIES  %02d" % count


func set_sun(amount: int) -> void:
	sun_label.text = "SUN  %03d" % amount


func set_dash_available(available: bool) -> void:
	dash_label.text = "DASH READY" if available else "DASH CHARGING"
	dash_label.modulate = Color("#bff7ff") if available else Color("#7f9098")


func show_intro() -> void:
	message_panel.visible = true
	message_title.text = "PROTECT THE LAST GARDEN"
	message_subtitle.text = "WASD  MOVE     MOUSE  AIM + FIRE     SPACE  DASH"
	var tween := create_tween()
	tween.tween_interval(4.2)
	tween.tween_property(message_panel, "modulate:a", 0.0, 0.7)
	tween.tween_callback(func() -> void:
		message_panel.visible = false
		message_panel.modulate.a = 1.0
	)


func show_game_over(victory: bool) -> void:
	message_panel.visible = true
	message_panel.modulate.a = 1.0
	message_title.text = "GARDEN SAVED" if victory else "THE GARDEN HAS FALLEN"
	message_title.modulate = Color("#fff0a6") if victory else Color("#ff9b86")
	message_subtitle.text = "PRESS  R  TO START A NEW RUN"


func _build_hud() -> void:
	var top_left := VBoxContainer.new()
	top_left.position = Vector2(28.0, 24.0)
	top_left.size = Vector2(300.0, 108.0)
	top_left.add_theme_constant_override("separation", 6)
	add_child(top_left)

	var dave_row := _make_bar_row("DAVE", Color("#62d686"))
	dave_bar = dave_row["bar"]
	top_left.add_child(dave_row["root"])
	var core_row := _make_bar_row("GARDEN", Color("#f2c45c"))
	core_bar = core_row["bar"]
	top_left.add_child(core_row["root"])

	dash_label = Label.new()
	dash_label.text = "DASH READY"
	dash_label.add_theme_font_size_override("font_size", 13)
	dash_label.modulate = Color("#bff7ff")
	top_left.add_child(dash_label)

	var top_center := VBoxContainer.new()
	top_center.set_anchors_preset(Control.PRESET_CENTER_TOP)
	top_center.position = Vector2(-170.0, 20.0)
	top_center.size = Vector2(340.0, 90.0)
	top_center.alignment = BoxContainer.ALIGNMENT_CENTER
	add_child(top_center)

	wave_label = Label.new()
	wave_label.text = "WAVE 0 / 3"
	wave_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wave_label.add_theme_font_size_override("font_size", 17)
	wave_label.modulate = Color("#ecf7e8")
	top_center.add_child(wave_label)

	var pip_row := HBoxContainer.new()
	pip_row.alignment = BoxContainer.ALIGNMENT_CENTER
	pip_row.add_theme_constant_override("separation", 12)
	top_center.add_child(pip_row)
	for pip_index in 3:
		var pip := ColorRect.new()
		pip.custom_minimum_size = Vector2(72.0, 6.0)
		pip.color = Color("#53666c")
		pip_row.add_child(pip)
		_wave_pips.append(pip)

	state_label = Label.new()
	state_label.text = "PREPARE"
	state_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	state_label.add_theme_font_size_override("font_size", 13)
	state_label.modulate = Color("#a9bbc0")
	top_center.add_child(state_label)

	var top_right := VBoxContainer.new()
	top_right.set_anchors_preset(Control.PRESET_TOP_RIGHT)
	top_right.position = Vector2(-224.0, 24.0)
	top_right.size = Vector2(196.0, 70.0)
	top_right.alignment = BoxContainer.ALIGNMENT_END
	add_child(top_right)

	sun_label = Label.new()
	sun_label.text = "SUN  000"
	sun_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	sun_label.add_theme_font_size_override("font_size", 20)
	sun_label.modulate = Color("#ffe277")
	top_right.add_child(sun_label)

	enemy_label = Label.new()
	enemy_label.text = "ZOMBIES  00"
	enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	enemy_label.add_theme_font_size_override("font_size", 14)
	enemy_label.modulate = Color("#c5d4d4")
	top_right.add_child(enemy_label)

	var controls := Label.new()
	controls.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	controls.position = Vector2(28.0, -54.0)
	controls.text = "WASD  MOVE     LMB  PEA BLASTER     SPACE  DASH     R  RESTART"
	controls.add_theme_font_size_override("font_size", 13)
	controls.modulate = Color(0.8, 0.88, 0.86, 0.84)
	add_child(controls)

	message_panel = PanelContainer.new()
	message_panel.set_anchors_preset(Control.PRESET_CENTER)
	message_panel.position = Vector2(-330.0, -76.0)
	message_panel.size = Vector2(660.0, 152.0)
	message_panel.add_theme_stylebox_override("panel", _make_panel_style())
	add_child(message_panel)

	var message_column := VBoxContainer.new()
	message_column.alignment = BoxContainer.ALIGNMENT_CENTER
	message_column.add_theme_constant_override("separation", 12)
	message_panel.add_child(message_column)

	message_title = Label.new()
	message_title.text = "PROTECT THE LAST GARDEN"
	message_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_title.add_theme_font_size_override("font_size", 28)
	message_title.modulate = Color("#fff0a6")
	message_column.add_child(message_title)

	message_subtitle = Label.new()
	message_subtitle.text = "WASD  MOVE     MOUSE  AIM + FIRE     SPACE  DASH"
	message_subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message_subtitle.add_theme_font_size_override("font_size", 14)
	message_subtitle.modulate = Color("#d6e2de")
	message_column.add_child(message_subtitle)


func _make_bar_row(label_text: String, fill_color: Color) -> Dictionary:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(300.0, 25.0)
	row.add_theme_constant_override("separation", 10)
	var label := Label.new()
	label.text = label_text
	label.custom_minimum_size = Vector2(68.0, 0.0)
	label.add_theme_font_size_override("font_size", 13)
	label.modulate = Color("#edf5ed")
	row.add_child(label)

	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(212.0, 14.0)
	bar.max_value = 100.0
	bar.value = 100.0
	bar.show_percentage = false
	var background := StyleBoxFlat.new()
	background.bg_color = Color(0.08, 0.12, 0.13, 0.9)
	background.corner_radius_top_left = 5
	background.corner_radius_top_right = 5
	background.corner_radius_bottom_left = 5
	background.corner_radius_bottom_right = 5
	var fill := StyleBoxFlat.new()
	fill.bg_color = fill_color
	fill.corner_radius_top_left = 5
	fill.corner_radius_top_right = 5
	fill.corner_radius_bottom_left = 5
	fill.corner_radius_bottom_right = 5
	bar.add_theme_stylebox_override("background", background)
	bar.add_theme_stylebox_override("fill", fill)
	row.add_child(bar)
	return {"root": row, "bar": bar}


func _make_panel_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.025, 0.055, 0.06, 0.93)
	style.border_color = Color(0.38, 0.61, 0.52, 0.75)
	style.set_border_width_all(2)
	style.set_corner_radius_all(14)
	style.content_margin_left = 28.0
	style.content_margin_right = 28.0
	style.content_margin_top = 22.0
	style.content_margin_bottom = 22.0
	return style
