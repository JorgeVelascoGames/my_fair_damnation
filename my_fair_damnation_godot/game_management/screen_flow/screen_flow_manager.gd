extends Node
class_name ScreenFlowManager

##This node should go in the default scene when loading the game. It manages
##the flow of screens, and can be used to load a new scene


@onready var loading_screen: LoadingScreen = %LoadingScreen
@onready var current_scene_container: Node3D = $CurrentSceneContainer

@export var lenguage_screen : PackedScene
@export var main_menu : PackedScene
@export var game : PackedScene
@export var end_demo_screen : PackedScene

var current_scene : Node


func _ready() -> void:
	loading_screen.new_sceen_loaded.connect(_on_loading_screen_new_scene_loaded)


func load_lenguage_screen() -> void:
	load_new_scene(lenguage_screen, true)


func load_main_menu() -> void:
	load_new_scene(main_menu)


func load_game() -> void:
	load_new_scene(game)


func load_end_demo_screen() -> void:
	load_new_scene(end_demo_screen, true)


##Load a new scene using the loading screen
func load_new_scene(scene : PackedScene, play_sound := false) -> void:
	loading_screen.load_scene(scene, play_sound)


func _on_loading_screen_new_scene_loaded(scene: Node) -> void:
	if current_scene:
		current_scene.queue_free()
	current_scene = scene
	current_scene_container.add_child(current_scene)
