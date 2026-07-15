extends Resource
class_name ItemPayload

# Empty on purpose — every category-specific payload extends this so
# ItemDefinition.payload can hold any of them behind one typed field,
# the same pattern DamageStage/CharacterAction already use elsewhere in
# this project (a common base, concrete behavior in subclasses).
