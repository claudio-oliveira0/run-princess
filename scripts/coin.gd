extends Area2D

@onready var col: CollisionShape2D = $CollisionShape2D
@onready var ray: RayCast2D = $RayCast2D
@onready var coin_sound: AudioStreamPlayer2D = $CoinSound

@export var fall_gravity := 550.0
@export var max_fall_speed := 250.0
@export var pickup_delay := 0.15
@export var pop_velocity := -220.0
@export var ground_offset := 8.0

var vy := 0.0
var grounded := false


func _ready() -> void:
	col.disabled = true
	await get_tree().create_timer(pickup_delay).timeout
	col.disabled = false


func spawn_pop() -> void:
	vy = pop_velocity
	grounded = false


func _physics_process(delta: float) -> void:
	if grounded:
		return

	vy = min(vy + fall_gravity * delta, max_fall_speed)
	global_position.y += vy * delta

	if ray.is_colliding() and vy >= 0.0:
		var target_y := ray.get_collision_point().y - ground_offset

		if global_position.y >= target_y:
			global_position.y = target_y
			vy = 0.0
			grounded = true


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("add_coin"):
		body.add_coin(1)

		coin_sound.play()

		visible = false
		col.set_deferred("disabled", true)
		set_physics_process(false)

		await coin_sound.finished
		call_deferred("queue_free")
