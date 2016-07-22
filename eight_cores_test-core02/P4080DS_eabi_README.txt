#-------------------------------------------------------------------------------------
#	P4080DS README
#-------------------------------------------------------------------------------------

This stationery project is designed to get you up and running
quickly with CodeWarrior for Power Architecture Development Studio.
It is set up for a particular evaluation board, but can be easily modified
to target custom hardware.  The hardware specific changes that
you may need to make include hardware initialization code, 
UART driver, flash programming code, and possibly the linker
command file for memory map issues.

The New Power Architecture Project wizard can create 8 projects, one for each 
core of P4080. The first core's project (core 0) is responsible for initializing 
the board. The projects for other than first core only initialize core specific
options, not the whole platform. Therefore launching projects for other cores
require that the core 0's project is running.


#-------------------------------------------------------------------------------------
#	P4080 DS (Expedition) README
#-------------------------------------------------------------------------------------

The init files can handle the following switch configuration:

 SW1 : 0x6B = 01101011		 SW5 : 0xFF = 11111111		 SW9 : 0xE4 = 11100100
 SW2 : 0xFF = 11111111		 SW6 : 0x02 = 00000010           SW10: 0x03 = 00000011
 SW3 : 0x0C = 00001100		 SW7 : 0x0F = 00001111
 SW4 : 0xFE = 11111110		 SW8 : 0xB2 = 10110010
 
Where '1' = up/ON

--------------------------------------------------------------------------------------
RCW for frequencies: CPU: 1500 MHz, CCB: 800MHz, DDR: 1300 MHz, SYSCLK: 100 MHz
--------------------------------------------------------------------------------------
	   
	   105a0000 00000000 1e1e181e 0000cccc
	   40464003 3c3c2000 fe800000 e1000000
	   00000000 00000000 00000000 008b6000
	   00000000 00000000 00000000 00000000
	   
--------------------------------------------------------------------------------------
RCW for frequencies: CPU: 1200 MHz, CCB: 600MHz, DDR: 1200 MHz, SYSCLK: 100 MHz
--------------------------------------------------------------------------------------
	   
	   4c580000 00000000 18185218 0000cccc
       40464000 3c3c2000 de800000 e1000000
       00000000 00000000 00000000 008b6000
       00000000 00000000 00000000 00000000

    RCW from: eLBC - GPCM (NOR Flash 16-bit)
    Boot from: eLBC flash bank 0

 	Recommanded JTAG clock speeds P4080DS
#------------------------------------------

USB TAP      : 10256 KHz
Ethernet TAP : 16000 KHz
Gigabit TAP  : 16000 KHz

In order to use the GTAP - JTAG through base Aurora Interface set SW8.8 to the ON position.
Also you must set your RSE System Connection Type to "JTAG over Aurora cable" in CodeWarrior.
 

 	Overriding RCW from JTAG
#-----------------------------#

You can have CodeWarrior override RCW values through JTAG at reset. For this you
need to use a JTAG config file that specifies the values to override. You can see
exemples of JTAG config files for P4080 (with comments inline) in
<CWInstallDir>\PA_10.0\PA_Support\Initialization_Files\jtag_chains\

 	Memory map and initialization
#-----------------------------------#

	Memory Map

   0x00000000  0x7FFFFFFF  DDR        2G     (LAW 31)	
   0x80000000  0x9FFFFFFF  PEX1       512M   (LAW 1)
   0xA0000000  0xBFFFFFFF  PEX2       512M   (LAW 3)
   0xC0000000  0xDFFFFFFF  PEX3       512M   (LAW 5)
   0xE0000000  0xEFFFFFFF  LocalBus   256M   (LAW 0)	 
   0xF4000000  0xF41FFFFF  BMAN       2M     (LAW 7)
   0xF4200000  0xF43FFFFF  QMAN       2M     (LAW 8)
   0xF8000000  0xF800FFFF  PEX1 I/O   64K    (LAW 2)
   0xF8010000  0xF801FFFF  PEX2 I/O   64K    (LAW 4)
   0xF8020000  0xF802FFFF  PEX3 I/O   64K    (LAW 6)
   0xFFDF0000  0xFFDF0FFF  PIXIS      4K     (LAW 9)
   0xFE000000  0xFEFFFFFF  CCSR Space 16M
   0xFFFFF000  0xFFFFFFFF  Boot Page  4k

 	NOR Flash
#----------------#

Please consult the Flash Programmer Release Notes for more details on flash programming

The flash address range on P4080DS is 0xE8000000 - 0xEFFFFFFF.
Each flash sector is 128KB and there are 1024 sectors for a total of 128MB of NOR flash space. 

The flash space is further divided into 8 virtual banks.

_________
|Bank7	| <----- RCW for the u-boot at Bank 0 is in this bank at address 0xe8000000
|Bank6	|
|Bank5	|
|Bank4	|
|Bank3	|
|Bank2	|
|Bank1	|
|Bank0	| <----- Bank 0 starts at 0xef000000; u-boot at address 0xeff80000 in this bank
---------

