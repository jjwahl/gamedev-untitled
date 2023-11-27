extends CharacterBody3D

@onready var head = $head
@onready var standing_collisionshape = $standing_collisionshape
@onready var crouching_collisionshape = $crouching_collisionshape
@export var current_speed = 5.0
@onready var ray_cast_3d = $RayCast3D

const walking_speed = 5.0
const sprinting_speed = 7.0
var crouching_speed = 3.0
const jump_velocity = 4
const mouse_sens = 0.3
const air_speed = 1.5
var lerp_speed = 10.0
var direction = Vector3.ZERO
var crouching_depth = -0.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x,deg_to_rad(-70),deg_to_rad(75))
		

func _physics_process(delta):
	if Input.is_action_pressed("Crouch"):
		current_speed = crouching_speed
		head.position.y = lerp(head.position.y,1.8 + crouching_depth,delta*lerp_speed)
		standing_collisionshape.disabled = true
		crouching_collisionshape.disabled = false
	elif !ray_cast_3d.is_colliding():
		standing_collisionshape.disabled = false
		crouching_collisionshape.disabled = true
		head.position.y = lerp(head.position.y,1.8,delta*lerp_speed)
		if Input.is_action_pressed("Sprinting"):
			current_speed = sprinting_speed
		else: 
			current_speed = walking_speed
		
	
	
	
	# Add the gravity.
	if not is_on_floor():
		crouching_speed = current_speed
		velocity.y -= gravity * delta
		velocity.z = direction.z * air_speed

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("Left", "Right", "Forward", "Backwards")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(),delta*lerp_speed)
	
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
