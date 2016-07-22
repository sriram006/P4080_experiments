################################################################################
# Automatically-generated file. Do not edit!
################################################################################

#Progress monitor hint: 4
first : all
-include ../makefile.init

# This file contains definitions of environment variables used in the makefiles and .args files if exist.
-include makefile.local

RM := "$(GNU_Make_Install_DirEnv)/rm" -f

# All of the sources participating in the build are defined here
-include sources.mk
-include subdir.mk
-include Sources/subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
ifneq ($(strip $(SX_DEPS)),)
-include $(SX_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
endif

-include ../makefile.defs

# Add inputs and outputs from these tool invocations to the build variables 
EXECUTABLES += \
eight_cores_test-core05.elf \

EXECUTABLES_QUOTED += \
"eight_cores_test-core05.elf" \

EXECUTABLES_OS_FORMAT += \
eight_cores_test-core05.elf \


# All Target
all: warning-messages explicit-dependencies eight_cores_test-core05.elf

# Tool invocations
eight_cores_test-core05.elf: $(OBJS) $(USER_OBJS) ../LCF/P4080DS_gcc-eabi_core5.lcf
	@echo 'Building target: $@'
	@echo 'Executing target #5 $@'
	@echo 'Invoking: PowerPC EABI e500mc C Linker'
	"$(PAGccEabiE500mcDirEnv)/powerpc-eabi-gcc"  $(USER_OBJS_QUOTED)  @"eight_cores_test-core05.args" -o"eight_cores_test-core05.elf"
	@echo 'Finished building target: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) "./*/*.o"  $(SX_DEPS_QUOTED) $(EXECUTABLES_QUOTED) $(S_UPPER_DEPS_QUOTED) "./*/*.d"  $(ProjDirPath)/RAM/eight_cores_test-core05.elf
	-@echo ' '

.PHONY: all clean dependents explicit-dependencies warning-messages
.SECONDARY:

-include ../makefile.targets

explicit-dependencies: ../LCF/P4080DS_gcc-eabi_core5.lcf 

warning-messages: 

