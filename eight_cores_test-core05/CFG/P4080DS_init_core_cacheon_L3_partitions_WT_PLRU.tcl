########################################################################################
# Initialization file for P4080 DS
# Clock Configuration:
#       CPU:1500 MHz,    CCB: 800 MHz,
#       DDR:1300 MHz, SYSCLK: 100 MHz, LBC: 100MHz
########################################################################################

#choose which core will initialize the board
variable master_core 0

variable CCSRBAR 0xFE000000
variable PIXISBAR 0xFFDF0000

proc CCSR {reg_off} {
	global CCSRBAR
	
	return "i:0x[format %x [expr {$CCSRBAR + $reg_off}]]"
}

proc PIXIS {reg_off} {
	global PIXISBAR
	
	return "i:0x[format %x [expr {$PIXISBAR + $reg_off}]]"
}

proc init_board {} {
	global PIXISBAR

	# decode S[0-2] to Output Divider (OD)
	set ics307_to_od {10 2 8 4 5 7 3 6}	
	
	# disable Boot Space Translation - LCC_BSTAR
	mem [CCSR 0x28] = 0x00000000 
	
	# invalidate again BR0 to prevent flash data damage in case 
	# the boot sequencer re-enables CS0 access - eLBC_BR0
	mem [CCSR 0x124000] = 0x00001000 
	
	##################################################################################
	# Local Access Windows Setup
	
	# LAW0 to eLBC - 256M
	mem [CCSR 0xC00] = 0x00000000
	mem [CCSR 0xC04] = 0xE0000000
	mem [CCSR 0xC08] = 0x81f0001b
	
	# LAW1 to PEX1 - 512MB
	mem [CCSR 0xC10] = 0x00000000
	mem [CCSR 0xC14] = 0x80000000
	mem [CCSR 0xC18] = 0x8000001C
	
	# LAW2 to PEX1 - 64KB
	mem [CCSR 0xC20] = 0x00000000
	mem [CCSR 0xC24] = 0xF8000000
	mem [CCSR 0xC28] = 0x8000000F
	
	# LAW3 to PEX2 - 512MB
	mem [CCSR 0xC30] = 0x00000000
	mem [CCSR 0xC34] = 0xA0000000
	mem [CCSR 0xC38] = 0x8010001C
	
	# LAW4 to PEX2 - 64KB
	mem [CCSR 0xC40] = 0x00000000
	mem [CCSR 0xC44] = 0xF8010000
	mem [CCSR 0xC48] = 0x8010000F
	
	# LAW5 to PEX3 - 512MB
	mem [CCSR 0xC50] = 0x00000000
	mem [CCSR 0xC54] = 0xC0000000
	mem [CCSR 0xC58] = 0x8020001C
	
	# LAW6 to PEX3 - 64KB
	mem [CCSR 0xC60] = 0x00000000
	mem [CCSR 0xC64] = 0xF8020000
	mem [CCSR 0xC68] = 0x8020000F
	
	# LAW7 to BMAN - 2MB
	mem [CCSR 0xC70] = 0x00000000
	mem [CCSR 0xC74] = 0xF4000000
	mem [CCSR 0xC78] = 0x81800014
	
	# LAW8 to QMAN - 2MB
	mem [CCSR 0xC80] = 0x00000000
	mem [CCSR 0xC84] = 0xF4200000
	mem [CCSR 0xC88] = 0x83C00014
	
	# LAW9 to eLBC - PIXIS - 4KB
	mem [CCSR 0xC90] = 0x00000000
	mem [CCSR 0xC94] = $PIXISBAR
	mem [CCSR 0xC98] = 0x81F0000B

	
	
# LAW10 for DDR partition 1 - 256MB
mem [CCSR 0xCA0] = 0x00000000
mem [CCSR 0xCA4] = 0x00000000
mem [CCSR 0xCA8] = 0x8140101B

# LAW11 for DDR partition 2 - 256MB
mem [CCSR 0xCB0] = 0x00000000
mem [CCSR 0xCB4] = 0x10000000
mem [CCSR 0xCB8] = 0x8140201B

# LAW12 for DDR partition 3 - 256MB
mem [CCSR 0xCC0] = 0x00000000
mem [CCSR 0xCC4] = 0x20000000
mem [CCSR 0xCC8] = 0x8140301B

# LAW13 for DDR partition 4 - 256MB
mem [CCSR 0xCD0] = 0x00000000
mem [CCSR 0xCD4] = 0x30000000
mem [CCSR 0xCD8] = 0x8140401B

# LAW14 for DDR partition 5 - 256MB
mem [CCSR 0xCE0] = 0x00000000
mem [CCSR 0xCE4] = 0x40000000
mem [CCSR 0xCE8] = 0x8140501B

# LAW15 for DDR partition 6 - 256MB
mem [CCSR 0xCF0] = 0x00000000
mem [CCSR 0xCF4] = 0x50000000
mem [CCSR 0xCF8] = 0x8140601B

# LAW16 for DDR partition 7 - 256MB
mem [CCSR 0xD00] = 0x00000000
mem [CCSR 0xD04] = 0x60000000
mem [CCSR 0xD08] = 0x8140701B

# LAW17 for DDR partition 8 - 256MB
mem [CCSR 0xD10] = 0x00000000
mem [CCSR 0xD14] = 0x70000000
mem [CCSR 0xD18] = 0x8140801B	

	
	
	
	# LAW31 to DDR - 2GB
#	mem [CCSR 0xDF0] = 0x00000000
#	mem [CCSR 0xDF4] = 0x00000000
	# Interleaved mode
#	mem [CCSR 0xDF8] = 0x8140001E
	
	
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
	mem [CCSR 0x124018] = 0x[format %x [expr $PIXISBAR + 0x801] -np]
	mem [CCSR 0x12401C] = 0xffff8ff7
	
	# LBCR
	mem [CCSR 0x1240D0] = 0x40000000
	
	# LCRR CLKDIV = 16
	mem [CCSR 0x1240D4] = 0x80000008
	
	
	##################################################################################
	# DDR Setup
	
	# control the 24-bit configuration word of the ICS307 system clock generator
	set PX_SCLK0 [mem [PIXIS 0x19] 8bit -np]
	set PX_SCLK1 [mem [PIXIS 0x1A] 8bit -np]
	set PX_SCLK2 [mem [PIXIS 0x1B] 8bit -np]

    # Get the value of SYSCLK
	# SYSCLK = Input Frequency * 2 * (VDW + 8) / ((RDW + 2) * OD)
	# PX_SCLK0:  C1 C0 TTL F1 F0 S2 S1 S0
	# PX_SCLK1:  V8 V7 V6 V5 V4 V3 V2 V1
	# PX_SCLK2:  V0 R6 R5 R4 R3 R2 R1 R0
	#
	# R6:R0 = Reference Divider Word (RDW)
	# V8:V0 = VCO Divider Word (VDW)
	# S2:S0 = Output Divider Select (OD)
	set INPUT_FREQ 33333000
	set VDW [expr (($PX_SCLK1 << 1) & 0x1FE) + (($PX_SCLK2 >> 7) & 1)]
	set RDW [expr $PX_SCLK2 & 0x7F]
	set OD [lindex $ics307_to_od [expr $PX_SCLK0 & 0x7]]
	set SYSCLK [expr $INPUT_FREQ * 0x2 * ($VDW + 0x8) / (($RDW + 0x2) * $OD)]
	set FREQSYSBUS $SYSCLK	
	set FREQDDRBUS $FREQSYSBUS

	# Get the value of DDR clk
	set FREQSYSBUS [expr ($FREQSYSBUS * (([mem [CCSR 0xE0100] -np] >> 25) & 0x1f))]
	set MEMPLLRAT [expr ([mem [CCSR 0xE0100] -np] >> 17) & 0x1f]
	if {$MEMPLLRAT > 0x2} {
		set FREQDDRBUS [expr $FREQDDRBUS * $MEMPLLRAT]
	} else {
		set FREQDDRBUS [expr $FREQSYSBUS * $MEMPLLRAT]
	}

	# parsing the value of FREQDDRBUS to get the value of frequency
	set freq [expr $FREQDDRBUS / 1000000]
	
	if {[expr $freq < 1250]} {
		set freq 1200
	} else {
		set freq 1300
	}

	if {$freq == 1200} {
		# DDR1 Controller Setup
		# DDR1_DDR_SDRAM_CFG
		mem [CCSR 0x8110] = 0x47044000
		# DDR1_CS0_CONFIG
		mem [CCSR 0x8080] = 0xa0014202
		# DDR1_CS1_CONFIG
		mem [CCSR 0x8084] = 0x80014202
		# DDR1_TIMING_CFG_3
		mem [CCSR 0x8100] = 0x01030000
		# DDR1_TIMING_CFG_0
		mem [CCSR 0x8104] = 0x40550804
		# DDR1_TIMING_CFG_1
		mem [CCSR 0x8108] = 0x868fa945
		# DDR1_TIMING_CFG_2
		mem [CCSR 0x810C] = 0x0fb8a912
		# DDR1_DDR_SDRAM_CFG_2
		mem [CCSR 0x8114] = 0x24401011
		# DDR1_DDR_SDRAM_MODE
		mem [CCSR 0x8118] = 0x00421a40
		# DDR1_DDR_SDRAM_MODE_3
		mem [CCSR 0x8200] = 0x00001a40
		# DDR1_DDR_SDRAM_MODE_5
		mem [CCSR 0x8208] = 0x00001a40
		# DDR1_DDR_SDRAM_MODE_7
		mem [CCSR 0x8210] = 0x00001a40
		# DDR1_DDR_SDRAM_INTERVAL
		mem [CCSR 0x8124] = 0x12480100
		# DDR1_TIMING_CFG_5 
		mem [CCSR 0x8164] = 0x03402400
		# DDR1_DDR_WRLVL_CNTL
		mem [CCSR 0x8174] = 0x8675a507
	
		# DDR2 Controller Setup
		# DDR2_DDR_SDRAM_CFG
		mem [CCSR 0x9110] = 0x47044000
		# DDR2_CS0_CONFIG
		mem [CCSR 0x9080] = 0xa0014202
		# DDR2_CS1_CONFIG
		mem [CCSR 0x9084] = 0x80014202
		# DDR2_TIMING_CFG_3
		mem [CCSR 0x9100] = 0x01030000
		# DDR2_TIMING_CFG_0
		mem [CCSR 0x9104] = 0x40550804
		# DDR2_TIMING_CFG_1
		mem [CCSR 0x9108] = 0x868fa945
		# DDR2_TIMING_CFG_2
		mem [CCSR 0x910C] = 0x0fb8a912
		# DDR2_DDR_SDRAM_CFG_2
		mem [CCSR 0x9114] = 0x24401011
		# DDR2_DDR_SDRAM_MODE
		mem [CCSR 0x9118] = 0x00421a40
		# DDR2_DDR_SDRAM_MODE_3
		mem [CCSR 0x9200] = 0x00001a40
		# DDR2_DDR_SDRAM_MODE_5
		mem [CCSR 0x9208] = 0x00001a40
		# DDR2_DDR_SDRAM_MODE_7
		mem [CCSR 0x9210] = 0x00001a40
		# DDR2_DDR_SDRAM_INTERVAL
		mem [CCSR 0x9124] = 0x12480100
		# DDR2_TIMING_CFG_5 
		mem [CCSR 0x9164] = 0x03402400
		# DDR2_DDR_WRLVL_CNTL
		mem [CCSR 0x9174] = 0x8675a507
	} elseif {$freq == 1300} {
		# DDR1 Controller Setup
		# DDR1_DDR_SDRAM_CFG
		mem [CCSR 0x8110] = 0x67044000
		# DDR1_CS0_CONFIG
		mem [CCSR 0x8080] = 0xa0044202
		# DDR1_CS1_CONFIG
		mem [CCSR 0x8084] = 0x80004202
		# DDR1_TIMING_CFG_3
		mem [CCSR 0x8100] = 0x01041000
		# DDR1_TIMING_CFG_0
		mem [CCSR 0x8104] = 0x50110104
		# DDR1_TIMING_CFG_1
		mem [CCSR 0x8108] = 0x98910a45
		# DDR1_TIMING_CFG_2
		mem [CCSR 0x810C] = 0x0fb8a914
		# DDR1_DDR_SDRAM_CFG_2
		mem [CCSR 0x8114] = 0x24401111
		# DDR1_DDR_SDRAM_MODE
		mem [CCSR 0x8118] = 0x00441a50
		# DDR1_DDR_SDRAM_MODE_3
		mem [CCSR 0x8200] = 0x00001a50
		# DDR1_DDR_SDRAM_MODE_5
		mem [CCSR 0x8208] = 0x00001a50
		# DDR1_DDR_SDRAM_MODE_7
		mem [CCSR 0x8210] = 0x00001a50
		# DDR1_DDR_SDRAM_INTERVAL
		mem [CCSR 0x8124] = 0x13ce0100
		# DDR1_TIMING_CFG_5 
		mem [CCSR 0x8164] = 0x03401400
		# DDR1_DDR_WRLVL_CNTL
		mem [CCSR 0x8174] = 0x8675f607
		
		# DDR2 Controller Setup
		# DDR2_DDR_SDRAM_CFG
		mem [CCSR 0x9110] = 0x67044000
		# DDR2_CS0_CONFIG
		mem [CCSR 0x9080] = 0xa0044202
		# DDR2_CS1_CONFIG
		mem [CCSR 0x9084] = 0x80004202
		# DDR2_TIMING_CFG_3
		mem [CCSR 0x9100] = 0x01041000
		# DDR2_TIMING_CFG_0
		mem [CCSR 0x9104] = 0x50110104
		# DDR2_TIMING_CFG_1
		mem [CCSR 0x9108] = 0x98910a45
		# DDR2_TIMING_CFG_2
		mem [CCSR 0x910C] = 0x0fb8a914
		# DDR2_DDR_SDRAM_CFG_2
		mem [CCSR 0x9114] = 0x24401111
		# DDR2_DDR_SDRAM_MODE
		mem [CCSR 0x9118] = 0x00441a50
		# DDR2_DDR_SDRAM_MODE_3
		mem [CCSR 0x9200] = 0x00001a50
		# DDR2_DDR_SDRAM_MODE_5
		mem [CCSR 0x9208] = 0x00001a50
		# DDR2_DDR_SDRAM_MODE_7
		mem [CCSR 0x9210] = 0x00001a50
		# DDR2_DDR_SDRAM_INTERVAL
		mem [CCSR 0x9124] = 0x13ce0100
		# DDR2_TIMING_CFG_5 
		mem [CCSR 0x9164] = 0x03401400
		# DDR2_DDR_WRLVL_CNTL
		mem [CCSR 0x9174] = 0x8675f607
	}

	# DDR1_CS0_BNDS
	mem [CCSR 0x8000] = 0x0000007f
	# DDR1_CS1_BNDS 
	mem [CCSR 0x8008] = 0x00000000
	# DDR1_CS0_CONFIG_2
	mem [CCSR 0x80C0] = 0x00000000
	# DDR1_CS1_CONFIG_2  
	mem [CCSR 0x80C4] = 0x00000000
	# DDR1_DDR_SDRAM_MODE_2 
	mem [CCSR 0x811C] = 0x00100000
	# DDR1_DDR_SDRAM_MODE_4 
	mem [CCSR 0x8204] = 0x00100000
	# DDR1_DDR_SDRAM_MODE_6 
	mem [CCSR 0x820C] = 0x00100000
	# DDR1_DDR_SDRAM_MODE_8 
	mem [CCSR 0x8214] = 0x00100000
	# DDR1_DDR_SDRAM_MD_CNTL
	mem [CCSR 0x8120] = 0x00000000
	# DDR1_DDR_DATA_INIT
	mem [CCSR 0x8128] = 0xdeadbeef
	# DDR1_DDR_SDRAM_CLK_CNTL
	mem [CCSR 0x8130] = 0x02800000
	# DDR1_DDR_INIT_ADDR 
	mem [CCSR 0x8148] = 0x00000000
	# DDR1_DDR_INIT_EXT_ADDRESS
	mem [CCSR 0x814C] = 0x00000000
	# DDR1_TIMING_CFG_4
	mem [CCSR 0x8160] = 0x00000001
	# DDR1_DDR_ZQ_CNTL
	mem [CCSR 0x8170] = 0x89080600
	# DDR1_DDR_SR_CNTR
	mem [CCSR 0x817C] = 0x00000000
	# DDR1_DDR_WRLVL_CNTL_2
	mem [CCSR 0x8190] = 0x00000000
	# DDR1_DDR_WRLVL_CNTL_3 
	mem [CCSR 0x8194] = 0x00000000
	# DDR1_DDRCDR_1
	mem [CCSR 0x8B28] = 0x00000000
	# DDR1_DDRCDR_2
	mem [CCSR 0x8B2C] = 0x00000000
	# DDR1_ERR_SBE
	mem [CCSR 0x8E58] = 0x00000000

	# DDR2_CS0_BNDS
	mem [CCSR 0x9000] = 0x0000007f
	# DDR2_CS1_BNDS 
	mem [CCSR 0x9008] = 0x00000000
	# DDR2_CS0_CONFIG_2
	mem [CCSR 0x90C0] = 0x00000000
	# DDR2_CS1_CONFIG_2  
	mem [CCSR 0x90C4] = 0x00000000
	# DDR2_DDR_SDRAM_MODE_2 
	mem [CCSR 0x911C] = 0x00100000
	# DDR2_DDR_SDRAM_MODE_4 
	mem [CCSR 0x9204] = 0x00100000
	# DDR2_DDR_SDRAM_MODE_6 
	mem [CCSR 0x920C] = 0x00100000
	# DDR2_DDR_SDRAM_MODE_8 
	mem [CCSR 0x9214] = 0x00100000
	# DDR2_DDR_SDRAM_MD_CNTL
	mem [CCSR 0x9120] = 0x00000000
	# DDR2_DDR_DATA_INIT
	mem [CCSR 0x9128] = 0xdeadbeef
	# DDR2_DDR_SDRAM_CLK_CNTL
	mem [CCSR 0x9130] = 0x02800000
	# DDR2_DDR_INIT_ADDR 
	mem [CCSR 0x9148] = 0x00000000
	# DDR2_DDR_INIT_EXT_ADDRESS
	mem [CCSR 0x914C] = 0x00000000
	# DDR2_TIMING_CFG_4
	mem [CCSR 0x9160] = 0x00000001
	# DDR2_DDR_ZQ_CNTL
	mem [CCSR 0x9170] = 0x89080600
	# DDR2_DDR_SR_CNTR
	mem [CCSR 0x917C] = 0x00000000
	# DDR2_DDR_WRLVL_CNTL_2
	mem [CCSR 0x9190] = 0x00000000
	# DDR2_DDR_WRLVL_CNTL_3 
	mem [CCSR 0x9194] = 0x00000000
	# DDR2_DDRCDR_1
	mem [CCSR 0x9B28] = 0x00000000
	# DDR2_DDRCDR_2
	mem [CCSR 0x9B2C] = 0x00000000
	# DDR2_ERR_SBE
	mem [CCSR 0x9E58] = 0x00000000

	if {$freq == 1200} {
		# delay before enable
		wait 1000
		# DDR1_DDR_SDRAM_CFG 
		mem [CCSR 0x8110] = 0xc7044000
		# DDR2_DDR_SDRAM_CFG 
		mem [CCSR 0x9110] = 0xc7044000
		# wait for DRAM data initialization
		wait 2000
	} elseif {$freq == 1300} {
		# delay before enable
		wait 1000
		# DDR1_DDR_SDRAM_CFG 
		mem [CCSR 0x8110] = 0xe7044000
		# DDR2_DDR_SDRAM_CFG 
		mem [CCSR 0x9110] = 0xe7044000
		# wait for DRAM data initialization
		wait 2000
	}
	
	
	##################################################################################
    # Serial RapidIO - enable timeouts such that cores can be stopped succesfully

    # set timers to max values
	# SRIO_PLTOCCSR
    mem [CCSR 0xC0120] = 0xFFFFFF00
	# SRIO_PRTOCCSR
    mem [CCSR 0xC0124] = 0xFFFFFF00
    
	# SRIO_P1LOPTTLCR
    mem [CCSR 0xD0124] = 0xFFFFFF00
	# SRIO_P2LOPTTLCR
    mem [CCSR 0xD01A4] = 0xFFFFFF00
    
    # set all bits
	# SRIO_P1ERECSR
    mem [CCSR 0xC0644] = 0x007E0037
	# SRIO_P2ERECSR
    mem [CCSR 0xC0684] = 0x007E0037	
	
	# configure internal CPC1 as L3 cache

#RAHUL	

# Partition 1 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10200] = 0x40000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10208] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1020C] = 0xf0000000

# Partition 2 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10210] = 0x20000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10218] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1021C] = 0x0f000000	
	
# Partition 3 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10220] = 0x10000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10228] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1022C] = 0x00f00000	
	
# Partition 4 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10230] = 0x08000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10238] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1023C] = 0x000f0000	
	
# Partition 5 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10240] = 0x04000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10248] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1024C] = 0x0000f000	
	
# Partition 6 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10250] = 0x02000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10258] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1025C] = 0x00000f00	
	
# Partition 7 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10260] = 0x01000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10268] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1026C] = 0x000000f0	
	
# Partition 8 of L3 cache, CPC 1
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x10270] = 0x00800000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x10278] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1027C] = 0x0000000f	
	
