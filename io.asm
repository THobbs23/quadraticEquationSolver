; data conversion procedures - 32-bit versions
; author:  R. Detmer
; revised: 10/2007

.586
.MODEL FLAT
PUBLIC wtoaproc, atowproc, dtoaproc, atodproc

.CODE

; wtoaproc(source, dest)
; convert integer (source) to string of 6 characters at given destination address
; source integer passed as a doubleword, but only low-order word is processed
wtoaproc    PROC
            push   ebp                  ; save base pointer
            mov    ebp, esp             ; establish stack frame
            push   eax                  ; Save registers
            push   ebx
            push   ecx
            push   edx
            push   edi
            pushfd                     ; save flags

            mov    eax, [ebp+8]        ; first parameter (source integer)
            and    eax, 0ffffh         ; mask high-order word
            mov    edi, [ebp+12]       ; second parameter (dest offset)
ifSpecW:    cmp    ax,8000h            ; special case -32,768?
            jne    EndIfSpecW          ; if not, then normal case
            mov    BYTE PTR [edi],'-'  ; manually put in ASCII codes
            mov    BYTE PTR [edi+1],'3'  ;   for -32,768
            mov    BYTE PTR [edi+2],'2'
            mov    BYTE PTR [edi+3],'7'
            mov    BYTE PTR [edi+4],'6'
            mov    BYTE PTR [edi+5],'8'
            jmp    ExitIToA            ; done with special case
EndIfSpecW:

            push eax                   ; save source number

            mov    al,' '              ; put blanks in
            mov    ecx,5               ;   first five
            cld                        ;   bytes of
            rep stosb                  ;   destination field    

            pop    eax                 ; restore source number
            mov    cl,' '              ; default sign (blank for +)
IfNegW:     cmp    ax,0                ; check sign of number
            jge    EndIfNegW           ; skip if not negative
            mov    cl,'-'              ; sign for negative number
            neg    ax                  ; number in AX now >= 0
EndIfNegW:

            mov    bx,10               ; divisor

WhileMoreW: mov    dx,0                ; extend number to doubleword
            div    bx                  ; divide by 10
            add    dl,'0'              ; convert remainder to character
            mov    [edi],dl            ; put character in string
            dec    edi                 ; move forward to next position
            cmp    ax,0                ; check quotient
            jnz    WhileMoreW          ; continue if quotient not zero

            mov    [edi],cl            ; insert blank or "-" for sign

ExitIToA:   popfd                      ; restore flags and registers
            pop    edi
            pop    edx
            pop    ecx
            pop    ebx 
            pop    eax
            pop    ebp 
            ret                        ;exit
wtoaproc    ENDP

; dtoaproc(source, dest)
; convert double (source) to string of 11 characters at given destination address
dtoaproc    PROC   NEAR32
            push   ebp                 ; save base pointer
            mov    ebp, esp            ; establish stack frame
            push   eax                 ; Save registers
            push   ebx                 ;   used by
            push   ecx                 ;   procedure
            push   edx
            push   edi
            pushfd                      ; save flags

            mov    eax, [ebp+8]         ; first parameter (source double)
            mov    edi, [ebp+12]        ; second parameter (dest addr)
ifSpecialD: cmp    eax,80000000h        ; special case -2,147,483,648?
            jne    EndIfSpecialD        ; if not, then normal case
            mov    BYTE PTR [edi],'-'   ; manually put in ASCII codes
            mov    BYTE PTR [edi+1],'2' ;   for -2,147,483,648
            mov    BYTE PTR [edi+2],'1'
            mov    BYTE PTR [edi+3],'4'
            mov    BYTE PTR [edi+4],'7'
            mov    BYTE PTR [edi+5],'4'
            mov    BYTE PTR [edi+6],'8'
            mov    BYTE PTR [edi+7],'3'
            mov    BYTE PTR [edi+8],'6'
            mov    BYTE PTR [edi+9],'4'
            mov    BYTE PTR [edi+10],'8'
            jmp    ExitDToA            ; done with special case
EndIfSpecialD:

            push   eax                 ; save source number

            mov    al,' '              ; put blanks in
            mov    ecx,10              ;   first ten
            cld                        ;   bytes of
            rep stosb                  ;   destination field    

            pop    eax                 ; copy source number
            mov    cl,' '              ; default sign (blank for +)
IfNegD:     cmp    eax,0               ; check sign of number
            jge    EndIfNegD           ; skip if not negative
            mov    cl,'-'              ; sign for negative number
            neg    eax                 ; number in EAX now >= 0
EndIfNegD:

            mov    ebx,10              ; divisor

WhileMoreD: mov    edx,0               ; extend number to doubleword
            div    ebx                 ; divide by 10
            add    dl,30h              ; convert remainder to character
            mov    [edi],dl            ; put character in string
            dec    edi                 ; move forward to next position
            cmp    eax,0               ; check quotient
            jnz    WhileMoreD          ; continue if quotient not zero

            mov    [edi],cl            ; insert blank or "-" for sign

ExitDToA:   popfd                      ; restore flags and registers
            pop    edi
            pop    edx
            pop    ecx
            pop    ebx 
            pop    eax
            pop    ebp 
            ret                        ;exit
dtoaproc    ENDP

