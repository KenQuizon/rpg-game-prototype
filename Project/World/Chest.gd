extends StaticBody3D

func _ready():

	add_to_group(
		"interactable"
	)


func interact(
	interactor: Node
) -> void:

	# Typed Node, not Character (roadmap 7.2) — InteractionComponent passes
	# context.character dynamically via call(), so anything implementing
	# the framework's host contract can open this chest, not only the
	# concrete Character class. Only .name is used here, which every Node
	# already has.
	print(
		"Opened by ",
		interactor.name
	)
