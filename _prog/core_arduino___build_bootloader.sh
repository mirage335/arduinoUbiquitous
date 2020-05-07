# ATTENTION: Overload!
_arduino_bootloader_procedure() {
	true
	#_arduino_bootloader_zero_procedure "$@"
}

_arduino_bootloader_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_arduino_sketch
	_ops_arduino_sketch
	
	_arduino_bootloader_procedure "$@"
	
	_stop
}

_arduino_bootloader() {
	"$scriptAbsoluteLocation" _arduino_bootloader_sequence "$@"
	_messagePlain_probe "done: _arduino_bootloader"
	_messagePlain_good 'End.'
}
