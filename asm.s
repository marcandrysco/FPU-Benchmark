	.intel_syntax noprefix

	.global cpuid
	.global runtest

	.data

v0:	.double 0.0
	.double 0.0
v0s:	.single 0.0
	.single 0.0
	.single 0.0
	.single 0.0
v1:	.double 0.0
	.double 0.0
v1s:	.single 0.0
	.single 0.0
	.single 0.0
	.single 0.0
store:	.double 0.0
	.double 0.0
stores:	.single 0.0
	.single 0.0
	.single 0.0
	.single 0.0

	.text

cpuid:
	push    rbx
	mov	eax,edi
	cpuid
	mov	DWORD PTR [rsi+0],eax
	mov	DWORD PTR [rsi+4],ebx
	mov	DWORD PTR [rsi+8],ecx
	mov	DWORD PTR [rsi+12],edx
	pop     rbx
	ret

runtest:
	movsd	QWORD PTR [rip+v0+0],xmm0
	movsd	QWORD PTR [rip+v0+8],xmm0
	movsd	QWORD PTR [rip+v1+0],xmm1
	movsd	QWORD PTR [rip+v1+8],xmm1
	movss	DWORD PTR [rip+v0s+0],xmm2
	movss	DWORD PTR [rip+v0s+4],xmm2
	movss	DWORD PTR [rip+v0s+8],xmm2
	movss	DWORD PTR [rip+v0s+12],xmm2
	movss	DWORD PTR [rip+v1s+0],xmm3
	movss	DWORD PTR [rip+v1s+4],xmm3
	movss	DWORD PTR [rip+v1s+8],xmm3
	movss	DWORD PTR [rip+v1s+16],xmm3

	stmxcsr	DWORD PTR [rsp-4]
	cmp	edi,1
	je	ftz
	cmp	edi,3
	je	ftz
noftz:
	and	DWORD PTR [rsp-4],0x7FFF
	jmp	endftz
ftz:
	or	DWORD PTR [rsp-4],0x8000
endftz:
	ldmxcsr	DWORD PTR [rsp-4]

	stmxcsr	DWORD PTR [rsp-4]
	cmp	edi,2
	je	daz
	cmp	edi,3
	je	daz
nodaz:
	and	DWORD PTR [rsp-4],0xFFBF
	jmp	enddaz
daz:
	or	DWORD PTR [rsp-4],0x0040
enddaz:
	ldmxcsr	DWORD PTR [rsp-4]

	cmp	esi,0
	je	noop
	# x87 double
	cmp	esi,1
	je	faddd
	cmp	esi,2
	je	fmuld
	cmp	esi,3
	je	fdivd
	# x87 single
	cmp	esi,4
	je	fadds
	cmp	esi,5
	je	fmuls
	cmp	esi,6
	je	fdivs
	# sse double
	cmp	esi,7
	je	addsd
	cmp	esi,8
	je	mulsd
	cmp	esi,9
	je	divsd
	# sse double simd
	cmp	esi,10
	je	addpd
	cmp	esi,11
	je	mulpd
	cmp	esi,12
	je	divpd
	# sse single
	cmp	esi,13
	je	addss
	cmp	esi,14
	je	mulss
	cmp	esi,15
	je	divss
	# sse single simd
	cmp	esi,16
	je	addps
	cmp	esi,17
	je	mulps
	cmp	esi,18
	je	divps

	jmp	error

noop:
	rdtscp
	mov	edi,eax
	rdtscp
	sub	eax,edi
	jmp	end

faddd:
	rdtscp
	mov	edi,eax
	fld	QWORD PTR [rip+v0]
	fld	QWORD PTR [rip+v1]
	faddp	st(1)
	fstp	QWORD PTR [rip+store]
	rdtscp
	sub	eax,edi
	jmp	end

fmuld:
	rdtscp
	mov	edi,eax
	fld	QWORD PTR [rip+v0]
	fld	QWORD PTR [rip+v1]
	fmulp	st(1)
	fstp	QWORD PTR [rip+store]
	rdtscp
	sub	eax,edi
	jmp	end

fdivd:
	rdtscp
	mov	edi,eax
	fld	QWORD PTR [rip+v0]
	fld	QWORD PTR [rip+v1]
	fdivp	st(1)
	fstp	QWORD PTR [rip+store]
	rdtscp
	sub	eax,edi
	jmp	end

