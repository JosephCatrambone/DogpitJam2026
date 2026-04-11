extends Control

@onready var new_game: Button = %NewGame
@onready var settings: Button = %Settings
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit

func _ready() -> void:
	self.new_game.pressed.connect(func(): SceneManager.swap_scenes("res://game/game.tscn"))
	self.settings.pressed.connect(func(): SceneManager.swap_scenes("res://menus/settings/settings.tscn"))
	self.quit.pressed.connect(func(): get_tree().quit())
