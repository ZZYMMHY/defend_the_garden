extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var user_arguments := OS.get_cmdline_user_args()
	var frames_to_wait := 5
	var run_waves := false
	if user_arguments.size() > 1:
		frames_to_wait = maxi(5, int(user_arguments[1]))
		run_waves = true
	var packed_scene := load("res://scenes/game/main.tscn") as PackedScene
	if packed_scene == null:
		push_error("Unable to load the main scene.")
		quit(1)
		return
	var game := packed_scene.instantiate()
	game.test_mode = not run_waves
	root.add_child(game)
	for _frame in frames_to_wait:
		await process_frame
	RenderingServer.force_draw(false)
	await process_frame
	var image: Image = root.get_texture().get_image()
	if image == null or image.is_empty():
		push_error("Viewport capture returned an empty image.")
		quit(1)
		return
	var output_path := "/private/tmp/garden_nightwatch_capture.png"
	if not user_arguments.is_empty():
		output_path = user_arguments[0]
	var save_error := image.save_png(output_path)
	if save_error != OK:
		push_error("Failed to save capture: %s" % error_string(save_error))
		quit(1)
		return
	print("CAPTURE SAVED: %s" % output_path)
	quit(0)
