_check_prog() {
	! _check_prog_arduino "$@" && return 1
	
	return 0
}

_test_prog() {
	! _test_prog_arduino "$@" && _stop 1
	
	! _check_prog && echo 'missing: dependency mismatch' && _stop 1
	
	return 0
}

_setup_prog() {
	#true
	
	! _setup_prog_arduino "$@" && _stop 1
	
	return 0
}

_package_prog() {
	! _package_prog_arduino "$@" && return 1
	
	return 0
}
