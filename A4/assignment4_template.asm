; Macro 1 - Returns the length of a given string in rax
; Argument 1: null terminated string
%macro stringLength 1
	mov rax, 0

	%%countLoop:
		cmp byte[%1 + rax], NULL
		je %%countLoopDone
		inc rax
		jmp %%countLoop

		%%countLoopDone:
			inc rax

%endmacro

; Macro 2 - Convert letters in a string to uppercase
; Argument 1: null terminated string
%macro toUppercase 1
	mov r8, 0

	%%stringLoop:
		cmp byte[%1 + r8], 96
		ja %%checkUpperCase
		jmp %%notUpper

		%%checkUpperCase:
			cmp byte[%1 + r8], 123
			jae %%notUpper
			mov al, byte[%1 + r8]
			sub al, 32
			mov byte[%1 + r8], al

		%%notUpper:
			cmp byte[%1 + r8], NULL
			je %%stringLoopDone
			inc r8
			jmp %%stringLoop
		
		%%stringLoopDone:

%endmacro

; Macro 3 - Convert a Decimal String to Integer
; Argument 1: null terminated string (byte array)
; Argument 2: dword integer variable
%macro convertDecimalToInteger 2
	mov rbx, %1
	mov r8, 1	; sign

	%%skipSpaces1:
		mov cl, byte[rbx]
		inc rbx
		cmp cl, ' '
		je %%skipSpaces1

	dec rbx
	mov cl, byte[rbx]
	cmp cl, '-'
	je %%setNegative
	cmp cl, '+'
	je %%skipPlus
	jmp %%skipSpaces2

	%%setNegative:
		mov r8, -1
		inc rbx
		jmp %%skipSpaces2
	
	%%skipPlus:
		inc rbx

	%%skipSpaces2:
		mov cl, byte[rbx]
		inc rbx
		cmp cl, ' '
		je %%skipSpaces2
	
	dec rbx
	mov eax, 0	; value
	mov r9d, 10

	%%convertNum:
		mov cl, byte[rbx]
		cmp cl, ' '
		je %%skipSpaces3

		sub cl, '0'			; cl holds digit
		mul r9d				; value *= 10
		movsx edx, cl
		add eax, edx
		inc rbx

		cmp byte[rbx], NULL
		je %%cvtDecToIntDone
		jmp %%convertNum

	%%skipSpaces3:
		mov cl, byte[rbx]
		inc rbx
		cmp cl, ' '
		je %%skipSpaces3

	dec rbx

	%%cvtDecToIntDone:
		mul r8d
		mov dword[%2], eax

%endmacro

; Macro 4 - Convert an Integer to a Hexadecimal String
; Argument 1: dword integer variable
; Argument 2: string (11 byte array)
%macro convertIntegerToHexadecimal 2
	mov eax, dword[%1]	; signed integer in eax
	mov r8d, 16 		; will be used for division by 16

	; setting placeholder values
	mov byte[%2], '0'	
	mov byte[%2 + 1], 'X'
	mov byte[%2 + 10], NULL

	mov rcx, 9
	%%convertLoop:
		mov rdx, 0
		div r8d			; divide value by 16
		
		cmp edx, 9
		ja %%hexDigit
		add edx, 48
		mov byte[%2 + rcx], dl
		jmp %%convertLoopDone

		%%hexDigit:
			add edx, 55
			mov byte[%2 + rcx], dl

		%%convertLoopDone:
			dec rcx
			cmp eax, 0
			ja %%convertLoop

	%%fillLoop:
		cmp rcx, 2
		jb %%convertDone
		mov byte[%2 + rcx], '0'
		dec rcx
		jmp %%fillLoop

	%%convertDone:

%endmacro

section .data
; System Service Call Constants
SYSTEM_WRITE equ 1
SYSTEM_EXIT equ 60
SUCCESS equ 0
STANDARD_OUT equ 1
STDIN equ 0
SYS_read equ 0

; Special Characters
LINEFEED equ 10
NULL equ 0

; Macro 1 Variable
macro1Message db "This is the string that never ends, it goes on and on my friends.", LINEFEED, NULL

