;			Tyler Hobbs
;			Quadratic Equation Program
;			30 April 2018

.586

.MODEL FLAT

INCLUDE IO.H

.STACK 4096

.DATA
;		define variables for use
prompt1		BYTE		"Coefficient of x^2?", 0
prompt2		BYTE		"Coefficient of x?", 0
prompt3		BYTE		"Constant term?", 0
string		BYTE		40 DUP (?)
rootsLbl	BYTE		"The roots are", 0
root1		BYTE		12 DUP (?), 0dh, 0ah
root2		BYTE		12 DUP (?)
aa			REAL4		?
bb			REAL4		?
cc			REAL4		?
discr		REAL4		?
x1			REAL4		?
x2			REAL4		?
four		DWORD		4
two			DWORD		2
ten			REAL4		10.0
one			REAL4		1.0
round		REAL4		0.000005
digit		DWORD		?
exponent	DWORD		?
byteTen		BYTE		10

.CODE
_MainProc	PROC 
;		the code zone

			input		prompt1, string, 40	
			lea			ebx, string			
			push		ebx					;	takes first coefficient, pushes it for conversion in atof, inputs numeric value into aa
			call		atofproc			
			add			esp, 4				
			fstp		aa					

			input		prompt2, string, 40	
			push		ebx					
			call		atofproc			;	takes second coefficient, pushes it for conversion in atof, inputs numeric value into bb
			add			esp, 4				
			fstp		bb					

			input		prompt3, string, 40
			push		ebx
			call		atofproc			;	takes third coefficient, pushes it for conversion in atof, inputs numeric value into cc
			add			esp, 4
			fstp		cc

			finit							;	intiallize floating point unit
			fld			bb
			fmul		bb					;	b^2
			fild		four
			fmul		aa
			fmul		cc					;	4*a*c
			fsub							;	b^2-4ac
			fldz
			fxch							;	puts result in float stack
			fcom		st(1)				;	compares to zero loaded by fldz
			fstsw		ax					
			sahf							
			jnae		endGE				;	loads condition flags from ax and compares
			fsqrt		
			fst			st(1)				;	sqrt(b^2-4ac) in st1
			fsub		bb					;	-b + sqrt(b^2-4ac)
			fdiv		aa
			fidiv		two					;	-b + sqrt(b^2-4ac) / 2a
			fstp		x1					;	pops first answer into x1
			fchs		
			fsub		bb		
			fdiv		aa
			fidiv		two					;	-b - sqrt(b^2-4ac) / 2a
			fstp		x2					;	pops second answer into x2

	endGE:		
			lea			ebx, root1			
			push		ebx					;	pushes root1 for loading with ascii value returned from ftoa
			push		x1					;	parameter for ftoa 
			call		ftoaproc
			add			esp, 8
			lea			ebx, root2			
			push		ebx					;	pushes root2 for ascii loading
			push		x2					;	parameter for root2
			call		ftoaproc
			add			esp, 8
			output		rootsLbl, root1

			mov			eax, 0
			ret

_MainProc	ENDP

atofproc	PROC
			
			push		ebp
			mov			ebp, esp
			sub			esp, 16
			push		eax
			push		esi

			mov			DWORD PTR [ebp-4], 10
			fld1
			fldz
			mov			DWORD PTR [ebp-8], 0
			mov			DWORD PTR [ebp-12], 0
			mov			esi, [ebp+8]
			cmp			BYTE PTR [esi], '-'
			jne			endIfMinus
			mov			DWORD PTR [ebp-12], -1
			inc			esi

	endIfMinus:
	whileOk:
			mov			al, [esi]
			cmp			al, '.'
			jne			endIfPoint
			mov			DWORD PTR [ebp-12], -1
			jmp			nextChar

	endIfPoint:
			cmp			al, '0'
			jnge		endWhileOk
			cmp			al, '9'
			jnle		endWhileOk
			and			eax, 0000000fh
			mov			DWORD PTR [ebp-16], eax
			fimul		DWORD PTR [ebp-4]
			fiadd		DWORD PTR [ebp-16]
			cmp			DWORD PTR [ebp-8], -1
			jne			endIfDec
			fxch		
			fimul		DWORD PTR [ebp-4]
			fxch		

	endIfDec:
	nextChar:
			inc			esi
			jmp			whileOk

	endWhileOk:
			fdivr		
			cmp			DWORD PTR [ebp-12], -1
			jne			endIfNeg
			fchs		

	endIfNeg:
			pop			esi
			pop			eax
			mov			esp, ebp
			pop			ebp
			ret

atofproc	ENDP

ftoaproc	PROC

			push		ebp
			mov			ebp, esp
			push		eax
			push		ebx
			push		ecx
			push		edi

			finit
			mov			edi, [ebp+12]
			fld			REAL4 PTR [ebp+8]
			ftst		
			fstsw		ax
			sahf		
			jnae		elseNeg
			mov			BYTE PTR [edi], ' '
			jmp			endIfNeg
	elseNeg:
			mov			BYTE PTR [edi], '-'
			fchs
	endIfNeg:
			inc			edi

			mov			exponent, 0
			ftst		
			fstsw		ax
			sahf
			jz			endIfZero
			fcom		ten
			fstsw		ax
			sahf		
			jnae		elseLess
	untilLess:
			fdiv		ten
			inc			exponent
			fcom		ten
			fstsw		ax
			sahf			
			jnb			untilLess
			jmp			endIfBigger
	elseLess:
	whileLess:
			fcom		one
			fstsw		ax
			sahf
			jnb			endWhileLess
			fmul		ten
			dec			exponent
			jmp			whileLess
	endWhileLess:
	endIfBigger:
	endIfZero:
			fadd		round
			fcom		ten
			fstsw		ax
			sahf
			jnae		endIfOver
			fdiv		ten
			inc			exponent
	endIfOver:
			fld			st
			fisttp		digit
			mov			ebx, digit
			or			ebx, 30h
			mov			[edi], bl
			inc			edi
			mov			BYTE PTR [edi], '.'
			inc			edi

			mov			ecx, 5
	forDigit:
			fisub		digit
			fmul		ten
			fld			st
			fisttp		digit
			mov			ebx, digit
			or			ebx, 30h
			mov			[edi], bl
			inc			edi
			loop		forDigit

			mov			BYTE PTR [edi], 'e'
			inc			edi
			mov			eax, exponent
			cmp			eax, 0
			jnge		negExp
			mov			BYTE PTR [edi], '+'
			jmp			endIfNegExp
	negExp:
			mov			BYTE PTR [edi], '-'
			neg			eax
	endIfNegExp:
			inc			edi

			div			byteTen
			or			eax, 3030h
			mov			[edi], al
			mov			[edi+1], ah

			pop			edi
			pop			ecx
			pop			ebx
			pop			eax
			pop			ebp
			ret

ftoaproc	ENDP

END	