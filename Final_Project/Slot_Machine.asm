INCLUDE Irvine32.inc

.data
;Variables
;GAME STATE
symbols       BYTE 'A','B','C','7','$'
grid          BYTE 9 DUP(?)            
balance       SDWORD 100 
currentBet    SDWORD 10
winMultiplier SDWORD 1

;BANKING 
userPin       BYTE 5 DUP(?)    
correctPin    BYTE "1234",0    
depositAmt    SDWORD ?              
startTime     DWORD ?
profit        SDWORD ?

;STATISTICS 
totalSpins    DWORD 0
totalJackpots DWORD 0
highScore     SDWORD 100

;DEV MODE press 9 to access
devJackpotInt DWORD 0          ; Win every X spins
devMegaInt    DWORD 0          ; Mega every X spins
devLossLimit  DWORD 0          ; Force Loss until Spin # X
spinCount     DWORD 0          ; Session Counter

;STRINGS
;MAIN MENU 
msgMenuTitle1 BYTE "========================================",0
msgMenuTitle2 BYTE "     $$$  GOLDEN PALACE CASINO  $$$     ",0
msgMenuTitle3 BYTE "========================================",0
msgOpt1       BYTE "   [1] Play Slots (Spin to Win)",0
msgOpt2       BYTE "   [2] Visit ATM (Deposit/Withdraw)",0
msgOpt3       BYTE "   [3] Player Statistics",0
msgOpt4       BYTE "   [4] Help / Payouts",0
msgOpt5       BYTE "   [5] Exit Casino",0

;BETTING MENU
msgBetTitle   BYTE "--- SELECT YOUR STAKES ---",0
msgBet1       BYTE "   [1] Standard    (Cost: 10  | Multiplier: 1x)",0
msgBet2       BYTE "   [2] High Roller (Cost: 50  | Multiplier: 5x)",0
msgBet3       BYTE "   [3] VIP Lounge  (Cost: 100 | Multiplier: 10x)",0
msgBetAll     BYTE "   [0] !! ALL IN !! (Risk ALL | Multiplier: 1000x)",0
msgBetErr     BYTE "   XX INSUFFICIENT FUNDS FOR THIS BET XX",0

;BANK
msgBankTitle  BYTE ":: CASINO TREASURY ATM ::",0
msgBankSub    BYTE "Secure Transaction Terminal v1.0",0
msgPinPrompt  BYTE "ENTER 4-DIGIT SECURITY PIN: ",0
msgPinErr     BYTE "ACCESS DENIED: INCORRECT PIN",0
msgBankOpt1   BYTE "   [1] Deposit Funds",0
msgBankOpt2   BYTE "   [2] Withdraw Profit",0
msgBankOpt3   BYTE "   [3] Return to Lobby",0

msgAskAmt     BYTE "ENTER AMOUNT: Rs. ",0
msgProcess    BYTE "   [ PROCESSING REQUEST... ]",0
msgInstruct   BYTE "   Security Check: Press ';' to Confirm",0
msgKey        BYTE "   (Time limit: 5 Seconds)",0
msgSuccess    BYTE "   >>> TRANSACTION APPROVED <<<",0
msgFailed     BYTE "   !!! TRANSACTION DENIED !!!",0

msgWdSuccess  BYTE "   >>> CASH DISPENSED <<<",0
msgWdAmt      BYTE "   Dispensed Amount: Rs. ",0
msgWdFail     BYTE "   !!! WITHDRAWAL ERROR !!!",0
msgWdReason   BYTE "   Error: Insufficient Profit (Base Rs.100 Locked)",0

;SLOT UI
msgTitle      BYTE "=== SUPER SLOTS 777 ===",0
msgBal        BYTE " BALANCE: Rs. ",0
msgCost       BYTE " BET:     Rs. ",0
msgEnter      BYTE " [ENTER] Spin   |   [ESC] Lobby",0
msgBroke      BYTE " !!! INSUFFICIENT FUNDS !!!",0
msgBrokeOpt   BYTE " [1] Go to ATM    [ESC] Lobby",0
msgSpace      BYTE "      ",0 

