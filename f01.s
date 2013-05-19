/*h01中函数的实现部分放在这里*/
#{{{ setup_idt
setup_idt:
	push %es
	pusha
	push %ds
	pop %es
	movl $nor_int,%edx
	movl $0x00200000,%eax
	movw %dx,%ax
	movw $0x8e00,%dx
	movl $256,%ecx
	leal idt,%edi
1:
	movl %eax,(%edi)
	movl %edx,4(%edi)
	addl $8,%edi
	loop 1b
	movl $time_int,%edx
	movl $0x00200000,%eax
	movw %dx,%ax
	movw $0x8e00,%dx
	movl $8,%ebx
	leal idt(,%ebx,8),%edi
	movl %eax,(%edi)
	movl %edx,4(%edi)		#end of int 0x8
	movl $sys_int,%edx
	movl $0x00200000,%eax
	movw %dx,%ax
	movw $0xef00,%dx		#trap gate
	movl $0x80,%ebx
	leal idt(,%ebx,8),%edi
	movl %eax,(%edi)
	movl %edx,4(%edi)		#end of int 0x80
	popa
	pop %es
	ret
#}}}
#{{{ setup_gdt
setup_gdt:
	pusha
	push %es
	push %ds
#push %ds
#pop %es
	movl $0x28,%eax
	movw %ax,%ds
	movw %ax,%es
	sgdt l_gdt_old
	movl $l_gdt_old,%ebx
	xorl %ecx,%ecx
	movw (%ebx),%cx
	movl 2(%ebx),%eax
	subl $BOOT_BASEADDR,%eax
	movl %eax,%esi				#get offset of first gdt
	leal gdt,%edi
	movl $0x10,%eax
	movw %ax,%ds
1:
	lodsb
	stosb
	loop 1b						#copy old gdt to new place
	movl $0x28,%eax
	movw %ax,%ds
	#begin set task's ldt & tss
	#tss0
	movl $HEAD_BASEADDR,%eax
	addl $tss0,%eax
	roll $16,%eax
	xorl %edx,%edx
	movw %ax,%dx
	andl $0xff00,%edx
	roll $16,%edx
	movw %ax,%dx
	andl $0xffff00ff,%edx
	andl $0xffff0000,%eax
	addl $104,%eax
	addl $0xe900,%edx
	movl %eax,(%edi)
	movl %edx,4(%edi)
	addl $8,%edi					#0x30 tss0
	#ldt0
	movl $HEAD_BASEADDR,%eax
	addl $ldt0,%eax
	roll $16,%eax
	xorl %edx,%edx
	movw %ax,%dx
	andl $0xff00,%edx
	roll $16,%edx
	movw %ax,%dx
	andl $0xffff00ff,%edx
	andl $0xffff0000,%eax
	addl $32,%eax
	addl $0xe200,%edx
	movl %eax,(%edi)
	movl %edx,4(%edi)
	addl $8,%edi					#0x38 ldt0
	#tss1
	movl $HEAD_BASEADDR,%eax
	addl $tss1,%eax
	roll $16,%eax
	movw %ax,%dx
	andl $0x0000ff00,%edx
	roll $16,%edx
	movw %ax,%dx
	andl $0xffff00ff,%edx
	andl $0xffff0000,%eax
	addl $104,%eax
	addl $0xe900,%edx
	movl %eax,(%edi)
	movl %edx,4(%edi)
	addl $8,%edi					#0x40 tss1
	#ldt1
	movl $HEAD_BASEADDR,%eax
	addl $ldt1,%eax
	roll $16,%eax
	movw %ax,%dx
	andl $0xff00,%edx
	roll $16,%edx
	movw %ax,%dx
	andl $0xffff00ff,%edx
	andl $0xffff0000,%eax
	addl $32,%eax
	addl $0xe200,%edx
	movl %eax,(%edi)
	movl %edx,4(%edi)				#0x48 ldt1
	pop %ds
	pop %es
	popa
	ret
#}}}
#{{{ reset_8253
reset_8253:
	pushl %eax
	pushl %edx
	movl $0x36,%eax
	movl $0x43,%edx
	outb %al,%dx
	movl $0xff,%eax
	movl $0x40,%edx
	outb %al,%dx
	outb %al,%dx
	popl %edx
	popl %eax
	ret
