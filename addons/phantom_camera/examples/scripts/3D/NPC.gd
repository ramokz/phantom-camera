extends Node3D

@onready var npc_pcam: PhantomCamera3D = %NPCPhantomCamera3D
@onready var dialogueArea: Area3D = %DialogueArea3D
@onready var dialogueLabel: Label3D = %DialogueExampleLabel

@onready var player: CharacterBody3D = %PlayerCharacterBody3D

var interactable: bool
var is_interacting: bool

func _ready() -> void:
	dialogueArea.connect("area_entered", _interactable)
	dialogueArea.connect("area_exited", _not_interactable)


func _interactable(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		dialogueLabel.set_visible(true)
		interactable = true


func _not_interactable(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		dialogueLabel.set_visible(false)
		interactable = false


func _input(event) -> void:
	if not interactable: return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:
			if not is_interacting:
				npc_pcam.set_priority(20)
				player.set_physics_process(false)
				var tween: Tween = get_tree().create_tween()
				tween.tween_property(player, "position", Vector3(-3.723, 0.5, -0.725), 0.6).set_trans(Tween.TRANS_QUAD)
#				tween.tween_callback()
			else:
				npc_pcam.set_priority(0)
				player.set_physics_process(true)

			is_interacting = !is_interacting