#RAHUL


	
	# CPC1_CPCSRCR0  - SRBARL=0, INTLVEN=0, SRAMSZ=0, SRAMEN=0
	mem [CCSR 0x10104] = 0x00000000
	# CPC1_CPCEWCR0 - disable stashing
	mem [CCSR 0x10010] = 0x00000000
	# CPC1_CPCERRDIS 
	mem [CCSR 0x10E44] = 0x00000000
	# invalidate(CPCFI) and No flash lock clear(CPCLFC)
	# CPC1_CPCCSR0
	mem [CCSR 0x10000] = 0x00283400
	wait 500	
	# enable L3 cache
	# CPC1_CPCCSR0
	mem [CCSR 0x10000] = 0xC0083000
	
	# configure internal CPC1 as L3 cache
	
#RAHUL
	
# Partition 1 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11200] = 0x40000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11208] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1120C] = 0xf0000000	

# Partition 2 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11210] = 0x20000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11218] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1121C] = 0x0f000000	

# Partition 3 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11220] = 0x10000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11228] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1122C] = 0x00f00000	

# Partition 4 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11230] = 0x08000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11238] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1123C] = 0x000f0000	

# Partition 5 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11240] = 0x04000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11248] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1124C] = 0x0000f000	

# Partition 6 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11250] = 0x02000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11258] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1125C] = 0x00000f00	

