//////////////////////////
//	Project Stationery  //
//////////////////////////

#include <stdio.h>

#define CPC_LATENCY
//#define CPC_CACHE_HITS
//#define COHERENCY_TRAFFIC

#define NUM_MEM_ACCESS			256

#if SMPTARGET
	#include "smp_target.h"
#endif

#ifdef CPC_LATENCY

int main()
{
	volatile int array[NUM_MEM_ACCESS][16];
	volatile int index;
	volatile int new_num;
		
	#if SMPTARGET
		initSmp();
	#endif

	for(index = 0; index < NUM_MEM_ACCESS; index++)
	{
		array[index][15] = index;
	}  
	
	index = 0;
	
	for(index = 0; index < (NUM_MEM_ACCESS); index++)
	{
		new_num = array[index][15];
	}

	return new_num;
}

#else

#ifdef CPC_CACHE_HITS

int main()
{
	volatile int array[NUM_MEM_ACCESS][16];
	int index;
	volatile int new_num;
		
	#if SMPTARGET
		initSmp();
	#endif
		
	for(index = 0; index < NUM_MEM_ACCESS; index++)
	{
		array[index][15] = index;
	}  
	
	return 0;
}

#else

#ifdef COHERENCY_TRAFFIC

int main()
{
	volatile int index;
	volatile int new_num[NUM_MEM_ACCESS];
	
	volatile int * ptr = (int*)0x603defd0;
	
#if SMPTARGET
	initSmp();
#endif

	while(1)
	{
		for(index = 0; index < NUM_MEM_ACCESS; index++)
		{
			*ptr = 1;
		}
	}
	
	return 0;
}

#else

int main()
{
	volatile int array[NUM_MEM_ACCESS];
	volatile int index;
	volatile int new_num[NUM_MEM_ACCESS];
	
#if SMPTARGET
	initSmp();
#endif
	
	for(index = 0; index < NUM_MEM_ACCESS; index++)
	{
		array[index] = index;
	}  
	
	for(index = 0; index < (NUM_MEM_ACCESS); index++)
	{
		new_num[index] = array[index];
	}

	return 0;
}
#endif

#endif


#endif

