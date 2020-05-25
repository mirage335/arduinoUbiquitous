# Preferences were determined by examining changes made by IDE to '_local/arduino/.arduino15/preferences.txt' .
_arduino_method_device_teensy36() {
	arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_package=teensy --pref target_platform=avr --pref board=teensy36 --pref custom_keys=teensy36_en-us --pref custom_opt=teensy36_o2std --pref custom_speed=teensy36_180 --pref custom_usb=teensy36_serial "$@"
}

_prepare_arduino_board_device_teensy36() {
	_arduino_method --save-prefs --pref programmer=arduino:sam_ice --pref target_package=teensy --pref target_platform=avr --pref board=teensy36 --pref custom_keys=teensy36_en-us --pref custom_opt=teensy36_o2std --pref custom_speed=teensy36_180 --pref custom_usb=teensy36_serial
}



_arduino_swd_openocd_teensy36() {
	false
	
	# WARNING: This may not be not easily supported.
	# https://mcuoneclipse.com/2017/04/29/modifying-the-teensy-3-5-and-3-6-for-arm-swd-debugging/
	# https://mcuoneclipse.com/2014/08/09/hacking-the-teensy-v3-1-for-swd-debugging/
	# https://medium.com/@mattmatic/preparing-teensy-3-6-for-swd-b014b0ce2999
	
	# Adafruit Metro M4 might support this with perhaps vaguely similar hardware.
	#https://www.adafruit.com/product/3382
	
	# Example ONLY.
	#_arduino_swd_openocd -f "$scriptLib"/ArduinoCore-samd/variants/arduino_zero/openocd_scripts/arduino_zero.cfg -c "telnet_port disabled; tcl_port disabled; gdb_port "$au_remotePort "$@"
}

#Requires bootloader.
_arduino_upload_swd_openocd_teensy36() {
	false
	
	#_arduino_swd_openocd_zero -c "telnet_port disabled; program {""$au_arduinoFirmware_bin""} verify reset 0x00002000; shutdown"
	#wait "$au_openocdPID"
}



_arduino_bootloader_teensy36_procedure() {
	false
	
	#export au_remotePort_orig="$au_remotePort"
	#export au_remotePort=disabled
	#_arduino_swd_openocd_zero -c "telnet_port disabled; init; halt; at91samd bootloader 0; program {""$scriptLib""/ArduinoCore-samd/bootloaders/zero/samd21_sam_ba.bin} verify reset; shutdown"
	#wait "$au_openocdPID"
	#export au_remotePort="$au_remotePort_orig"
}
_arduino_bootloader_teensy36() {
	false
	
	#_arduino_bootloader_zero_procedure "$@"
}

_check_arduino_firmware_hex_teensy36() {
	! [[ -e "$au_arduinoFirmware_hex_teensy36" ]] && return 1
	return 0
}

_set_arduino_firmware_hex_teensy36() {
	export au_arduinoFirmware_hex_teensy36=$(find "$shortTmp"/_build -maxdepth 1 -name '*.hex' ! -name '*bootloader*' 2> /dev/null | head -n 1)
	! [[ -e "$au_arduinoFirmware_hex_teensy36" ]] && export au_arduinoFirmware_hex_teensy36=$(find "$au_arduinoBuildOut" -maxdepth 1 -name '*.hex' ! -name '*bootloader*' 2> /dev/null | head -n 1)
	
	[[ -e "$au_arduinoFirmware_hex_teensy36" ]] && export au_arduinoFirmware=$(_getAbsoluteFolder "$au_arduinoFirmware_hex_teensy36")
	
	
	export au_arduinoFirmware_hex_teensy36_basename=$(basename "$au_arduinoFirmware_hex_teensy36")
	
	export au_arduinoFirmware_hex_teensy36_sketchname="${au_arduinoFirmware_hex_teensy36_basename%.*}"
	
	! _check_arduino_firmware_hex_teensy36 && return 1
	return 0
}

_arduino_upload_teensy36_procedure() {
	! _set_arduino_firmware_hex_teensy36 && return 1
	
	# https://www.pjrc.com/teensy/loader_cli.html
	#-mmcu=imxrt1062 : 	Teensy 4.0
	#-mmcu=mk66fx1m0 : 	Teensy 3.6
	#-mmcu=mk64fx512 : 	Teensy 3.5
	#-mmcu=mk20dx256 : 	Teensy 3.2 & 3.1
	#-mmcu=mk20dx128 : 	Teensy 3.0
	#-mmcu=mkl26z64 : 	Teensy LC
	#-mmcu=at90usb1286 : 	Teensy++ 2.0
	#-mmcu=atmega32u4 : 	Teensy 2.0
	#-mmcu=at90usb646 : 	Teensy++ 1.0
	#-mmcu=at90usb162 : 	Teensy 1.0
	# teensy_loader_cli -mmcu=mk66fx1m0 -w "$au_arduinoFirmware_hex_teensy36"
	
	# https://www.pjrc.com/teensy/loader_linux.html
	#hardware/tools
	#_messagePlain_request "$au_arduinoFirmware_hex_teensy36"
	#"$au_arduinoDir"/hardware/tools/teensy "$au_arduinoFirmware_hex_teensy36"
	
	# Taken from Teensyduino/ArduinoIDE verbose messages after compile request.
	#"$au_arduinoDir"/hardware/teensy/../tools/teensy_post_compile -file="$au_arduinoFirmware_hex_teensy36_sketchname" -path="$au_arduinoFirmware" -tools="$au_arduinoDir"/hardware/teensy/../tools/ -board=TEENSY36
	
	# Taken from Teensyduino/ArduinoIDE verbose messages after upload request.
	"$au_arduinoDir"/hardware/teensy/../tools/teensy_post_compile -file="$au_arduinoFirmware_hex_teensy36_sketchname" -path="$au_arduinoFirmware" -tools="$au_arduinoDir"/hardware/teensy/../tools -board=TEENSY36 -reboot -port=/dev/ttyACM0 -portlabel=/dev/ttyACM0 -portprotocol=serial
	
}






_declare_arduino_device_teensy36() {
	export au_teensy36='true'

	_declare_arduino_installation_default

	_arduino_method_device() {
		_arduino_method_device_teensy36 "$@"
	}

	_prepare_arduino_board() {
		_messagePlain_good 'aU: precaution: set: board'
		_prepare_arduino_board_device_teensy36 "$@"
	}
	
	# ATTENTION: Unusual device-specific Teensyduino upload program is required.
	# Future Arduino type, or legacy AVRISP, devices, may need to overload this.
	_arduino_upload_procedure() {
		_arduino_upload_teensy36_procedure "$@"
		#_arduino_upload_swd_procedure "$@"
		#_arduino_upload_avrisp_procedure "$@"
	}

	_arduino_swd_openocd_device() {
		_arduino_swd_openocd_teensy36 "$@"
	}

	_arduino_upload_swd_openocd_device() {
		_arduino_upload_swd_openocd_teensy36 "$@"
	}
	
	# ATTENTION Overload ONLY if further specialization is actually required!
	#_arduino_upload_serial_bossac_device() {
	#	_arduino_upload_serial_bossac_typical "$@"
	#}

	_arduino_bootloader_procedure() {
		_arduino_bootloader_teensy36_procedure "$@"
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



