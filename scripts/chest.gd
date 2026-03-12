extends StaticBody2D


@export var coin_scene: PackedScene


func break_open() -> void:
	# evita erro de física chamando no próximo frame
	call_deferred("_break_open_deferred")


func _break_open_deferred() -> void:

	if coin_scene != null:
		var coin = coin_scene.instantiate()

		get_parent().add_child(coin)

		# posição da moeda (um pouco acima do baú)
		coin.global_position = global_position + Vector2(0, -10)

		# faz a moeda pular ao nascer
		if coin.has_method("spawn_pop"):
			coin.spawn_pop()

	# remove o baú
	queue_free()
