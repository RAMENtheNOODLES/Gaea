@tool
class_name ChunkLoader
extends Node2D


## The generator that loads the chunks.
@export var generator: HeightmapGenerator2D
## Chunks will be loaded arround this Node. 
## If set to null chunks will be loaded around (0, 0)
@export var actor: Node2D
## The distance around the actor which will be loaded.
## The actual loading area will be this value in all 4 directions.
@export var loading_radius: Vector2i = Vector2i(2, 2)
## Amount of frames the loader waits before it checks if new chunks need to be loaded.
@export_range(0, 10) var update_rate: int = 0
## Executes the loading process on ready [br]
## [b]Warning:[/b] No chunks might load if set to false.
@export var load_on_ready: bool = true

var _update_status: int = 0
var _last_position: Vector2i


func _ready() -> void:
	if load_on_ready:
		_update_loading(_get_actors_position())


func _process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	_update_status -= 1
	if _update_status <= 0:
		# todo make check loading
		_try_loading()
		_update_status = update_rate


# checks if chunk loading is neccessary and executes if true
func _try_loading() -> void:
	var actor_position: Vector2i = _get_actors_position()
	if actor_position == _last_position:
		return
	
	_last_position = actor_position
	_update_loading(actor_position)


# loads needed chunks around the given position
func _update_loading(actor_position: Vector2i) -> void:
	if generator == null:
		push_error("Chunk loading failed because generator property not set!")
		return
	
	var required_chunks: Array[Vector2i] = _get_required_chunks(actor_position)
	print("loading ", required_chunks)
	for required in required_chunks:
		if generator.has_chunk(required): return
		generator.generate_chunk(required)


func _get_actors_position() -> Vector2i:
	# getting actors positions
	var actor_position := Vector2.ZERO
	if actor != null: actor_position = actor.global_position
	
	var chunk_position := Vector2i(
		floori(actor_position.x / GaeaGenerator.CHUNK_SIZE),
		floori(actor_position.y / GaeaGenerator.CHUNK_SIZE)
	)
	
	return actor_position


func _get_required_chunks(actor_position: Vector2i) -> Array[Vector2i]:
	var chunks: Array[Vector2i] = []
	
	var x_range = range(
		actor_position.x - abs(loading_radius).x,
		actor_position.x + abs(loading_radius).x + 1
	)
	var y_range = range(
		actor_position.y - abs(loading_radius).y,
		actor_position.y + abs(loading_radius).y + 1
	)
	
	for x in x_range:
		for y in y_range:
			chunks.append(Vector2i(x, y))
	
	return chunks


func _get_configuration_warnings() -> PackedStringArray:
	var warnings : PackedStringArray

	if not is_instance_valid(generator):
		warnings.append("Generator is required!")

	return warnings
