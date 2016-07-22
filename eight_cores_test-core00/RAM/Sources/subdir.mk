################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.local

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS_QUOTED += \
"../Sources/__start_e500mc_crt0.c" \
"../Sources/interrupt.c" \
"../Sources/main.c" \

ASM_SRCS += \
../Sources/pa_exception.asm \

C_SRCS += \
../Sources/__start_e500mc_crt0.c \
../Sources/interrupt.c \
../Sources/main.c \

ASM_SRCS_QUOTED += \
"../Sources/pa_exception.asm" \

OBJS += \
./Sources/__start_e500mc_crt0.o \
./Sources/interrupt.o \
./Sources/main.o \
./Sources/pa_exception.o \

C_DEPS += \
./Sources/__start_e500mc_crt0.d \
./Sources/interrupt.d \
./Sources/main.d \

OBJS_QUOTED += \
"./Sources/__start_e500mc_crt0.o" \
"./Sources/interrupt.o" \
"./Sources/main.o" \
"./Sources/pa_exception.o" \

OBJS_OS_FORMAT += \
./Sources/__start_e500mc_crt0.o \
./Sources/interrupt.o \
./Sources/main.o \
./Sources/pa_exception.o \

C_DEPS_QUOTED += \
"./Sources/__start_e500mc_crt0.d" \
"./Sources/interrupt.d" \
"./Sources/main.d" \


# Each subdirectory must supply rules for building sources it contributes
Sources/__start_e500mc_crt0.o: ../Sources/__start_e500mc_crt0.c
	@echo 'Building file: $<'
	@echo 'Executing target #1 $<'
	@echo 'Invoking: PowerPC EABI e500mc C Compiler'
	"$(PAGccEabiE500mcDirEnv)/powerpc-eabi-gcc" "$<" @"Sources/__start_e500mc_crt0.args" -MMD -MP -MF"$(@:%.o=%.d)" -o"Sources/__start_e500mc_crt0.o"
	@echo 'Finished building: $<'
	@echo ' '

Sources/interrupt.o: ../Sources/interrupt.c
	@echo 'Building file: $<'
	@echo 'Executing target #2 $<'
	@echo 'Invoking: PowerPC EABI e500mc C Compiler'
	"$(PAGccEabiE500mcDirEnv)/powerpc-eabi-gcc" "$<" @"Sources/interrupt.args" -MMD -MP -MF"$(@:%.o=%.d)" -o"Sources/interrupt.o"
	@echo 'Finished building: $<'
	@echo ' '

Sources/main.o: ../Sources/main.c
	@echo 'Building file: $<'
	@echo 'Executing target #3 $<'
	@echo 'Invoking: PowerPC EABI e500mc C Compiler'
	"$(PAGccEabiE500mcDirEnv)/powerpc-eabi-gcc" "$<" @"Sources/main.args" -MMD -MP -MF"$(@:%.o=%.d)" -o"Sources/main.o"
	@echo 'Finished building: $<'
	@echo ' '

Sources/%.o: ../Sources/%.asm
	@echo 'Building file: $<'
	@echo 'Executing target #4 $<'
	@echo 'Invoking: PowerPC EABI e500mc Assembler'
	"$(PAGccEabiE500mcDirEnv)/powerpc-eabi-as" "$<" -g -me500mc -o"$@"
	@echo 'Finished building: $<'
	@echo ' '


