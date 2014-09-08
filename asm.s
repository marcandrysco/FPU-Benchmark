	.intel_syntax noprefix

	.global runtest

	.data

ctrl:	.int 0
v0:	.double 0.0
v1:	.double 0.0
store:	.double 0.0

	.text

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
	je	sse_add
	cmp	esi,5
	je	sse_mul
	cmp	esi,6
	je	sse_div

	jmp	error

noop:
	rdtsc
	mov	edi,eax
	rdtsc
	sub	eax,edi
	jmp	end

x87_add:
	rdtsc
	mov	edi,eax
	fld	QWORD PTR [v0]
	fld	QWORD PTR [v1]
	faddp	st(1)
	fstp	QWORD PTR [store]
	rdtsc
	sub	eax,edi
	jmp	end

x87_mul:
	rdtsc
	mov	edi,eax
	fld	QWORD PTR [v0]
	fld	QWORD PTR [v1]
	fmulp	st(1)
	fstp	QWORD PTR [store]
	rdtsc
	sub	eax,edi
	jmp	end

x87_div:
	rdtsc
	mov	edi,eax
	fld	QWORD PTR [v0]
	fld	QWORD PTR [v1]
	fdivp	st(1)
	fstp	QWORD PTR [store]
	rdtsc
	sub	eax,edi
	jmp	end

sse_add:
	rdtsc
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	addsd	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtsc
	sub	eax,edi
	jmp	end

sse_mul:
	rdtsc
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	mulsd	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtsc
	sub	eax,edi
	jmp	end

sse_div:
	rdtsc
	mov	edi,eax
	movsd	xmm0,QWORD PTR [v0]
	movsd	xmm1,QWORD PTR [v1]
	divsd	xmm0,xmm1
	movsd	QWORD PTR [store],xmm0
	rdtsc
	sub	eax,edi
	jmp	end

error:
	mov	eax,-1
end:
	stmxcsr	DWORD PTR [ctrl]
	and	DWORD PTR [ctrl],0x7FBF
	ldmxcsr	DWORD PTR [ctrl]

	ret
