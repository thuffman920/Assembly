;---------------------------------------------------------------------
;   Program:     MASM version of extend.asm (which is used to calculate PI)
;
;   Function:    This file contains subroutines that perform
;                extended precision arithmetic.
;                addx - extended precision addition
;                divx - extended precision division
;
;   Owner:       Tyler Huffman (tshuffma)
;
;   Last Update: Date            Reason
;                06/03/2012      Original version
;
;---------------------------------------------------------------------
         .model    small                 ;64k code and 64k data
         .8086                           ;only allow 8086 instructions
         .stack    256 
         public    addx                  ;allow linker to access addx
         public    divx                  ;allow linker to access divx
;-----------------------------------------
                   
                   
;-----------------------------------------
;   ADDX Subroutine
;-----------------------------------------
         .data       



         .code
;-----------------------------------------
addx:                                    ; 
         pushf                           ; 
         push       cx                   ; Push the size of the list onto the stack
         push       ax                   ; Push a holding register onto the stack
         push       si                   ; Push the source list onto the stack
         push       di                   ; Push the destination list onto the stack
         mov        cx, [si]             ; 
         mov        ax, cx               ; 
         add        ax, cx               ; 
         add        si, ax               ; 
         add        di, ax               ; 
         mov        ax, 0000h            ; 
;-----------------------------------------
; 
;-----------------------------------------
repeating:                               ; 
         add        ax, word ptr [si]    ; Get the element in the source list at the 2 position
         add        word ptr [di], ax    ; Add the source element to the destination list at the 2nd position
         jnc        carryOver            ; 
         mov        ax, 0001h            ; 
         jmp        increment            ; 
;-----------------------------------------
; 
;-----------------------------------------
carryOver:                               ; 
         mov        ax, 0000h            ; 
;-----------------------------------------
; 
;-----------------------------------------
increment:                               ; 
         sub        si, 2                ; Move the source list's pointer two positions
         sub        di, 2                ; Move the destination list's pointer two postions
         loop       repeating            ; 
         pop        di                   ; Restore the destination list from the stack
         pop        si                   ; Restore the source list from the stack
         pop        ax                   ; Restore the size of the list from the stack
         pop        cx                   ; 
         popf                            ; 
         ret                             ;return
;-----------------------------------------



;-----------------------------------------
;   DIVX Subroutine
;-----------------------------------------
         .data



         .code
;-----------------------------------------
divx:                                    ;
         push        ax                  ; Push the ax register onto the stack 
         push        bx                  ; Push the bx register onto the stack
         push        cx                  ; Push the cx register onto the stack
         push        dx                  ; Push the dx register onto the stack
         push        si                  ; Push the si register onto the stack
         mov         bx, dx              ; Set the bx register to the input divisor
         mov         dx, 0h              ; Initially set the upper word to zero
         mov         cx, [si]            ; Set cx to the size of the list si
;-----------------------------------------
; 
;-----------------------------------------
continue:                                ; 
         add         si, 2               ; Move the index of the pointer by 2
         mov         ax, word ptr [si]   ; Set the ax register to the word at the current index
         div         bx                  ; Divide the dx:ax combination by the divisor bx
         mov         word ptr [si], ax   ; Set the word at the current index equal to the quotient
         loop        continue            ; Loop back until cx is equal to zero
;-----------------------------------------
; 
;-----------------------------------------
         pop         si                  ; Restore the si register from the stack
         pop         dx                  ; Resotre the dx register from the stack
         pop         cx                  ; Restore the cx register from the stack
         pop         bx                  ; Restore the bx register from the stack
         pop         ax                  ; Restore the ax register from the stack 
         ret                             ; return
;-----------------------------------------

;-----------------------------------------
          .data
;-----------------------------------------
pisum     dw         255                 ; This contains the size of the list
          dw         255 dup(0)          ; 
first     dw         255                 ; This sets the size of the first list
          dw         16                  ; This sets the first word to 16 decimal number
          dw         254 dup(0)          ; This initializes the other words with zeroes
second    dw         255                 ; This sets the size of the second list
          dw         4                   ; This sets the first word to 4 decimal number
          dw         254 dup(0)          ; This initializes the other words with zeroes
;-----------------------------------------


;-----------------------------------------
           .code
