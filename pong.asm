.MODEL SMALL
.STACK 64

.DATA   
    
    WINDOW_L DW 320
    WINDOW_W DW 200
    
    TOP_MARGIN DW 40
    LEFT_MARGIN DW 20
    BOTTOM_MARGIN DW 20
    RIGHT_MARGIN DW 60

.CODE
MAIN PROC FAR 
    MOV AX, @DATA
    MOV DS, AX
                    
    CALL SET_GRAPHIC_MODE  
    CALL DRAW_BORDERS
                
                
    MOV AH, 4CH
    INT 21H
MAIN ENDP  

;---------------
DRAW_BORDERS PROC
    
    CALL DRAW_TOP_BORDER
    CALL DRAW_LEFT_BORDER
    CALL DRAW_BOTTOM_BORDER
    RET
    
DRAW_BORDERS ENDP

;---------------       
DRAW_TOP_BORDER PROC   
            
    MOV DX, TOP_MARGIN
    MOV CX, LEFT_MARGIN
TOP_LOOP:
    MOV AH, 0CH ; set pixel
    MOV AL, 0FH ; white
    INT 10H
    
    INC CX
    MOV AX, WINDOW_L
    SUB AX, RIGHT_MARGIN
    CMP CX, AX
    JNE TOP_LOOP    
    
    RET
DRAW_TOP_BORDER ENDP

;---------------
DRAW_LEFT_BORDER PROC 
    MOV CX, LEFT_MARGIN
    MOV DX, TOP_MARGIN
LEFT_LOOP:
    MOV AH, 0CH
    MOV AL, 0FH
    INT 10H
    
    INC DX
    MOV AX, WINDOW_W
    SUB AX, BOTTOM_MARGIN
    CMP DX, AX
    JNE LEFT_LOOP
    
    RET
DRAW_LEFT_BORDER ENDP

;---------------
DRAW_BOTTOM_BORDER PROC
    MOV DX, WINDOW_W
    SUB DX, BOTTOM_MARGIN
    MOV CX, LEFT_MARGIN
BOTTOM_LOOP:
    MOV AH, 0CH ; set pixel
    MOV AL, 0FH ; white
    INT 10H
    
    INC CX
    MOV AX, WINDOW_L
    SUB AX, RIGHT_MARGIN
    CMP CX, AX
    JNE BOTTOM_LOOP    
    
    RET
DRAW_BOTTOM_BORDER ENDP

;---------------
SET_GRAPHIC_MODE PROC  
    
    MOV AH, 00H     
    MOV AL, 13H  ; 320x200 256
    INT 10H
    
    RET
    
SET_GRAPHIC_MODE ENDP
;---------------

CLEAR_SCREEN PROC    
    
    MOV AH, 06H
    MOV AL, 00H
    MOV BH, 00H
    MOV CX, 0000
    MOV DX, 184FH
    INT 10H
    RET                          
                       
CLEAR_SCREEN ENDP
;---------------

END MAIN
