_scope_arduinoide_procedure() {
	_messagePlain_nominal 'ArduinoIDE.'
	
	# TODO: Is this redundant?
	if ! _set_arduino_var "$ub_specimen"
	then
		true
		#_stop 1
	fi
	_import_ops_sketch
	_ops_arduino_sketch
	
	#Current directory is generally irrelevant to arduino, and if different from sketchDir, may cause problems.
	cd "$au_arduinoSketchDir"
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	_set_arduino_userShortHome
	
	mkdir -p "$shortTmp"/_build
	_arduino_method --save-prefs --pref build.path="$shortTmp"/_build
	
	_set_arduino_userShortHome
	_prepare_arduino_board "$@"
	
	_set_arduino_userShortHome
	_messagePlain_probe _fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$au_arduinoSketchDir" "$@"
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$au_arduinoSketch" "$@"
	#_arduino_executable "$@"
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_arduino_deconfigure_method
	#_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
}

#No production use.
_scope_arduinoide_sequence() {
	_start
	
	_scope_arduinoide_procedure "$@"
	
	_stop
}

_scope_arduinoide() {
	_scope "$shiftParam1" "_scope_arduinoide_procedure" "$@"
}

_scope_ddd_procedure() {
	_arduino_ddd_procedure "$@"
}