;RESULTS
msgMega       BYTE " $$$ MEGA JACKPOT (3 ROWS) $$$",0
msgWin        BYTE " *** WINNER! ***",0
msgLose       BYTE " ... No Win ...",0

;STATS & HELP
msgStatsTitle BYTE "=== PLAYER STATISTICS ===",0
msgStat1      BYTE "Total Spins:      ",0
msgStat2      BYTE "Total Jackpots:   ",0
msgStat3      BYTE "Highest Balance:  Rs. ",0
msgHelpTitle  BYTE "=== PAYOUT TABLE ===",0
msgHelp1      BYTE " 7 7 7  =  JACKPOT (50x Bet)",0
msgHelp2      BYTE " $ $ $  =  BIG WIN (20x Bet)",0
msgHelp3      BYTE " A A A  =  WIN     (5x Bet)",0
msgHelp4      BYTE "Any Match = Small Win",0
msgPause      BYTE "Press any key to return...",0

;DEV MENU
msgDevTitle   BYTE "/// DEVELOPER CONSOLE  ///",0
msgDevOpt1    BYTE "   [1] Force WIN Interval  (Current: ",0
msgDevOpt2    BYTE "   [2] Force MEGA Interval (Current: ",0
msgDevOpt3    BYTE "   [3] Force LOSS Until Spin # (Current: ",0
msgDevInput   BYTE "Enter Value (0 to disable): ",0
msgDevSet     BYTE "   >>> RIGGED LOGIC UPDATED <<<",0

.code
main PROC
    call Randomize        
    mov eax, white + (black * 16)
    call SetTextColor
    call Clrscr

AppLoop:
    ; Check High Score
    mov eax, balance
    cmp eax, highScore
    jle DrawMenu
    mov highScore, eax

DrawMenu:
    mov eax, white + (black * 16)
    call SetTextColor
    call Clrscr
    
    ; Header
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 4
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgMenuTitle1
    call WriteString
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgMenuTitle2
    call WriteString
    mov dh, 6
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgMenuTitle3
    call WriteString
    
    ; Options
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov dh, 9
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgOpt1
    call WriteString
    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgOpt2
    call WriteString
    mov dh, 13
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgOpt3
    call WriteString
    mov dh, 15
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgOpt4
    call WriteString
    mov dh, 17
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgOpt5
    call WriteString

    ; Input Logic
    call ReadChar
    cmp al, '1'
    je  SelectBetting
    cmp al, '2'
    je  RunBank
    cmp al, '3'
    je  ShowStats
    cmp al, '4'
    je  ShowHelp
    cmp al, '5'
    je  CloseApp
    cmp al, '9'       ; SECRET KEY
    je  RunDevMode
    jmp AppLoop

SelectBetting:
    call BettingMenu
    cmp eax, 0        ; Check if user cancelled
    je  AppLoop
    call PlaySlotsSystem
    jmp AppLoop

RunBank:
    call BankSystem
    jmp AppLoop

RunDevMode:
    call DevMenu
    jmp AppLoop

ShowStats:
    call StatsScreen
    jmp AppLoop

ShowHelp:
    call HelpScreen
    jmp AppLoop

CloseApp:
    exit
main ENDP


; BETTING SYSTEM 
BettingMenu PROC
    call Clrscr
    mov eax, yellow + (black * 16)
    call SetTextColor
    
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgBetTitle
    call WriteString

    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgBet1
    call WriteString
    
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgBet2
    call WriteString
    
    mov dh, 12
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgBet3
    call WriteString
    
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgBetAll
    call WriteString

    call ReadChar
    
    cmp al, '1'
    je SetBet1
    cmp al, '2'
    je SetBet2
    cmp al, '3'
    je SetBet3
    cmp al, '0'
    je SetBetAll
    cmp al, 27 
    je CancelBet

