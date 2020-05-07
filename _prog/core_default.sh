
_declare_scope_arduino


# DANGER: Do NOT override.
# All Arduino related build toolchains require parent directory names matching sketch file names. None requrie 8.3 .
_set_share_abstractfs() {
	_set_share_abstractfs_reset
	
	# ATTENTION: Using absolute folder, may preserve apparent parent directory name at the expense of reducing likelihood of 8.3 compatibility.
	#./ubiquitous_bash.sh _abstractfs ls -lad ./.
	#/dev/shm/uk4u/randomid/.
	#/dev/shm/uk4u/randomid/ubiquitous_bash
	#export sharedHostProjectDir="$abstractfs_base"
	export sharedHostProjectDir=$(_getAbsoluteFolder "$abstractfs_base")
	
	export sharedGuestProjectDir="$abstractfs"
	
	#Blank default. Resolves to lowest directory shared by "$PWD" and "$@" .
	#export sharedHostProjectDir="$sharedHostProjectDirDefault"
}
