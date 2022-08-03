extends CanvasLayer

const FILE := "file"
const WAIT := "wait"
const SCRIPT_FLAG := "--script"
const SCRIPT_FLAGS := [SCRIPT_FLAG, "-s"]

var file_path := ""
var wait: float = 1.0

#-----------------------------------------------------------------------------#
# Builtin functions                                                           #
#-----------------------------------------------------------------------------#

func _ready() -> void:
	var args: PoolStringArray = OS.get_cmdline_args()
	for i in SCRIPT_FLAGS:
		if i in args:
			return
	
	var current_arg := ""
	
	for raw_arg in args:
		raw_arg = raw_arg.lstrip("-")
		var split: PoolStringArray = raw_arg.split("=")
		
		if split.size() > 1:
			_handle_arg(split[0], split[1])
			current_arg = ""
		else:
			if current_arg.empty():
				current_arg = raw_arg
			else:
				_handle_arg(current_arg, raw_arg)
				current_arg = ""
	
	var file := File.new()
	if not file.file_exists(file_path):
		_exit_failure("File does not exist at path: %s" % file_path)
		return
	
	OS.execute(OS.get_executable_path(), [SCRIPT_FLAG, file_path], false)
	
	yield(get_tree().create_timer(wait), "timeout")
	
	_exit_success()
	return

#-----------------------------------------------------------------------------#
# Connections                                                                 #
#-----------------------------------------------------------------------------#

#-----------------------------------------------------------------------------#
# Private functions                                                           #
#-----------------------------------------------------------------------------#

func _handle_arg(key: String, value: String) -> void:
	match key:
		FILE:
			if not value.is_rel_path() and not value.is_abs_path():
				_exit_failure("Invalid path, bailing out")
				return
			file_path = value
		WAIT:
			if not value.is_valid_float():
				printerr("Invalid float, ignoring arg")
				wait = value.to_float()

func _exit_success() -> void:
	get_tree().quit(0)

func _exit_failure(message: String) -> void:
	printerr(message)
	get_tree().quit(1)

#-----------------------------------------------------------------------------#
# Public functions                                                            #
#-----------------------------------------------------------------------------#
