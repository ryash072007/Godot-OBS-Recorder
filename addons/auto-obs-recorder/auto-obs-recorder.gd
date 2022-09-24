tool
extends Control

const ObsWebsocket: GDScript = preload("res://addons/obs-websocket-gd/obs_websocket.gd")

var obs_websocket: Node

var port = 4455
var server = "127.0.0.1"
var password = "Change to password"
var stop_when_exit = true
var obs_path = null
var exectuable_path: String
var folder_path: String

var save_file_used = false

var mode = "NOT_RECORDING"

var mode_type := {
	"NOT_RECORDING" : "NOT_RECORDING",
	"RECORDING" : "RECORDING",
	"PAUSED_RECORDING" : "PAUSED_RECORDING"
	
}

func start_recording():
	if obs_websocket == null:
		print("OBS either not connected or open!")
		return
	if obs_websocket.obs_client.get_connection_status() != WebSocketClient.CONNECTION_CONNECTED: return
	obs_websocket.send_command("StartRecord")
	mode = mode_type.RECORDING
	$VBoxContainer/HBoxContainer/statusVar.text = mode
	
func stop_recording():
	if obs_websocket == null:
		print("OBS either not connected or open!")
		return
	if obs_websocket.obs_client.get_connection_status() != WebSocketClient.CONNECTION_CONNECTED: return
	obs_websocket.send_command("StopRecord")
	mode = mode_type.NOT_RECORDING
	$VBoxContainer/HBoxContainer/statusVar.text = mode

func pause_recording():
	if obs_websocket == null:
		print("OBS either not connected or open!")
		return
	if obs_websocket.obs_client.get_connection_status() != WebSocketClient.CONNECTION_CONNECTED: return
	obs_websocket.send_command("PauseRecord")
	mode = mode_type.PAUSED_RECORDING
	$VBoxContainer/HBoxContainer/statusVar.text = mode

func _on_portEdit_text_changed(new_text: String) -> void:
	port = int(new_text)

func _on_serverEdit_text_changed(new_text: String) -> void:
	server = new_text

func _on_passwordEdit_text_changed(new_text: String) -> void:
	password = new_text

func _on_obsSelectorEnabler_pressed() -> void:
	$"VBoxContainer/Container/OBS path/obsPathSelector".popup_centered(Vector2(1000, 600))

func _on_obsConnect_pressed() -> void:
	var file = File.new()
	if file.file_exists("res://addons/auto-obs-recorder/obs_opener.bat") == false:
		print("Please create obs_opener.bat by filling the neccessary details and pressing the save button!")
		return
	print("Attempting to connect...")
	OS.shell_open(ProjectSettings.globalize_path("res://addons/auto-obs-recorder/obs_opener.bat"))
	obs_websocket = ObsWebsocket.new()
	obs_websocket.port = port
	obs_websocket.password = password
	$delay_obs.start()

func _on_delay_obs_timeout() -> void:
	add_child(obs_websocket)

	obs_websocket.connect("obs_data_received", self, "_on_obs_data_received")

	obs_websocket.establish_connection()

	yield(obs_websocket, "obs_authenticated")

func _on_obs_data_received(data):
	var actual_data = data.get_as_json()
	print(actual_data)

func _on_saveDataBtn_pressed() -> void:
	var save_file := File.new()
	save_file.open("res://addons/auto-obs-recorder/OBSdata.ryash", File.WRITE)
	var data = {
		"port": port,
		"password": password,
		"server": server,
		"stop_when_exit": stop_when_exit,
		"exectuable_path": exectuable_path,
		"folder_path": folder_path
	}
	save_file.store_string(var2str(data))
	save_file.close()
	print("saved")

func _on_obsPathSelector_file_selected(path: String) -> void:
	var newPath = path.replace("/", "\\")
	folder_path = newPath.substr(0, newPath.find_last("\\"))
#	print(folder_path)
	exectuable_path = newPath.substr(newPath.find_last("\\") + 1, -1)
#	print(exectuable_path)
	var obs_opener = File.new()
	obs_opener.open("res://addons/auto-obs-recorder/obs_opener.bat", File.WRITE)
	obs_opener.store_line("cd /d " + folder_path)
	obs_opener.store_line(exectuable_path + " /popup")
	obs_opener.store_line("exit")
	obs_opener.close()


#func add_godot_to_scene():
#	if obs_websocket == null:
#		print("OBS either not connected or open!")
#		return
#	obs_websocket.send_command("CreateScene", {"sceneName": "Godot"})
#	obs_websocket.send_command("CreateSource", {
#		"sourceName": "Godot",
#		"sourceKind": "window_capture",
#		"sceneName": "Godot",
#	})

