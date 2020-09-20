_check_prog() {
	! _check_prog_arduino "$@" && return 1
	
	return 0
}

_test_prog() {
	! _test_prog_arduino "$@" && _stop 1
	
	! _check_prog && echo 'missing: dependency mismatch' && _stop 1
	
	return 0
}

# CAUTION: Reboot or relogin may be required to take effect.
_setup_udev() {
	! _wantSudo && echo 'denied: sudo' && _stop 1
	
	sudo -n bash -c '[[ -e /etc/udev/rules.d/ ]]' && sudo -n cp -r "$scriptLib"/app/udev-avr/rules/. /etc/udev/rules.d/
	
	# WARNING: System groups are expected to have been created with correct uid/gid by other utilities prior to running these scripts.
	#sudo -n groupadd plugdev
	sudo -n usermod -a -G plugdev "$USER"
	
	#sudo -n groupadd dialout
	sudo -n usermod -a -G dialout "$USER"
}

_setup_prog() {
	#true
	
	! _setup_prog_arduino "$@" && _stop 1
	
	_setup_udev
	
	return 0
}

_package_prog() {
	! _package_prog_arduino "$@" && return 1
	
	return 0
}