SetBet1:
    mov currentBet, 10
    mov winMultiplier, 1
    jmp CheckFunds
SetBet2:
    mov currentBet, 50
    mov winMultiplier, 5
    jmp CheckFunds
SetBet3:
    mov currentBet, 100
    mov winMultiplier, 10
    jmp CheckFunds
SetBetAll:
    mov eax, balance
    mov currentBet, eax
    mov winMultiplier, 1000 
    jmp CheckFunds

CheckFunds:
    mov eax, balance
    cmp eax, currentBet
    jl  BetFail
    mov eax, 1 ; Success
    ret

BetFail:
    mov dh, 16
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgBetErr
    call WriteString
    mov eax, 1500
    call Delay
    jmp BettingMenu

CancelBet:
    mov eax, 0 
    ret
BettingMenu ENDP


; SLOT MACHINE SYSTEM 
PlaySlotsSystem PROC
SlotLoop:
    call Clrscr 
    
    ; 1. Draw UI
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 1
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET msgTitle
    call WriteString

    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov dh, 3
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET msgBal
    call WriteString
    mov eax, balance
    call WriteInt
    mov edx, OFFSET msgSpace 
    call WriteString
    
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov dh, 3
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgCost
    call WriteString
    mov eax, currentBet
    call WriteInt
    mov edx, OFFSET msgSpace
    call WriteString

    ; 2. Check Money
    mov eax, balance
    cmp eax, currentBet
    jl  BrokeState

    ; 3. Wait Input
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET msgEnter 
    call WriteString
    
    call ReadChar         
    cmp al, 27            
    je  ExitSlots          

    ; 4. Spin
    call Clrscr 
    mov eax, currentBet
    sub balance, eax       
    inc totalSpins        
    inc spinCount

    ; Redraw Header
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 1
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET msgTitle
    call WriteString

    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov dh, 3
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET msgBal
    call WriteString
    mov eax, balance
    call WriteInt
    mov edx, OFFSET msgSpace
    call WriteString
    
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov dh, 3
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgCost
    call WriteString
    mov eax, currentBet
    call WriteInt

    mov eax, white + (black * 16)
    call SetTextColor
    
    ; === CORE GAMEPLAY CALL ===
    call SpinReels
    call CheckJackpot     
    ; ==========================

    mov dh, 16
    mov dl, 1
    call Gotoxy
    call WaitMsg          
    jmp SlotLoop          

BrokeState:
    call Crlf
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov dh, 13
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET msgBroke
    call WriteString
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 14
    mov dl, 2
    call Gotoxy
    mov edx, OFFSET msgBrokeOpt
    call WriteString
    call ReadChar
    cmp al, '1'
    je  QuickBank
    cmp al, 27
    je  ExitSlots
    jmp BrokeState
QuickBank:
    call BankSystem
    jmp SlotLoop

ExitSlots:
    ret
PlaySlotsSystem ENDP


; BANKING SYSTEM
BankSystem PROC
    ; 1. AUTHENTICATION
    call Clrscr
    mov eax, white + (blue * 16)
    call SetTextColor
    
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgPinPrompt
    call WriteString
    
    mov edx, OFFSET userPin
    mov ecx, 5 
    call ReadString
    
    mov esi, OFFSET userPin
    mov edi, OFFSET correctPin
    mov ecx, 4
    cld
    repe cmpsb
    jne PinFail
    
    jmp BankMenu

PinFail:
    mov dh, 12
    mov dl, 20
    mov eax, lightRed + (blue * 16)
    call SetTextColor
    mov edx, OFFSET msgPinErr
    call WriteString
    mov eax, 2000
    call Delay
    ret

