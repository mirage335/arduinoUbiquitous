

_declare_scope_arduino() {

	_scope_prog() {
		[[ "$ub_scope_name" == "" ]] && export ub_scope_name='arduino'
	}

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
	
	
	_scope_attach_prog() {
		_messagePlain_nominal '_scope_attach: prog'
		
		if ! _set_arduino_var "$@"
		then
			_messagePlain_bad 'fail: _set_arduino_var'
			_stop 1
		fi
		
		[[ "$au_arduinoSketchDir" != "$ub_specimen" ]] && _messagePlain_bad 'fail: mismatch: au_arduinoSketchDir, ub_specimen' && _stop 1
		
		#_set_arduino_editShortHome
		#_set_arduino_userShortHome
		_set_arduino_fakeHome
		_prepare_arduino_installation
		#export arduinoExecutable="$au_arduinoDir"/arduino
		export arduinoExecutable=
		
		_messagePlain_nominal '_scope_attach: prog: deploy'
		
		_scope_command_write _scope_arduino
		_scope_command_write _scope_arduino_arduinoide
		
		_scope_command_write _arduino_compile
		_scope_command_write _arduino_upload
		_scope_command_write _arduino_run
		
		_scope_command_write _arduino_debug_ddd
		_scope_command_write _arduino_debugrun_ddd
		
		#_scope_command_write _arduino_debug_gdb
		#_scope_command_write _arduino_debugrun_gdb
		
		#_scope_command_write _arduino_debug_atom
		#_scope_command_write _arduino_debugrun_atom
		#_scope_command_write _arduino_interface_debug_atom
		
		#_scope_command_write _arduino_debug_eclipse
		#_scope_command_write _arduino_debugrun_eclipse
		#_scope_command_write _arduino_interface_debug_eclipse
		
		_scope_command_write _arduino_bootloader
		
		_scope_command_write _arduino_bootloader_zero
		#_scope_command_write _arduino_bootloader_m0
		#_scope_command_write _arduino_bootloader_mkr1000
	}


}

_scope_arduino() {
	_declare_scope_arduino
	_scope "$@"
}

