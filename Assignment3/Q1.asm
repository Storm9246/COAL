; Zain Ul Abideen | 24K-0818 | BCS-3F
; Assignment 03 | Question 01

INCLUDE Irvine32.inc

.data
    dividend WORD 0D4A4h
    divisor WORD 0Ah
    msg BYTE "The quotient is ",0

.code
main PROC
    movzx eax, dividend
    movzx ebx, divisor
    call RecursiveFunction

    mov edx, OFFSET msg
    call WriteString
    call WriteInt
    call CRLF

    exit
main ENDP

RecursiveFunction PROC
    cmp eax, 5h
    jbe return

    push ebx
    xor edx, edx
    div ebx
    call RecursiveFunction
    pop ebx
return:
    ret
RecursiveFunction ENDP

END main
