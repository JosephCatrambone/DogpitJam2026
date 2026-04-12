class_name LoadingScreen extends Control

signal transition_complete

enum SceneTransitionTypes {
	NONE,
	FADE_TO_BLACK,
	FADE_TO_WHITE,
}

const SCENE_TRANSITION_TO_NAME: Dictionary[SceneTransitionTypes, StringName] = {
	SceneTransitionTypes.NONE: "RESET",
	SceneTransitionTypes.FADE_TO_BLACK: "FadeToBlack",
	SceneTransitionTypes.FADE_TO_WHITE: "FadeToBlack",
}

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass

func update_bar(percentage: float):
	pass

func start_transition(transition: SceneTransitionTypes):
	anim_player.play(SCENE_TRANSITION_TO_NAME[transition])
	# Should we track the last transition or rely on anim_player.curent_animation?
	await anim_player.animation_finished
	self.transition_complete.emit()

func end_transition():
	if anim_player.current_animation != null:
		anim_player.play_backwards(anim_player.current_animation)
	else:
		anim_player.play_backwards("FadeToBlack")
	await anim_player.animation_finished
	self.transition_complete.emit()
