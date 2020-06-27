_check_prog_arduino() {
	#! _typeDep java && return 1
	#! _typeDep ddd && return 1
	#! _typeDep atom && return 1
	
	[[ -e "$au_openocdStaticUB" ]] && ! "$au_openocdStaticUB" _test_prog "$@" && return 1
	
	return 0
}

_test_prog_arduino() {
	#_getDep java
	#_getDep ddd
	#_getDep atom
	
	_wantGetDep ddd
	
	[[ -e "$au_openocdStaticUB" ]] && ! "$au_openocdStaticUB" _test_prog "$@" && _stop 1
	
	return 0
}

_setup_prog_arduino() {
	[[ -e "$au_openocdStaticUB" ]] && ! "$au_openocdStaticUB" _setup_prog "$@" && _stop 1
	
	#cat << 'CZXWXcRMTo8EmM8i4d' | sudo tee "$1"'/etc/udev/rules.d/49-teensy-'"$ubiquitiousBashIDshort"'.rules' > /dev/null
#CZXWXcRMTo8EmM8i4d
	sudo -n cp "$scriptLib"/udev_teensy-rules/49-teensy.rules /etc/udev/rules.d/ > /dev/null 2>&1
	sudo -n cp "$scriptLib"/arduinoUbiquitous/_lib/udev_teensy-rules/49-teensy.rules /etc/udev/rules.d/ > /dev/null 2>&1
	
	! [[ -e /etc/udev/rules.d/49-teensy.rules ]] && _messagePlain_warn 'write: udev: missing'
	
	#_messagePlain_good 'write: udev: complete'
	
	
	return 0
}

# ATTENTION: Overload with 'ops' or similar.
_package_prog_arduino_ops() {
	true
}

# WARNING: Untested.
_package_prog_arduino() {
	#_set_arduino_installation > /dev/null
	au_arduinoInstallation="$au_arduinoDir"
	
	
	_prepare_arduino_installation > /dev/null
	
	! [[ -e "$au_arduinoInstallation" ]] && _stop 1
	
	export safeToDeleteGit="true"
	#git gc
	#cp -a "$scriptAbsoluteFolder"/.git "$safeTmp"/package/.git
	
	
	
	mkdir -p "$safeTmp"/package/_lib/src_arduino
	cp -a "$scriptLib"/src_arduino/. "$safeTmp"/package/_lib/src_arduino
	
	# WARNING: Untested.
	#mkdir -p "$safeTmp"/package/_lib/src_arduino/"$au_arduinoVersion"
	#cp -a "$scriptLib"/src_arduino/"$au_arduinoVersion"/. "$safeTmp"/package/_lib/src_arduino/"$au_arduinoVersion"/
	
	
	
	mkdir -p "$safeTmp"/package/_local/arduino
	cp -a "$au_arduinoLocal"/. "$safeTmp"/package/_local/arduino/
	
	# WARNING: Untested.
	#mkdir -p "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"
	#cp -a "$au_arduinoLocal"/"$au_arduinoVersion"/. "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"/
	
	# WARNING: Untested.
	#rm "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"/portable
	#mkdir -p "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"/portable
	#cp -a "$au_arduinoLocal"/.arduino15/. "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"/portable/
	
	# WARNING: Untested.
	#rm "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"/portable/sketchbook
	#mkdir -p "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"/portable/sketchbook
	#cp -a "$au_arduinoLocal"/Arduino/. "$safeTmp"/package/_local/arduino/"$au_arduinoVersion"/portable/sketchbook
	
	
	_package_prog_arduino_ops
	
	return 0
}
