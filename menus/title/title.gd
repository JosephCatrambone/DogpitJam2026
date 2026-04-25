extends Control

@onready var how_to_play_menu: Control = %HowToPlayMenu
@onready var main_menu: Control = %MainMenu
@onready var game_menu: Control = %GameMenu
@onready var credits_menu: Control = %CreditsMenu
@onready var settings_menu: Control = %SettingsMenu

@onready var back_button: Button = %BackButton

# Main Menu buttons:
@onready var how_to_play: Button = %HowToPlay
@onready var game: Button = %NewGame
@onready var settings: Button = %Settings
@onready var credits: Button = %Credits
@onready var quit: Button = %Quit

# Game Menu buttons:
@onready var story_game: Button = %StoryGame
@onready var human_vs_human: Button = %HumanVsHuman
@onready var human_vs_computer_easy: Button = %HumanVsComputerEasy
@onready var human_vs_computer_medium: Button = %HumanVsComputerMedium
@onready var human_vs_computer_hard: Button = %HumanVsComputerHard

func _ready() -> void:
	# Wire up Main Menu:
	self.how_to_play.pressed.connect(self._show_node.bind(self.how_to_play_menu))
	self.game.pressed.connect(self._show_node.bind(self.game_menu))
	self.settings.pressed.connect(self._show_node.bind(self.settings_menu))
	self.credits.pressed.connect(self._show_node.bind(self.credits_menu))
	self.quit.pressed.connect(func(): get_tree().quit())
	self.back_button.pressed.connect(self._show_node.bind(self.main_menu))
	
	# Wire up game menu:
	self.story_game.pressed.connect(func(): SceneManager.swap_scenes("res://cutscene/cutscene.tscn", {"sequence": "res://cutscene/scene_10_intro_sequence.json", "start_dialog": "start"}))
	self.human_vs_human.pressed.connect(func(): SceneManager.swap_scenes("res://game/game.tscn"))
	self.human_vs_computer_easy.pressed.connect(func(): SceneManager.swap_scenes("res://game/game.tscn", {"ai_difficulty_2": 1}))
	self.human_vs_computer_medium.pressed.connect(func(): SceneManager.swap_scenes("res://game/game.tscn", {"ai_difficulty_2": 2}))
	self.human_vs_computer_hard.pressed.connect(func(): SceneManager.swap_scenes("res://game/game.tscn", {"ai_difficulty_2": 3}))
	
	self._show_node(self.main_menu)


func _show_node(node: Control):
	self.how_to_play_menu.visible = false
	self.main_menu.visible = false
	self.credits_menu.visible = false
	self.game_menu.visible = false
	self.settings_menu.visible = false
	
	node.visible = true
	self.back_button.visible = node != self.main_menu
