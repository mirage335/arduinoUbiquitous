_set_share_abstractfs() {
	_set_share_abstractfs_reset
	
	#export sharedHostProjectDir="$abstractfs_base"
	export sharedHostProjectDir=$(_getAbsoluteFolder "$abstractfs_base")
	export sharedGuestProjectDir="$abstractfs"
	
	#Blank default. Resolves to lowest directory shared by "$PWD" and "$@" .
	#export sharedHostProjectDir="$sharedHostProjectDirDefault"
}

_set_arduino_userShortHome() {
	export actualFakeHome="$shortFakeHome"
	export fakeHomeEditLib="false"
	export keepFakeHome="true"
}

_set_arduino_editShortHome() {
	export actualFakeHome="$shortFakeHome"
	export fakeHomeEditLib="true"
	export keepFakeHome="true"
}

# WARNING: No production use expected.
_set_arduino_userFakeHome() {
	export actualFakeHome="$instancedFakeHome"
	export fakeHomeEditLib="false"
	export keepFakeHome="true"
}

# WARNING: No production use expected.
_set_arduino_editFakeHome() {
	export actualFakeHome="$globalFakeHome"
	export fakeHomeEditLib="false"
	export keepFakeHome="true"
}

_prepare_arduino_installation() {
	mkdir -p "$au_arduinoLocal"/.arduino15
	mkdir -p "$au_arduinoLocal"/Arduino
	
	mkdir -p "$au_arduinoDir"
	
	mkdir -p "$au_arduinoDir"/portable
	mkdir -p "$au_arduinoDir"/portable/sketchbook
	
	_relink ../.arduino15 "$au_arduinoDir"/portable
	_relink ../Arduino "$au_arduinoDir"/portable/sketchbook
	
	#Default not to create "project.afs" file, unless "$afs_nofs" explicitly set to "false".
	[[ "$afs_nofs" != "false" ]] && export afs_nofs=true
	[[ -e "$au_arduinoSketchDir" ]] && _abstractfs true "$au_arduinoSketchDir"
}

_install_fakeHome_arduino() {
	_prepare_arduino_installation
	
	_link_fakeHome "$au_arduinoDir" "$au_arduinoVersion"
	
	_link_fakeHome "$au_arduinoLocal"/.arduino15 .arduino15
	_link_fakeHome "$au_arduinoLocal"/Arduino Arduino
}

_install_fakeHome_app() {
	_install_fakeHome_arduino
}

_reset_arduino_sketchDir() {
	export au_arduinoSketch=
	export au_arduinoSketchDir=
	export au_basename=
}

_validate_arduino_sketchDir() {
	local au_basename_test
	
	! [[ -e "$au_arduinoSketch" ]] && return 1
	! [[ -e "$au_arduinoSketchDir" ]] && return 1
	! [[ -d "$au_arduinoSketchDir" ]] && return 1
	
	au_basename_test=$(basename "$au_arduinoSketchDir")
	! [[ -e "$au_arduinoSketchDir"/"$au_basename_test".ino ]] && return 1
	! [[ -e "$au_arduinoSketchDir"/"$au_basename".ino ]] && return 1
	
	[[ "$au_arduinoSketch" != "$au_arduinoSketchDir"/"$au_basename_test".ino ]] && return 1
	[[ "$au_arduinoSketch" != "$au_arduinoSketchDir"/"$au_basename".ino ]] && return 1
	
	return 0
}

# WARNING: Scope directory as first parameter is only supported method. All other methods are for convenience only, may be disabled, and must not be relied on.
_set_arduino_sketchDir() {
	if [[ -d "$1" ]] && [[ -e "$1" ]]
	then
		_reset_arduino_sketchDir
		export au_arduinoSketchDir=$(_getAbsoluteLocation "$1")
		export au_basename=$(basename "$au_arduinoSketchDir")
		export au_arduinoSketch="$au_arduinoSketchDir"/"$au_basename".ino
		
		_validate_arduino_sketchDir && return 0
		
		#Fallback. Fatal error, tool.
		_messagePlain_bad 'missing: au_arduinoSketch'
		return 1
	fi
	
	if [[ "$1" == *".ino" ]] && [[ -e "$1" ]]
	then
		_reset_arduino_sketchDir
		export au_arduinoSketch=$(_getAbsoluteLocation "$1")
		export au_arduinoSketchDir=$(_getAbsoluteFolder "$1")
		export au_basename=$(basename "$au_arduinoSketchDir")
		_validate_arduino_sketchDir && return 0
		
		#Fallback. Fatal error, tool.
		_messagePlain_bad 'mismatch: au_arduinoSketch, au_arduinoSketchDir'
		return 1
	fi
	
	_reset_arduino_sketchDir
	export au_arduinoSketchDir=$(_getAbsoluteLocation "$PWD")
	au_basename=$(basename "$au_arduinoSketchDir")
	export au_arduinoSketch="$au_arduinoSketchDir"/"$au_basename".ino
	_validate_arduino_sketchDir && return 0
	
	#Fallback. Fatal error, tool.
	_messagePlain_bad 'missing: ./"$au_arduinoSketch"'
	return 1
}

_check_arduino_debug() {
	_checkPort_local "$au_remotePort" && return 1
	return 0
}

_set_arduino_var() {
	if ! _set_arduino_sketchDir "$@"
	then
		return 1
	fi
	
	export au_arduinoBuildOut="$au_arduinoSketchDir"/_build
	
	_checkPort_local "$au_remotePort" && export au_remotePort=$(_findPort)
	[[ "$au_remotePort" == "" ]] && export au_remotePort=$(_findPort)
	! _check_arduino_debug && return 1
	
	#Consistent name for ELF binary file, to be used by any debuggers which are infeasible to update with heurestically determined filename strings.
	#export au_arduinoFirmware_sym="$au_arduinoBuildOut"/"$au_basename".ino.elf
	export au_arduinoFirmware_sym="$shortTmp"/_build/"$au_basename".ino.elf
	
	
	_messagePlain_probe 'au_arduinoSketch= '"$au_arduinoSketch"
	_messagePlain_probe 'au_arduinoSketchDir= '"$au_arduinoSketchDir"
	
	_messagePlain_probe 'au_arduinoFirmware_bin= '"$au_arduinoFirmware_bin"
	_messagePlain_probe 'au_arduinoFirmware_elf= '"$au_arduinoFirmware_elf"
	
	_messagePlain_probe 'au_remotePort= '"$au_remotePort"
	
	_messagePlain_probe 'au_arduinoFirmware_sym= '"$au_arduinoFirmware_sym"
	
	return 0
}
