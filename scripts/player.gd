extends CharacterBody2D

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var cam: Camera2D = $Camera2D
@onready var attack_hitbox: Area2D = $AttackHitbox
@onready var attack_sound: AudioStreamPlayer2D = $AttackSound
@onready var jump_sound: AudioStreamPlayer2D = $JumpSound


# HUD
@onready var coins_label: Label = $"../HUD/CoinsLabel"
@onready var timer_label: Label = $"../HUD/TimerLabel"
@onready var best_time_label: Label = $"../HUD/BestTimeLabel"

const ATTACK_ACTIVE_TIME := 0.12

const WALK_SPEED = 80.0
const RUN_SPEED = 140.0
const JUMP_VELOCITY = -300.0
const MAX_LIFE = 3
const FALL_MARGIN := 80.0

var life := MAX_LIFE
var is_attacking := false
var is_dead := false

# moedas
var coins := 0

# timer
var time_elapsed := 0.0
var timer_running := true


func _ready() -> void:
	attack_hitbox.monitoring = false
	update_coin_label()
	update_timer_label()
	update_best_time_label()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	# restart rápido da fase
	if Input.is_action_just_pressed("restart"):
		get_tree().reload_current_scene()
		return

	# cronômetro
	if timer_running:
		time_elapsed += delta
		update_timer_label()

	# Reset ao cair abaixo da tela
	var screen_h := get_viewport_rect().size.y
	var bottom_y := cam.get_screen_center_position().y + (screen_h * 0.5) / cam.zoom.y + FALL_MARGIN
	if global_position.y > bottom_y:
		restart_level()
		return

	# Gravidade
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Pulo
	if Input.is_action_just_pressed("jump") and is_on_floor() and not is_attacking:
		velocity.y = JUMP_VELOCITY
		jump_sound.play()

	# Ataque
	if Input.is_action_just_pressed("attack2") and not is_attacking:
		start_attack("attack_2")

	# Movimento
	var direction := Input.get_axis("left", "right")
	var speed := RUN_SPEED if Input.is_action_pressed("run") else WALK_SPEED

	if not is_attacking:
		if direction != 0:
			velocity.x = direction * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)

	update_animation(direction)
	move_and_slide()


func update_animation(direction: float) -> void:
	if is_dead or is_attacking:
		return

	if not is_on_floor():
		anim.play("jump")
	elif direction != 0:
		anim.flip_h = direction < 0
		if Input.is_action_pressed("run"):
			anim.play("run")
		else:
			anim.play("walk")
	else:
		anim.play("idle")


func start_attack(attack_anim: String) -> void:
	is_attacking = true
	velocity.x = 0

	var dir := -1 if anim.flip_h else 1
	attack_hitbox.position.x = abs(attack_hitbox.position.x) * dir

	anim.play(attack_anim)
	attack_sound.play()

	attack_hitbox.monitoring = true
	await get_tree().process_frame

	for a in attack_hitbox.get_overlapping_areas():
		if a.is_in_group("chest"):
			a.queue_free()

	await get_tree().create_timer(ATTACK_ACTIVE_TIME).timeout
	attack_hitbox.monitoring = false

	await anim.animation_finished
	is_attacking = false


func take_damage(amount: int) -> void:
	if is_dead:
		return

	life -= amount
	if life <= 0:
		die()


func die() -> void:
	is_dead = true
	velocity = Vector2.ZERO
	anim.play("dead")


func restart_level() -> void:
	get_tree().reload_current_scene()


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("chest") and body.has_method("break_open"):
		body.break_open()


# =====================
# MOEDAS
# =====================

func add_coin(amount: int = 1) -> void:
	coins += amount
	update_coin_label()


func update_coin_label() -> void:
	if coins_label:
		coins_label.text = "🪙 %d" % coins


# =====================
# TIMER
# =====================

func update_timer_label() -> void:
	if timer_label:
		var minutes := int(time_elapsed / 60)
		var seconds := int(time_elapsed) % 60
		var milliseconds := int((time_elapsed - int(time_elapsed)) * 100)
		timer_label.text = "⏱ %02d:%02d.%02d" % [minutes, seconds, milliseconds]


func finish_level() -> void:
	timer_running = false

	var best_time := load_best_time()

	# verifica se é novo recorde
	if best_time == -1.0 or time_elapsed < best_time:
		save_best_time()
		timer_label.modulate = Color(0.2, 1, 0.2) # verde
	else:
		timer_label.modulate = Color(1, 1, 1) # branco

	update_best_time_label()
	timer_label.text = "FINISH " + timer_label.text


# =====================
# BEST TIME
# =====================

func save_best_time() -> void:
	var best_time := load_best_time()

	if best_time == -1.0 or time_elapsed < best_time:
		var file := FileAccess.open("user://save_game2.save", FileAccess.WRITE)
		file.store_var(time_elapsed)


func load_best_time() -> float:
	if FileAccess.file_exists("user://save_game2.save"):
		var file := FileAccess.open("user://save_game2.save", FileAccess.READ)
		return file.get_var()

	return -1.0


func update_best_time_label() -> void:
	if best_time_label:
		var best_time := load_best_time()

		if best_time < 0:
			best_time_label.text = "BEST --:--.--"
		else:
			var minutes := int(best_time / 60)
			var seconds := int(best_time) % 60
			var milliseconds := int((best_time - int(best_time)) * 100)
			best_time_label.text = "🏆Recorde %02d:%02d.%02d" % [minutes, seconds, milliseconds]
