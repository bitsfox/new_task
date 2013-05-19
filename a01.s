.code16
.include"/workarea/cprogram/kernel/include/defconst.inc"
.text
	jmp $BOOT_SEG,$go
go:
	mov %cs,%ax
	mov %ax,%ds
	mov %ax,%es
	mov $0,%dx
	mov $0x02,%cx
	mov $512,%bx
	mov $0x0210,%ax
	int $0x13
	jnc 1f
	jmp .
1:
	mov $DISP_SEG,%ax
	mov %ax,%es
	xor %di,%di
	mov $0x0720,%ax
	mov $4000,%cx
3:
	stosw
	loop 3b
	mov $len,%cx
	xor %di,%di
	lea msg,%si
	mov $0x0b,%ah
2:
	lodsb
	stosw
	loop 2b
	lgdt l_gdt
	cli
	mov $1,%ax
	lmsw %ax
	jmp $0x20,$0

msg:	.ascii "booting: load data...............................[ok]"
len=.-msg
l_gdt:	.word 48
		.long BOOT_BASEADDR+gdt
gdt:	.word 0,0,0,0
		.word 1,BOOT_BASEADDR,0x9a00,0x00c0			#0x08
		.word 1,BOOT_BASEADDR,0x9200,0x00c0			#0x10
		.word 2,0x8000,0x920b,0x00c0				#0x18
		.word 2,HEAD_BASEADDR,0x9a00,0x00c0			#0x20
		.word 2,HEAD_BASEADDR,0x9200,0x00c0			#0x28
.org 510
.word 0xaa55


