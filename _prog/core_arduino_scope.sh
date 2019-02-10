
_scope_var_here_prog() {
	cat << CZXWXcRMTo8EmM8i4d

#Global Variables and Defaults
export au_arduinoLocal="$scriptLocal"/arduino

export au_arduinoVersion=arduino-1.8.5
export au_arduinoDir="$au_arduinoLocal"/"$au_arduinoVersion"

export au_gdbBin="$au_arduinoLocal"/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1/bin/arm-none-eabi-gdb

export au_openocdStatic="$scriptLib"/openocd-static
export au_openocdStaticUB="$au_openocdStatic"/ubiquitous_bash.sh
export au_openocdStaticBin="$au_openocdStatic"/build/bin/openocd
export au_openocdStaticScript="$au_openocdStatic"/build/share/openocd/scripts


#Sketch
export au_arduinoSketch="$au_arduinoSketch"
export au_arduinoSketchDir="$au_arduinoSketchDir"
export au_arduinoBuildOut="$au_arduinoBuildOut"

#Debug
export au_remotePort="$au_remotePort"
export au_arduinoFirmware_sym="$au_arduinoFirmware_sym"

CZXWXcRMTo8EmM8i4d
}

_scope_attach() {
	_messagePlain_nominal '_scope_attach: init'
	
	if ! _set_arduino_var "$@"
	then
		_messagePlain_bad 'fail: _set_arduino_var'
		_stop 1
	fi
	
	[[ "$au_arduinoSketchDir" != "$ub_specimen" ]] && _messagePlain_bad 'fail: mismatch: au_arduinoSketchDir, ub_specimen' && _stop 1
	
	#_set_arduino_editShortHome
	_set_arduino_userShortHome
	_prepare_arduino_installation
	#export arduinoExecutable="$au_arduinoDir"/arduino
	export arduinoExecutable=
	
	_messagePlain_nominal '_scope_attach: deploy'
	
	_scope_here > "$ub_scope"/.devenv
	_scope_readme_here > "$ub_scope"/README
	
	_scope_command_write _scope_terminal_procedure
	
	_scope_command_write _scope_konsole_procedure
	_scope_command_write _scope_dolphin_procedure
	_scope_command_write _scope_eclipse_procedure
	_scope_command_write _scope_atom_procedure
	
	_scope_command_write _scope_arduinoide_procedure
	_scope_command_write _scope_ddd_procedure
	
	_scope_command_write _arduinoide
	
	_scope_command_write _bootloader
	
	_scope_command_write _compile
	_scope_command_write _upload
	_scope_command_write _run
	
	_scope_command_write _debug_gdb
	_scope_command_write _debug_ddd
	
	_scope_command_write _interface_debug_atom
	_scope_command_write _interface_debug_eclipse
}

_scope_prog() {
	[[ "$ub_scope_name" == "" ]] && export ub_scope_name='arduino'
}

