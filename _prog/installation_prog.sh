_check_prog() {
	#! _typeDep java && return 1
	! _typeDep ddd && return 1
	! _typeDep atom && return 1
	
	[[ -e "$au_openocdStaticUB" ]] && ! "$au_openocdStaticUB" _test_prog "$@" && return 1
	
	return 0
}

_test_prog() {
	#_getDep java
	_getDep ddd
	_getDep atom
	
	[[ -e "$au_openocdStaticUB" ]] && ! "$au_openocdStaticUB" _test_prog "$@" && _stop 1
	
	! _check_prog && echo 'missing: dependency mismatch' && _stop 1
}

_setup_prog() {
	#true
	
	[[ -e "$au_openocdStaticUB" ]] && "$au_openocdStaticUB" _setup_prog "$@"
}

_package_prog() {
	export safeToDeleteGit="true"
	cp -a "$scriptAbsoluteFolder"/.git "$safeTmp"/package/.git
	
	mkdir -p "$safeTmp"/package/arduino
	cp -a "$au_arduinoInstallation"/. "$safeTmp"/package/arduino
	
	rm "$safeTmp"/package/arduino/portable
	mkdir -p "$safeTmp"/package/arduino/portable
	cp -a "$globalFakeHome"/.arduino15/. "$safeTmp"/package/arduino/portable/
	
	rm "$safeTmp"/package/arduino/portable/sketchbook
	mkdir -p "$safeTmp"/package/arduino/portable/sketchbook
	cp -a "$globalFakeHome"/Arduino/. "$safeTmp"/package/arduino/portable/sketchbook
}