#}}}
#{{{ show_msg
show_msg:
	push %ebp
	movl %esp,%ebp
	movl 8(%ebp),%eax
	movl %eax,%esi
	movl $len,%ecx
	movl $0x18,%eax
	movw %ax,%es
	movl $320,%edi
	movb $0x0e,%ah
1:
	lodsb
	stosw
	loop 1b
	pop %ebp
	ret
#}}}
#{{{ nor_int
nor_int:
	pusha
	push %es
	movl $0x18,%eax
	movw %ax,%es
	movl $0x0d41,%eax
	movl $450,%edi
	stosw
	pop %es
	popa
	iret
#}}}
#{{{ time_int
time_int:
	pusha
	push %ds
	movl $0x28,%eax
	movw %ax,%ds
	movl $0x20,%eax
	outb %al,$0x20
	cmpl $0,current
	je	1f
	movl $0,%eax
	movl %eax,current
	ljmp $0x30,$0
	jmp 2f
1:
	movl $1,%eax
	movl %eax,current
	ljmp $0x40,$0
2:	
	pop %ds
	popa
	iret
#}}}
#{{{ sys_int
sys_int:

	iret
#}}}	
#{{{ setup_tss0
setup_tss0:
	push %es
	push %ds
	pop  %es
	leal tss0,%edi
	movl $stk0,ESP0(%edi)
	movl $0x28,SS0(%edi)
	movl $0x38,ELDT(%edi)
	movl $0x8000000,EIO(%edi)
	pop %es
	ret
#}}}
#{{{ setup_tss1
setup_tss1:
	push %es
	push %ds
	pop %es
	leal tss1,%edi
	movl $stk1,ESP0(%edi)
	movl $0x28,SS0(%edi)
	movl $task1,EIP(%edi)
	movl $0x200,EFLAG(%edi)
	movl $ustk1,ESP(%edi)
	movl $0x0f,%eax
	movl %eax,ECS(%edi)
	movl $0x17,%eax
	movl %eax,EDS(%edi)
	movl %eax,EES(%edi)
	movl %eax,ESS(%edi)
	movl %eax,EFS(%edi)
	movl %eax,EGS(%edi)
	movl $0x48,ELDT(%edi)
	movl $0x8000000,EIO(%edi)
	pop %es
	ret
#}}}
#{{{ show_msg1
show_msg1:
	push %es
	pusha
	push %fs
	pop	 %es
	leal msg1,%esi
	movl $len,%ecx
	movl $160,%edi
	movb $0x0b,%ah
1:
	lodsb
	stosw
	loop 1b
	popa
	pop %es
	ret
#}}}
#{{{ task0
task0:
	movl $0x17,%eax
	movw %ax,%ds
	movw %ax,%fs
	movw %ax,%gs
	movl $0x1f,%eax
	movw %ax,%es
	movl $958,%edi
	movl $0x0720,%eax
	movl $0x0d41,%ebx
1:
	stosw
	cmpl $959,%edi
	jb	2f
	movl $800,%edi
2:
	movw %bx,%es:(%edi)
	incl %ebx
	cmpb $'Z,%bl
	jbe  3f
	movb $0x41,%bl
3:
	movl $0x10fffff,%ecx
	loop .
	jmp 1b
	ret
#}}}
#{{{ task1
task1:
	movl $0x17,%eax
	movw %ax,%ds
	movw %ax,%fs
	movw %ax,%gs
	movl $0x1f,%eax
	movw %ax,%es
	movl $1118,%edi
	movl $0x0720,%eax
	movl $0x0e41,%ebx
1:
	stosw
	cmpl $1119,%edi
	jb	2f
	movl $960,%edi
2:
	movw %bx,%es:(%edi)
	incl %ebx
	cmpb $'Z,%bl
	jbe  3f
	movb $0x41,%bl
3:
	movl $0x10fffff,%ecx
	loop .
	jmp 1b
	ret
#}}}
.org 8188
.ascii "ttyy"


