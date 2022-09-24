tool
extends EditorPlugin

var tool_window := preload("res://addons/auto-obs-recorder/auto-obs-recorder.tscn").instance()


func _enter_tree() -> void:
	add_control_to_bottom_panel(tool_window, "Auto OBS Recorder")
	check_if_exists()


func _exit_tree() -> void:
	if tool_window.stop_when_exit:
		tool_window.obs_websocket.send_command("StopRecord")
	remove_control_from_bottom_panel(tool_window)

func check_if_exists():
	var save_file = File.new()
	if save_file.file_exists("res://addons/auto-obs-recorder/OBSdata.ryash"):
		save_file.open("res://addons/auto-obs-recorder/OBSdata.ryash", File.READ)
		var data = str2var(save_file.get_as_text())
		tool_window.port = data.port
		tool_window.password = data.password
		tool_window.server = data.server
		tool_window.stop_when_exit = data.stop_when_exit
		tool_window.exectuable_path = data.exectuable_path
		tool_window.folder_path = data.folder_path
		print("OBS Plugin Data loaded successfully!")
	else:
		print("No OBS Plugin Data Found! Consider making one for ease of use")