fadds:
	rdtscp
	mov	edi,eax
	fld	DWORD PTR [rip+v0s]
	fld	DWORD PTR [rip+v1s]
	faddp	st(1)
	fstp	DWORD PTR [rip+stores]
	rdtscp
	sub	eax,edi
	jmp	end

fmuls:
	rdtscp
	mov	edi,eax
	fld	DWORD PTR [rip+v0s]
	fld	DWORD PTR [rip+v1s]
	fmulp	st(1)
	fstp	DWORD PTR [rip+stores]
	rdtscp
	sub	eax,edi
	jmp	end

fdivs:
	rdtscp
	mov	edi,eax
	fld	DWORD PTR [rip+v0s]
	fld	DWORD PTR [rip+v1s]
	fdivp	st(1)
	fstp	DWORD PTR [rip+stores]
	rdtscp
	sub	eax,edi
	jmp	end

addsd:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [rip+v0]
	movsd	xmm1,QWORD PTR [rip+v1]
	addsd	xmm0,xmm1
	movsd	QWORD PTR [rip+store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulsd:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [rip+v0]
	movsd	xmm1,QWORD PTR [rip+v1]
	mulsd	xmm0,xmm1
	movsd	QWORD PTR [rip+store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divsd:
	rdtscp
	mov	edi,eax
	movsd	xmm0,QWORD PTR [rip+v0]
	movsd	xmm1,QWORD PTR [rip+v1]
	divsd	xmm0,xmm1
	movsd	QWORD PTR [rip+store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

addpd:
	rdtscp
	mov	edi,eax
	movupd	xmm0,XMMWORD PTR [rip+v0]
	movupd	xmm1,XMMWORD PTR [rip+v1]
	addpd	xmm0,xmm1
	movupd	XMMWORD PTR [rip+store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulpd:
	rdtscp
	mov	edi,eax
	movupd	xmm0,XMMWORD PTR [rip+v0]
	movupd	xmm1,XMMWORD PTR [rip+v1]
	mulpd	xmm0,xmm1
	movupd	XMMWORD PTR [rip+store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divpd:
	rdtscp
	mov	edi,eax
	movupd	xmm0,XMMWORD PTR [rip+v0]
	movupd	xmm1,XMMWORD PTR [rip+v1]
	divpd	xmm0,xmm1
	movupd	XMMWORD PTR [rip+store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

addss:
	rdtscp
	mov	edi,eax
	movss	xmm0,DWORD PTR [rip+v0s]
	movss	xmm1,DWORD PTR [rip+v1s]
	addss	xmm0,xmm1
	movss	DWORD PTR [rip+stores],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulss:
	rdtscp
	mov	edi,eax
	movss	xmm0,DWORD PTR [rip+v0s]
	movss	xmm1,DWORD PTR [rip+v1s]
	mulss	xmm0,xmm1
	movss	DWORD PTR [rip+stores],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divss:
	rdtscp
	mov	edi,eax
	movss	xmm0,DWORD PTR [rip+v0s]
	movss	xmm1,DWORD PTR [rip+v1s]
	divss	xmm0,xmm1
	movss	DWORD PTR [rip+stores],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

addps:
	rdtscp
	mov	edi,eax
	movups	xmm0,XMMWORD PTR [rip+v0]
	movups	xmm1,XMMWORD PTR [rip+v1]
	addps	xmm0,xmm1
	movups	XMMWORD PTR [rip+store],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

mulps:
	rdtscp
	mov	edi,eax
	movups	xmm0,XMMWORD PTR [rip+v0s]
	movups	xmm1,XMMWORD PTR [rip+v1s]
	mulps	xmm0,xmm1
	movups	XMMWORD PTR [rip+stores],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

divps:
	rdtscp
	mov	edi,eax
	movups	xmm0,XMMWORD PTR [rip+v0s]
	movups	xmm1,XMMWORD PTR [rip+v1s]
	divps	xmm0,xmm1
	movups	XMMWORD PTR [rip+stores],xmm0
	rdtscp
	sub	eax,edi
	jmp	end

error:
	mov	eax,-1
end:
	stmxcsr	DWORD PTR [rsp-4]
	and	DWORD PTR [rsp-4],0x7FBF
	ldmxcsr	DWORD PTR [rsp-4]

	ret
