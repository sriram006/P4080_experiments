#pragma section code_type ".init"

#if SMPTARGET
	#include "smp_target.h"
#endif

#ifdef __cplusplus
extern "C" {
#endif

void __reset(void) __attribute__ ((section (".init")));
void usr_init1() __attribute__ ((section (".init")));
void usr_init2() __attribute__ ((section (".init")));
void init_boot_space_translation() __attribute__ ((section (".init")));

extern void __start();
extern unsigned long gInterruptVectorTable;
extern unsigned long gInterruptVectorTableEnd;

#ifdef __cplusplus
}
#endif


//The next two entries should be added in smp_target.c too in case of SMP project
//# define 256MB TLB entry  2: 0xE0000000 - 0xEFFFFFFF for LB      cache inhibited, guarded
#define INIT_MMU_LB				\
	asm ("lis	5, 0x1002");	\
	asm ("ori 5, 5, 0");		\
	asm ("mtspr 624, 5");		\
								\
	asm ("lis	5, 0x8000");	\
	asm ("ori 5, 5, 0x0900");	\
	asm ("mtspr 625, 5");		\
								\
	asm ("lis	5, 0xe000");	\
	asm ("ori 5, 5, 0x000a");	\
	asm ("mtspr 626, 5");		\
								\
	asm ("lis	5, 0xe000");	\
	asm ("ori 5, 5, 0x0015");	\
	asm ("mtspr 627, 5");		\
								\
	asm ("tlbwe");				\
	asm ("msync");				\
	asm ("isync");	

//# define   1GB TLB entry  8: 0x00000000 - 0x3FFFFFFF for DDR     cache inhibited
#define INIT_MMU_DDR			\
	asm ("lis	5, 0x1008");	\
	asm ("ori 5, 5, 0");		\
	asm ("mtspr 624, 5");		\
								\
	asm ("lis	5, 0x8000");	\
	asm ("ori 5, 5, 0x0a00");	\
	asm ("mtspr 625, 5");		\
								\
	asm ("lis	5, 0x0000");	\
	asm ("ori 5, 5, 0x000E");	\
	asm ("mtspr 626, 5");		\
								\
	asm ("lis	5, 0x0000");	\
	asm ("ori 5, 5, 0x0015");	\
	asm ("mtspr 627, 5");		\
								\
	asm ("tlbwe");				\
	asm ("msync");				\
	asm ("isync");

void __reset(void)
{
	//
	//   Enable machine check exceptions, SPE, debug interrupts
	//
	asm("lis		3, 0x0200");
	asm("ori		3, 3, 0x1200\n");
	asm("mtmsr	3");
	asm("b		__start");
}

#ifdef __cplusplus
extern "C" {
#endif

	extern volatile const unsigned long DdrCtrlArray_1300[];
	extern volatile const unsigned long DdrCtrlArray_1200[];
	extern volatile const unsigned long ics307[];
	
#ifdef __cplusplus
}
#endif	

// reserve registers r17-r19 to be used for the DDR frequency detection mechanism 
register unsigned int  	mem_pll_rat 		asm ("r17");
register unsigned int	selected_freq_ddr   asm ("r18"); 
register unsigned int 	freq_utils  		asm ("r19");

//ICS307 System clock synthesizer; this values can be calculated from the ICS307 
//data sheet examples, or using the convenient online calculator IDT provides
volatile const unsigned long ics307[] __attribute__ ((section (".init_data"))) = {10, 2, 8, 4, 5, 7, 3, 6}; 

