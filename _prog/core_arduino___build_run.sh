_arduino_run_procedure() {
	_arduino_compile_procedure "$@"
	_arduino_upload_procedure "$@"
}

_arduino_run_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_arduino_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_set_arduino_fakeHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	#_arduino_method "$@"
	#_arduino_executable "$@"
	_arduino_run_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_run() {
	"$scriptAbsoluteLocation" _arduino_run_sequence "$@"
}
