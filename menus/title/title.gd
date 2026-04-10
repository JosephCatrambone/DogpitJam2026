extends Control

@onready var new_game: Button = %NewGame
@onready var settings: Button = %Settings
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit

func _ready() -> void:
	self.settings.pressed.connect(func(): SceneManager.swap_scenes("res://menus/settings/settings.tscn"))