BankMenu:
    mov eax, white + (blue * 16) 
    call SetTextColor
    call Clrscr 

    mov eax, black + (white * 16)
    call SetTextColor
    mov dh, 2
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgBankTitle
    call WriteString
    
    mov eax, yellow + (blue * 16)
    call SetTextColor
    mov dh, 3
    mov dl, 24
    call Gotoxy
    mov edx, OFFSET msgBankSub
    call WriteString
    
    mov eax, white + (blue * 16)
    call SetTextColor
    mov dh, 6
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgBal
    call WriteString
    mov eax, balance
    call WriteInt
    
    mov dh, 9
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgBankOpt1
    call WriteString
    mov dh, 11
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgBankOpt2
    call WriteString
    mov dh, 13
    mov dl, 25
    call Gotoxy
    mov edx, OFFSET msgBankOpt3
    call WriteString

    call ReadChar
    cmp al, '1'
    je  DoDeposit
    cmp al, '2'
    je  DoWithdraw
    cmp al, '3'
    je  ExitBank
    jmp BankMenu

DoDeposit:
    call Clrscr
    mov eax, yellow + (blue * 16)
    call SetTextColor
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgAskAmt
    call WriteString
    mov eax, white + (blue * 16) 
    call SetTextColor
    call ReadInt
    mov depositAmt, eax
    mov dh, 9
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgProcess
    call WriteString
    mov dh, 11
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgInstruct
    call WriteString
    mov dh, 12
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgKey
    call WriteString
    call GetMseconds    
    mov startTime, eax  
TimerLoop:
    call GetMseconds
    sub eax, startTime
    cmp eax, 5000       
    jg  TransFailed
    call ReadKey        
    jz   TimerLoop      
    cmp al, ';'
    je  TransSuccess
    jmp TransFailed

TransSuccess:
    mov dh, 15
    mov dl, 20
    call Gotoxy
    mov eax, lightGreen + (blue * 16)
    call SetTextColor
    mov edx, OFFSET msgSuccess
    call WriteString
    mov eax, depositAmt
    add balance, eax
    mov eax, 1000
    call Delay
    jmp BankMenu

TransFailed:
    mov dh, 15
    mov dl, 20
    call Gotoxy
    mov eax, lightRed + (blue * 16)
    call SetTextColor
    mov edx, OFFSET msgFailed
    call WriteString
    mov eax, 2000
    call Delay
    jmp BankMenu

DoWithdraw:
    call Clrscr
    mov eax, balance
    sub eax, 100
    mov profit, eax
    cmp profit, 0
    jle WdFail
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov eax, lightGreen + (blue * 16)
    call SetTextColor
    mov edx, OFFSET msgWdSuccess
    call WriteString
    mov dh, 11
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgWdAmt
    call WriteString
    mov eax, profit
    call WriteInt
    mov balance, 100
    call Crlf
    call WaitMsg
    jmp BankMenu

WdFail:
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov eax, lightRed + (blue * 16)
    call SetTextColor
    mov edx, OFFSET msgWdFail
    call WriteString
    mov dh, 11
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgWdReason
    call WriteString
    call Crlf
    call WaitMsg
    jmp BankMenu

ExitBank:
    ret
BankSystem ENDP


; DEV MENU (GOD MODE)
DevMenu PROC
    call Clrscr
    mov eax, lightRed + (black * 16)
    call SetTextColor
    mov dh, 2
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgDevTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 5
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET msgDevOpt1
    call WriteString
    mov eax, devJackpotInt
    call WriteInt
    mov al, ')'
    call WriteChar
    
    mov dh, 7
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET msgDevOpt2
    call WriteString
    mov eax, devMegaInt
    call WriteInt
    mov al, ')'
    call WriteChar
    
    mov dh, 9
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET msgDevOpt3
    call WriteString
    mov eax, devLossLimit
    call WriteInt
    mov al, ')'
    call WriteChar
    
    mov dh, 12
    mov dl, 10
    call Gotoxy
    call ReadChar
    cmp al, '1'
    je SetDev1
    cmp al, '2'
    je SetDev2
    cmp al, '3'
    je SetDev3
    ret

SetDev1:
    mov dh, 14
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET msgDevInput
    call WriteString
    call ReadInt
    mov devJackpotInt, eax
    mov spinCount, 0 
    jmp DevSuccess
    
