extends Control

@onready var main_menu: Control = %MainMenu
@onready var credits_menu: Control = %CreditsMenu
@onready var settings_menu: Control = %SettingsMenu

@onready var back_button: Button = %BackButton

@onready var new_game: Button = %NewGame
@onready var settings: Button = %Settings
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit

func _ready() -> void:
	self.new_game.pressed.connect(func(): SceneManager.swap_scenes("res://cutscene/cutscene.tscn", {"sequence": "res://cutscene/scene_10_intro_sequence.json", "start_dialog": "start"}))
	self.settings.pressed.connect(self._show_node.bind(self.settings_menu))
	self.credits.pressed.connect(self._show_node.bind(self.credits_menu))
	self.quit.pressed.connect(func(): get_tree().quit())
	self.back_button.pressed.connect(self._show_node.bind(self.main_menu))
	
	self._show_node(self.main_menu)


func _show_node(node: Control):
	self.main_menu.visible = false
	self.credits_menu.visible = false
	self.settings_menu.visible = false
	
	node.visible = true
	self.back_button.visible = node != self.main_menu
