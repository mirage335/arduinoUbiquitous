_scope_arduino_arduinoide_procedure() {
	_messagePlain_nominal 'ArduinoIDE.'
	
	# TODO: Is this redundant?
	if ! _set_arduino_var "$ub_specimen"
	then
		true
		#_stop 1
	fi
	_import_ops_arduino_sketch
	_ops_arduino_sketch
	
	#Current directory is generally irrelevant to arduino, and if different from sketchDir, may cause problems.
	cd "$au_arduinoSketchDir"
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	#_set_arduino_userShortHome
	
	# Already run by _scope .
	#_prepare_arduino_installation
	
	mkdir -p "$shortTmp"/_build
	
	#_set_arduino_userShortHome
	#_messagePlain_probe _fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$au_arduinoSketchDir" "$@"
	#export arduinoExecutable="$au_arduinoDir"/arduino
	#export arduinoExecutable=
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$au_arduinoSketch" "$@"
	#_arduino_executable "$@"
	
	
	
	_arduino_compile_preferences_procedure "$au_arduinoSketch" "$@"
	
	
	
	#_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_set_arduino_fakeHome
	_arduino_deconfigure_method
	#_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
}

_scope_arduino_arduinoide() {
	local shiftParam1
	shiftParam1="$1"
	shift
	_declare_scope_arduino
	_scope "$shiftParam1" "_scope_arduino_arduinoide_procedure" "$@"
}
