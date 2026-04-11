extends Node

"""
This class bootstraps the main game and switches to title, etc.
"""

var active_scene: Node

var first_load: bool = true

func _ready() -> void:
	self.init_scene(null)
	self.start_scene.call_deferred()

func init_scene(data: Variant = null):
	pass

func start_scene():
	if first_load:
		self.first_load = false
		SceneManager.swap_scenes("res://menus/title/title.tscn") #, null, LoadingScreen.SceneTransitionTypes.FADE_TO_BLACK, $SubViewport)
