_arduino_method_device_zero() {
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_package=arduino --pref target_platform=samd --pref board=arduino_zero_native "$@"
}

_prepare_arduino_board_device_zero() {
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_package=arduino --pref target_platform=samd --pref board=arduino_zero_native
}



_arduino_swd_openocd_zero() {
	_arduino_swd_openocd -f "$scriptLib"/ArduinoCore-samd/variants/arduino_zero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; tcl_port disabled; gdb_port "$au_remotePort "$@"
}

#Requires bootloader.
_arduino_upload_swd_openocd_zero() {
	_arduino_swd_openocd_zero -c "telnet_port disabled; program {""$au_arduinoFirmware_bin""} verify reset 0x00002000; shutdown"
	wait "$au_openocdPID"
}



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







_declare_arduino_device_zero() {

	_declare_arduino_installation_default

	_arduino_method_device() {
		_arduino_method_device_zero "$@"
	}

	_prepare_arduino_board() {
		_messagePlain_good 'aU: precaution: set: board'
		_prepare_arduino_board_device_zero "$@"
	}
	
	# Future Arduino type, or legacy AVRISP, devices, may need to overload this.
	_arduino_upload_procedure() {
		_arduino_upload_swd_procedure "$@"
		#_arduino_upload_avrisp_procedure "$@"
	}

	_arduino_swd_openocd_device() {
		_arduino_swd_openocd_zero "$@"
	}

	_arduino_upload_swd_openocd_device() {
		_arduino_upload_swd_openocd_zero "$@"
	}
	
	# ATTENTION Overload ONLY if further specialization is actually required!
	#_arduino_upload_serial_bossac_device() {
	#	_arduino_upload_serial_bossac_typical "$@"
	#}

	_arduino_bootloader_procedure() {
		_arduino_bootloader_zero_procedure "$@"
	}
	
	
	# ATTENTION Overload ONLY if further specialization is actually required!
	#_arduino_debug_ddd_procedure() {
	#	_arduino_debug_ddd_openocd_procedure_typical "$@"
	#}
	
	# ATTENTION Overload ONLY if further specialization is actually required!
	#_arduino_debug_gdb_procedure() {
	#	_arduino_debug_gdb_openocd_procedure_typical "$@"
	#}

}