; Macro 1 Test Variables
macro1Label db "Macro 1: "
macro1Pass db "Pass", LINEFEED
macro1Fail db "Fail", LINEFEED
macro1Expected dq 67

; Macro 2 Variables
macro2Message db "Did you read Chapters 8, 9, and 11 yet?", LINEFEED, NULL

; Macro 2 Test Variable
macro2Label db "Macro 2: "

; Macro 3 Variables
macro3Number1 db "12345", NULL
macro3Number2 db "      +19", NULL
macro3Number3 db " -    1468     ", NULL
macro3Integer1 dd 0
macro3Integer2 dd 0
macro3Integer3 dd 0

; Macro 3 Test Variables
macro3Label1 db "Macro 3-1: "
macro3Label2 db "Macro 3-2: "
macro3Label3 db "Macro 3-3: "
macro3Pass db "Pass", LINEFEED
macro3Fail db "Fail", LINEFEED
macro3Expected1 dd 12345
macro3Expected2 dd 19
macro3Expected3 dd -1468

; Macro 4 Variables
macro4Integer1 dd 255
macro4Integer2 dd 1988650
macro4Integer3 dd -7

; Macro 4 Test Variables
macro4Label1 db "Macro 4-1: "
macro4Label2 db "Macro 4-2: "
macro4Label3 db "Macro 4-3: "
macro4NewLine db LINEFEED

section .bss
; Macro 4 Strings
macro4String1 resb 11
macro4String2 resb 11
macro4String3 resb 11

section .text
global _start
_start:

	; DO NOT ALTER _start in any way.

	mov rax, 0
	
	; Macro 1 - Do not alter
	; Invokes the macro using macro1Message as the argument
	stringLength macro1Message

	; Macro 1 Test - Do not alter
	push rax
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro1Label
	mov rdx, 9
	syscall
	
	mov rdi, STANDARD_OUT
	mov rsi, macro1Fail
	mov rdx, 5
	pop rax
	cmp rax, qword[macro1Expected]
	jne macro1_Fail
		mov rsi, macro1Pass
	macro1_Fail:
	mov rax, SYSTEM_WRITE
	syscall
	
	; Macro 2 - Do not alter
	; Invokes the macro using macro2message as the argument
	toUppercase macro2Message
	
	; Macro 2 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Label
	mov rdx, 9
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro2Message
	mov rdx, 41
	syscall
	
	; Macro 3 - 1 - Do not alter
	; Invokes the macro with macro3Number1 and macro3Integer1
	convertDecimalToInteger macro3Number1, macro3Integer1

	; Macro 3 - 2 - Do not alter
	; Invokes the macro with macro3Number2 and macro3Integer2
	convertDecimalToInteger macro3Number2, macro3Integer2
	
	; Macro 3 - 3 - Do not alter
	; Invokes the macro with macro3Number3 and macro3Integer3
	convertDecimalToInteger macro3Number3, macro3Integer3

	; Macro 3 Test - Do not alter
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer1]
	cmp ebx, dword[macro3Expected1]
	jne macro3_1_Fail
		mov rsi, macro3Pass
	macro3_1_Fail:
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label2
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer2]
	cmp ebx, dword[macro3Expected2]
	jne macro3_2_Fail
		mov rsi, macro3Pass
	macro3_2_Fail:
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro3Fail
	mov rdx, 5
	mov ebx, dword[macro3Integer3]
	cmp ebx, dword[macro3Expected3]
	jne macro3_3_Fail
		mov rsi, macro3Pass
	macro3_3_Fail:
	syscall
	
	; Macro 4 - 1 - Do not alter
	convertIntegerToHexadecimal macro4Integer1, macro4String1
	
	; Macro 4 - 2 - Do not alter
	convertIntegerToHexadecimal macro4Integer2, macro4String2
	
	; Macro 4 - 3 - Do not alter
	convertIntegerToHexadecimal macro4Integer3, macro4String3

	; Macro 4 Test - Do not alter	
	; Test 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label1
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String1
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 2
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label2
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String2
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
	; Test 3
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4Label3
	mov rdx, 11
	syscall
	
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4String3
	mov rdx, 11
	syscall	
		
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, macro4NewLine
	mov rdx, 1
	syscall	
	
endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall