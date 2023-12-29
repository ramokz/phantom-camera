extends Node3D

@onready var npc_pcam: PhantomCamera3D = %NPCPhantomCamera3D
@onready var dialogueArea: Area3D = %NPCInteractionArea3D
@onready var dialogueLabel3D: Label3D = %NPCDialogueExampleLabel

@onready var player: CharacterBody3D = %PlayerCharacterBody3D

@onready var move_to_location: Vector3 = %MoveToLocation.get_global_position()

var dialogue_label_initial_position: Vector3
var dialogue_label_initial_rotation: Vector3

var tween: Tween
var tween_duration: float = 0.9
var tween_transition: Tween.TransitionType = Tween.TRANS_QUAD

var interactable: bool
var is_interacting: bool

func _ready() -> void:
	dialogueArea.connect("area_entered", _interactable)
	dialogueArea.connect("area_exited", _not_interactable)

	dialogueLabel3D.set_visible(false)

	dialogue_label_initial_position = dialogueLabel3D.get_global_position()
	dialogue_label_initial_rotation = dialogueLabel3D.get_global_rotation()
	
	npc_pcam.became_active.connect(_on_became_active)
	npc_pcam.became_inactive.connect(_on_became_inactive)
	
	npc_pcam.tween_started.connect(_on_tween_started)
	npc_pcam.tween_interrupted.connect(_on_tween_interrupted)
	npc_pcam.is_tweening.connect(_on_is_tweening)
	npc_pcam.tween_completed.connect(_on_tween_completed)

func _on_became_active() -> void:
	print("NPC became active")
	
func _on_became_inactive() -> void:
	print("NPC became inactive")
	
func _on_is_tweening() -> void:
	print("Is tweening")
	
func _on_tween_started() -> void:
	print("NPC Tween started")

func _on_tween_interrupted(pcam: PhantomCamera3D) -> void:
	print("NPC Tween interrupted by: ", pcam)

func _on_tween_completed() -> void:
	print("NPC Tween completed")
	pass

func _interactable(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		dialogueLabel3D.set_visible(true)
		interactable = true

		var tween: Tween = get_tree().create_tween().set_trans(tween_transition).set_ease(Tween.EASE_IN_OUT).set_loops()
		tween.tween_property(dialogueLabel3D, "position", dialogue_label_initial_position - Vector3(0, -0.2, 0), tween_duration)
		tween.tween_property(dialogueLabel3D, "position", dialogue_label_initial_position, tween_duration)


func _not_interactable(area_3D: Area3D) -> void:
	if area_3D.get_parent() is CharacterBody3D:
		dialogueLabel3D.set_visible(false)
		interactable = false


func _input(event) -> void:
	if not interactable: return

	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F:
			var tween: Tween = get_tree().create_tween() \
				.set_parallel(true) \
				.set_trans(Tween.TRANS_QUART) \
				.set_ease(Tween.EASE_IN_OUT)
			if not is_interacting:
				npc_pcam.set_priority(20)
				player.set_physics_process(false)
				tween.tween_property(player, "position", move_to_location, 0.6).set_trans(tween_transition)
				tween.tween_property(dialogueLabel3D, "rotation", Vector3(deg_to_rad(-20), deg_to_rad(53), 0), 0.6).set_trans(tween_transition)

			else:
				npc_pcam.set_priority(0)
				player.set_physics_process(true)
				tween.tween_property(dialogueLabel3D, "rotation", dialogue_label_initial_rotation, 0.9)

			is_interacting = !is_interacting
