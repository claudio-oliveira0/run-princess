extends StaticBody2D

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

@export var cracked_texture: Texture2D
@export var broken_texture: Texture2D
@export var break_delay := 0.3

var is_breaking := false


func _on_area_2d_body_entered(body: Node2D) -> void:
	if is_breaking:
		return

	if body.name == "Player":
		break_stone()


func break_stone() -> void:
	is_breaking = true
	sprite.texture = broken_texture

	await get_tree().create_timer(break_delay).timeout

	collision.disabled = true
	visible = false
