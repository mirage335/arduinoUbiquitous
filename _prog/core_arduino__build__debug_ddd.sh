
_arduino_debug_ddd_openocd_procedure_typical() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'IDE: ddd .'
	
	mkdir -p "$shortTmp"/_build
	
	_set_arduino_firmware
	_gather_arduino_sym
	
	#! [[ -e "$au_arduinoFirmware" ]] && _messagePlain_warn 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	#! [[ -d "$au_arduinoFirmware" ]] && _messagePlain_warn 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	
	#Current directory is generally irrelevant to arduino, and if different from sketchDir, may cause problems.
	cd "$au_arduinoSketchDir"
	
	#Safety provisions require this to be reset by any script process, even if "--parent" or similar declared.
	#_set_arduino_editShortHome
	#_set_arduino_userShortHome
	_set_arduino_fakeHome
	
	! _check_arduino_debug && _messagePlain_bad 'fail: block: au_remotePort= '"$au_remotePort" > /dev/tty 2>&1 && return 1
	_arduino_swd_openocd_device
	
	_here_arduino_gdbinit_openocd_debug > "$safeTmp"/.gdbinit
	
	_messagePlain_probe ddd --debugger "$au_gdbBin" -d "$shortTmp"/_build -x "$safeTmp"/.gdbinit
	ddd --debugger "$au_gdbBin" -d "$shortTmp"/_build -x "$safeTmp"/.gdbinit
	
	#Kill process only if name is openocd.
	kill $(pgrep openocd | grep "$au_openocdPID")
	
	cd "$localFunctionEntryPWD"
}


# ATTENTION Overload ONLY if further specialization is actually required!
_arduino_debug_ddd_procedure() {
	_arduino_debug_ddd_openocd_procedure_typical "$@"
}

_arduino_debug_ddd_sequence() {
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
	
	_arduino_debug_ddd_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_debug_ddd() {
	#"$scriptAbsoluteLocation" _arduino_run_sequence "$@"
	"$scriptAbsoluteLocation" _arduino_debug_ddd_sequence "$@"
}

_arduino_debugrun_ddd() {
	"$scriptAbsoluteLocation" _arduino_run_sequence "$@"
	"$scriptAbsoluteLocation" _arduino_debug_ddd_sequence "$@"
}


