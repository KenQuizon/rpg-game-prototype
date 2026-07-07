extends StaticBody3D

func _ready():

	add_to_group(
		"interactable"
	)


func interact(
	interactor: Character
) -> void:

	print(
		"Opened by ",
		interactor.name
	)
