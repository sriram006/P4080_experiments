########################################################################################
# Initialization file for P4080 DS
# Clock Configuration:
#       CPU:1500 MHz,    CCB: 800 MHz,
#       DDR:1300 MHz, SYSCLK: 100 MHz, LBC: 100MHz
########################################################################################

variable CCSRBAR 0xFE000000

proc CCSR {reg_off} {
	global CCSRBAR
	
	return i:0x[format %x [expr {$CCSRBAR + $reg_off}]]
}

proc init_board {} {
	
	# disable Boot Space Translation
	mem [CCSR 0x28] = 0x00000000 
	
	# invalidate again BR0 to prevent flash data damage in case 
	# the boot sequencer re-enables CS0 access
	mem [CCSR 0x124000] = 0x00001000 
	
	##################################################################################
	# Local Access Windows Setup
	
	# LAW0 to eLBC - 256M
	mem [CCSR 0xC00] = 0x00000000
	mem [CCSR 0xC04] = 0xE0000000
	mem [CCSR 0xC08] = 0x81f0001b
	
	# LAW1 to SRAM - 1MB
	mem [CCSR 0xC10] = 0x00000000
	mem [CCSR 0xC14] = 0x00000000
	mem [CCSR 0xC18] = 0x81000013
	
	# LAW9 to eLBC - PIXIS - 4KB
	mem [CCSR 0xC90] = 0x00000000
	mem [CCSR 0xC94] = 0xFFDF0000
	mem [CCSR 0xC98] = 0x81F0000B
	
	##################################################################################
	# configure internal CPC1 as SRAM at 0x00000000

	# CPC - 0x01_0000

	# CPC1_CPCCSR0
	#0   0  00 0000 00 1  0   0000 0000 1   1 00 0000 0000       
	#DIS ECCdis        FI               FL LFC
	#1                  1                1   0

	# flush
	# CPC1_CPCCSR0
	mem [CCSR 0x10000] = 0x00200C00
	# enable
	# CPC1_CPCCSR0
	mem [CCSR 0x10000] = 0x80200800

	# CPC1_CPCEWCR0 - disable stashing
	# CPC1_CPCEWCR0
	mem [CCSR 0x10010] = 0x00000000

	# CPC1_CPCSRCR1 - SRBARU=0
	# CPC1_CPCSRCR1
	mem [CCSR 0x10100] = 0x00000000

	# CPC1_CPCSRCR0 - SRBARL=0, INTLVEN=0, SRAMSZ=5(32ways), SRAMEN=1
	# CPC1_CPCSRCR0
	mem [CCSR 0x10104] = 0x0000000B

	# CPC1_CPCERRDIS 
	mem [CCSR 0x10E44] = 0x000000EC
	
	# CPC1_CPCHDBCR0
	# enable SPEC_DIS from CPC1_CPCHDBCR0 
    mem [CCSR 0x10F00] = 0x[format %x [expr {[mem [CCSR 0x10F00] -np] | 0x8000000}]]
	
	
	##################################################################################
	# eSPI Setup
	# ESPI_SPMODE 
	mem [CCSR 0x110000] = 0x80000403
	# ESPI_SPIM - catch all events
	mem [CCSR 0x110008] = 0x00000000
	# ESPI_SPMODE0
	mem [CCSR 0x110020] = 0x30170008
	
	
	##################################################################################
	# LBC Controller Setup
	
	# CS0 - Flash,   addr at 0xE8000000, 128MB size, 16-bit, GCPM, Valid 
	mem [CCSR 0x124000] = 0xe8001001  
	mem [CCSR 0x124004] = 0xf8000ff7
	
	# CS1 - PromJet, addr at 0xE0000000, 128MB size, 16-bit, GCPM, Valid 
	mem [CCSR 0x124008] = 0xe0001001
	mem [CCSR 0x12400C] = 0xf8000ff7
	
	# CS3 - PIXIS,   addr at 0xFFDF0000,   1MB size,  8-bit, GCPM, Valid  
	mem [CCSR 0x124018] = 0xffdf0801
	mem [CCSR 0x12401C] = 0xffff8ff7
	
	# LBCR
	mem [CCSR 0x1240D0] = 0x40000000
	
	# LCRR CLKDIV = 16
	mem [CCSR 0x1240D4] = 0x80000002

	# eLBC_FMR
	mem [CCSR 0x1240e0] = 0x0000F000	
}

