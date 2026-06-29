extends Control

func _process(delta: float) -> void:
	$MarginContainer/TextEdit.text = str(get_parent().get_parent().NumOfJumps)
