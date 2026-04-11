extends Node

func _ready() -> void:
	self._switch_to_title.call_deferred()
	
func _switch_to_title():
	SceneManager.swap_scenes("res://menus/title/title.tscn")
