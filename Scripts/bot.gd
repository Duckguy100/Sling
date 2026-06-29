extends CharacterBody2D

const SPEED = 165.0 # Walking speed
const JUMP_VELOCITY = -280.0 # Jump velocity

var Direction = 0 # The direction in which the player is moving
var FacingDirection = false # False is left, True is Right

var NumOfJumps = 1 # The number of Jumps a Player has
var MaxNumOfJumps = 2 # The maximum Number of Jumps a Player can store

var TempSpeed = 0.0 # Gets added to SPEED

var IsGrowing = false # Checks if the Player is Changing size
var IsCrouching = false # Checks if the Player is Crouching
var IsFastFalling = false # Checks If the Player is Fast-Falling
var IsOnGround = true # Checks if the player is on ground

func _physics_process(delta: float) -> void:
	
	#-#---Facing Direction---#
	if Direction != 0: 
		FacingDirection = true
		if Direction < 0:
			FacingDirection = false
			
	#-#---Actions---#
	if Input.is_action_just_pressed("Jump"): # Handles jumping abd Wall-Jumping
		if NumOfJumps > 0:
			if not is_on_floor() and not $ObjectDetectorLeft.get_overlapping_bodies().is_empty(): # Wall-Jumps
				TempSpeed += 850
				velocity.y += -100
			if not is_on_floor() and not $ObjectDetectorRight.get_overlapping_bodies().is_empty():
				TempSpeed += -850
				velocity.y += -100
			velocity.y = JUMP_VELOCITY # Normall Jumps
			NumOfJumps -= 1
	
	if Input.is_action_just_pressed("Shift"): # Handles Crouching
		IsCrouching = not IsCrouching
 
	if Input.is_action_pressed("Down"): # Handles Fast-Falling
		if velocity.y > 40 and $FastFallingDelayTimer.is_stopped():
			IsFastFalling = true
			velocity.y += 500
			$FastFallingDelayTimer.start()
			
	if not IsOnGround and is_on_floor():# IsOnGround is on a delay so it only Runs for 1 
		if IsGrowing and IsCrouching: # Handles Hops
			if FacingDirection: # Right
				TempSpeed += 600
			else: # Left
				TempSpeed -= 600
			velocity.y -= 200
			
		if IsFastFalling: # Handles Disabling Fast-Fall and KnockBack
			IsFastFalling = false
			velocity.y = JUMP_VELOCITY
			
		NumOfJumps = MaxNumOfJumps # Refills Jumps
	
	# Update IsOnGround
	IsOnGround = is_on_floor()

	#---Functions---#
	SpriteAnimation() # Handles sprite animation (currently only squash and strech)
	
	#---Movement---#
	Direction = Input.get_axis("Left", "Right") # Gets Direction
	if not is_on_floor(): # Applies gravity
		velocity += get_gravity() * delta
	velocity.x = Direction * SPEED + TempSpeed # Calculates Movement
	TempSpeed = lerp(TempSpeed, 0.0,0.25 ) # Makes TempSpeed decay
	
	move_and_slide()
	
#---Functions---#
func SpriteAnimation():
	$Slugcat.flip_h = FacingDirection
	$Slugcat.scale.y = scale.y
	
	if not is_on_floor(): # Stretch when Jumping
		$Slugcat.scale.x = scale.x - (-(velocity.y * 0.0007))
		$Slugcat.scale.y = scale.y + (-(velocity.y * 0.0007))
	
	if IsCrouching: # Squash when Crouching
		$Slugcat.scale.y = lerp(scale.y, 0.1, 0.25)
		$Collision.scale.y = lerp(scale.y, 0.1, 0.25)
	else:
		if $Slugcat.scale.y < 0.95 and not IsGrowing:
			IsGrowing = true
			$ChangingTimer.start()
		$Slugcat.scale.y = lerp($Slugcat.scale.y, 1.0, 0.25) 
		$Collision.scale.y = lerp($Collision.scale.y, 1.0, 0.25)
		
	if is_on_floor():
		$Slugcat.scale.x = 1
	if $Slugcat.scale.y < 0.2:
		$Slugcat.scale.y = 0.2

#---#---Child-Functions---#
func _on_fast_falling_delay_timer_timeout() -> void: # Fast-Falling delay Timer
	$FastFallingDelayTimer.stop()

func _on_changing_timer_timeout() -> void: # Window of time in which you can preferm a jump
	IsGrowing = false
	$ChangingTimer.stop()