volatile const unsigned long DdrCtrlArray_1300[] __attribute__ ((section (".init_data"))) =
{
		0xfe008110, 0x67044000,		//DDR1_DDR_SDRAM_CFG
		0xfe008000, 0x0000007f,		//DDR1_CS0_BNDS
		0xfe008008, 0x00000000,		//DDR1_CS1_BNDS
		0xfe008080, 0xa0044202,		//DDR1_CS0_CONFIG
		0xfe008084, 0x80004202,		//DDR1_CS1_CONFIG
		0xfe0080c0, 0x00000000,		//DDR1_CS0_CONFIG_2
		0xfe0080c4, 0x00000000,		//DDR1_CS1_CONFIG_2
		0xfe008100, 0x01041000,		//DDR1_TIMING_CFG_3
		0xfe008104, 0x50110104,		//DDR1_TIMING_CFG_0
		0xfe008108, 0x98910a45,		//DDR1_TIMING_CFG_1
		0xfe00810c, 0x0fb8a914,		//DDR1_TIMING_CFG_2
		0xfe008114, 0x24401111,		//DDR1_DDR_SDRAM_CFG_2
		0xfe008118, 0x00441a50,		//DDR1_DDR_SDRAM_MODE
		0xfe00811c, 0x00100000,		//DDR1_DDR_SDRAM_MODE_2
		0xfe008200, 0x00001a50,		//DDR1_DDR_SDRAM_MODE_3
		0xfe008204, 0x00100000,		//DDR1_DDR_SDRAM_MODE_4
		0xfe008208, 0x00001a50,		//DDR1_DDR_SDRAM_MODE_5
		0xfe00820C, 0x00100000,		//DDR1_DDR_SDRAM_MODE_6
		0xfe008210, 0x00001a50,		//DDR1_DDR_SDRAM_MODE_7
		0xfe008214, 0x00100000,		//DDR1_DDR_SDRAM_MODE_8
		0xfe008120, 0x00000000,		//DDR1_DDR_SDRAM_MD_CNTL
		0xfe008124, 0x13ce0100,		//DDR1_DDR_SDRAM_INTERVAL
		0xfe008128, 0xdeadbeef,		//DDR1_DDR_DATA_INIT
		0xfe008130, 0x02800000,		//DDR1_DDR_SDRAM_CLK_CNTL
		0xfe008148,	0x00000000,		//DDR1_DDR_INIT_ADDR
		0xfe00814c,	0x00000000,		//DDR1_DDR_INIT_EXT_ADDRESS
		0xfe008160, 0x00000001,		//DDR1_TIMING_CFG_4
		0xfe008164, 0x03401400,		//DDR1_TIMING_CFG_5
		0xfe008170, 0x89080600,		//DDR1_DDR_ZQ_CNTL
		0xfe008174, 0x8675f607,		//DDR1_DDR_WRLVL_CNTL
		0xfe00817c, 0x00000000,		//DDR1_DDR_SR_CNTR
		0xfe008190, 0x00000000,		//DDR1_DDR_WRLVL_CNTL_2
		0xfe008194, 0x00000000,		//DDR1_DDR_WRLVL_CNTL_3
		0xfe008b28, 0x00000000,		//DDR1_DDRCDR_1
		0xfe008b2c, 0x00000000,		//DDR1_DDRCDR_2
		0xfe008e58, 0x00000000,		//DDR1_ERR_SBE
		0xfe009110, 0x67044000,		//DDR2_DDR_SDRAM_CFG
		0xfe009000, 0x0000007f,		//DDR2_CS0_BNDS
		0xfe009008, 0x00000000,		//DDR2_CS1_BNDS
		0xfe009080, 0xa0044202,		//DDR2_CS0_CONFIG
		0xfe009084, 0x80004202,		//DDR2_CS1_CONFIG
		0xfe0090c0, 0x00000000,		//DDR2_CS0_CONFIG_2
		0xfe0090c4, 0x00000000,		//DDR2_CS1_CONFIG_2
		0xfe009100, 0x01041000,		//DDR2_TIMING_CFG_3
		0xfe009104, 0x50110104,		//DDR2_TIMING_CFG_0
		0xfe009108, 0x98910a45,		//DDR2_TIMING_CFG_1
		0xfe00910c, 0x0fb8a914,		//DDR2_TIMING_CFG_2
		0xfe009114, 0x24401111,		//DDR2_DDR_SDRAM_CFG_2
		0xfe009118, 0x00441a50,		//DDR2_DDR_SDRAM_MODE
		0xfe00911c, 0x00100000,		//DDR2_DDR_SDRAM_MODE_2
		0xfe009200, 0x00001a50,		//DDR2_DDR_SDRAM_MODE_3
		0xfe009204, 0x00100000,		//DDR2_DDR_SDRAM_MODE_4
		0xfe009208, 0x00001a50,		//DDR2_DDR_SDRAM_MODE_5
		0xfe00920C, 0x00100000,		//DDR2_DDR_SDRAM_MODE_6
		0xfe009210, 0x00001a50,		//DDR2_DDR_SDRAM_MODE_7
		0xfe009214, 0x00100000,		//DDR2_DDR_SDRAM_MODE_8
		0xfe009120, 0x00000000,		//DDR2_DDR_SDRAM_MD_CNTL
		0xfe009124, 0x13ce0100,		//DDR2_DDR_SDRAM_INTERVAL
		0xfe009128, 0xdeadbeef,		//DDR2_DDR_DATA_INIT
		0xfe009130, 0x02800000,		//DDR2_DDR_SDRAM_CLK_CNTL
		0xfe009148,	0x00000000,		//DDR2_DDR_INIT_ADDR
		0xfe00914c,	0x00000000,		//DDR2_DDR_INIT_EXT_ADDRESS
		0xfe009160, 0x00000001,		//DDR2_TIMING_CFG_4
		0xfe009164, 0x03401400,		//DDR2_TIMING_CFG_5
		0xfe009170, 0x89080600,		//DDR2_DDR_ZQ_CNTL
		0xfe009174, 0x8675f607,		//DDR2_DDR_WRLVL_CNTL
		0xfe00917c, 0x00000000,		//DDR2_DDR_SR_CNTR
		0xfe009190, 0x00000000,		//DDR2_DDR_WRLVL_CNTL_2
		0xfe009194, 0x00000000,		//DDR2_DDR_WRLVL_CNTL_3
		0xfe009b28, 0x00000000,		//DDR2_DDRCDR_1
		0xfe009b2c, 0x00000000,		//DDR2_DDRCDR_2
		0xfe009e58, 0x00000000,		//DDR2_ERR_SBE
};

