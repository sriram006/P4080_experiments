#ifdef __cplusplus
extern "C" {
#endif

void InterruptHandler(long cause);

#ifdef __cplusplus
}
#endif

void InterruptHandler(long cause)
{
	/* recover floating point enable in MSR for printf */
	asm ("mfmsr 0;"
		 "ori 0, 0, 0x2000;" /* set MSR[FP] */
		 "mtmsr 0 \n"
		 : /* no output */
		 : /* no input */
		 : "0"  /* clobbered register */
		 );
}
