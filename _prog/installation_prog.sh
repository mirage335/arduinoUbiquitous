_check_prog() {
	! _typeDep java && return 1
	
	return 0
}

_test_prog() {
	_getDep java
	
	! _check_prog && echo 'missing: dependency mismatch' && stop 1
}

_setup_udev() {
	_mustGetSudo
	sudo -n cp "$scriptLocal"/98-openocd.rules /etc/udev/rules.d/
	sudo -n usermod -a -G plugdev "$USER"
}

_setup_prog() {
	_setup_udev
}
