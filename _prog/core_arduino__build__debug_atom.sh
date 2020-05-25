
# DANGER: Do NOT enable through 'includeScriptList' under 'compile_bash_prog.sh' .
# CAUTION: No production use. Unmaintained. Kept for reference ONLY.

# DANGER: Requires '_interface_debug_atom' as anchor script.
# TODO: Requires retesting.
# TODO: Requires function renaming to avoid creating conflicting defaults.



# WARNING: Intermittent failures, upstream issues, bad practices, no production use, not officially supported.
_interface_debug_atom_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	# WARNING: Bad practice.
	pkill openocd
	
	_set_arduino_firmware
	! [[ -e "$au_arduinoFirmware_elf" ]] && _messagePlain_bad 'fail: missing: firmware elf' > /dev/tty 2>&1 && return 1
	! [[ -e "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	! [[ -d "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' > /dev/tty 2>&1 && return 1
	
	#! _check_arduino_debug && _messagePlain_bad 'fail: block: au_remotePort= '"$au_remotePort" > /dev/tty 2>&1 && return 1
	_check_arduino_debug && _arduino_swd_openocd_device > /dev/tty 2>&1
	
	_here_gdbinit_delegate > "$safeTmp"/.gdbinit
	#_messagePlain_probe "$au_gdbBin" -d "$au_arduinoFirmware" -x "$safeTmp"/.gdbinit "$@" > /dev/tty
	"$au_gdbBin" -d "$au_arduinoFirmware" -x "$safeTmp"/.gdbinit "$@"
	
	#Kill process only if name is openocd.
	#_messagePlain_probe 'au_openocdPID= '$au_openocdPID > /dev/tty 2>&1
	kill $(pgrep openocd | grep "$au_openocdPID") > /dev/tty 2>&1
	
	cd "$localFunctionEntryPWD"
}

_interface_debug_atom_sequence() {
	_start
	
	_interface_debug_atom_procedure "$@"
	
	_stop
}

# DANGER: Required to be present as an anchor script, or atom debug functionality WILL NOT WORK.
_interface_debug_atom() {
	"$scriptAbsoluteLocation" _interface_debug_atom_sequence "$@"
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
	
	_arduino_atom_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_atom() {
	"$scriptAbsoluteLocation" _arduino_atom_sequence "$@"
}

_ide_atom() {
	_import_ops_arduino_sketch
	_ops_arduino_sketch
	
	_arduino_atom_procedure "$@"
}

_debug_atom() {
	_arduino_run_procedure "$@"
	_arduino_atom_procedure "$@"
}