# Partition 7 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11260] = 0x01000000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11268] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1126C] = 0x000000f0	

# Partition 8 of L3 cache, CPC 2
# CPC partition ID register 0 (CPC1_CPCPIR0)
	mem [CCSR 0x11270] = 0x00800000
# CPC partition allocation register 0 (CPC1_CPCPAR0)
	mem [CCSR 0x11278] = 0x000004A0
# CPC partition way register 0 (CPC1_CPCPWR0)
	mem [CCSR 0x1127C] = 0x0000000f

	
#RAHUL
	
	# CPC2_CPCSRCR0  - SRBARL=0, INTLVEN=0, SRAMSZ=0, SRAMEN=0
	mem [CCSR 0x11104] = 0x00000000
	# CPC2_CPCEWCR0 - disable stashing
	mem [CCSR 0x11010] = 0x00000000
	# CPC2_CPCERRDIS 
	mem [CCSR 0x11E44] = 0x00000000
	# invalidate(CPCFI) and No flash lock clear(CPCLFC)
	# CPC2_CPCCSR0
	mem [CCSR 0x11000] = 0x00283400
	wait 500	
	# enable L3 cache
	# CPC2_CPCCSR0
	mem [CCSR 0x11000] = 0xC0083000
}

proc P4080DS_init_core_cacheon {} {
	
	##################################################################################
	#	
	#	Memory Map
	#
	#   0x00000000  0x7FFFFFFF  DDR        2G
	#   0x80000000  0x9FFFFFFF  PEX1       512M
	#   0xA0000000  0xBFFFFFFF  PEX2       512M
	#   0xC0000000  0xDFFFFFFF  PEX3       512M
	#   0xE0000000	0xEFFFFFFF  LocalBus   256M		 
	#   0xF4000000	0xF41FFFFF  BMAN       2M
	#   0xF4200000	0xF43FFFFF  QMAN       2M
	#   0xF8000000  0xF800FFFF  PEX1 I/O   64K
	#   0xF8010000  0xF801FFFF  PEX2 I/O   64K
	#   0xF8020000  0xF802FFFF  PEX3 I/O   64K
	#   0xFE000000  0xFEFFFFFF  CCSR Space 16M
	#   0xFFDF0000  0xFFDF0FFF  PIXIS      4K
	#   0xFFFFF000  0xFFFFFFFF  Boot Page  4k
	#
	##################################################################################
	
	global master_core
	
	variable CAM_GROUP "regPPCTLB1/"
	variable SPR_GROUP "e500mc Special Purpose Registers/"
	variable GPR_GROUP "General Purpose Registers/"
	
	##################################################################################
	# MMU initialization
	
	set CCSR_EPN [string range [CCSR 1] 4 11]
	set CCSR_RPN [string range [CCSR 0] 4 11]
	set PIXIS_EPN [string range [PIXIS 1] 4 11]
	set PIXIS_RPN [string range [PIXIS 0] 4 11]
	
	# define 16MB  TLB entry  1: 0xFE000000 - 0xFEFFFFFF for CCSR    cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM1 = 0x7000000A1C080000${CCSR_RPN}${CCSR_EPN}

	# define 256MB TLB entry  2: 0xE0000000 - 0xEFFFFFFF for LB      cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM2 = 0x9000000A1C080000E0000000E0000001
	
	# define  1GB  TLB entry  3: 0x80000000 - 0xBFFFFFFF for PEX1/2  cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM3 = 0xA000000A1C0800008000000080000001
	
	# define 256MB TLB entry  4: 0xC0000000 - 0xCFFFFFFF for PEX3    cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM4 = 0x9000000A1C080000C0000000C0000001
	
	# define 256MB TLB entry  5: 0xD0000000 - 0xDFFFFFFF for PEX3    cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM5 = 0x9000000A1C080000D0000000D0000001
	
	# define 256KB TLB entry  6: 0xF8000000 - 0xF803FFFF for PEX I/0 cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM6 = 0x4000000A1C080000F8000000F8000001
		
	# define   1GB TLB entry  7: 0x00000000 - 0x3FFFFFFF for DDR     cacheable
	reg ${CAM_GROUP}L2MMU_CAM7 = 0xA00000061C0800000000000000000001
	
	# define   1GB TLB entry  8: 0x40000000 - 0x7FFFFFFF for DDR     cacheable
	reg ${CAM_GROUP}L2MMU_CAM8 = 0xA00000061C0800004000000040000001
	
	# define   1MB TLB entry  9: 0xF4000000 - 0xF40FFFFF for BMAN    cacheable
	reg ${CAM_GROUP}L2MMU_CAM9 = 0x500000041C080000F4000000F4000001
	
	# define   1MB TLB entry 10: 0xF4100000 - 0xF41FFFFF for BMAN    cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM10 = 0x5000000A1C080000F4100000F4100001
	
	# define   1MB TLB entry 11: 0xF4200000 - 0xF42FFFFF for QMAN    cacheable
	reg ${CAM_GROUP}L2MMU_CAM11 = 0x500000041C080000F4200000F4200001
	
	# define   1MB TLB entry 12: 0xF4300000 - 0xF43FFFFF for QMAN    cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM12 = 0x5000000A1C080000F4300000F4300001

	# define   4KB TLB entry 13: 0xFFDF0000 - 0xFFDF0FFF for PIXIS   cache inhibited, guarded
	reg ${CAM_GROUP}L2MMU_CAM13 = 0x1000000A1C080000${PIXIS_RPN}${PIXIS_EPN}


	# init board, only when the init is run for master core
	variable proc_id [expr {[reg ${SPR_GROUP}PIR %d -np] >> 5 }]
	if {$proc_id == $master_core} {
        init_board
    }
    
	##################################################################################
	# Interrupt vectors initialization 
	# interrupt vectors in RAM at 0x${proc_id}0000000
	# IVPR (default reset value) 
	set Ret [catch {evaluate __start__SMP}]
	
	if {$Ret} {
		reg ${SPR_GROUP}IVPR = 0x${proc_id}0000000
	} else {
		# SMP project, same interrupt vectors for all cores
		reg ${SPR_GROUP}IVPR = 0x00000000
   }
	
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
	
	###################################################################
	# Enable caches
	
	# L1 init: CFI, CE, ICFI, ICE
#	reg ${SPR_GROUP}L1CSR0 = 0x00000003
#	reg ${SPR_GROUP}L1CSR1 = 0x00000003
	
	# L2 init: L2E, L2FI
#	reg ${SPR_GROUP}L2CSR0 = 0x80210000

    ##################################################################################
    # Enable branch prediction
    reg ${SPR_GROUP}BUCSR = 0x00000200
    
   	##################################################################################
	# Debugger settings
	
	# enable MAS7 update
	reg ${SPR_GROUP}HID0 = 0x00000080
	
	# enable floating point
	reg ${SPR_GROUP}MSR = 0x00002000
	
	# infinite loop at program exception to prevent taking the exception again
	mem v:0x${proc_id}0000700 = 0x48000000
	
	# prevent stack unwinding at entry_point/reset when stack pointer is not initialized
	reg ${GPR_GROUP}SP = 0x0000000F
	
	# CONFIG_BRRL - enable all cores
	if {$proc_id == $master_core} {
		# DCFG_BRR
		mem [CCSR 0xE00E4] = 0x000000ff
		# RCPM_CTBENR
		mem [CCSR 0xE2084] = 0x000000ff
	}	
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
  
  P4080DS_init_core_cacheon