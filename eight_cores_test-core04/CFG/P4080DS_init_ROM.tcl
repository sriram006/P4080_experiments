proc envsetup {} {
	# Environment Setup
	radix x 
	config hexprefix 0x
	config MemIdentifier v
	config MemWidth 32 
	config MemAccess 32 
	config MemSwap off
}

#-------------------------------------------------------------------------------
# Main                                                                          
#-------------------------------------------------------------------------------

envsetup
  
#######################################################################
# debugger settings

# prevent stack unwinding at entry_point/reset when stack pointer is not initialized
reg	"General Purpose Registers/SP" = 0x0000000F
