; IO.H -- header file for I/O macros (listing suppressed)
.NOLIST      ; turn off listing

; 32-bit version with windows I/O
; must be used with project framework defining showOutput and getInput
; R. Detmer   October 2007
.586
EXTRN _getInput:NEAR32, _showOutput:NEAR32, atodproc:NEAR32, dtoaproc:NEAR32, wtoaproc:NEAR32, atowproc:NEAR32


dtoa        MACRO  dest,source         ; convert double to ASCII string
            push   ebx                 ; save EBX
            lea    ebx, dest           ; destination address
            push   ebx                 ; destination parameter
            mov    ebx, [esp+4]        ; in case source was EBX
            mov    ebx, source         ; source value
            push   ebx                 ; source parameter
            call   dtoaproc            ; call dtoaproc(source,dest)
            add    esp, 8              ; remove parameters
            pop    ebx                 ; restore EBX
            ENDM

atod        MACRO  source              ; convert ASCII string to integer in EAX
            lea    eax,source          ; source address to AX
            push   eax                 ; source parameter on stack
            call   atodproc            ; call atodproc(source)
            add    esp, 4              ; remove parameter
            ENDM

wtoa        MACRO  dest,source         ; convert word to ASCII string
            push   ebx                 ; save EBX
            lea    ebx,dest            ; destination address
            push   ebx                 ; destination parameter
            mov    ebx, [esp+4]        ; in case source was BX
            mov    bx, source          ; source value
            push   ebx                 ; source parameter
            call   wtoaproc            ; call dtoaproc(source,dest)
            add    esp, 8              ; remove parameters
            pop    ebx                 ; restore EBX
            ENDM

atow        MACRO  source              ; convert ASCII string to integer in AX
            lea    eax,source          ; source address to AX
            push   eax                 ; source parameter on stack
            call   atowproc            ; call atodproc(source)
            add    esp, 4              ; remove parameter
            ENDM

output      MACRO  outLbl, outStr      ; display label and string

            pushad                     ; save general registers
            cld                        ; clear DF
            lea    eax,outStr          ; string address
            push   eax                 ; string parameter on stack
            lea    eax,outLbl          ; label address
            push   eax                 ; string parameter on stack
            call   _showOutput         ; showOutput(outLbl, outStr)
            add    esp, 8              ; remove parameters
            popad                      ; restore general registers
            ENDM

input       MACRO  inPrompt, inStr, maxLength     ; prompt for and input  string
	        pushad                     ; save general registers
            mov    ebx, maxLength      ; length of input string
            push   ebx                 ; length parameter on stack
            lea    ebx,inStr           ; destination address
            push   ebx                 ; dest parameter on stack
            lea    ebx,inPrompt        ; prompt address
            push   ebx                 ; prompt parameter on stack
            call   _getInput           ; getInput(inPrompt, inStr, maxLength)
			add    esp, 12             ; remove parameters
            popad                      ; restore general registers
            ENDM

.NOLISTMACRO ; suppress macro expansion listings
.LIST        ; begin listing
