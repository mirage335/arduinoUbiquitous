# ATTENTION Overload with ops!
_arduino_ddd_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'IDE: ddd .'
	
	mkdir -p "$shortTmp"/_build
	
	_set_arduino_firmware
	if ! [[ -e "$au_arduinoFirmware_sym" ]]
	then
		_messagePlain_warn 'warn: missing: firmware elf' > /dev/tty 2>&1
		#return 1
		
		[[ -e "$au_arduinoFirmware_elf" ]] && cp -n "$au_arduinoFirmware_elf" "$au_arduinoFirmware_sym"
		! [[ -e "$au_arduinoFirmware_sym" ]] && echo > "$au_arduinoFirmware_sym"
	fi
	
	#! [[ -e "$au_arduinoFirmware" ]] && _messagePlain_warn 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	#! [[ -d "$au_arduinoFirmware" ]] && _messagePlain_warn 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	
	#Current directory is generally irrelevant to arduino, and if different from sketchDir, may cause problems.
	cd "$au_arduinoSketchDir"
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	_set_arduino_userShortHome
	
	! _check_arduino_debug && _messagePlain_bad 'fail: block: au_remotePort= '"$au_remotePort" > /dev/tty 2>&1 && return 1
	_arduino_swd_openocd_device
	
	_here_gdbinit_debug > "$safeTmp"/.gdbinit
	
	_messagePlain_probe ddd --debugger "$au_gdbBin" -d "$shortTmp"/_build -x "$safeTmp"/.gdbinit
	ddd --debugger "$au_gdbBin" -d "$shortTmp"/_build -x "$safeTmp"/.gdbinit
	
	#Kill process only if name is openocd.
	kill $(pgrep openocd | grep "$au_openocdPID")
	
	cd "$localFunctionEntryPWD"
}

_arduino_ddd_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	#_arduino_method "$@"
	#_arduino_executable "$@"
	
	_arduino_ddd_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_ddd() {
	"$scriptAbsoluteLocation" _arduino_ddd_sequence "$@"
}

_ide_ddd() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_ddd_procedure "$@"
}

_debug_ddd() {
	_arduino_run_procedure "$@"
	_arduino_ddd_procedure "$@"
}

# ATTENTION Overload with ops!
_arduino_atom_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'IDE: atom .'
	
	_set_arduino_firmware
	! [[ -e "$au_arduinoFirmware_elf" ]] && _messagePlain_bad 'fail: missing: firmware elf' > /dev/tty 2>&1 && return 1
	! [[ -e "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	! [[ -d "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	_set_arduino_userShortHome
	
	#_set_atomFakeHomeSource
	#_install_fakeHome_atom
	#_messagePlain_probe _fakeHome atom --foreground "$@"
	#_fakeHome atom --foreground "$@"
	
	#_atom_user_procedure "$@"
	
	_atom_tmp_procedure "$@"
	
	#Kill process only if name is openocd.
	kill $(pgrep openocd | grep "$au_openocdPID") > /dev/null 2>&1
	
	cd "$localFunctionEntryPWD"
}

_arduino_atom_sequence() {
	_start
	
	if ! _set_arduino_var "$@"
	then
		#true
		_stop 1
	fi
	
	_import_ops_sketch
	_ops_arduino_sketch
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	#_arduino_method "$@"
	#_arduino_executable "$@"
	
	_arduino_atom_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_atom() {
	"$scriptAbsoluteLocation" _arduino_atom_sequence "$@"
}

_ide_atom() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_arduino_atom_procedure "$@"
}

_debug_atom() {
	_arduino_run_procedure "$@"
	_arduino_atom_procedure "$@"
}

_debug() {
	_import_ops_sketch
	_ops_arduino_sketch
	
	_debug_ddd "$@"
}

_arduino_debug() {
	_arduino_run "$@"
	_arduino_ddd "$@"
}
