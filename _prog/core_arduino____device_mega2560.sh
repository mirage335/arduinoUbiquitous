_arduino_method_device_mega2560() {
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_package=arduino --pref target_platform=avr --pref board=mega --pref custom_cpu=mega_atmega2560 "$@"
}

_prepare_arduino_board_device_mega2560() {
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_package=arduino --pref target_platform=avr --pref board=mega --pref custom_cpu=mega_atmega2560
}



_arduino_swd_openocd_mega2560() {
	false
	#_arduino_swd_openocd -f "$scriptLib"/ArduinoCore-samd/variants/arduino_zero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; tcl_port disabled; gdb_port "$au_remotePort "$@"
}

#Requires bootloader.
_arduino_upload_swd_openocd_mega2560() {
	false
	
	# WARNING: Probably not relevant. AVR ISP support is should probably be implemented as an overload for "_arduino_upload_procedure".
	
	#_arduino_swd_openocd_mega2560 -c "telnet_port disabled; program {""$au_arduinoFirmware_bin""} verify reset 0x00002000; shutdown"
	#wait "$au_openocdPID"
}


## ATTENTION: Overload ONLY if further specialization is actually required!
#_get_arduino_serialport_avrdude_typical() {
#	local arduinoSerialPort
#	
#	arduinoSerialPort=ttyACM0
#	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyACM1
#	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyACM2
#	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB0
#	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB1
#	! [[ -e /dev/"$arduinoSerialPort" ]] && arduinoSerialPort=ttyUSB2
#	! [[ -e /dev/"$arduinoSerialPort" ]] && return 1
#	
#	echo "$arduinoSerialPort"
#	return 0
#}
# ATTENTION: WARNING: Overload. Further specialization required!
_arduino_upload_serial_avrdude_mega2560() {
	local arduinoSerialPort
	! arduinoSerialPort=$(_get_arduino_serialport_avrdude_typical) && return 1

	_set_arduino_fakeHome
	_fakeHome "$au_avrdudeStatic" -C"$au_avrdudeStaticConf" -v -patmega2560 -cwiring -P"$arduinoSerialPort" -b115200 -D -Uflash:w:"$au_arduinoFirmware_hex":i
}


_arduino_bootloader_mega2560_procedure() {
	false
	
	# WARNING: AVR ISP tools are probably required, not SWD.
	
	#export au_remotePort_orig="$au_remotePort"
	#export au_remotePort=disabled
	#_arduino_swd_openocd_mega2560 -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/zero/samd21_sam_ba.bin} verify reset; shutdown"
	#wait "$au_openocdPID"
	#export au_remotePort="$au_remotePort_orig"
}
_arduino_bootloader_mega2560() {
	false
	
	#_arduino_bootloader_mega2560_procedure "$@"
}








_declare_arduino_device_mega2560() {

	_declare_arduino_installation_default

	_arduino_method_device() {
		_arduino_method_device_mega2560 "$@"
	}

	_prepare_arduino_board() {
		_messagePlain_good 'aU: precaution: set: board'
		_prepare_arduino_board_device_mega2560 "$@"
	}
	
	# Future Arduino type, or legacy AVRISP, devices, may need to overload this.
	_arduino_upload_procedure() {
		#_arduino_upload_swd_procedure "$@"
		_arduino_upload_avrisp_procedure "$@"
	}

	#_arduino_swd_openocd_device() {
	#	_arduino_swd_openocd_mega2560 "$@"
	#}

	#_arduino_upload_swd_openocd_device() {
	#	_arduino_upload_swd_openocd_mega2560 "$@"
	#}
	
	# ATTENTION: Overload ONLY if further specialization is actually required!
	#_arduino_upload_serial_bossac_device() {
	#	_arduino_upload_serial_bossac_typical "$@"
	#}

	# ATTENTION: Overload. Further specialization required!
	_arduino_upload_serial_avrdude_device() {
		_arduino_upload_serial_avrdude_mega2560 "$@"
	}

	_arduino_bootloader_procedure() {
		_arduino_bootloader_mega2560_procedure "$@"
	}
	
	
	# ATTENTION: Overload ONLY if further specialization is actually required!
	#_arduino_debug_ddd_procedure() {
	#	_arduino_debug_ddd_openocd_procedure_typical "$@"
	#}
	
	# ATTENTION: Overload ONLY if further specialization is actually required!
	#_arduino_debug_gdb_procedure() {
	#	_arduino_debug_gdb_openocd_procedure_typical "$@"
	#}

}


