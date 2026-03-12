extends Area2D

var finished := false

func _on_body_entered(body: Node2D):

	if finished:
		return

	if body.has_method("finish_level"):
		finished = true
		body.finish_level()
