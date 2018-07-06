_here_gdbinit_debug() {
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

_arduino_swd_openocd_zero() {
	_arduino_swd_openocd -f "$scriptLib"/ArduinoCore-samd/variants/arduino_zero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; tcl_port disabled; gdb_port "$au_remotePort "$@"
}

#Requires bootloader.
_arduino_upload_swd_openocd_zero() {
	_arduino_swd_openocd_zero -c "telnet_port disabled; program {""$au_arduinoFirmware_bin""} verify reset 0x00002000; shutdown"
	wait "$au_openocdPID"
}

# ATTENTION: Overload with ops!
_arduino_swd_openocd_device() {
	_arduino_swd_openocd_zero "$@"
}

# ATTENTION: Overload with ops!
#Upload over serial COM. Crude, hardcoded serial port expected. Consider adding code to upload to specific Arduinos if needed. Recommend "ops" file overload.
_arduino_serial_bossac_device() {
	local arduinoSerialPort
	
	arduinoSerialPort=ttyACM0
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyACM1
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyACM2
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB0
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB1
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB2
	! [[ -e /dev/"$arduinoSerialPort" ]] && return 1
	
	stty --file=/dev/"$arduinoSerialPort" 1200;stty stop x --file=/dev/"$arduinoSerialPort";stty --file=/dev/"$arduinoSerialPort" 1200;stty stop x --file=/dev/"$arduinoSerialPort";
	sleep 2
	"$au_arduinoLocal"/.arduino15/packages/arduino/tools/bossac/1.7.0/bossac -i -d --port="$arduinoSerialPort" -U true -i -e -w -v "$au_arduinoFirmware_bin" -R
}
