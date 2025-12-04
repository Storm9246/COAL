; Zain ul abideen | 24K-0818 | BCS-3F
; Assignment 03 | Question 04

INCLUDE Irvine32.inc

.data
    arr1 DWORD 7,3,5,5,5,5,5,6,9
    s1 DWORD 9
    arr2 DWORD 5,5,5,5,5,9,8,7
    s2 DWORD 8
    arr3 DWORD 9,8,7,5,5,5,5,5
    s3 DWORD 8
    arr4 DWORD 9,8,7,5,5,5,5
    s4 DWORD 7

.code
FindFive PROC, ptrArray : PTR DWORD, arrSize : DWORD
    push ebx
    push ecx
    push esi
    push edi
    
    mov esi, ptrArray
    mov ecx, arrSize
    sub ecx, 4
    jle not_found
    
L1:
    mov edi, 0
    mov ebx, 0
    
check_consecutive:
    cmp edi, 5
    je found

    mov eax, [esi + ebx * 4]
    cmp eax, 5
    jne next
    inc edi
    inc ebx
    jmp check_consecutive
    
next:
    add esi, 4
    loop L1
    
not_found:
    mov eax, 0
    jmp return
    
found:
    mov eax, 1
    
return:
    pop edi
    pop esi
    pop ecx
    pop ebx

    ret
FindFive ENDP

main PROC
    INVOKE FindFive, ADDR arr1, s1
    call WriteDec
    call CRLF
    
    INVOKE FindFive, ADDR arr2, s2
    call WriteDec
    call CRLF
    
    INVOKE FindFive, ADDR arr3, s3
    call WriteDec
    call CRLF
    
    INVOKE FindFive, ADDR arr4, s3
    call WriteDec
    call CRLF

    exit
main ENDP

END main
