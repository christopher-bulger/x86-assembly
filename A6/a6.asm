section .data
    ; Program constants
    SYSTEM_EXIT equ 60
    EXIT_SUCCESS equ 0
    NULL equ 0
    SYSTEM_WRITE equ 1
	SYSTEM_READ equ 0
	STANDARD_OUT equ 1
	STANDARD_IN equ 0
    LINEFEED equ 10

    errorStringUnexpected db LINEFEED,"Error - Unexpected character found in input." , LINEFEED, LINEFEED, NULL
	errorStringNoDigits db LINEFEED,"Error - Value must contain at least one numeric digit." , LINEFEED, LINEFEED, NULL

section .bss
    array resd 10000   
    ARRAY_LENGTH resd 1

section .text
    global _start
    _start:

        endProgram:
            mov rax, SYSTEM_EXIT
            mov rdi, EXIT_SUCCESS
            syscall

    global randomNumberGenerator
    randomNumberGenerator:
        ret

    ; Parameters
    ; 1: address to dword array of values to sort (rdi)
    ; 2: length of dword array passed by value (esi)
    global combSort
    combSort:
        ; Prologue
        push rbp
        mov rbp, rsp
        push r12
        push r13
        push r14 

        ; Function code
        ; ------------------------------------------------------
        mov r8, 0 ; sortLoop offset
        mov r9, 0 ; swapLoop offset
        mov r10, 0
        mov r10, rsi ; gapsize
        mov r11, 0 ; swapsDone
        mov r12, 0 ; temp
        mov r13d, 10  ; for multiplication by 10
        mov r14d, 13  ; for division by 13

        sortLoop:
            cmp r8d, dword[rsi]
            jae sortLoopDone

            ; gapsize = (gapsize * 10) / 13
            mov eax, dword[r10]
            mul r13d 
            div r14d 
            mov r10d, eax
            
            ; swapsDone = 0
            mov r11, 0

            ; if(gapsize == 0) gapsize = 1
            cmp dword[r10], 0 
            jne swapLoop
            mov r10, 1

            swapLoop:
                mov eax, dword[rsi]
                sub eax, dword[r10]
                cmp r9d, dword[rax]  ; cmp j to arraysize - gapsize
                jae swapLoopDone

                ; if(array[j] > array[j + gapsize])
                mov rdx, 0
                mov eax, dword[rdi + r9*4]
                mov edx, dword[r10]
                add edx, dword[r9]
                cmp eax, dword[rdi + rdx*4] ; array[j + gapsize]
                jbe swapContinue

                ;swap
                mov r12d, dword[rdi + r9*4]  ; temp = array[j]
                mov eax, dword[rdi + rdx*4]  ; array[j + gapsize] in eax
                mov dword[rdi + r9*4], eax   ; array[j] = array[j + gapsize]
                mov dword[rdi + r10*4], r12d  ; array[j + gapsize] = temp
                inc r11

                swapContinue:
                    inc r9
                    jmp swapLoop

                swapLoopDone:

            cmp dword[r10], 1 ; compare gapsize to 1
            je sortContinue
            cmp r9, 0
            je sortLoopDone

            sortContinue:
                inc r8
                jmp sortLoop

            sortLoopDone:
        ; ------------------------------------------------------

        ; Epilogue
        pop r14
        pop r13
        pop r12
        mov rsp, rbp
        pop rbp
        ret

    ; Parameters
    ; Argument 1: Null terminated string (byte array)(rdi)
    ; Argument 2: dword integer variable (rsi)
    global decimalToInteger
    decimalToInteger:
        ; Prologue
        push rbp
        mov rbp, rsp
        push rbx

        ; Function code
        ; ------------------------------------------------------
        mov eax, 0
        mov rbx, rdi
        mov r9d, 1
        mov r8d, 10
        mov r10, 0

        checkForSpaces1:
            mov cl, byte[rbx]
            cmp cl, " "
            jne nextCheck1

            inc rbx
            jmp checkForSpaces1
        nextCheck1:
            cmp cl, "+"
            je checkForSpaces2Adjust
            cmp cl, '-'
            jne checkNumerals
            mov r9d, -1
        checkForSpaces2Adjust:
            inc rbx
        checkForSpaces2:
            mov cl, byte[rbx]
            cmp cl, " "
            jne nextCheck2

            inc rbx
            jmp checkForSpaces2
        nextCheck2:

        checkNumerals:
            movzx ecx, byte[rbx]
            cmp cl, NULL 
            je finishConversion

            cmp cl, " "
            je checkForSpaces3

            cmp cl, "0"
            jb errorUnexpectedCharacter
            cmp cl, "9"
            ja errorUnexpectedCharacter
            jmp convertCharacter
            errorUnexpectedCharacter:
                mov rax, SYSTEM_WRITE
                mov rdi, errorStringUnexpected
                mov rdx, 47
                syscall
                jmp endProgram

            convertCharacter:
                sub cl, "0"
                mul r8d
                add eax, ecx
                inc r10

                inc rbx
                jmp checkNumerals
            
            checkForSpaces3:
                mov cl, byte[rbx]
                cmp cl, " "
                jne checkNull

                inc rbx
                jmp checkForSpaces3

            checkNull:
                cmp cl, NULL
                je finishConversion
                
                mov rax, SYSTEM_WRITE
                mov rdi, errorStringUnexpected
                mov rdx, 47
                syscall
                jmp endProgram

            finishConversion:
                cmp r10, 0
                jne applySign
                
                mov rax, SYSTEM_WRITE
                mov rdi, errorStringNoDigits
                mov rdx, 58
                syscall
                jmp endProgram

            applySign:
                mul r9d
        ; ------------------------------------------------------

        ; Epilogue
        pop rbx
        mov rsp, rbp
        pop rbp
        ret

    ; Parameters:
    ; Argument 1: dword integer variable (rdi)
    ; Argument 2: string (11 byte array) (rsi)
    global integerToHex
    integerToHex:
        ; Prologue
        push rbp
        mov rbp, rsp
        push rbx

        ; Function code
        ; ------------------------------------------------------
        mov byte[rsi], "0"
        mov byte[rsi+1], "x"
        mov byte[rsi+10], NULL
        
        mov rbx, rsi
        add rbx, 9
        
        mov r8d, 16 ;base
        mov rcx, 8
        mov eax, dword[rdi]
        convertHexLoop:
            mov edx, 0
            div r8d
            
            cmp dl, 10
            jae addA
                add dl, "0" ; Convert 0-9 to "0"-"9"
            jmp nextDigit
            
            addA:
                add dl, 55 ; 65 - 10 = 55 to convert 10 to "A"
                
            nextDigit:
                mov byte[rbx], dl
                dec rbx
                dec rcx
        cmp eax, 0
        jne convertHexLoop

        addZeroes:
            cmp rcx, 0
            je endConversion
            mov byte[rbx], "0"
            dec rbx
            dec rcx
        jmp addZeroes
        endConversion:
        ; ------------------------------------------------------

        ; Epilogue
        pop rbx
        mov rsp, rbp
        pop rbp
        ret

