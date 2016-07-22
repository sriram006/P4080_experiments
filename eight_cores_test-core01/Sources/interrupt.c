#include <stdio.h>

#ifdef __cplusplus
extern "C" {
#endif

void InterruptHandler(long cause);

#ifdef __cplusplus
}
#endif

void InterruptHandler(long cause)
{
	unsigned long proc_id;
	
	/* recover floating point enable in MSR for printf */
	asm ("mfmsr 0;"
		 "ori 0, 0, 0x2000;" /* set MSR[FP] */
		 "mtmsr 0 \n"
		 : /* no output */
		 : /* no input */
		 : "0"  /* clobbered register */
		 );
	
	/* read processor id */
	asm ("mfpir %0" : "=r" (proc_id));

	printf("Core%lu: InterruptHandler: %#lx exception.\r\n", proc_id>>5, cause);
}
