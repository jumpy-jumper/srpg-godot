class_name Command
# Commands are the ONLY way code is allowed to modify stage state.
# Stage state refers to unit and terrain attributes, as well as stage
# round logic.


var executed: bool = false


func execute() -> void:
	executed = true


func undo() -> void:
	if not executed:
		print("Undo attempted without executing first.")
		return
	executed = false