;-----------------------------------------
extend:                                  ; 
           mov        ax, @data          ; Sets the addressibility to the data segment
           mov        ds, ax             ; Declares that is the data segment
           mov        cx, 1              ; 
           mov        ax, 1              ; 
           mov        di, offset pisum   ; 
;-----------------------------------------
; This will set up an initial x and will loop
; through incrementing the output by using the
; Machin's formula
;-----------------------------------------
looping:                                 ; 
           mov        si, offset first   ; 
           mov        bx, 5              ; 
           jmp        beforehand         ; 
;-----------------------------------------
; 
;-----------------------------------------
nextStep:                                ; 
           call       addx               ; 
           mov        si, offset second  ; 
           mov        bx, 00efh          ;
           inc        ax                 ;
;-----------------------------------------
; 
;-----------------------------------------
beforehand:                              ; 
           mov        dx, cx             ; 
           call       divx               ;
           mov        dx, bx             ; 
           mov        bx, 0              ; 	   
;-----------------------------------------
mulx:                                    ;
           call       divx               ; 
           inc        bx                 ; 
           cmp        bx, cx             ; 
           jl         mulx               ; 
           push       cx                 ; 
           push       ax                 ; 
           push       dx                 ; 
           push       bx                 ;
           push       si	         ; 
           mov        cx, 2              ; 
           mov        dx, 0              ; 
           div        cx                 ; 
           cmp        dx, 1              ; 
           je         goback             ;
           mov        cx, [si]           ; 
subtract:                                ; 
           add        si, 2              ;
           mov        ax, word ptr [si]  ; 
           not        ax                 ; 
           mov        word ptr [si], ax  ; 
           loop       subtract           ; 
goback:                                  ;
           pop        si
           pop        bx
           pop        dx
           pop        ax
           pop        cx
           push       bx
           push       dx
           push       ax
           push       di
           mov        bx, 2              ;
next2:
           mov        dl, byte ptr [di+bx] ;
           add        dl, '0'            ;
           inc        bx                 ;
           mov        ah, 02h            ;
           int        21h                ;
           cmp        bx, 12             ;
           jl         next2              ;
           pop        di	         ; 
           pop        ax
           pop        dx
           pop        bx
           cmp        dx, 5              ; 
           je         nextStep           ; 		   
;-----------------------------------------
; 
;-----------------------------------------
           call       addx               ;  
           add        cx, 2              ;
           mov        si, offset first   ;
           mov        di, offset second  ;
           mov        bx, 2              ;
           mov        byte ptr [si+bx], 16 ;
           mov        byte ptr [di+bx], 4  ;
           mov        byte ptr [si+bx+1], 0 ;
           mov        byte ptr [di+bx+1], 0 ;
reset:
           add        bx, 2              ;
           mov        word ptr [si+bx], 0 ;
           mov        word ptr [di+bx], 0 ;
           cmp        bx, 255            ;
           jl         reset              ;
           mov        di, offset pisum   ;
           cmp        cx, 5              ; 
           jl         looping            ; 
;-----------------------------------------
; There will be a subroutine call for dividing the 
; result by a certain string/number
;-----------------------------------------
           mov        cx, [si]           ; Sets the size back to 255 for printing
           add        di, 2              ; 
           push       di                 ;
           mov        bx, [si]           ;
;-----------------------------------------
; Display the final result of pi to 300 decimal places
;-----------------------------------------
printing:                                ; 
           add        di, bx             ;
next1:
           mov        al, byte ptr [di]  ; Sets the value at the current pointer position to the dl register
           or         al, f0h            ; 
           mul        10h                ;
           mov        dl, al             ;
           mov        al, byte ptr [di]  ; Sets the value at the current pointer position to the dl register
           or         al, 0fh            ;
           
           dec        di
           mov        ah, 02h            ; DOS Code for printing out a byte
           int        21h                ; The execution command
           inc        di                 ; 
           loop       printing           ; Loop back to print another byte
;-----------------------------------------
; Exits the program
;-----------------------------------------
exit:                                    ; 
           pop        di                 ; 
           mov        ax,4c00h           ; DOS Code for exiting the execution of my program
           int        21h                ; The execution command
           end        extend             ; 
;-----------------------------------------