SetDev2:
    mov dh, 14
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET msgDevInput
    call WriteString
    call ReadInt
    mov devMegaInt, eax
    mov spinCount, 0
    jmp DevSuccess

SetDev3:
    mov dh, 14
    mov dl, 10
    call Gotoxy
    mov edx, OFFSET msgDevInput
    call WriteString
    call ReadInt
    mov devLossLimit, eax
    mov spinCount, 0
    jmp DevSuccess

DevSuccess:
    mov dh, 16
    mov dl, 10
    mov eax, lightGreen + (black * 16)
    call SetTextColor
    mov edx, OFFSET msgDevSet
    call WriteString
    mov eax, 1000
    call Delay
    ret
DevMenu ENDP


; STATS & HELP
StatsScreen PROC
    call Clrscr
    mov eax, cyan + (black * 16)
    call SetTextColor
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgStatsTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    
    mov dh, 8
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgStat1
    call WriteString
    mov eax, totalSpins
    call WriteInt
    
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgStat2
    call WriteString
    mov eax, totalJackpots
    call WriteInt
    
    mov dh, 12
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgStat3
    call WriteString
    mov eax, highScore
    call WriteInt
    
    ; FIXED SPACING: Row 22
    mov dh, 16
    mov dl, 15
    mov edx, OFFSET msgPause
    call WriteString
    call ReadChar
    ret
StatsScreen ENDP

HelpScreen PROC
    call Clrscr
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov dh, 5
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgHelpTitle
    call WriteString
    
    mov eax, white + (black * 16)
    call SetTextColor
    mov dh, 8
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgHelp1
    call WriteString
    mov dh, 10
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgHelp2
    call WriteString
    mov dh, 12
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgHelp3
    call WriteString
    mov dh, 14
    mov dl, 20
    call Gotoxy
    mov edx, OFFSET msgHelp4
    call WriteString
    
    ; FIXED SPACING: Row 22
    mov dh, 22
    mov dl, 20
    mov edx, OFFSET msgPause
    call WriteString
    call ReadChar
    ret
HelpScreen ENDP


; VISUALS & RIGGING LOGIC
SpinReels PROC
    ; 1. ALWAYS PLAY THE FULL ANIMATION
    ; This ensures the rigging is seamless.
    mov ecx, 35           
SpinLoop:
    push ecx              
    mov dh, 5            
    mov dl, 6            
    call Gotoxy
    mov eax, yellow + (black * 16)
    call SetTextColor
    call DrawTopBorder   
    mov dh, 6            
    mov esi, 0            
    mov ecx, 3            
RowLoop:
    push ecx              
    mov dl, 6            
    call Gotoxy          
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov al, 186          
    call WriteChar
    mov al, ' '
    call WriteChar
    mov ecx, 3            
ColLoop:
        mov eax, 5
        call RandomRange 
        mov bl, symbols[eax]
        mov grid[esi], bl 
        inc esi           
        mov eax, white + (black * 16)
        call SetTextColor
        mov al, bl
        call WriteChar
        mov al, ' '
        call WriteChar
    loop ColLoop          
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov al, 186          
    call WriteChar
    inc dh                
    pop ecx               
    loop RowLoop          
    mov dl, 6           
    call Gotoxy
    call DrawBottomBorder
    mov eax, 50           
    call Delay
    pop ecx               
    dec ecx               
    cmp ecx, 0            
    jne SpinLoop          

  
    mov eax, devMegaInt
    cmp eax, 0
    je CheckRegularDev
    mov eax, spinCount
    mov edx, 0
    div devMegaInt 
    cmp edx, 0
    je ForceMegaGrid 
    
CheckRegularDev:
    ; B. Check Normal Win Rig
    mov eax, devJackpotInt
    cmp eax, 0
    je CheckLossDev
    mov eax, spinCount
    mov edx, 0
    div devJackpotInt
    cmp edx, 0
    je ForceJackpotGrid 

