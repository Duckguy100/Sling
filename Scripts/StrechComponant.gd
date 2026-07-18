extends Node2D
class_name StrechComponant

@export var Sprite := Node # Parent Sprite
@export var Collision := Node2D # Parent Sprite

var Parent # Parent

func _ready() -> void:
	Parent = get_parent() # Sets Parent, Has to be set in _ready or It will not find the parent

func SpriteAnimation():

	if not Parent.is_on_floor() and not Parent.IsCrouching and not Parent.IsFastFalling: # Stretch when Jumping
		Sprite.scale.x = scale.x - (-(Parent.velocity.y * 0.0007))
		Sprite.scale.y = scale.y + (-(Parent.velocity.y * 0.0007))
	elif Parent.IsFastFalling: # Streches the Parent when fast falling so the Parent won't get squshed to much
		Sprite.scale.x = scale.x - (-(Parent.velocity.y * 0.0004))
		Sprite.scale.y = scale.y + (-(Parent.velocity.y * 0.0004))
	elif Parent.IsCrouching: # Squash when Crouching
		Sprite.scale.y = lerp(Sprite.scale.y, 0.5, 0.2)
		Collision.scale.y = lerp(Collision.scale.y, 0.5, 0.2)
	else: # Makes the parent Go back to their original size
		Sprite.scale.y = lerp(Sprite.scale.y, 1.0, 0.2) 
		Sprite.scale.x = lerp(Sprite.scale.x, 1.0, 0.2) 
		Collision.scale.y = lerp(Collision.scale.y, 1.0, 0.2)
		
	if Sprite.scale.y < 0.1:
		Sprite.scale.y = 0.1

func Recoil(): # Recoil for various things
	Sprite.scale.y -= (Sprite.scale.y / 2)
	Sprite.scale.x += (Sprite.scale.x / 2)
