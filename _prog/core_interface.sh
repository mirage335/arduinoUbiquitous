_here_gdbinit_debug() {
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

_here_gdbinit_delegate() {
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

_interface_debug_gdb_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_set_arduino_firmware
	! [[ -e "$au_arduinoFirmware_elf" ]] && _messagePlain_bad 'fail: missing: firmware elf' && return 1
	! [[ -e "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' && return 1
	! [[ -d "$au_arduinoFirmware" ]] && _messagePlain_bad 'fail: missing: firmware dir' && return 1
	
	#! _check_arduino_debug && _messagePlain_bad 'fail: block: au_remotePort= '"$au_remotePort" && return 1
	_check_arduino_debug && _arduino_swd_openocd_device
	
	_here_gdbinit_debug > "$safeTmp"/.gdbinit
	#_messagePlain_probe "$au_gdbBin" -d "$au_arduinoFirmware" -x "$safeTmp"/.gdbinit "$@"
	"$au_gdbBin" -d "$au_arduinoFirmware" -x "$safeTmp"/.gdbinit "$@"
	
	#Kill process only if name is openocd.
	#_messagePlain_probe 'au_openocdPID= '$au_openocdPID
	kill $(pgrep openocd | grep "$au_openocdPID")
	
	cd "$localFunctionEntryPWD"
}

_debug_gdb() {
	_interface_debug_gdb_procedure "$@"
}

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

_interface_debug_atom() {
	"$scriptAbsoluteLocation" _interface_debug_atom_sequence "$@"
}




_arduino_swd_openocd() {
	_messagePlain_probe "$au_openocdStaticBin" -d2 -s "$au_openocdStaticScript" "$@"
	"$au_openocdStaticBin" -d2 -s "$au_openocdStaticScript" "$@" &
	export au_openocdPID="$!"
}

###
### variant upload interface kept at "_variant.sh"
###

_arduino_serial_wait() {
	sleep 2
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	sleep 3
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	sleep 9
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	return 1
}

