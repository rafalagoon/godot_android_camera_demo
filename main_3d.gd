extends Node3D


var plugin
var plugin_name = "GodotGetImage"


func _ready() -> void:
	if not Engine.has_singleton(plugin_name):
		print("Could not load plugin: ", plugin_name)

		return

	plugin = Engine.get_singleton(plugin_name)
	if not plugin:
		print("Could not get plugin: ", plugin_name)

		return

	var options = {
		"auto_rotate_image": true,
		"image_height" : 1920,
		"image_width" : 1080,
		"keep_aspect" : true,
		"image_format" : "jpg"
	}

	plugin.setOptions(options)

	plugin.connect("error", _on_error)
	plugin.connect("image_request_completed", _on_image_request_completed)
	plugin.connect("permission_not_granted_by_user", _on_permission_not_granted_by_user)


func _on_image_request_completed(dict) -> void:
	var img_buffer = dict.values()[0]

	var image = Image.new()

	var error = image.load_jpg_from_buffer(img_buffer)

	if error != OK:
		print("Error loading png/jpg buffer, ", error)

		return

	print("Loading texture... ")

	var texture = ImageTexture.new().create_from_image(image)
	var region = Rect2(0, 420, 1080, 1500)

	$Head.get_active_material(0).albedo_texture = get_cropped_texture(texture, region)


func get_cropped_texture(texture : Texture, region : Rect2) -> AtlasTexture:
	var atlas_texture := AtlasTexture.new()

	atlas_texture.set_atlas(texture)
	atlas_texture.set_region(region)

	return atlas_texture


func _on_error (e) -> void:
	var dialog = get_node("AcceptDialog")

	dialog.window_title = "Error!"
	dialog.dialog_text = e

	dialog.show()


func _on_permission_not_granted_by_user (permission) -> void:
	print("Permission not granted by user!")

	var dialog = get_node("AcceptDialog")
	var permission_text = permission.capitalize().split(".")[-1]

	dialog.window_title = "Permission necessary"
	dialog.dialog_text = permission_text + "\n permission is necessary"

	dialog.show()

	plugin.resendPermission()


func _on_camera_pressed () -> void:
	if not plugin:
		print(plugin_name, " plugin not loaded!")

		return

	plugin.getCameraImage()

