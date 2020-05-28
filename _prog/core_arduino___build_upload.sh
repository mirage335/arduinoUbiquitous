# ATTENTION Overload ONLY if further specialization is actually required!
_arduino_upload_serial_bossac_typical() {
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
# ATTENTION: Overload ONLY if further specialization is actually required!
_arduino_upload_serial_bossac_device() {
	_arduino_upload_serial_bossac_typical "$@"
}


# ATTENTION: Overload ONLY if further specialization is actually required!
_get_arduino_serialport_avrdude_typical() {
	local arduinoSerialPort
	
	arduinoSerialPort=ttyACM0
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyACM1
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyACM2
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB0
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB1
	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB2
	! [[ -e /dev/"$arduinoSerialPort" ]] && return 1
	
	echo "$arduinoSerialPort"
	return 0
}
# ATTENTION: EXAMPLE ONLY.
# NOT typical. Unique.
# https://forum.arduino.cc/index.php?topic=168515.msg1254196#msg1254196
# ATTENTION: WARNING: Overload. Further specialization required!
_arduino_upload_serial_avrdude_example() {
	local arduinoSerialPort
	! arduinoSerialPort=$(_get_arduino_serialport_avrdude_typical) && return 1

	_set_arduino_fakeHome
	_fakeHome "$au_avrdudeStatic" -C"$au_avrdudeStaticConf" -v -patmega2560 -cwiring -P"$arduinoSerialPort" -b115200 -D -Uflash:w:"$au_arduinoFirmware_hex":i
}
# ATTENTION: Overload. Further specialization required!
_arduino_upload_serial_avrdude_device() {
	_arduino_upload_serial_avrdude_example "$@"
}


# ONLY required by some specific devices. Generic implementation available for Arduino AVR. Other addons should define their own functions (eg. _set_arduino_firmware_hex_teensy36 ).
_check_arduino_firmware_hex() {
	! [[ -e "$au_arduinoFirmware_hex" ]] && return 1
	return 0
}
_set_arduino_firmware_hex() {
	export au_arduinoFirmware_hex=$(find "$shortTmp"/_build -maxdepth 1 -name '*.hex' ! -name '*bootloader*' 2> /dev/null | head -n 1)
	! [[ -e "$au_arduinoFirmware_hex" ]] && export au_arduinoFirmware_hex=$(find "$au_arduinoBuildOut" -maxdepth 1 -name '*.hex' ! -name '*bootloader*' 2> /dev/null | head -n 1)
	
	[[ -e "$au_arduinoFirmware_hex" ]] && export au_arduinoFirmware=$(_getAbsoluteFolder "$au_arduinoFirmware_hex")
	
	
	export au_arduinoFirmware_hex_basename=$(basename "$au_arduinoFirmware_hex")
	
	export au_arduinoFirmware_hex_sketchname="${au_arduinoFirmware_hex_basename%.*}"
	
	! _check_arduino_firmware_hex && return 1
	return 0
}



_check_arduino_firmware() {
	! [[ -e "$au_arduinoFirmware_bin" ]] && return 1
	! [[ -e "$au_arduinoFirmware_elf" ]] && return 1
	! [[ -e "$au_arduinoFirmware" ]] && return 1
	! [[ -d "$au_arduinoFirmware" ]] && return 1
	return 0
}
_set_arduino_firmware() {
	export au_arduinoFirmware_bin=$(find "$shortTmp"/_build -maxdepth 1 -name '*.bin' 2> /dev/null | head -n 1)
	! [[ -e "$au_arduinoFirmware_bin" ]] && export au_arduinoFirmware_bin=$(find "$au_arduinoBuildOut" -maxdepth 1 -name '*.bin' 2> /dev/null | head -n 1)
	
	export au_arduinoFirmware_elf=$(find "$shortTmp"/_build -maxdepth 1 -name '*.elf' 2> /dev/null | head -n 1)
	! [[ -e "$au_arduinoFirmware_elf" ]] && export au_arduinoFirmware_elf=$(find "$au_arduinoBuildOut" -maxdepth 1 -name '*.elf' 2> /dev/null | head -n 1)
	
	if [[ -e "$au_arduinoFirmware_elf" ]]
	then
		export au_arduinoFirmware=$(_getAbsoluteFolder "$au_arduinoFirmware_elf")
	fi
	
	if [[ -e "$au_arduinoFirmware_bin" ]]
	then
		export au_arduinoFirmware=$(_getAbsoluteFolder "$au_arduinoFirmware_bin")
	fi
	
	! _check_arduino_firmware && return 1
	return 0
}

_arduino_serial_wait() {
	sleep 2
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	sleep 3
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	sleep 9
	( [[ -e "/dev/ttyACM0" ]] || [[ -e "/dev/ttyACM1" ]] || [[ -e "/dev/ttyACM2" ]] || [[ -e "/dev/ttyUSB0" ]] || [[ -e "/dev/ttyUSB1" ]] || [[ -e "/dev/ttyUSB2" ]] ) && return 0
	return 1
}

# ATTENTION: Overload!
_arduino_upload_swd_openocd_device() {
	true
	#_arduino_upload_swd_openocd_zero "$@"
}

# ATTENTION Overload ONLY if further specialization is actually required!
_arduino_upload_swd_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Upload.'
	
	_set_arduino_firmware
	
	! [[ -e "$au_arduinoFirmware_bin" ]] && _messagePlain_bad 'fail: missing: firmware' > /dev/tty 2>&1 && return 1
	
	local swdUploadStatus
	
	#Upload over SWD debugger.
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	_arduino_upload_swd_openocd_device
	swdUploadStatus=$?
	export au_remotePort="$au_remotePort_orig"
	
	if [[ "$swdUploadStatus" != 0 ]]	#SWD upload failed.
	then
		_arduino_upload_serial_bossac_device
	fi
	
	_arduino_serial_wait
	
	cd "$localFunctionEntryPWD"
}