volatile const unsigned long DdrCtrlArray_1200[] __attribute__ ((section (".init_data"))) =
{
		0xfe008110, 0x47044000,		//DDR1_DDR_SDRAM_CFG
		0xfe008000, 0x0000007f,		//DDR1_CS0_BNDS
		0xfe008008, 0x00000000,		//DDR1_CS1_BNDS
		0xfe008080, 0xa0014202,		//DDR1_CS0_CONFIG
		0xfe008084, 0x80014202,		//DDR1_CS1_CONFIG
		0xfe0080c0, 0x00000000,		//DDR1_CS0_CONFIG_2
		0xfe0080c4, 0x00000000,		//DDR1_CS1_CONFIG_2
		0xfe008100, 0x01030000,		//DDR1_TIMING_CFG_3
		0xfe008104, 0x40550804,		//DDR1_TIMING_CFG_0
		0xfe008108, 0x868fa945,		//DDR1_TIMING_CFG_1
		0xfe00810c, 0x0fb8a912,		//DDR1_TIMING_CFG_2
		0xfe008114, 0x24401011,		//DDR1_DDR_SDRAM_CFG_2
		0xfe008118, 0x00421a40,		//DDR1_DDR_SDRAM_MODE
		0xfe00811c, 0x00100000,		//DDR1_DDR_SDRAM_MODE_2
		0xfe008200, 0x00001a40,		//DDR1_DDR_SDRAM_MODE_3
		0xfe008204, 0x00100000,		//DDR1_DDR_SDRAM_MODE_4
		0xfe008208, 0x00001a40,		//DDR1_DDR_SDRAM_MODE_5
		0xfe00820C, 0x00100000,		//DDR1_DDR_SDRAM_MODE_6
		0xfe008210, 0x00001a40,		//DDR1_DDR_SDRAM_MODE_7
		0xfe008214, 0x00100000,		//DDR1_DDR_SDRAM_MODE_8
		0xfe008120, 0x00000000,		//DDR1_DDR_SDRAM_MD_CNTL
		0xfe008124, 0x12480100,		//DDR1_DDR_SDRAM_INTERVAL
		0xfe008128, 0xdeadbeef,		//DDR1_DDR_DATA_INIT
		0xfe008130, 0x02800000,		//DDR1_DDR_SDRAM_CLK_CNTL
		0xfe008148,	0x00000000,		//DDR1_DDR_INIT_ADDR
		0xfe00814c,	0x00000000,		//DDR1_DDR_INIT_EXT_ADDRESS
		0xfe008160, 0x00000001,		//DDR1_TIMING_CFG_4
		0xfe008164, 0x03402400,		//DDR1_TIMING_CFG_5
		0xfe008170, 0x89080600,		//DDR1_DDR_ZQ_CNTL
		0xfe008174, 0x8675a507,		//DDR1_DDR_WRLVL_CNTL
		0xfe00817c, 0x00000000,		//DDR1_DDR_SR_CNTR
		0xfe008190, 0x00000000,		//DDR1_DDR_WRLVL_CNTL_2
		0xfe008194, 0x00000000,		//DDR1_DDR_WRLVL_CNTL_3
		0xfe008b28, 0x00000000,		//DDR1_DDRCDR_1
		0xfe008b2c, 0x00000000,		//DDR1_DDRCDR_2
		0xfe008e58, 0x00000000,		//DDR1_ERR_SBEL
		0xfe009110, 0x47044000,		//DDR2_DDR_SDRAM_CFG
		0xfe009000, 0x0000007f,		//DDR2_CS0_BNDS
		0xfe009008, 0x00000000,		//DDR2_CS1_BNDS
		0xfe009080, 0xa0014202,		//DDR2_CS0_CONFIG
		0xfe009084, 0x80014202,		//DDR2_CS1_CONFIG
		0xfe0090c0, 0x00000000,		//DDR2_CS0_CONFIG_2
		0xfe0090c4, 0x00000000,		//DDR2_CS1_CONFIG_2
		0xfe009100, 0x01030000,		//DDR2_TIMING_CFG_3
		0xfe009104, 0x40550804,		//DDR2_TIMING_CFG_0
		0xfe009108, 0x868fa945,		//DDR2_TIMING_CFG_1
		0xfe00910c, 0x0fb8a912,		//DDR2_TIMING_CFG_2
		0xfe009114, 0x24401011,		//DDR2_DDR_SDRAM_CFG_2
		0xfe009118, 0x00421a40,		//DDR2_DDR_SDRAM_MODE
		0xfe00911c, 0x00100000,		//DDR2_DDR_SDRAM_MODE_2
		0xfe009200, 0x00001a40,		//DDR2_DDR_SDRAM_MODE_3
		0xfe009204, 0x00100000,		//DDR2_DDR_SDRAM_MODE_4
		0xfe009208, 0x00001a40,		//DDR2_DDR_SDRAM_MODE_5
		0xfe00920C, 0x00100000,		//DDR2_DDR_SDRAM_MODE_6
		0xfe009210, 0x00001a40,		//DDR2_DDR_SDRAM_MODE_7
		0xfe009214, 0x00100000,		//DDR2_DDR_SDRAM_MODE_8
		0xfe009120, 0x00000000,		//DDR2_DDR_SDRAM_MD_CNTL
		0xfe009124, 0x12480100,		//DDR2_DDR_SDRAM_INTERVAL
		0xfe009128, 0xdeadbeef,		//DDR2_DDR_DATA_INIT
		0xfe009130, 0x02800000,		//DDR2_DDR_SDRAM_CLK_CNTL
		0xfe009148,	0x00000000,		//DDR2_DDR_INIT_ADDR
		0xfe00914c,	0x00000000,		//DDR2_DDR_INIT_EXT_ADDRESS
		0xfe009160, 0x00000001,		//DDR2_TIMING_CFG_4
		0xfe009164, 0x03402400,		//DDR2_TIMING_CFG_5
		0xfe009170, 0x89080600,		//DDR2_DDR_ZQ_CNTL
		0xfe009174, 0x8675a507,		//DDR2_DDR_WRLVL_CNTL
		0xfe00917c, 0x00000000,		//DDR2_DDR_SR_CNTR
		0xfe009190, 0x00000000,		//DDR2_DDR_WRLVL_CNTL_2
		0xfe009194, 0x00000000,		//DDR2_DDR_WRLVL_CNTL_3
		0xfe009b28, 0x00000000,		//DDR2_DDRCDR_1
		0xfe009b2c, 0x00000000,		//DDR2_DDRCDR_2
		0xfe009e58, 0x00000000,		//DDR2_ERR_SBEL
};

