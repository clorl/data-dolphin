extends Control

@export var color: Color.GREY

func _ready():
	item_rect_changed.connect(_on_rect_changed)

func _on_rect_changed():
	pass

func _draw():
	pass
