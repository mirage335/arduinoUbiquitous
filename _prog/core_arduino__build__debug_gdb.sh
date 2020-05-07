# CAUTION: Other debug applications may use GDB as an interface.

_here_arduino_gdbinit_openocd_debug() {
cat << CZXWXcRMTo8EmM8i4d
#####Config
#search path
#	/arduino/sketch

#####Startup

file "$au_arduinoFirmware_sym"
#file "$au_arduinoFirmware_elf"

#set substitute-path /arduino/_build/sketch /arduino/sketch
#set substitute-path /arduino/sketch/sketch.ino /arduino/sketch/sketch.ino.cpp

#####Remote

set \$au_remotePort=$au_remotePort

eval "target extended-remote localhost:%d", $au_remotePort

monitor reset halt

monitor reset init

CZXWXcRMTo8EmM8i4d
}

_here_arduino_gdbinit_openocd_delegate() {
cat << CZXWXcRMTo8EmM8i4d
#####Config
#search path
#	/arduino/sketch

#####Startup

file "$au_arduinoFirmware_elf"

#set substitute-path /arduino/_build/sketch /arduino/sketch
#set substitute-path /arduino/sketch/sketch.ino /arduino/sketch/sketch.ino.cpp

#####Remote

set \$au_remotePort=$au_remotePort

CZXWXcRMTo8EmM8i4d
}

# TODO: Currently must be run within "_scope" and after a "_compile" .
_arduino_debug_gdb_openocd_procedure_typical() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_set_arduino_firmware
	# TODO: Consider enabling.
	#_gather_arduino_sym
	
	! [[ -e "$au_arduinoFirmware_elf" ]] && _messagePlain_bad 'fail: missing: firmware elf' && return 1
	! [[ -e "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' && return 1
	! [[ -d "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' && return 1
	
	#! _check_arduino_debug && _messagePlain_bad 'fail: block: au_remotePort= '"$au_remotePort" && return 1
	_check_arduino_debug && _arduino_swd_openocd_device
	
	_here_arduino_gdbinit_openocd_debug > "$safeTmp"/.gdbinit
	#_messagePlain_probe "$au_gdbBin" -d "$au_arduinoFirmware" -x "$safeTmp"/.gdbinit "$@"
	"$au_gdbBin" -d "$au_arduinoFirmware" -x "$safeTmp"/.gdbinit "$@"
	
	#Kill process only if name is openocd.
	#_messagePlain_probe 'au_openocdPID= '$au_openocdPID
	kill $(pgrep openocd | grep "$au_openocdPID")
	
	cd "$localFunctionEntryPWD"
}

# ATTENTION Overload ONLY if further specialization is actually required!
_arduino_debug_gdb_procedure() {
	_arduino_debug_gdb_openocd_procedure_typical "$@"
}

# TODO: Consider adding sequence similar to '_arduino_debug_ddd' .
_arduino_debug_gdb() {
	_arduino_debug_gdb_procedure "$@"
}