# ATTENTION Overload ONLY if further specialization is actually required!
# TODO: Placeholder for AVR.
_arduino_upload_avrisp_procedure() {
	local localFunctionEntryPWD
	localFunctionEntryPWD="$PWD"
	
	_messagePlain_nominal 'Upload.'
	
	
	#_set_arduino_firmware
	
	_set_arduino_firmware_hex
	
	#! [[ -e "$au_arduinoFirmware_bin" ]] && _messagePlain_bad 'fail: missing: firmware' > /dev/tty 2>&1 && return 1
	! [[ -e "$au_arduinoFirmware_hex" ]] && _messagePlain_bad 'fail: missing: firmware' > /dev/tty 2>&1 && return 1
	
	local avrispUploadStatus
	
	#Upload over SWD debugger.
	export au_remotePort_orig="$au_remotePort"
	export au_remotePort=disabled
	
	# TODO
	false
	#_arduino_upload_swd_openocd_device
	
	avrispUploadStatus=$?
	export au_remotePort="$au_remotePort_orig"
	
	if [[ "$avrispUploadStatus" != 0 ]]	#AVRISP upload failed.
	then
		
		# TODO: Testing.
		false
		#_arduino_upload_serial_bossac_device
		_arduino_upload_serial_avrdude_device
		
	fi
	
	_arduino_serial_wait
	
	cd "$localFunctionEntryPWD"
}

# Future Arduino type, or legacy AVRISP, devices, may need to overload this.
_arduino_upload_procedure() {
	_arduino_upload_swd_procedure "$@"
	#_arduino_upload_avrisp_procedure "$@"
}


_arduino_upload_sequence() {
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
	_arduino_upload_procedure "$@"
	
	_arduino_deconfigure_method
	
	_stop
}

_arduino_upload() {
	"$scriptAbsoluteLocation" _arduino_upload_sequence "$@"
}

