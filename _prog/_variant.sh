##### "core_arduino" #####


###
### variant set/prepare kept at "_variant.sh"
###


_set_arduino_board_mkr1000() {
	_messagePlain_nominal 'aU: set: board'
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_platform=samd --pref board=mkr1000
}

_set_arduino_board_zero_native() {
	_messagePlain_nominal 'aU: set: board'
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_platform=samd --pref board=arduino_zero_native
}

# ATTENTION: Overload with ops!
_prepare_arduino_board() {
	#_messagePlain_nominal 'aU: set: board'
	#_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_platform=samd --pref board=arduino_zero_native
	_set_arduino_board_zero_native
	#_set_arduino_board_mkr1000
}


###
### variant upload kept at "_variant.sh"
###

# WARNING: Example only! Rely upon "_arduino_upload_swd_procedure" or "_arduino_upload_avrisp_procedure" unless further specialization is actually required!
_arduino_upload_procedure_zero() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Upload.'
	
	_set_arduino_firmware
	
	! [[ -e "$au_arduinoFirmware_bin" ]] && _messagePlain_bad 'fail: missing: firmware' > /dev/tty 2>&1 && return 1
	
	local swdUploadStatus
	
	#Upload over SWD debugger.
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_upload_swd_openocd_zero
	swdUploadStatus=$?
	export au_remotePort="$au_remotePort_orig"
	
	if [[ "$swdUploadStatus" != 0 ]]	#SWD upload failed.
	then
		_arduino_upload_serial_bossac_zero
	fi
	
	_arduino_serial_wait
	
	cd "$localFunctionEntryPWD"
}

# ATTENTION Overload with ops!
_arduino_upload_procedure() {
	_arduino_upload_swd_procedure "$@"
	#_arduino_upload_procedure_zero "$@"
}

###
### variant bootloader kept at "_variant.sh"
###


# WARNING: No production use. Obsolete hardware, upstream bugs in development tools. Recommend programming as zero.
_arduino_bootloader_m0_procedure() {
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_swd_openocd_zero -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/mzero/Bootloader_D21_M0_150515.hex} verify reset; shutdown"
	wait "$au_openocdPID"
	export au_remotePort="$au_remotePort_orig"
}
_arduino_bootloader_m0() {
	_arduino_bootloader_m0_procedure "$@"
}

# Arduino Zero
_arduino_bootloader_zero_procedure() {
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_swd_openocd_zero -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/zero/samd21_sam_ba.bin} verify reset; shutdown"
	wait "$au_openocdPID"
	export au_remotePort="$au_remotePort_orig"
}
_arduino_bootloader_zero() {
	_arduino_bootloader_zero_procedure "$@"
}

# Arduino mkr1000
_arduino_bootloader_mkr1000_procedure() {
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_swd_openocd_mkr1000 -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/mkr1000/samd21_sam_ba_arduino_mkr1000.bin} verify reset; shutdown"
	#_arduino_swd_openocd_mkr1000 -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/mkr1000/samd21_sam_ba_genuino_mkr1000.bin} verify reset; shutdown"
	wait "$au_openocdPID"
	export au_remotePort="$au_remotePort_orig"
}
_arduino_bootloader_mkr1000() {
	_arduino_bootloader_mkr1000_procedure "$@"
}

# ATTENTION: Overload with ops!
_arduino_bootloader_procedure() {
	#_arduino_bootloader_mkr1000_procedure "$@"
	_arduino_bootloader_zero_procedure "$@"
}


###
### variant upload interface kept at "_variant.sh"
###


# Arduino Zero
_arduino_swd_openocd_zero() {
	_arduino_swd_openocd -f "$scriptLib"/ArduinoCore-samd/variants/arduino_zero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; tcl_port disabled; gdb_port "$au_remotePort "$@"
}
#Requires bootloader.
_arduino_upload_swd_openocd_zero() {
	_arduino_swd_openocd_zero -c "telnet_port disabled; program {""$au_arduinoFirmware_bin""} verify reset 0x00002000; shutdown"
	wait "$au_openocdPID"
}

# Arduino mkr1000
_arduino_swd_openocd_mkr1000() {
	_arduino_swd_openocd -f "$scriptLib"/ArduinoCore-samd/variants/mkr1000/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; tcl_port disabled; gdb_port "$au_remotePort "$@"
}
#Requires bootloader.
_arduino_upload_swd_openocd_mkr1000() {
	_arduino_swd_openocd_mkr1000 -c "telnet_port disabled; program {""$au_arduinoFirmware_bin""} verify reset 0x00002000; shutdown"
	wait "$au_openocdPID"
}

# ATTENTION: Overload with ops!
_arduino_upload_swd_openocd_device() {
	#_arduino_upload_swd_openocd_mkr1000 "$@"
	_arduino_upload_swd_openocd_zero "$@"
}

# ATTENTION: Overload with ops!
_arduino_swd_openocd_device() {
	#_arduino_swd_openocd_mkr1000 "$@"
	_arduino_swd_openocd_zero "$@"
}

_arduino_upload_serial_bossac_zero() {
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

_arduino_upload_serial_bossac_mkr1000() {
	_arduino_upload_serial_bossac_zero "$@"
}

# ATTENTION: Overload with ops!
#Upload over serial COM. Crude, hardcoded serial port expected. Consider adding code to upload to specific Arduinos if needed. Recommend "ops" file overload.
_arduino_upload_serial_bossac_device() {
	#_arduino_upload_serial_bossac_mkr1000 "$@"
	_arduino_upload_serial_bossac_zero "$@"
}