void usr_init1() {

	//########################################################################################
	//# Initialization file for P4080 DS
	//# Clock Configuration:
	//#       CPU:1200 MHz,    CCB: 500 MHz,
	//#       DDR:1000 MHz, SYSCLK: 100 MHz, LBC: 31.250MHz
	//########################################################################################
	//
	//##################################################################################
	//#
	//#	Memory Map
	//#
	//#   0x00000000  0x7FFFFFFF  DDR        2G
	//#   0x80000000  0x9FFFFFFF  PEX1       512M
	//#   0xA0000000  0xBFFFFFFF  PEX2       512M
	//#   0xC0000000  0xDFFFFFFF  PEX3       512M
	//#   0xE0000000  0xEFFFFFFF  LocalBus   256M
	//#   0xF4000000  0xF41FFFFF  BMAN       2M
	//#   0xF4200000  0xF43FFFFF  QMAN       2M
	//#   0xF8000000  0xF800FFFF  PEX1 I/O   64K
	//#   0xF8010000  0xF801FFFF  PEX2 I/O   64K
	//#   0xF8020000  0xF802FFFF  PEX3 I/O   64K
	//#   0xFE000000  0xFEFFFFFF  CCSR Space 16M
	//#   0xFFDF0000  0xFFDF0FFF  PIXIS      4K
	//#   0xFFFFF000  0xFFFFFFFF  Boot Page  4k
	//#
	//##################################################################################
	//
	//
	//##################################################################################
	//# MMU initialization
	//
	//# define 16MB  TLB entry  1: 0xFE000000 - 0xFEFFFFFF for CCSR    cache inhibited, guarded
	//writereg128 L2MMU_CAM1  0x7000000A 0x1C080000 0xFE000000 0xFE000001

	asm ("lis	5, 0x1001");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0700");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xfe00");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xfe00");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	
	//
	//# define 256MB TLB entry  2: 0xE0000000 - 0xEFFFFFFF for LB      cache inhibited, guarded
	//writereg128 L2MMU_CAM2  0x9000000A 0x1C080000 0xE0000000 0xE0000001		
	INIT_MMU_LB
	
	//
	//# define  1GB  TLB entry  3: 0x80000000 - 0xBFFFFFFF for PEX1/2  cache inhibited, guarded
	//writereg128 L2MMU_CAM3  0xA000000A 0x1C080000 0x80000000 0x80000001	
	asm ("lis	5, 0x1003");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0a00");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define 256MB TLB entry  4: 0xC0000000 - 0xCFFFFFFF for PEX3    cache inhibited, guarded
	//writereg128 L2MMU_CAM4  0x9000000A 0x1C080000 0xC0000000 0xC0000001
	asm ("lis	5, 0x1004");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0900");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xc000");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xc000");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define 256MB TLB entry  5: 0xD0000000 - 0xDFFFFFFF for PEX3    cache inhibited, guarded
	//writereg128 L2MMU_CAM5  0x9000000A 0x1C080000 0xD0000000 0xD0000001
	asm ("lis	5, 0x1005");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0900");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xd000");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xd000");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define 256KB TLB entry  6: 0xF8000000 - 0xF803FFFF for PEX I/0 cache inhibited, guarded
	//writereg128 L2MMU_CAM6  0x4000000A 0x1C080000 0xF8000000 0xF8000001
	asm ("lis	5, 0x1006");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0400");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xf800");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xf800");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define   4KB TLB entry  7: 0xFFDF0000 - 0xFFDF0FFF for PIXIS   cache inhibited, guarded
	//writereg128 L2MMU_CAM7  0x1000000A 0x1C080000 0xFFDF0000 0xFFDF0001
	asm ("lis	5, 0x1007");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0100");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xffdf");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xffdf");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define   1GB TLB entry  8: 0x00000000 - 0x3FFFFFFF for DDR     cache inhibited
	//writereg128 L2MMU_CAM8  0xA0000008 0x1C080000 0x00000000 0x00000001
	INIT_MMU_DDR
	
	//
	//# define   1GB TLB entry  9: 0x40000000 - 0x7FFFFFFF for DDR     cache inhibited
	//writereg128 L2MMU_CAM9  0xA0000008 0x1C080000 0x40000000 0x40000001
	asm ("lis	5, 0x1009");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0a00");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0x4000");
	asm ("ori 5, 5, 0x0008");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0x4000");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define   1MB TLB entry 10: 0xF4100000 - 0xF41FFFFF for BMAN    cache inhibited, guarded
	//writereg128 L2MMU_CAM10 0x5000000A 0x1C080000 0xF4100000 0xF4100001
	asm ("lis	5, 0x100a");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0500");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xf410");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xf410");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define   1MB TLB entry 11: 0xF4200000 - 0xF42FFFFF for QMAN    cache inhibited
	//writereg128 L2MMU_CAM11 0x50000008 0x1C080000 0xF4200000 0xF4200001
	asm ("lis	5, 0x100b");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0500");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xf420");
	asm ("ori 5, 5, 0x0008");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xf420");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define   1MB TLB entry 12: 0xF4300000 - 0xF43FFFFF for QMAN    cache inhibited, guarded
	//writereg128 L2MMU_CAM12 0x5000000A 0x1C080000 0xF4300000 0xF4300001
	asm ("lis	5, 0x100c");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0500");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xf430");
	asm ("ori 5, 5, 0x000a");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xf430");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//# define   1MB TLB entry 13: 0xF4000000 - 0xF40FFFFF for BMAN    cache inhibited
	//writereg128 L2MMU_CAM13 0x50000008 0x1C080000 0xF4000000 0xF4000001
	asm ("lis	5, 0x100d");
	asm ("ori 5, 5, 0");
	asm ("mtspr 624, 5");

	asm ("lis	5, 0x8000");
	asm ("ori 5, 5, 0x0500");
	asm ("mtspr 625, 5");

	asm ("lis	5, 0xf400");
	asm ("ori 5, 5, 0x0008");
	asm ("mtspr 626, 5");

	asm ("lis	5, 0xf400");
	asm ("ori 5, 5, 0x0015");
	asm ("mtspr 627, 5");

	asm ("tlbwe");
	asm ("msync");
	asm ("isync");

	//
	//##################################################################################
	//# Local Access Windows Setup
	//
