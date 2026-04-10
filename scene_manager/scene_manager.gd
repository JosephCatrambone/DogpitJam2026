extends Node

# Much of this code is inspired by https://baconandgames.itch.io/scene-manager-source-code
# Liberties have been taken in the adaptation, so assume any errors are my own.

# We will call init_scene() after it's added as a child and start_scene before the fade is done.

signal load_start()
signal scene_created(loaded_scene: Node, loading_screen_ref: LoadingScreen)  # Emitted after the new scene is created but before the load screen disappears or the fade happens.
signal load_finished(loaded_scene: Node)  # Called after the scene is finished loading and after it's added as a child, but before the transition is finished.
signal load_failed(content_path: String)

var _loading_screen: LoadingScreen
var _loading_screen_packed: PackedScene = preload("res://scene_manager/LoadingScreen.tscn")
var _loading_in_progress: bool = false  # True when a scene is being loaded.
var _load_progress_timer: Timer  # This will be disconnected and cleared when our new scene loads.
var _previously_loaded_scene: Node

class SceneLoadOperation:
	var scene_to_load: String
	var data_for_new_scene
	var new_scene_parent: Node
	var scene_to_unload: Node

func swap_scenes(
		scene_to_load: String, 
		data_for_new_scene: Variant = null, 
		transition_type: LoadingScreen.SceneTransitionTypes = LoadingScreen.SceneTransitionTypes.FADE_TO_BLACK, 
		load_into: Node = null, 
		scene_to_unload: Node = null, 
		unload_previous: bool = false,
) -> void:
	if self._loading_in_progress:
		printerr("Scene swap triggered during a different scene swap!")
		return
	
	self._loading_in_progress = true
	
	var load_op: SceneLoadOperation = SceneLoadOperation.new()
	load_op.scene_to_load = scene_to_load
	load_op.data_for_new_scene = data_for_new_scene
	load_op.new_scene_parent = load_into
	if load_into == null:
		load_op.new_scene_parent = get_tree().root  # Do we want to do the root?
	if unload_previous:
		load_op.scene_to_unload = self._previously_loaded_scene
	
	_add_loading_screen(transition_type)
	_load_content(load_op)

func _add_loading_screen(transition_type: LoadingScreen.SceneTransitionTypes):
	self._loading_screen = self._loading_screen_packed.instantiate() as LoadingScreen
	get_tree().root.add_child(_loading_screen)
	self._loading_screen.start_transition(transition_type)

func _load_content(load_op: SceneLoadOperation):
	self.load_start.emit()  # Do we want to do this _before_ we load the loading screen?
	
	#_content_path = content_path
	var loader = ResourceLoader.load_threaded_request(load_op.content_path)
	if not ResourceLoader.exists(load_op.content_path) or loader == null:
		printerr("Failed to load new scene!")
		self.load_failed.emit(load_op.content_path)
		return
	
	self._load_progress_timer = Timer.new()
	self._load_progress_timer.wait_time = 0.1
	self._load_progress_timer.timeout.connect(self._update_load_status.bind(load_op))
	
	get_tree().root.add_child(self._load_progress_timer)
	self._load_progress_timer.start()

func _delete_load_progress_timer():
	self._load_progress_timer.stop()
	self._load_progress_timer.queue_free()
	self._load_progress_timer.timeout.disconnect(self._update_load_status)
	self._load_progress_timer = null

## Called at 0.1 second intervals to update our progress bars and check status.
func _update_load_status(load_op: SceneLoadOperation):
	var load_progress: Array = []
	var load_status = ResourceLoader.load_threaded_get_status(load_op.content_path, load_progress)

	match load_status:
		ResourceLoader.THREAD_LOAD_INVALID_RESOURCE:
			self.load_failed.emit(load_op.content_path)
			self._delete_load_progress_timer()
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			if _loading_screen != null:
				_loading_screen.update_bar(load_progress[0] * 100)
		ResourceLoader.THREAD_LOAD_FAILED:
			self.load_failed.emit(load_op.content_path)
			self._delete_load_progress_timer()
		ResourceLoader.THREAD_LOAD_LOADED:
			self._delete_load_progress_timer()
			var new_scene_instance = ResourceLoader.load_threaded_get(load_op.content_path).instantiate()
			self._finish_loading(new_scene_instance, load_op)

func _finish_loading(new_scene_instance, load_op: SceneLoadOperation):
	self._previously_loaded_scene = new_scene_instance
	load_op.new_scene_parent.add_child(new_scene_instance)
	
	if new_scene_instance.has_method("init_scene"):
		new_scene_instance.init_scene(load_op.data_for_new_scene)
	
	if is_instance_valid(load_op.scene_to_unload):
		load_op.scene_to_unload.queue_free()
		
	if is_instance_valid(self._loading_screen):
		self._loading_screen.end_transition()
	
	if new_scene_instance.has_method("start_scene"): 
		new_scene_instance.start_scene()
	
	self.load_finished.emit(new_scene_instance)
