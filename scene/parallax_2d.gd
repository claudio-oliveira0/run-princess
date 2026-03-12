extends Parallax2D


@export var speed := 7.0

func _process(delta):
	scroll_offset.x += speed * delta