#if SMPTARGET
	asm("mfpir  7");
	asm("srwi   7, 7, 5");
	asm("cmpwi  7, %0" : : "i" (MASTER_CORE_ID));
	asm("bne  usr_init1_end");
#endif

	//# LAW0 to eLBC - 256M
	//writemem.l 0xFE000c00 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c00@ha");
	asm ("stw	5, 0xFE000c00@l(4)");
	//writemem.l 0xFE000c04 0xE0000000
	asm ("lis	5, 0xe000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c04@ha");
	asm ("stw	5, 0xFE000c04@l(4)");
	//writemem.l 0xFE000c08 0x81f0001b
	asm ("lis	5, 0x81f0");
	asm ("ori	5, 5, 0x001b");
	asm ("lis	4, 0xFE000c08@ha");
	asm ("stw	5, 0xFE000c08@l(4)");
	//
	//# LAW1 to PEX1 - 512MB
	//writemem.l 0xFE000c10 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c10@ha");
	asm ("stw	5, 0xFE000c10@l(4)");
	//writemem.l 0xFE000c14 0x80000000
	asm ("lis	5, 0x8000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c14@ha");
	asm ("stw	5, 0xFE000c14@l(4)");
	//writemem.l 0xFE000c18 0x8000001C
	asm ("lis	5, 0x8000");
	asm ("ori	5, 5, 0x001c");
	asm ("lis	4, 0xFE000c18@ha");
	asm ("stw	5, 0xFE000c18@l(4)");
	//
	//# LAW2 to PEX1 - 64KB
	//writemem.l 0xFE000c20 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c20@ha");
	asm ("stw	5, 0xFE000c20@l(4)");
	//writemem.l 0xFE000c24 0xF8000000
	asm ("lis	5, 0xf800");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c24@ha");
	asm ("stw	5, 0xFE000c24@l(4)");
	//writemem.l 0xFE000c28 0x8000000F
	asm ("lis	5, 0x8000");
	asm ("ori	5, 5, 0x000f");
	asm ("lis	4, 0xFE000c28@ha");
	asm ("stw	5, 0xFE000c28@l(4)");
	//
	//# LAW3 to PEX2 - 512MB
	//writemem.l 0xFE000c30 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c30@ha");
	asm ("stw	5, 0xFE000c30@l(4)");
	//writemem.l 0xFE000c34 0xA0000000
	asm ("lis	5, 0xa000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c34@ha");
	asm ("stw	5, 0xFE000c34@l(4)");
	//writemem.l 0xFE000c38 0x8010001C
	asm ("lis	5, 0x8010");
	asm ("ori	5, 5, 0x001c");
	asm ("lis	4, 0xFE000c38@ha");
	asm ("stw	5, 0xFE000c38@l(4)");
	//
	//# LAW4 to PEX2 - 64KB
	//writemem.l 0xFE000c40 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c40@ha");
	asm ("stw	5, 0xFE000c40@l(4)");
	//writemem.l 0xFE000c44 0xF8010000
	asm ("lis	5, 0xf801");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c44@ha");
	asm ("stw	5, 0xFE000c44@l(4)");
	//writemem.l 0xFE000c48 0x8010000F
	asm ("lis	5, 0x8010");
	asm ("ori	5, 5, 0x000f");
	asm ("lis	4, 0xFE000c48@ha");
	asm ("stw	5, 0xFE000c48@l(4)");
	//
	//# LAW5 to PEX3 - 512MB
	//writemem.l 0xFE000c50 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c50@ha");
	asm ("stw	5, 0xFE000c50@l(4)");
	//writemem.l 0xFE000c54 0xC0000000
	asm ("lis	5, 0xc000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c54@ha");
	asm ("stw	5, 0xFE000c54@l(4)");
	//writemem.l 0xFE000c58 0x8020001C
	asm ("lis	5, 0x8020");
	asm ("ori	5, 5, 0x001c");
	asm ("lis	4, 0xFE000c58@ha");
	asm ("stw	5, 0xFE000c58@l(4)");
	//
	//# LAW6 to PEX3 - 64KB
	//writemem.l 0xFE000c60 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c60@ha");
	asm ("stw	5, 0xFE000c60@l(4)");
	//writemem.l 0xFE000c64 0xF8020000
	asm ("lis	5, 0xf802");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c64@ha");
	asm ("stw	5, 0xFE000c64@l(4)");
	//writemem.l 0xFE000c68 0x8020000F
	asm ("lis	5, 0x8020");
	asm ("ori	5, 5, 0x000f");
	asm ("lis	4, 0xFE000c68@ha");
	asm ("stw	5, 0xFE000c68@l(4)");
	//
	//# LAW7 to BMAN - 2MB
	//writemem.l 0xFE000c70 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c70@ha");
	asm ("stw	5, 0xFE000c70@l(4)");
	//writemem.l 0xFE000c74 0xF4000000
	asm ("lis	5, 0xf400");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c74@ha");
	asm ("stw	5, 0xFE000c74@l(4)");
	//writemem.l 0xFE000c78 0x81800014
	asm ("lis	5, 0x8180");
	asm ("ori	5, 5, 0x0014");
	asm ("lis	4, 0xFE000c78@ha");
	asm ("stw	5, 0xFE000c78@l(4)");
	//
	//# LAW8 to QMAN - 2MB
	//writemem.l 0xFE000c80 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c80@ha");
	asm ("stw	5, 0xFE000c80@l(4)");
	//writemem.l 0xFE000c84 0xF4200000
	asm ("lis	5, 0xf420");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c84@ha");
	asm ("stw	5, 0xFE000c84@l(4)");
	//writemem.l 0xFE000c88 0x83C00014
	asm ("lis	5, 0x83c0");
	asm ("ori	5, 5, 0x0014");
	asm ("lis	4, 0xFE000c88@ha");
	asm ("stw	5, 0xFE000c88@l(4)");
	//
	//# LAW9 to eLBC - PIXIS - 4KB
	//writemem.l 0xFE000c90 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c90@ha");
	asm ("stw	5, 0xFE000c90@l(4)");
	//writemem.l 0xFE000c94 0xFFDF0000
	asm ("lis	5, 0xffdf");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000c94@ha");
	asm ("stw	5, 0xFE000c94@l(4)");
	//writemem.l 0xFE000c98 0x81F0000B
	asm ("lis	5, 0x81f0");
	asm ("ori	5, 5, 0x000b");
	asm ("lis	4, 0xFE000c98@ha");
	asm ("stw	5, 0xFE000c98@l(4)");
	//
	//# LAW31 to DDR1 - 2GB
	//writemem.l 0xFE000df0 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000df0@ha");
	asm ("stw	5, 0xFE000df0@l(4)");
	//writemem.l 0xFE000df4 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000df4@ha");
	asm ("stw	5, 0xFE000df4@l(4)");
	//writemem.l 0xFE000df8 0x8140001E
	asm ("lis	5, 0x8140");
	asm ("ori	5, 5, 0x001E");
	asm ("lis	4, 0xFE000df8@ha");
	asm ("stw	5, 0xFE000df8@l(4)");
	
	asm("usr_init1_end:");
}

