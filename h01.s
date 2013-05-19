.include "/workarea/cprogram/kernel/include/defconst.inc"
.data
.text
.org 0
	movl $0x28,%eax
	movw %ax,%ds
	movw %ax,%es
	movw %ax,%gs
	movl $0x18,%eax
	movw %ax,%fs
	lss	 stk,%esp
	call show_msg1
	xorl %eax,%eax
	call reset_8253
	xorl %eax,%eax
	call setup_idt
	lidt l_idt
	call setup_gdt
	lgdt l_gdt
	movl $0x28,%eax
	movw %ax,%ds
	movw %ax,%es
	movw %ax,%gs
	movl $0x18,%eax
	movw %ax,%fs
	leal msg2,%eax
	push %eax
	call show_msg
	popl %eax
	call setup_tss0
	xorl %eax,%eax
	call setup_tss1
	movl $l_gdt_old,%eax
	movw (%eax),%cx
	pushfl
	andl $0xffffbfff,(%esp)
	popfl
	movl $0x30,%eax
	ltr %ax
	movl $0x38,%eax
	lldt %ax
	sti
	pushl $0x17
	pushl $stk
	pushfl
	pushl $0x0f
	pushl $task0
	iret 


msg1:	.ascii "booting: switch protected model .................[ok]"
len=.-msg1
msg2:	.ascii "heading: reset idt/gdt...........................[ok]"
.space 0x400
stk:	.long stk,0x28
l_idt:	.word 2048
		.long HEAD_BASEADDR+idt
l_gdt:	.word 160
		.long HEAD_BASEADDR+gdt
idt:	.space 2048,0
gdt:	.space 160,0
/*gdt:
		.word 0,0,0,0
		.word 1,BOOT_BASEADDR,0x9a00,0x00c0			#0x08
		.word 1,BOOT_BASEADDR,0x9200,0x00c0			#0x10
		.word 2,0x8000,0x920b,0x00c0				#0x18
		.word 2,HEAD_BASEADDR,0x9a00,0x00c0			#0x20
		.word 2,HEAD_BASEADDR,0x9200,0x00c0			#0x28
		.word 104,HEAD_BASEADDR+tss0,0xe900,0		#0x30
		.word 32,HEAD_BASEADDR+ldt0,0xe200,0		#0x38
		.word 104,HEAD_BASEADDR+tss1,0xe900,0		#0x40
		.word 32,HEAD_BASEADDR+ldt1,0xe200,0		#0x48*/
l_gdt_old: .word 0
		   .long 0
ldt0:	.word 0,0,0,0
		.word 2,HEAD_BASEADDR,0xfa00,0xc0		#0xf
		.word 2,HEAD_BASEADDR,0xf200,0xc0		#0x17
		.word 2,0x8000,0xf20b,0xc0		#0x1f
.space	100,0
stk0:
tss0:	.space 104,0
/*tss0:	.long 0						#back link
		.long stk0,0x28				#esp0,ss0
		.long 0,0,0,0,0				#esp1,ss1,esp2,ss2,cr3
		.long 0,0,0,0,0				#eip,eflags,eax,ecx,edx
		.long 0,0,0,0,0				#ebx,esp,ebp,esi,edi
		.long 0,0,0,0,0,0			#es,cs,ss,ds,fs,gs
		.long 0x38,0x8000000		#ldt,io-map
*/		
ldt1:	.word 0,0,0,0
		.word 2,HEAD_BASEADDR,0xfa00,0xc0		#0xf
		.word 2,HEAD_BASEADDR,0xf200,0xc0		#0x17
		.word 2,0x8000,0xf20b,0xc0		#0x1f
.space  100,0
stk1:
tss1:	.space 104,0
/*tss1:	
		.long 0
		.long stk1,0x28
		.long 0,0,0,0,0
		.long task1,0x200,0,0,0
		.long 0,ustk1,0,0,0
		.long 0x17,0x0f,0x17,0x17,0x17,0x17
		.long 0x48,0x8000000	*/
.space  100,0
ustk1:
pos:	.long 0
current: .long 0


