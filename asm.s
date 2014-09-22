	.intel_syntax noprefix

	.global cpuid
	.global runtest

	.data

ctrl:	.int 0
v0:	.double 0.0
	.double 0.0
v1:	.double 0.0
	.double 0.0
store:	.double 0.0
	.double 0.0

	.text

cpuid:
	mov	eax,edi
	cpuid
	mov	DWORD PTR [rsi+0],eax
	mov	DWORD PTR [rsi+4],ebx
	mov	DWORD PTR [rsi+8],ecx
	mov	DWORD PTR [rsi+12],edx
	ret

runtest:
	movsd	QWORD PTR [v0],xmm0
	movsd	QWORD PTR [v1],xmm1

	stmxcsr	DWORD PTR [ctrl]
	cmp	edi,1
	je	ftz
	cmp	edi,3
	je	ftz
noftz:
	and	DWORD PTR [ctrl],0x7FFF
	jmp	endftz
ftz:
	or	DWORD PTR [ctrl],0x8000
endftz:
	ldmxcsr	DWORD PTR [ctrl]

	stmxcsr	DWORD PTR [ctrl]
	cmp	edi,2
	je	daz
	cmp	edi,3
	je	daz
nodaz:
	and	DWORD PTR [ctrl],0xFFBF
	jmp	enddaz
daz:
	or	DWORD PTR [ctrl],0x0040
enddaz:
	ldmxcsr	DWORD PTR [ctrl]

	cmp	esi,0
	je	noop
	cmp	esi,1
	je	x87_add
	cmp	esi,2
	je	x87_mul
	cmp	esi,3
	je	x87_div
	cmp	esi,4
	je	addsd
	cmp	esi,5
	je	mulsd
	cmp	esi,6
	je	divsd
	cmp	esi,7
	je	addpd
	cmp	esi,8
	je	mulpd
	cmp	esi,9
	je	divpd
	cmp	esi,10
	je	addss
	cmp	esi,11
	je	mulss
	cmp	esi,12
	je	divss
	cmp	esi,13
	je	addps
	cmp	esi,14
	je	mulps
	cmp	esi,15
	je	divps

	jmp	error

noop:
	rdtscp
	mov	edi,eax
	rdtscp
	sub	eax,edi
	jmp	end

x87_add:
	rdtscp
	mov	edi,eax
	fld	QWORD PTR [v0]
	fld	QWORD PTR [v1]
	faddp	st(1)
	fstp	QWORD PTR [store]
	rdtscp
	sub	eax,edi
	jmp	end

x87_mul:
	rdtscp
	mov	edi,eax
	fld	QWORD PTR [v0]
	fld	QWORD PTR [v1]
	fmulp	st(1)
	fstp	QWORD PTR [store]
	rdtscp
	sub	eax,edi
	jmp	end

x87_div:
	rdtscp
	mov	edi,eax
	fld	QWORD PTR [v0]
	fld	QWORD PTR [v1]
	fdivp	st(1)
	fstp	QWORD PTR [store]
	rdtscp
	sub	eax,edi
	jmp	end

addsd:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	addsd	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulsd:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	mulsd	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divsd:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	divsd	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

addpd:
	rdtscp
	mov	edi,eax
	movupd	xmm0,OWORD PTR [v0]
	movupd	xmm1,OWORD PTR [v1]
	addpd	xmm0,xmm1
	movupd	OWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulpd:
	rdtscp
	mov	edi,eax
	movupd	xmm0,OWORD PTR [v0]
	movupd	xmm1,OWORD PTR [v1]
	mulpd	xmm0,xmm1
	movupd	OWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divpd:
	rdtscp
	mov	edi,eax
	movupd	xmm0,OWORD PTR [v0]
	movupd	xmm1,OWORD PTR [v1]
	divpd	xmm0,xmm1
	movupd	OWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

addss:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	addss	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulss:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	mulss	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divss:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	divss	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

addps:
	rdtscp
	mov	edi,eax
	movups	xmm0,OWORD PTR [v0]
	movups	xmm1,OWORD PTR [v1]
	addps	xmm0,xmm1
	movups	OWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulps:
	rdtscp
	mov	edi,eax
	movups	xmm0,OWORD PTR [v0]
	movups	xmm1,OWORD PTR [v1]
	mulps	xmm0,xmm1
	movups	OWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divps:
	rdtscp
	mov	edi,eax
	movups	xmm0,OWORD PTR [v0]
	movups	xmm1,OWORD PTR [v1]
	divps	xmm0,xmm1
	movups	OWORD PTR [store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

error:
	mov	eax,-1
end:
	stmxcsr	DWORD PTR [ctrl]
	and	DWORD PTR [ctrl],0x7FBF
	ldmxcsr	DWORD PTR [ctrl]

	ret