; atowproc(source)
; Procedure to scan data segment starting at source address, interpreting 
; ASCII characters as an word-size integer value which is returned in AX.

; Leading blanks are skipped.  A leading - or + sign is acceptable.
; Digit(s) must immediately follow the sign (if any).
; Memory scan is terminated by any non-digit.

; No error checking is done. If the number is outside the range for a
; signed word, then the return value is undefined.

atowproc    PROC
            push   ebp                 ; save base pointer
            mov    ebp, esp            ; establish stack frame
            sub    esp, 2              ; local space for sign
            push   ebx                 ; Save registers
            push   edx
            push   esi
            pushfd                     ; save flags

            mov    esi,[ebp+8]         ; get parameter (source addr)

WhileBlankW:cmp    BYTE PTR [esi],' '  ; space?
            jne    EndWhileBlankW      ; exit if not
            inc    esi                 ; increment character pointer
            jmp    WhileBlankW         ; and try again
EndWhileBlankW:

            mov    ax,1                ; default sign multiplier
IfPlusW:    cmp    BYTE PTR [esi],'+'  ; leading + ?
            je     SkipSignW           ; if so, skip over
IfMinusW:   cmp    BYTE PTR [esi],'-'  ; leading - ?
            jne    EndIfSignW          ; if not, save default +
            mov    ax,-1               ; -1 for minus sign
SkipSignW:  inc    esi                 ; move past sign
EndIfSignW:

            mov    [ebp-2],ax          ; save sign multiplier
            mov    ax,0                ; number being accumulated

WhileDigitW:cmp    BYTE PTR [esi],'0'  ; next character >= '0'
            jnge   EndWhileDigitW      ; exit if not
            cmp    BYTE PTR [esi],'9'  ; next character <= '9'
            jnle   EndWhileDigitW      ; not a digit if bigger than '9'
            imul   ax,10               ; multiply old number by 10
            mov    bl,[esi]            ; ASCII character to BL
            and    bx,000Fh            ; convert to single-digit integer
            add    ax,bx               ; add to sum
            inc    esi                 ; increment character pointer
            jmp    WhileDigitW         ; go try next character
EndWhileDigitW:

; if value is < 8000h, multiply by sign
            cmp    ax,8000h            ; 8000h?
            jnb    endIfMaxW           ; skip if not
            imul   WORD PTR [ebp-2]    ; make signed number
endIfMaxW:

            popfd                      ; restore flags
            pop    esi                 ; restore registers
            pop    edx
            pop    ebx
            mov    esp, ebp            ; delete local variable space
            pop    ebp 
            ret                        ; exit
atowproc    ENDP

; atodproc(source)
; Procedure to scan data segment starting at source address, interpreting 
; ASCII characters as an doubleword-size integer value which is returned in EAX.

; Leading blanks are skipped.  A leading - or + sign is acceptable.
; Digit(s) must immediately follow the sign (if any).
; Memory scan is terminated by any non-digit.

; No error checking is done. If the number is outside the range for a
; signed word, then the return value is undefined.

atodproc    PROC
            push   ebp                 ; save base pointer
            mov    ebp, esp            ; establish stack frame
            sub    esp, 4              ; local space for sign
            push   ebx                 ; Save registers
            push   edx
            push   esi
            pushfd                     ; save flags

            mov    esi,[ebp+8]         ; get parameter (source addr)

WhileBlankD:cmp    BYTE PTR [esi],' '  ; space?
            jne    EndWhileBlankD      ; exit if not
            inc    esi                 ; increment character pointer
            jmp    WhileBlankD         ; and try again
EndWhileBlankD:

            mov    eax,1               ; default sign multiplier
IfPlusD:    cmp    BYTE PTR [esi],'+'  ; leading + ?
            je     SkipSignD           ; if so, skip over
IfMinusD:   cmp    BYTE PTR [esi],'-'  ; leading - ?
            jne    EndIfSignD          ; if not, save default +
            mov    eax,-1              ; -1 for minus sign
SkipSignD:  inc    esi                 ; move past sign
EndIfSignD:

            mov    [ebp-4],eax         ; save sign multiplier
            mov    eax,0               ; number being accumulated

WhileDigitD:cmp    BYTE PTR [esi],'0'  ; compare next character to '0'
            jl     EndWhileDigitD      ; not a digit if smaller than '0'
            cmp    BYTE PTR [esi],'9'  ; compare to '9'
            jg     EndWhileDigitD      ; not a digit if bigger than '9'
            imul   eax,10              ; multiply old number by 10
            mov    bl,[esi]            ; ASCII character to BL
            and    ebx,0000000Fh       ; convert to single-digit integer
            add    eax,ebx             ; add to sum
            inc    esi                 ; increment character pointer
            jmp    WhileDigitD         ; go try next character
EndWhileDigitD:

; if value is < 80000000h, multiply by sign
            cmp    eax,80000000h       ; 80000000h?
            jnb    endIfMaxD           ; skip if not
            imul   DWORD PTR [ebp-4]   ; make signed number
endIfMaxD:

            popfd                      ; restore flags
            pop    esi                 ; restore registers
            pop    edx
            pop    ebx
            mov    esp, ebp            ; delete local variable space
            pop    ebp 
            ret                        ; exit
atodproc    ENDP

            END
