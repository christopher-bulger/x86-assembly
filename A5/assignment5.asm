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


;	Determines the number of characters (including null) of the provided string
;	Argument 1: Address of string
;	Returns length in rdx
%macro findLength 1
	push rcx
	
	mov rdx, 1
	%%countLettersLoop:
		mov cl, byte[%1 + rdx - 1]
		cmp cl, NULL
		je %%countLettersDone
		
		inc rdx
	loop %%countLettersLoop
	%%countLettersDone:
	
	pop rcx
%endmacro

;	Outputs error message and stops program execution
;	Argument 1: Address of error message
%macro endOnError 1
	mov rax, SYSTEM_WRITE
	mov rdi, STANDARD_OUT
	mov rsi, %1
	findLength %1	; rdx set by macro findLength
	syscall
	
	jmp endProgram
%endMacro

section .data
	; 	System Service Call Constants
	SYSTEM_EXIT equ 60
	SUCCESS equ 0
	SYSTEM_WRITE equ 1
	SYSTEM_READ equ 0
	STANDARD_OUT equ 1
	STANDARD_IN equ 0

	;	ASCII Values
	NULL equ 0
	LINEFEED equ 10
	
	;	Program Constraints
	MINIMUM_ARRAY_SIZE equ 1
	MAXIMUM_ARRAY_SIZE equ 1000
	INPUT_LENGTH equ 20
	OUTPUT_LENGTH equ 11
	VALUES_PER_LINE equ 5
	
	;	Labels / Useful Strings
	labelHeader db "Number Converter (Decimal to Hexadecimal)", LINEFEED, LINEFEED, NULL
	labelConverted db "Converted Values", LINEFEED, NULL
	endOfLine db LINEFEED, NULL
	space db " "
	
	;	Prompts
	promptCount db "Enter number of values to convert (1-1000):", LINEFEED, NULL
	promptDataEntry db "Enter decimal value:", LINEFEED, NULL
	
	;	Error Messages
	;		Array Length
	errorArrayMinimum db LINEFEED, "Error - Program can only convert at least 1 value.", LINEFEED, LINEFEED, NULL
	errorArrayMaximum db LINEFEED, "Error - Program can only convert at most 1,000 values.", LINEFEED, LINEFEED, NULL
							 
	;		Decimal String Conversion
	errorStringUnexpected db LINEFEED,"Error - Unexpected character found in input." , LINEFEED, LINEFEED, NULL
	errorStringNoDigits db LINEFEED,"Error - Value must contain at least one numeric digit." , LINEFEED, LINEFEED, NULL
	
	;		Input Length
	errorStringTooLong db LINEFEED, "Error - Input can be at most 20 characters long." , LINEFEED, LINEFEED, NULL
	
	;	Other
	arrayLength dd 0
	dTen		dd 10

section .bss
	;	Array of integer values, not all will necessarily be used
	array resd 1000
	inputChar resb 1
	inputString resb 21
	outputString resb 11
	convertedVal resd 1

