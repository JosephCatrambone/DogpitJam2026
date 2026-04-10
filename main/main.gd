extends Node

var active_scene: Node

func _ready() -> void:
	SceneManager.swap_scenes("res://menus/Title.tscn")
