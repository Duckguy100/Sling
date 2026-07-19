extends Node2D
class_name EvilComponant

# SPIN SPIN SPIN SPIN SPIN SPINSPIN SPIN SPINSPIN SPIN SPINSPIN SPIN SPIN
@export var Victim := Node

var IsSpinning

func _process(delta: float) -> void:
	if IsSpinning:
		if abs(Victim.skew) >= 89:
			Victim.skew = -(Victim.skew)
		else:
			Victim.skew += 0.03
	else:
		Victim.skew = lerp(Victim.skew, 0.0, 0.05)
			
	if Input.is_action_just_pressed("ui_down"):
		pass
		IsSpinning = not IsSpinning # SPIN SPIN SPIN
		
