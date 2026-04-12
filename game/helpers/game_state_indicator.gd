extends Control

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var popover_label: Label = $PopoverMessage

func _ready() -> void:
	var p: MainGame = self.get_parent()
	p.player_start.connect(self._on_player_start)

func _show_popover_message(msg: String, speed: float = 1.0):
	self.popover_label.text = msg
	self.anim_player.play("ShowPopoverMessage", -1, speed)

func _on_player_start(player_idx: int):
	self._show_popover_message("Player %d Start" % (player_idx+1))

func _on_game_over(player_idx: int):
	self._show_popover_message("GAME OVER\nPLAYER %d LOSES" % (player_idx+1))