section .text
global _start
_start:
	;	Output Header
		mov rax, SYSTEM_WRITE
		mov rdi, STANDARD_OUT
		mov rsi, labelHeader
		findLength labelHeader
		syscall

	;	Output Array Length Prompt
		mov rax, SYSTEM_WRITE
		mov rdi, STANDARD_OUT
		mov rsi, promptCount
		findLength promptCount
		syscall

	;	Read in Array Length - one character at a time
		mov r8, 0							; offset

		readLoop:
			readCall:
				mov rax, SYSTEM_READ
				mov rdi, STANDARD_IN
				mov rsi, inputChar				; read characters into inputString
				mov rdx, 1						; read one character at a time
				syscall

			cmp byte[inputChar], LINEFEED	; check for end of input
			je readLoopDone

			cmp byte[inputChar], 48			; check for ASCII value less than '0'
			jae checkUpperBound
			jmp invalidInput
			
			checkUpperBound:
				cmp byte[inputChar], 57		; check for ASCII value greater than '9'
				jbe continue

			invalidInput:			
				endOnError errorStringUnexpected	; output error message, end program

			continue:
				mov al, byte[inputChar]
				mov byte[inputString + r8], al
				inc r8
				jmp readLoop

			readLoopDone:
				inc r8
				mov bl, byte[inputChar]				;REMOVE 204, 205 and 206 IF ERROR
				mov byte[inputString + r8], bl
				findLength inputString
				cmp rdx, 21
				jb convertArrayLength
				endOnError errorStringTooLong

	;	Convert Array Length
		convertArrayLength:
			mov r8, 0							; offset
			mov r9, 0
			mov r9d, 10							; will store n for 10^n
			
		convertLoop:
			cmp r8, 20
			je convertLoopDone

			cmp byte[inputString + r8], NULL
			je convertLoopDone

			mov rax, 0
			mov rdx, 0
			mov eax, dword[arrayLength]		; current array length value in eax
			mul r9d							; multiply arrayLength by 10
			mov rbx, 0
			mov bl, byte[inputString + r8]	; add inputstring digit to al
			sub bl, '0'
			add eax, ebx
			mov dword[arrayLength], eax

			inc r8
			jmp convertLoop

			convertLoopDone:

	;	Check that Array Length is Valid - output error message and end program if not
		cmp dword[arrayLength], MINIMUM_ARRAY_SIZE
		jl sizeTooSmall

		cmp dword[arrayLength], MAXIMUM_ARRAY_SIZE
		ja sizeTooLarge
		jmp sizeGood

		sizeTooSmall:
			endOnError errorArrayMinimum
		sizeTooLarge:
			endOnError errorArrayMaximum
		sizeGood:


	;	Read in Array Values
	mov r15d, 0

	readArrayValues:
		cmp r15d, dword[arrayLength]
		je readArrayValuesDone

		; Prompt For New Value
		mov rax, SYSTEM_WRITE
		mov rdi, STANDARD_OUT
		mov rsi, promptDataEntry
		findLength promptDataEntry
		syscall

		;	Read in Value - one character at a time
		mov r11, 0
		arrayInputs:
			mov rax, SYSTEM_READ
			mov rdi, STANDARD_IN
			mov rsi, inputChar
			mov rdi, 1
			syscall

			cmp byte[inputChar], NULL
			je arrayInputsDone

			cmp byte[inputChar], 48			; check for ASCII value less than '0'
			jae checkUpperBound2
			jmp invalidInput2
			
			checkUpperBound2:
				cmp byte[inputChar], 57		; check for ASCII value greater than '9'
				jbe continue2

			invalidInput2:			
				endOnError errorStringUnexpected	; output error message, end program

			continue2:
				mov rbx, 0
				mov bl, byte[inputChar]
				mov byte[inputString + r11], bl
				inc r11
				jmp arrayInputs

			arrayInputsDone:
				inc r11
				mov bl, byte[inputChar]
				mov byte[inputString + r11], bl
				findLength inputString
				cmp rdx, 21
				jbe convertValue
				endOnError errorStringTooLong

		;	Convert Value
		convertValue:
			convertDecimalToInteger inputString, convertedVal
			mov r12d, dword[convertedVal]
			mov dword[array + r15d], r12d
			inc r15d
			jmp readArrayValues

		readArrayValuesDone:


	;	Output Array Values in Hex - (5 Per Line)
	; 		Print Header

	mov r8, 0 
	convertToHex:
		cmp r8d, dword[arrayLength]
		je convertToHexDone
		mov r9d, dword[array + r8]
		convertIntegerToHexadecimal r9d, outputString
		inc r8
		jmp convertToHex

		convertToHexDone:

	;print output
	mov r8, 0
	outputLoop:
		cmp r8d, dword[arrayLength]
		je outputLoopDone
		mov ebx, dword[array + r8]
		mov dword[outputString], ebx

		mov rax, SYSTEM_WRITE
		mov rdi, STANDARD_OUT
		mov rsi, outputString
		findLength outputString
		syscall

		inc r8
		jmp outputLoop

		outputLoopDone:

endProgram:
	mov rax, SYSTEM_EXIT
	mov rdi, SUCCESS
	syscall