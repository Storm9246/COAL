
; Zain Ul Abideen | 24K-0818 | BCS-3F
; Assignment 03 | Question 02

INCLUDE Irvine32.inc

.data
    str1 BYTE 50 DUP(?)
    msg1 BYTE "Enter a string: ",0
    msg2 BYTE "Vowel Count",0
    countVowel BYTE 5 DUP(0)
    msg3 BYTE "a or A = ",0
    msg4 BYTE "e or E = ",0
    msg5 BYTE "i or I = ",0
    msg6 BYTE "o or O = ",0
    msg7 BYTE "u or U = ",0

.code
main PROC
    mov edx, OFFSET msg1
    call WriteString
    mov edx, OFFSET str1
    mov ecx, SIZEOF str1
    call ReadString

    mov esi, OFFSET str1
check_loop:
    mov al, [esi]
    cmp al, 0
    je display

    cmp al, 'a'
    je inc_A
    cmp al, 'A'
    je inc_A

    cmp al, 'e'
    je inc_E
    cmp al, 'E'
    je inc_E

    cmp al, 'i'
    je inc_I
    cmp al, 'I'
    je inc_I

    cmp al, 'o'
    je inc_O
    cmp al, 'O'
    je inc_O

    cmp al, 'u'
    je inc_U
    cmp al, 'U'
    je inc_U
    jmp next

inc_A:
    inc BYTE PTR [countVowel + 0]
    jmp next

inc_E:
    inc BYTE PTR [countVowel + 1]
    jmp next

inc_I:
    inc BYTE PTR [countVowel + 2]
    jmp next

inc_O:
    inc BYTE PTR [countVowel + 3]
    jmp next

inc_U:
    inc BYTE PTR [countVowel + 4]

next:
    inc esi
    jmp check_loop

display:
    call CRLF
    mov edx, OFFSET msg2
    call WriteString
    call CRLF

    mov edx, OFFSET msg3
    call WriteString
    movzx eax, BYTE PTR [countVowel + 0]
    call WriteDec
    call CRLF

    mov edx, OFFSET msg4
    call WriteString
    movzx eax, BYTE PTR [countVowel + 1]
    call WriteDec
    call CRLF

    mov edx, OFFSET msg5
    call WriteString
    movzx eax, BYTE PTR [countVowel + 2]
    call WriteDec
    call CRLF

    mov edx, OFFSET msg6
    call WriteString
    movzx eax, BYTE PTR [countVowel + 3]
    call WriteDec
    call CRLF

    mov edx, OFFSET msg7
    call WriteString
    movzx eax, BYTE PTR [countVowel + 4]
    call WriteDec
    call CRLF

    exit
main ENDP
END main