Changing SW7[1:4] swaps the banks. Adjust SW7[1:4] to the bank number you want to use.
By default Bank 0 is used (SW7[1:4] = 0000). This means bootcode will is always NOR Flash Bank 0,
and the RCW is at Bank 7 (address 0xe8000000).
RCW for Bank i is in Bank (7-i) 


If you want to use Flash Programmer, you have to select S29GL01GP. 
A preconfigured target task already exists in:
PA_10.0\bin\plugins\support\TargetTask\FlashProgrammer\QorIQ_P4\P4080DS_NOR_FLASH.xml.

CodeWarrior provides a flash programmer cheat-sheet that will guide you through the steps
needed to program the flash.You can access the cheat-sheet from Eclipse 
Help->Cheat Sheets->Using Flash Programmer.

 	Cache support
#---------------------#
The default stationery project for P4080DS also contains a launch configuration with L1, L2 and L3 caches enabled.


#-------------------------------------------------------------------------------------
	 CodeWarrior Debugger Console I/O
#-------------------------------------------------------------------------------------

Every project will print "Welcome to CodeWarrior from Core x!" out of the common 
serial port (DUART1). To view the output, connect a null-modem serial cable from 
the serial port to your computer. Open a terminal program and set it up to match 
these settings:

Baud Rate: 115200
Data Bits: 8
Parity: None
Stop Bits: 1
Flow Control: None

NOTES:

* To be able to debug into the UART library you need to do the following steps:
1. Create a stationary project using the UART option.
2. Build the project
3. Right click on the elf file and select properties.
4. On the "File Mappings" tab see the unmapped files, select them, and click the "Add" button.
5. Browse the local file system path according to the UART source files. Default located in
<CWInstallDir>\PA_10.0\PA_Support\Serial\P4080DS_eabi_serial\Source.
Now you can debug into the UART source files.

* The UART libraries are compiled with a specific CCSRBAR address. For a different
value of the CCSRBAR you need to rebuild the UART library:
1. From your CW install directory, import the 
PA_10.0\PA_Support\Serial\P4080DS_eabi_serial project
2. Switch to the correspondent Build Target (eg DuartA_UC).
Open duart_config.h file and change the value of the "MMR_BASE" accordingly
3. Re-build the project (and copy the output library in you project) 

* The stationery projects use UART1 output by default. If you need to use UART2, please
check the corresponding UART library in the build target and uncheck the default one
(both UART1_P4080DS.eabi.a and UART2_P4080DS.eabi.a are included in the project's Lib folder).
Also please make sure you have the correct library listed in the "Other objects" panel in the project's
Properties > C/C++ Build > Settings > PowerPC EABI e500mc Linker > Miscellaneous.

* If you want to redirect output to a debugger console instead of UART driver, 
please follow above instruction to remove UART1_P4080DS.eabi from the project and instead use the ‘libconsole.a’ 
library from <CWInstallDir>\PA\PA_Support\SystemCallSupport\libconsole\lib\e500mc\libconsole.a or the project Lib Folder.
Also please make sure you "Activate Support for System Services" in the "System Call Services" sub-tab
from the "Debugger" tab in the corresponding debug launch configuration. 
Also please make sure you have the correct library listed in the "Other objects" panel in the project's
Properties > C/C++ Build > Settings > PowerPC EABI e500mc Linker > Miscellaneous.

* The default baud rate is set at ‘115200’. For changing the baud rate in a default project (made with EABI toolchain) define 
function “UARTBaudRate SetUARTBaudRate (void)” to an appropriate value in the application code. For a project made with Linux toolchain, update
PA\PA_Support\MSL\MSL_C\PPC_EABI\Include\uart_console_config.h 
PA\PA_Support\MSL\MSL_C\PPC_LinuxABI\Include\uart_console_config.h
to an appropriate value in the application code and rebuild the MSL runtime library.


#-------------------------------------------------------------------------------------
# 	Adding your own code
#-------------------------------------------------------------------------------------

Once everything is working as expected, you can begin adding your own code
to the project.  Keep in mind that we provide this as an example of how to
get up and running quickly with CodeWarrior.  There are certainly other 
ways to set up your linker command file or handle interrupts.  Feel free
to modify any of the source provided. 


#-------------------------------------------------------------------------------------
# 	Contacting Freescale
#-------------------------------------------------------------------------------------

You can contact us via email, newsgroups, voice, fax or the 
CodeWarrior website.  For details on contacting Freescale, visit 
http://www.freescale.com/codewarrior, or refer to the front of any 
CodeWarrior manual.

For questions, bug reports, and suggestions, please use the email 
report forms in the Release Notes folder.

For the latest news, offers, and updates for CodeWarrior, browse
Freescale Worldwide.

<http://www.freescale.com>