CheckLossDev:
    mov eax, devLossLimit
    cmp eax, 0
    je FinishSpin 
    
    mov eax, spinCount
    cmp eax, devLossLimit
    jle ForceLossGrid 

FinishSpin:
    ret 

;Rigging

ForceMegaGrid:
    mov ecx, 9
    mov esi, 0
Fill7s:
    mov grid[esi], '7'
    inc esi
    loop Fill7s
    call DrawStaticGrid ; Redraw so user sees the 7s
    ret

ForceJackpotGrid:
    mov grid[3], '7'
    mov grid[4], '7'
    mov grid[5], '7'
    call DrawStaticGrid
    ret

ForceLossGrid:
    mov grid[0], 'A'
    mov grid[1], 'B'
    mov grid[2], 'A'
    
    mov grid[3], 'C'
    mov grid[4], 'A'
    mov grid[5], 'B'
    
    mov grid[6], 'B'
    mov grid[7], 'C'
    mov grid[8], 'B'
    call DrawStaticGrid
    ret
    
SpinReels ENDP

DrawStaticGrid PROC
    mov dh, 5
    mov dl, 6
    call Gotoxy
    mov eax, yellow + (black * 16)
    call SetTextColor
    call DrawTopBorder
    mov dh, 6
    mov esi, 0
    mov ecx, 3
DLoop1:
    push ecx
    mov dl, 6
    call Gotoxy
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov al, 186
    call WriteChar
    mov al, ' '
    call WriteChar
    mov ecx, 3
DLoop2:
    mov eax, white + (black * 16)
    call SetTextColor
    mov al, grid[esi]
    call WriteChar
    mov al, ' '
    call WriteChar
    inc esi
    loop DLoop2
    mov eax, yellow + (black * 16)
    call SetTextColor
    mov al, 186
    call WriteChar
    inc dh
    pop ecx
    loop DLoop1
    mov dl, 6
    call Gotoxy
    call DrawBottomBorder
    ret
DrawStaticGrid ENDP

CheckJackpot PROC
    mov dh, 12            
    mov dl, 1             
    call Gotoxy
    mov ebx, 0            

    ; Row 1
    mov al, grid[0]
    cmp al, grid[1]
    jne CheckRow2         
    cmp al, grid[2]
    jne CheckRow2
    inc ebx               
    mov eax, black + (yellow * 16)
    call SetTextColor
    call HighlightRow1    
    mov eax, lightGray + (black * 16)
    call SetTextColor

    CheckRow2:
    mov al, grid[3]
    cmp al, grid[4]
    jne CheckRow3
    cmp al, grid[5]
    jne CheckRow3
    inc ebx               
    mov eax, black + (yellow * 16)
    call SetTextColor
    call HighlightRow2    
    mov eax, lightGray + (black * 16)
    call SetTextColor

    CheckRow3:
    mov al, grid[6]
    cmp al, grid[7]
    jne AnalyzeWins
    cmp al, grid[8]
    jne AnalyzeWins
    inc ebx               
    mov eax, black + (yellow * 16)
    call SetTextColor
    call HighlightRow3    
    mov eax, lightGray + (black * 16)
    call SetTextColor

    AnalyzeWins:
    cmp ebx, 3            
    je  MegaWin           
    cmp ebx, 0            
    jg  NormalWin         

    ; Diags
    mov al, grid[0]
    cmp al, grid[4]
    jne TryDiag2
    cmp al, grid[8]
    jne TryDiag2          
    mov eax, black + (yellow * 16)
    call SetTextColor
    call HighlightDiag1   
    jmp NormalWin

    TryDiag2:
    mov al, grid[6]
    cmp al, grid[4]
    jne YouLost
    cmp al, grid[2]
    jne YouLost
    mov eax, black + (yellow * 16)
    call SetTextColor
    call HighlightDiag2   
    jmp NormalWin

    YouLost:
    mov eax, lightRed + (black * 16) 
    call SetTextColor
    call RedrawBorders    
    mov dh, 12            
    mov dl, 1
    call Gotoxy
    mov edx, OFFSET msgLose
    call WriteString
    jmp ExitCheck

    MegaWin:
    inc totalJackpots
    mov eax, 500              
    imul eax, winMultiplier   
    add balance, eax      
    mov eax, yellow + (black * 16)    
    call SetTextColor
    call RedrawBorders
    mov eax, yellow + (blue * 16)     
    call SetTextColor
    mov dh, 12
    mov dl, 1
    call Gotoxy
    mov edx, OFFSET msgMega
    call WriteString
    mov al, 7
    call WriteChar
    jmp ExitCheck

    NormalWin:
    inc totalJackpots
    mov eax, 50             
    imul eax, winMultiplier 
    add balance, eax       
    mov eax, yellow + (black * 16) 
    call SetTextColor
    call RedrawBorders
    mov eax, lightGreen + (black * 16) 
    call SetTextColor
    mov dh, 12
    mov dl, 1
    call Gotoxy
    mov edx, OFFSET msgWin
    call WriteString
    mov al, 7
    call WriteChar

    ExitCheck:
    mov eax, lightGray + (black * 16)
    call SetTextColor
    call Crlf
    ret
