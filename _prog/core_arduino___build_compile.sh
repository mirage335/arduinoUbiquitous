
# ATTENTION: Overload!
_arduino_method_device() {
	true
	#_arduino_method_device_zero "$@"
}


_arduino_compile_preferences_procedure() {
	# ATTENTION: Precautionary. Wastes time. Disable if possible.
	#_set_arduino_userShortHome
	#_set_arduino_editShortHome
	_set_arduino_fakeHome
	_messagePlain_nominal 'au: compile: set: build path'
	_arduino_method --save-prefs --pref build.path="$shortTmp"/_build
	
	# ATTENTION: Precautionary. Wastes time. Disable if possible.
	#_set_arduino_userShortHome
	#_set_arduino_editShortHome
	_set_arduino_fakeHome
	_messagePlain_nominal 'au: compile: set: board'
	_prepare_arduino_board
	
	# ATTENTION: WARNING: Partial operation combination. Undefined behavior may occur.
	#_set_arduino_userShortHome
	#_set_arduino_editShortHome
	#_set_arduino_fakeHome
	#_messagePlain_nominal 'au: compile: combine: partial'
	#_arduino_method_device --pref build.path="$shortTmp"/_build
	
	
	# ATTENTION: WARNING: Full operation combination. Undefined behavior may occur.
	#_set_arduino_userShortHome
	#_set_arduino_editShortHome
	#_set_arduino_fakeHome
	#_messagePlain_nominal 'au: compile: combine: full'
	#_arduino_method_device --pref build.path="$shortTmp"/_build "$@"
	
	
	# ATTENTION: Precautionary. Wastes time. Disable if possible.
	#_set_arduino_userShortHome
	#_set_arduino_editShortHome
	_set_arduino_fakeHome
	_arduino_method "$@"
}

_arduino_compile_wait_teensy() {
	_messagePlain_nominal 'Waiting: teensy bootloader open'
	
	ps -e | grep teensy
	
	local currentWaitTime=0
	for currentWaitTime in {1..270}
	do
		pgrep teensy > /dev/null 2>&1 && sleep 1
	done
	
	return 0
}


_arduino_compile_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Compile.'
	
	#Current directory is generally irrelevant to arduino, and if different from sketchDir, may cause problems.
	cd "$au_arduinoSketchDir"
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	#_set_arduino_userShortHome
	
	mkdir -p "$shortTmp"/_build
	
	
	
	_arduino_compile_preferences_procedure --verify "$au_arduinoSketch"
	
	
	
	mkdir -p "$au_arduinoBuildOut"
	cp "$shortTmp"/_build/*.bin "$au_arduinoBuildOut"/
	cp "$shortTmp"/_build/*.hex "$au_arduinoBuildOut"/
	cp "$shortTmp"/_build/*.elf "$au_arduinoBuildOut"/
	
	# May allow teensy graphical loader to read file.
	[[ "$au_teensy36" == 'true' ]] && _arduino_compile_wait_teensy
	
	cd "$localFunctionEntryPWD"
}

_arduino_compile_sequence() {
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
	_arduino_compile_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_compile() {
	"$scriptAbsoluteLocation" _arduino_compile_sequence "$@"
}