proc P4080DS_init_core {} {
	
	##################################################################################
	#	
	#	Memory Map
	#
	#   0x00000000  0x7FFFFFFF  SRAM	   1M
	#   0xE0000000	0xEFFFFFFF  LocalBus   256M		 
	#   0xFE000000  0xFEFFFFFF  CCSR Space 16M
	#   0xFFDF0000  0xFFDF0FFF  PIXIS      4K
	#   0xFFFFF000  0xFFFFFFFF  Boot Page  4k
	#
	##################################################################################
	
	variable CAM_GROUP "regPPCTLB1/"
	variable SPR_GROUP "e500mc Special Purpose Registers/"
	variable GPR_GROUP "General Purpose Registers/"
	
	##################################################################################
	# MMU initialization
	
	# define 16MB  TLB entry  1: 0xFE000000 - 0xFEFFFFFF for CCSR    cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM1 = 0x7000000A1C080000FE000000FE000001

	# define 256MB TLB entry  2: 0xE0000000 - 0xEFFFFFFF for LB      cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM2 = 0x9000000A1C080000E0000000E0000001
	
	# define   1MB TLB entry  3 : 0x00000000 - 0x000FFFFF for SRAM     cache inhibited
	reg ${CAM_GROUP}L2MMU_CAM3 = 0x5000000AFC0800000000000000000001

	# define   4KB TLB entry 13: 0xFFDF0000 - 0xFFDF0FFF for PIXIS   cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM13 = 0x1000000A1C080000FFDF0000FFDF0001

    init_board
	
	##################################################################################
	# Interrupt vectors initialization 
	# interrupt vectors in RAM at 0x${proc_id}0000000
	# IVPR (default reset value) 
	reg ${SPR_GROUP}IVPR = 0x00000000
	
	# interrupt vector offset registers 
	# IVOR0 - critical input
	reg ${SPR_GROUP}IVOR0 = 0x00000100	
	# IVOR1 - machine check
	reg ${SPR_GROUP}IVOR1 = 0x00000200	
	# IVOR2 - data storage
	reg ${SPR_GROUP}IVOR2 = 0x00000300	
	# IVOR3 - instruction storage
	reg ${SPR_GROUP}IVOR3 = 0x00000400	
	# IVOR4 - external input
	reg ${SPR_GROUP}IVOR4 = 0x00000500	
	# IVOR5 - alignment
	reg ${SPR_GROUP}IVOR5 = 0x00000600	
	# IVOR6 - program
	reg ${SPR_GROUP}IVOR6 = 0x00000700	
    # IVOR7 - floating point unavailable
    reg ${SPR_GROUP}IVOR7 = 0x00000800	
	# IVOR8 - system call
	reg ${SPR_GROUP}IVOR8 = 0x00000c00	
	# IVOR10 - decrementer
	reg ${SPR_GROUP}IVOR10 = 0x00000900	
	# IVOR11 - fixed-interval timer interrupt
	reg ${SPR_GROUP}IVOR11 = 0x00000f00	
	# IVOR12 - watchdog timer interrupt
	reg ${SPR_GROUP}IVOR12 = 0x00000b00	
	# IVOR13 - data TLB errror
	reg ${SPR_GROUP}IVOR13 = 0x00001100	
	# IVOR14 - instruction TLB error
	reg ${SPR_GROUP}IVOR14 = 0x00001000	
	# IVOR15 - debug
	reg ${SPR_GROUP}IVOR15 = 0x00001500	
	# IVOR35 - performance monitor
	reg ${SPR_GROUP}IVOR35 = 0x00001900	 
    	
	##################################################################################
	# Debugger settings
	
	# enable machine check
	reg ${SPR_GROUP}HID0 = 0x00000080
	
	# enable floating point
	reg ${SPR_GROUP}MSR = 0x00002000
	
	# infinite loop at program exception to prevent taking the exception again
	mem v:0x00000700 = 0x48000000
	
	# prevent stack unwinding at entry_point/reset when stack pointer is not initialized
	reg ${GPR_GROUP}SP = 0x0000000F
	
	# CONFIG_BRRL - enable all cores
	# DCFG_BRR
	mem [CCSR 0xE00E4] = 0x000000ff
	# RCPM_CTBENR
	mem [CCSR 0xE2084] = 0x000000ff	
}

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
  
  P4080DS_init_core