CheckJackpot ENDP

;VISUAL HELpers
HighlightRow1 PROC
    mov dh, 6            
    mov dl, 8            
    call Gotoxy
    mov al, grid[0]
    call WriteChar
    mov dl, 10           
    call Gotoxy
    mov al, grid[1]
    call WriteChar
    mov dl, 12           
    call Gotoxy
    mov al, grid[2]
    call WriteChar
    ret
HighlightRow1 ENDP

HighlightRow2 PROC
    mov dh, 7            
    mov dl, 8
    call Gotoxy
    mov al, grid[3]
    call WriteChar
    mov dl, 10
    call Gotoxy
    mov al, grid[4]
    call WriteChar
    mov dl, 12
    call Gotoxy
    mov al, grid[5]
    call WriteChar
    ret
HighlightRow2 ENDP

HighlightRow3 PROC
    mov dh, 8            
    mov dl, 8
    call Gotoxy
    mov al, grid[6]
    call WriteChar
    mov dl, 10
    call Gotoxy
    mov al, grid[7]
    call WriteChar
    mov dl, 12
    call Gotoxy
    mov al, grid[8]
    call WriteChar
    ret
HighlightRow3 ENDP

HighlightDiag1 PROC      
    mov dh, 6            
    mov dl, 8
    call Gotoxy
    mov al, grid[0]
    call WriteChar
    mov dh, 7            
    mov dl, 10
    call Gotoxy
    mov al, grid[4]
    call WriteChar
    mov dh, 8            
    mov dl, 12
    call Gotoxy
    mov al, grid[8]
    call WriteChar
    ret
HighlightDiag1 ENDP

HighlightDiag2 PROC      
    mov dh, 8            
    mov dl, 8
    call Gotoxy
    mov al, grid[6]
    call WriteChar
    mov dh, 7            
    mov dl, 10
    call Gotoxy
    mov al, grid[4]
    call WriteChar
    mov dh, 6            
    mov dl, 12
    call Gotoxy
    mov al, grid[2]
    call WriteChar
    ret
HighlightDiag2 ENDP

RedrawBorders PROC
    push edx
    mov dh, 5
    mov dl, 6
    call Gotoxy
    call DrawTopBorder
    mov dh, 9
    mov dl, 6
    call Gotoxy
    call DrawBottomBorder
    pop edx
    ret
RedrawBorders ENDP

DrawTopBorder PROC
    mov al, 201          
    call WriteChar
    mov al, 205          
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    mov al, 187          
    call WriteChar
    call Crlf
    ret
DrawTopBorder ENDP

DrawBottomBorder PROC
    mov al, 200          
    call WriteChar
    mov al, 205          
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    call WriteChar
    mov al, 188          
    call WriteChar
    call Crlf
    ret
DrawBottomBorder ENDP

END main
