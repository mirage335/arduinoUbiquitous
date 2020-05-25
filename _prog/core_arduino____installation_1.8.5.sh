# ATTENTION: WARNING: Override of arduino related environment variables should only be done to support build toolchains entirely compatible with the existing functions to support arduino (eg. other arduino versions, teensyduino, not eclipse).



_declare_arduino_installation_1.8.5() {
	export au_arduinoVersion=arduino-1.8.5
	export au_arduinoDir="$au_arduinoLocal"/"$au_arduinoVersion"

	export au_gdbBin="$au_arduinoLocal"/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1/bin/arm-none-eabi-gdb

	export au_openocdStatic="$scriptLib"/openocd-static
	export au_openocdStaticUB="$au_openocdStatic"/ubiquitous_bash.sh
	export au_openocdStaticBin="$au_openocdStatic"/build/bin/openocd
	export au_openocdStaticScript="$au_openocdStatic"/build/share/openocd/scripts
}

_declare_arduino_installation_1.8.12() {
	export au_arduinoVersion=arduino-1.8.12
	export au_arduinoDir="$au_arduinoLocal"/"$au_arduinoVersion"

	export au_gdbBin="$au_arduinoLocal"/.arduino15/packages/arduino/tools/arm-none-eabi-gcc/4.8.3-2014q1/bin/arm-none-eabi-gdb

	export au_openocdStatic="$scriptLib"/openocd-static
	export au_openocdStaticUB="$au_openocdStatic"/ubiquitous_bash.sh
	export au_openocdStaticBin="$au_openocdStatic"/build/bin/openocd
	export au_openocdStaticScript="$au_openocdStatic"/build/share/openocd/scripts
}


_declare_teensyduino_installation_1.52() {
	_declare_arduino_installation_1.8.12
	
	# Specific teensyduino variables.
	
	
}