void usr_init2() {
	
#if SMPTARGET
	asm("mfpir  7");
	asm("srwi   7, 7, 5");
	asm("cmpwi  7, %0" : : "i" (MASTER_CORE_ID));
	asm("bne  init_vectors");
#endif

	//##################################################################################
	//# eSPI Controller Setup
	// ESPI_SPMODE - 0x80000403
	asm ("lis	5, 0x8000");
	asm ("ori	5, 5, 0x0403");
	asm ("lis	4, 0xfe110000@ha");
	asm ("stw	5, 0xfe110000@l(4)");
	// ESPI_SPIM - 0x00000000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xfe110008@ha");
	asm ("stw	5, 0xfe110008@l(4)");
	// ESPI_SPMODE0 - 0x30170008
	asm ("lis	5, 0x3017");
	asm ("ori	5, 5, 0x0008");
	asm ("lis	4, 0xfe110020@ha");
	asm ("stw	5, 0xfe110020@l(4)");
	
	//
	//##################################################################################
	//# LBC Controller Setup
	//
	//# CS0 - Flash,   addr at 0xE8000000, 128MB size, 16-bit, GCPM, Valid
	//writemem.l 0xfe124000 0xe8001001
	asm ("lis	5, 0xe800");
	asm ("ori	5, 5, 0x1001");
	asm ("lis	4, 0xfe124000@ha");
	asm ("stw	5, 0xfe124000@l(4)");
	//writemem.l 0xfe124004 0xf8000ff7
	asm ("lis	5, 0xf800");
	asm ("ori	5, 5, 0x0ff7");
	asm ("lis	4, 0xfe124004@ha");
	asm ("stw	5, 0xfe124004@l(4)");
	//
	//# CS1 - PromJet, addr at 0xE0000000, 128MB size, 16-bit, GCPM, Valid
	//writemem.l 0xfe124008 0xe0001001
	asm ("lis	5, 0xe000");
	asm ("ori	5, 5, 0x1001");
	asm ("lis	4, 0xfe124008@ha");
	asm ("stw	5, 0xfe124008@l(4)");
	//writemem.l 0xfe12400c 0xf8000ff7
	asm ("lis	5, 0xf800");
	asm ("ori	5, 5, 0x0ff7");
	asm ("lis	4, 0xfe12400c@ha");
	asm ("stw	5, 0xfe12400c@l(4)");
	//
	//# CS2 - PIXIS,   addr at 0xFFDF0000,   1MB size,  8-bit, GCPM, Valid
	//writemem.l 0xfe124018 0xffdf0801
	asm ("lis	5, 0xffdf");
	asm ("ori	5, 5, 0x0801");
	asm ("lis	4, 0xfe124018@ha");
	asm ("stw	5, 0xfe124018@l(4)");
	//writemem.l 0xfe12401c 0xffff8ff7
	asm ("lis	5, 0xffff");
	asm ("ori	5, 5, 0x8ff7");
	asm ("lis	4, 0xfe12401c@ha");
	asm ("stw	5, 0xfe12401c@l(4)");
	//
	//# LBCR
	//writemem.l 0xfe1240d0 0x40000000
	asm ("lis	5, 0x4000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xfe1240d0@ha");
	asm ("stw	5, 0xfe1240d0@l(4)");
	//
	//# LCRR CLKDIV = 16
	//writemem.l 0xfe1240d4 0x80000008
	asm ("lis	5, 0x8000");
	asm ("ori	5, 5, 0x0008");
	asm ("lis	4, 0xfe1240d4@ha");
	asm ("stw	5, 0xfe1240d4@l(4)");
	//
	//
	//##################################################################################
	//# DDR Controller Setup
	//
	//control the 24-bit configuration word of the ICS307 system clock generator
	//PX_SCLK0
	asm ("lis	15, 0xffdf");
	asm ("ori	15, 15, 0x0019");
	asm ("lwz	14, 0(15)");  
	asm ("srwi	14, 14, 0x18");//shift right
	//PX_SCLK1
	asm ("lis	15, 0xffdf");
	asm ("ori	15, 15, 0x001A");
	asm ("lwz	13, 0(15)"); 
	asm ("srwi	13, 13, 0x18");//shift right
	//PX_SCLK2
	asm ("lis	15, 0xffdf");
	asm ("ori	15, 15, 0x001B");
	asm ("lwz	12, 0(15)"); 
	asm ("srwi	12, 12, 0x18");//right shift
	
    // Get the value of SYSCLK
	// SYSCLK = Input Frequency * 2 * (VDW + 8) / ((RDW + 2) * OD)
	// PX_SCLK0:  C1 C0 TTL F1 F0 S2 S1 S0
	// PX_SCLK1:  V8 V7 V6 V5 V4 V3 V2 V1
	// PX_SCLK2:  V0 R6 R5 R4 R3 R2 R1 R0
	//
	// R6:R0 = Reference Divider Word (RDW)
	// V8:V0 = VCO Divider Word (VDW)
	// S2:S0 = Output Divider Select (OD)

	//VDW
	asm ("slwi	11, 13, 0x1");
	asm ("andi.	11, 11, 0x1FE");
	asm ("srwi	10, 12, 0x7");
	asm ("andi.	10, 10, 0x1");
	asm ("addc	11, 11, 10");
	
	//RDW
	asm ("andi.	10, 12, 0x7F");
	
	//OD; it is obtained from ics307
	asm ("andi.	9, 14, 0x7");
	asm ("lis	8, 0x0000");
	asm ("ori	8, 8, 0x0004");
	asm ("mullw	9, 9, 8");
	asm ("lis	4, ics307@h");
	asm ("ori	4, 4, ics307@l");
	asm ("addc	4, 4, 9");
	asm ("lwz	9, 0(4)");
	
	//SYSCLK
	asm ("lis	7, 0x01fc");
	asm ("ori	7, 7, 0x9f08");
	asm ("lis	6, 0x0000");
	asm ("ori	6, 6, 0x0002");
	asm ("mullw	8, 7, 6");
	asm ("addi	11, 11, 0x8");
	asm ("mullw	8, 8, 11");
	asm ("addi	10, 10, 0x2");
	asm ("mullw	10, 10, 9");
	asm ("divw	8, 8, 10");
	
	//RCW1
	asm ("lis	15, 0xfe0e");
	asm ("ori	15, 15, 0x0100");
	asm ("lwz	7, 0(15)");
	
	//FREQSYSBUS
	asm ("srwi	6, 7, 0x19");
	asm ("andi.	6, 6, 0x1f");
	asm ("mullw	5, 8, 6");

	//Mem PLL ratio
	asm ("srwi	6, 7, 0x11");
	asm ("andi.	6, 6, 0x1f");
	asm ("mr %0, 6" : "=r"(mem_pll_rat));

	//FREQDDRBUS
	if (mem_pll_rat > 0x2)
		asm ("mullw	8, 8, 6");
	else
		asm ("mullw	8, 5, 6");

	//parsing the value of FREQDDRBUS to get the value of frequency
	asm ("lis	14, 1000000@ha");
	asm ("ori	14, 14, 1000000@l");
	asm ("divw	8, 8, 14");
	
	// compare the computed frequency with 1250
	asm ("lis	25, 1250@ha");
	asm ("ori	25, 25, 1250@l");

	asm ("cmp	cr3, 25, 8");
	asm ("ble	cr3, freq_1300");
	asm ("freq_1200:");//if the computed frequency is closer to 1200
	asm ("lis	25, 1200@ha");
	asm ("ori	25, 25, 1200@l");//the selected frequency is 1200
	asm ("b	select_frequency");
	asm ("freq_1300:");//if the computed frequency is closer to 1300
	asm ("lis	25, 1300@ha");
	asm ("ori	25, 25, 1300@l");//the selected frequency is 1300
	asm ("b	select_frequency");
	
	asm ("select_frequency:");
	asm ("mr %0, 25" : "=r"(freq_utils));
	
	selected_freq_ddr = freq_utils;
	
	if (selected_freq_ddr == 1200) {
		freq_utils = sizeof(DdrCtrlArray_1200) / (2 * sizeof(unsigned long));
		asm ("mtctr	%0" : "=r" (freq_utils));
		asm ("lis	4, DdrCtrlArray_1200@h");
		asm ("ori	4, 4, DdrCtrlArray_1200@l");
		// save the address of the vector with DDR values in an auxiliary register
		asm ("mr	12, 4");
	}
	else if (selected_freq_ddr == 1300) {
		freq_utils = sizeof(DdrCtrlArray_1300) / (2 * sizeof(unsigned long));
		asm ("mtctr	%0" : "=r" (freq_utils));
		asm ("lis	4, DdrCtrlArray_1300@h");
		asm ("ori	4, 4, DdrCtrlArray_1300@l");
		// save the address of the vector with DDR values in an auxiliary register
		asm ("mr	12, 4");
	}
	
	asm ("ddr_loop:");
	asm ("lwz	3,0(4)");		//put in r3 the address of the register
	asm ("lwz	5,4(4)");		//put in r5 the value of the register
	asm ("addi	4,4,8");		//get to next line 
	asm ("stw	5,0(3)");		//put at the address r3 the value from r5
	asm ("bdnz	ddr_loop");		//repeat until CTR is 0
	
	//# delay before enable
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0fff");
	asm ("mtspr 9 ,5");
	asm ("wait_loop1:");
	asm ("bc    16,0,wait_loop1 ");

	// load the address of the vector with DDR values from the auxiliary register
	asm ("mr	4, 12");
				
	// DDR1_SDRAM_CFG
	//writemem.l 0xfe008110	0xc7040000
	asm ("lwz	3, 0(4)");		//put in r3 the address of DDR1_SDRAM_CFG
	asm ("addi	4, 4, 4");		//get to value of DDR1_SDRAM_CFG
	asm ("lis	6, 0x8000");
	asm ("ori	6, 6, 0x0000"); //set the mask to be applied to set the enable bit
	asm ("lwz	5, 0(4)");		//put in r5 the value of DDR1_SDRAM_CFG(with the enable bit off)
	asm ("or	5, 5, 6");		//set enable bit
	asm ("stw	5, 0(3)");		//put at the address r3 the value from r5
				
	// load the address of the vector with DDR values from the auxiliary register
	asm ("mr	4, 12");
	// move with half of the size of DdrCtrlArray_1200 or DdrCtrlArray_1300
	freq_utils = freq_utils * sizeof(unsigned long);
	asm ("add	4, 4, %0" : "=r"(freq_utils));	// get to DDR2_SDRAM_CFG
				
	// DDR2_SDRAM_CFG
	//writemem.l 0xfe009110	0xc7040000
	asm ("lwz	3, 0(4)");		//put in r3 the address of DDR1_SDRAM_CFG
	asm ("addi	4, 4, 4");		//get to value of DDR2_SDRAM_CFG
	asm ("lis	6, 0x8000");
	asm ("ori	6, 6, 0x0000"); //set the mask to be applied to set the enable bit
	asm ("lwz	5, 0(4)");		//put in r5 the value of DDR2_SDRAM_CFG(with the enable bit off)
	asm ("or	5, 5, 6");		//set enable bit
	asm ("stw	5, 0(3)");		//put at the address r3 the value from r5

	//# wait for DRAM data initialization
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x2ffd");
	asm ("mtspr 9 ,5");
	asm ("wait_loop2:");
	asm ("bc    16,0,wait_loop2 ");

	asm("init_vectors:");
	//##################################################################################
	//# Interrupt vectors initialization
	//
	//
	//# interrupt vectors in RAM at 0x00000000
	//writereg	IVPR 0x00000000 	# IVPR (default reset value)
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("mtspr 63, 5");
	//
	//# interrupt vector offset registers
	//writespr	400 0x00000100	# IVOR0 - critical input
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0100");
	asm ("mtspr 400, 5");
	//writespr	401 0x00000200	# IVOR1 - machine check
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0200");
	asm ("mtspr 401, 5");
	//writespr	402 0x00000300	# IVOR2 - data storage
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0300");
	asm ("mtspr 402, 5");
	//writespr	403 0x00000400	# IVOR3 - instruction storage
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0400");
	asm ("mtspr 403, 5");
	//writespr	404 0x00000500	# IVOR4 - external input
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0500");
	asm ("mtspr 404, 5");
	//writespr	405 0x00000600	# IVOR5 - alignment
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0600");
	asm ("mtspr 405, 5");
	//writespr	406 0x00000700	# IVOR6 - program
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0700");
	asm ("mtspr 406, 5");
	//writespr	408 0x00000c00	# IVOR8 - system call
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0c00");
	asm ("mtspr 408, 5");
	//writespr	410 0x00000900	# IVOR10 - decrementer
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0900");
	asm ("mtspr 410, 5");
	//writespr	411 0x00000f00	# IVOR11 - fixed-interval timer interrupt
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0f00");
	asm ("mtspr 411, 5");
	//writespr	412 0x00000b00	# IVOR12 - watchdog timer interrupt
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0b00");
	asm ("mtspr 412, 5");
	//writespr	413 0x00001100	# IVOR13 - data TLB errror
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x1100");
	asm ("mtspr 413, 5");
	//writespr	414 0x00001000	# IVOR14 - instruction TLB error
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x1000");
	asm ("mtspr 414, 5");
	//writespr	415 0x00001500	# IVOR15 - debug
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x1500");
	asm ("mtspr 415, 5");
	//writespr	531 0x00001900	# IVOR35 - performance monitor
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x1900");
	asm ("mtspr 531, 5");
	//
	//
	//##################################################################################
	//# Debugger settings
	//
	//# enable MAS7 update
	//writereg 	HID0 	0x00000080
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0080");
	asm ("mtspr 1008, 5");
	//
	//# enable floating point
	//writereg 	MSR 	0x00002000
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x2000");
	asm ("mtmsr 5");
	//
	//
	//# prevent stack unwinding at entry_point/reset when stack pointer is not initialized
	//writereg	SP	0x0000000F
	//

	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	//
	// Copy the exception vectors from ROM to RAM
	//
	////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
	asm ("__copy_vectors:");
	asm ("lis		3, gInterruptVectorTable@h");
	asm ("ori		3, 3, gInterruptVectorTable@l");
	asm ("subi		3,3,0x0004");

	asm ("lis		4, gInterruptVectorTableEnd@h");
	asm ("ori		4, 4, gInterruptVectorTableEnd@l");

	asm ("lis		5, 0xFFFF");
	asm ("ori		5,5,0xFFFC");

	asm ("loop:");
	asm ("	lwzu	6, 4(3)");
	asm ("	stwu	6, 4(5)");

	asm ("	cmpw	3,4");
	asm ("	blt		loop");

	/*-----------------------------------------------------------------*/
}

void init_boot_space_translation() {
	
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x0000");
	asm ("lis	4, 0xFE000020@ha");
	asm ("stw	5, 0xFE000020@l(4)");
	//writemem.l 0xFE000024 0x10000000
	asm ("lis	5, 0xEFFF");
	asm ("ori	5, 5, 0xD000");
	asm ("lis	4, 0xFE000024@ha");
	asm ("stw	5, 0xFE000024@l(4)");
	//writemem.l 0xFE000028 0x8100000b
	asm ("lis	5, 0x81f0");
	asm ("ori	5, 5, 0x000b");
	asm ("lis	4, 0xFE000028@ha");
	asm ("stw	5, 0xFE000028@l(4)");
	
	//writemem.l 0xfe0e00e4 0x000000ff
	asm ("lis	5, 0x0000");
	asm ("ori	5, 5, 0x00ff");
	asm ("lis	4, 0xfe0e00e4@ha");
	asm ("stw	5, 0xfe0e00e4@l(4)");
}
