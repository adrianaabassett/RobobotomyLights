@tool
extends Sprite3D

# imported images that are filler for testing. Please do not keep the beans in the final product
const STICKER_DATA = {
	"None": null,
	"One": preload("res://Assets/Resources/Eyes/kidney_beans.png"),
	"Two": preload("res://Assets/Resources/Eyes/meme.png"),
	"Three": preload("res://Assets/Resources/Eyes/why.jpg")
}

# creating a dropdown for ease 
@export_enum("None", "One", "Two", "Three") var sticker_type: String = "None":
	set(value):
		sticker_type = value
		_update_sticker()

func _update_sticker():
	if STICKER_DATA.has(sticker_type):
		self.texture = STICKER_DATA[sticker_type]
		
		# FORCE EDITOR REFRESH: 
		# This notifies the inspector that a property changed visually
		update_configuration_warnings() 
		
		# If the 3D viewport is still stale, 
		# you can force the node to update its mesh logic
		if Engine.is_editor_hint():
			self.notify_property_list_changed()
