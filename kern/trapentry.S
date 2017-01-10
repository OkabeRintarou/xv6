/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>



###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
TRAPHANDLER_NOEC(handle_divide,T_DIVIDE) // 0
TRAPHANDLER_NOEC(handle_debug,T_DEBUG)   // 1
TRAPHANDLER_NOEC(handle_nmi,T_NMI)       // 2
TRAPHANDLER_NOEC(handle_brkpt,T_BRKPT)   // 3
TRAPHANDLER_NOEC(handle_oflow,T_OFLOW)   // 4
TRAPHANDLER_NOEC(handle_bound,T_BOUND)   // 5
TRAPHANDLER_NOEC(handle_illop,T_ILLOP)   // 6
TRAPHANDLER_NOEC(handle_device,T_DEVICE) // 7
TRAPHANDLER(handle_dblflt,T_DBLFLT)      // 8
// 9 reversed
TRAPHANDLER(handle_tss,T_TSS)            // 10
TRAPHANDLER(handle_segnp,T_SEGNP)        // 1
TRAPHANDLER(handle_stack,T_STACK)        // 12
TRAPHANDLER(handle_gpflt,T_GPFLT)        // 13
TRAPHANDLER(handle_pgflt,T_PGFLT)        // 14
// 15 reversed
TRAPHANDLER_NOEC(handle_fperr,T_FPERR)   // 16
TRAPHANDLER(handle_align,T_ALIGN)        // 17
TRAPHANDLER_NOEC(handle_mchk,T_MCHK)     // 18
TRAPHANDLER_NOEC(handle_simderr,T_SIMDERR) // 19

TRAPHANDLER_NOEC(handle_syscall,T_SYSCALL)
/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    // push values to make the stack look like a struct Trapframe
    pushw $(0x00)
    pushw %ds
    pushw $(0x00)
    pushw %es
    pushal

    // load GD_KD into %ds and %es
    movl $(GD_KD),%eax
    movw %ax,%ds
    movw %ax,%es

    // push %esp to pass a pointer to the Trapframe as an argument to trap()
    pushl %esp
    // call trap
    call trap
