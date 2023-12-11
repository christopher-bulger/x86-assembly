;This program takes the averages of values in two lists and puts the result into a new list.
;It will then calculate the sum, min, max, average, count of even and odd numbers, of the list.

section .data
    TRUE		equ	1
    FALSE		equ	0

    EXIT_SUCCESS	equ	0		; successful operation
    SYS_exit	equ	60			; call code for terminate

    LENGTH  equ 50              ; list length

    list1   dd 2078, 3854, 6593, 947, 5252, 1190, 716, 3587, 8014, 9563,
            dd 9821, 3195, 1051, 6454, 5752, 980, 9015, 2478, 5624, 7251,
            dd 2936, 1073, 1731, 5376, 4452, 792, 2375, 2542, 5666, 2228,
            dd 454, 2379, 6066, 3340, 2631, 9138, 3530, 7528, 7152, 1551,
            dd 9537, 9590, 2168, 9647, 5362, 2728, 5939, 4620, 1828, 5736

    list2   dd 5087, 6614, 6035, 6573, 6287, 5624, 4240, 3198, 5162, 6972,
            dd 6219, 1331, 1039, 23, 4540, 2950, 2758, 3243, 1229, 8402,
            dd 8522, 4559, 1704, 4160, 6746, 5289, 2430, 9660, 702, 9609,
            dd 8673, 5012, 2340, 1477, 2878, 2331, 3652, 2623, 4679, 6041,
            dd 4160, 2310, 5232, 4158, 5419, 2158, 380, 5383, 4140, 1874

    sum     dq 0
    min     dd 0
    max     dd 0
    ave     dd 0
    oddCount   db 0
    evenCount   db 0
    dTwo    dd 2

section .bss
    list3 resd 50

section .text
global _start
_start:
    mov r8, 0   ; r8 will act as my index

    mainLoop:
        mov eax, dword[list1 + r8*4]    ; eax = list1[i]
        add eax, dword[list2 + r8*4]    ; eax = list1[i] + list2[i]
        mov edx, 0
        div eax, dword[dTwo]            ; eax = (list1[1] + list2[i]) / 2
        mov dword[list3 + r8*4], eax    ; moving result to list3[i]

        cmp r8, 0
        ja minMaxLoop

        mov eax, dword[list3 + r8*4]    ; eax = list3[0]
        mov dword[min], eax             ; initializing min to list3[0]
        mov dword[max], eax             ; initializing max to list3[0]
        jmp minMaxEnd

        minMaxLoop:
            mov eax, dword[list3 + r8*4]
            cmp eax, dword[min]
            jae setMax
            mov dword[min], eax
            
            setMax:
                cmp eax, dword[max]
                jbe minMaxEnd
                mov dword[max], eax
            
            minMaxEnd:
        
        mov edx, 0
        div dword[dTwo]
        cmp edx, 0
        jne oddNum
        inc byte[evenCount]
        jmp sumLabel

        oddNum:
            inc byte[oddCount]

        sumLabel:
            mov rax, 0
            mov eax, dword[list3 + r8*4]
            add qword[sum], rax

        inc r8
        cmp r8, LENGTH
        jb mainLoop

    mov rdx, 0
    mov rax, qword[sum]
    mov r9, LENGTH
    div r9
    mov dword[ave], eax

    last:
        mov	rax, SYS_exit
        mov	rbx, EXIT_SUCCESS
        syscall

