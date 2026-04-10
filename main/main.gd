extends Node

var active_scene: Node

func _ready() -> void:
	self.init_scene(null)
	self.start_scene.call_deferred()

func init_scene(data: Variant = null):
	pass

func start_scene():
	SceneManager.swap_scenes("res://menus/title/title.tscn") #, null, LoadingScreen.SceneTransitionTypes.FADE_TO_BLACK, $SubViewport)
