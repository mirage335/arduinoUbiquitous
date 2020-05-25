
# WARNING: Ignores all sketch ops. Intended for manual IDE configuration management and testing.
# Prefer _scope .
_arduino_arduinoide_user() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		true
		#_stop 1
	fi
	
	_import_ops_arduino_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	
	#export arduinoExecutable="$au_arduinoDir"/arduino
	#export arduinoExecutable=
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
	_arduino_method "$@"
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_arduino_deconfigure_method
	#_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

# WARNING: Ignores all sketch ops. Intended for manual IDE configuration management and testing.
# Prefer _scope .
_arduino_arduinoide_edit() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		true
		#_stop 1
	fi
	
	_import_ops_arduino_sketch
	_ops_arduino_sketch
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_prepare_arduino_installation
	
	#export arduinoExecutable="$au_arduinoDir"/arduino
	#export arduinoExecutable=
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
	_arduino_method "$@"
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_arduino_deconfigure_method
	#_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}

# WARNING: Ignores all sketch ops. Intended for manual IDE configuration management and testing.
# Prefer _scope .
#config, assumes portable directories have been setup
# WARNING: No production use.
# DANGER: May be obsolete and broken.
_arduino_arduinoide_config() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		true
		#_stop 1
	fi
	
	_import_ops_arduino_sketch
	_ops_arduino_sketch
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_prepare_arduino_installation
	
	#export arduinoExecutable="$au_arduinoDir"/arduino
	#export arduinoExecutable=
	#_fakeHome "$scriptAbsoluteLocation" --parent _arduino_executable "$@"
	#_arduino_executable "$@"
	_arduino_method_config "$@"
	
	_set_arduino_editShortHome
	#_set_arduino_userShortHome
	#_arduino_deconfigure_method
	_arduino_deconfigure_procedure "$au_arduinoDir"/portable/preferences.txt
	
	_stop
}


