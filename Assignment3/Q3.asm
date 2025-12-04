; Zain ul abideen | 24K-0818 | BCS-3F
; Assignment 03 | Question 03

INCLUDE Irvine32.inc

.data
    str1 BYTE "######FAST", 0

.code
STR_TRIMM PROC, AddrStr : PTR BYTE, char2trim : BYTE
    mov esi, AddrStr
    mov edi, esi
    mov bl, char2trim

skip_loop:
    mov al, [esi]
    cmp al, 0
    je string_end

    cmp al, bl
    jne copy_rest_char
    inc esi
    jmp skip_loop

copy_rest_char:
    mov al, [esi]
    mov [edi], al
    cmp al, 0
    je return
    inc esi
    inc edi
    jmp copy_rest_char

string_end:
    mov BYTE PTR [edi], 0

return:
    ret
STR_TRIMM ENDP

main PROC
    INVOKE STR_TRIMM, ADDR str1, '#'
    mov edx, OFFSET str1
    call WriteString
    call CRLF

    exit
main ENDP
END main
