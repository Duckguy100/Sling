extends CharacterBody2D
class_name Player

const SPEED = 165.0 # Walking speed
const JUMP_VELOCITY = -280.0 # Jump velocity

var Direction = 0 # The direction in which the player is moving
var FacingDirection = false # False is left, True is Right

var NumOfJumps = 1 # The number of Double Jumps a Player has
var MaxNumOfJumps = 1 # The maximum Number of Double Jumps a Player can store

var TempSpeed = 0.0 # Gets added to SPEED when calculating movement, then decays over time

var IsCrouching = false # Checks if the Player is Crouching
var IsFastFalling = false # Checks If the Player is Fast-Falling
var IsOnGround = true # Checks if the player is on ground
var IsGrowing = false # Checks if the player's size is Growing



func _physics_process(delta: float) -> void:
	
	#---Facing Direction---#
	
	# Finds the direction in which the player is facing, a lot of Actions and Processes relay on these so It has to be before those.
	if Direction != 0: 
		FacingDirection = true # Right
		if Direction < 0:
			FacingDirection = false # Left
			
	#---Actions---#
	
	# Handles Jumping, Wall-Jumping and Double jumping
	if Input.is_action_just_pressed("Jump"):
		if NumOfJumps > 0: # Checks if you have any Double jumps avliable
			if not is_on_floor() and not $ObjectDetectorLeft.get_overlapping_bodies().is_empty(): # Checks if there are any Objects To the left of the player
				TempSpeed += 700 # Wall jumping to the left
				velocity.y += -200
			if not is_on_floor() and not $ObjectDetectorRight.get_overlapping_bodies().is_empty(): # Checks if there are any Objects To the right of the player
				TempSpeed += -700 # Wall jumping to the right
				velocity.y += -200
			velocity.y = JUMP_VELOCITY # Normal Jumps if there are no objects to the right or left of the player
			if not is_on_floor() and $CoyoteTimer.is_stopped(): # Consumes a Double jump if they are not on the floor and the coyote timer isn't active 
				NumOfJumps -= 1
					
	 # Handles Crouching
	if Input.is_action_just_pressed("Shift"):
		if not IsCrouching: # Starts a timer in which you can fast fall
			$ChangingTimer.start()
			IsGrowing = true
		IsCrouching = not IsCrouching # Sets Crouching state

	# Handles Fast-Falling
	if Input.is_action_pressed("Down"):
		if velocity.y > 40 and $FastFallingDelayTimer.is_stopped(): # Only runs if the player is off the ground and hasn't fast-falled in 1.2 seconds.
			IsFastFalling = true
			velocity.y += 500
			$FastFallingDelayTimer.start()

	#---Processes---#
	
	# Runs when leaving ground 
	if IsOnGround and not is_on_floor():
		$CoyoteTimer.start()
	
	# Runs when Landing on the ground.
	if not IsOnGround and is_on_floor():
		if IsGrowing and IsCrouching: # Handles Hops
			$CPUParticles2D.emitting = not $CPUParticles2D.emitting
			if FacingDirection: # Right
				TempSpeed += 800
			else: # Left
				TempSpeed -= 800
			velocity.y -= 200
			IsCrouching = false # Stops crouching
		if abs(int(TempSpeed)) == 0 and not IsFastFalling: # Makes the player squsih when hitting the ground
			$StrechComponant.Recoil()


		if IsFastFalling: # Handles Disabling Fast-Fall and KnockBack
			$CPUParticles2D.emitting = not $CPUParticles2D.emitting
			IsFastFalling = false
			velocity.y = JUMP_VELOCITY - 20 # Makes the player Go up after hitting the floor, slightly higher then a normal jump.
			
		NumOfJumps = MaxNumOfJumps # Refills Jumps
	
	# Update IsOnGround
	IsOnGround = is_on_floor()
	
	# Handles squash and strech
	$StrechComponant.SpriteAnimation() 
	
	#---Movement---#
	
	Direction = Input.get_axis("Left", "Right") # Gets Direction
	if not is_on_floor(): # Applies gravity
		velocity += get_gravity() * delta
	velocity.x = Direction * SPEED + TempSpeed # Calculates Movement
	TempSpeed = lerp(TempSpeed, 0.0,0.25 ) # Makes TempSpeed decay
	
	move_and_slide()
	
#---Child-Functions---#

# Time Window in which you can preform a Bunny hop.
func _on_changing_timer_timeout() -> void: 
	IsGrowing = false
