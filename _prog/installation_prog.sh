_check_prog() {
	! _typeDep java && return 1
	
	return 0
}

_test_prog() {
	_getDep java
	
	! _check_prog && echo 'missing: dependency mismatch' && stop 1
}
