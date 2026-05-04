.MODEL SMALL
.STACK 64

.DATA   
    
    WINDOW_L DW 320
    WINDOW_W DW 200
    
    TOP_MARGIN DW 40
    LEFT_MARGIN DW 20
    BOTTOM_MARGIN DW 20
    RIGHT_MARGIN DW 60  
    
    RACKET_X DW ?
    RACKET_Y DW ?
    RACKET_L DW 35
    RACKET_W DW 6
    RACKET_COL DB 0FH
    RACKET_SPEED DW 6
    
    
    BALL_X DW 0
    BALL_Y DW 0
    BALL_SZ DW 4
    BALL_SX DW -4
    BALL_SY DW -3
    BALL_COL DB 0FH
    
    KEY DB 0       
    GAME_OVER DB 0
    

.CODE
MAIN PROC FAR 
    MOV AX, @DATA
    MOV DS, AX
                    
    CALL SET_GRAPHIC_MODE
    CALL DRAW_ENV    
                
  MAIN_LOOP:
    
    CMP GAME_OVER, 1
    JE EXIT
  
    CALL CHECK_KEY_PRESS
    CALL UPDATE_BALL 
    CALL DELAY           
               
    JMP MAIN_LOOP
  
  
  EXIT:              
    MOV AH, 4CH
    INT 21H
MAIN ENDP  

                
;---------------                
DRAW_ENV PROC
    CALL DRAW_BORDERS
    CALL DRAW_INITIAL_RACKET
    CALL INIT_BALL
    CALL DRAW_BALL
    RET

DRAW_ENV ENDP                
     
;---------------
CHECK_KEY_PRESS PROC
    
    MOV AH, 01H
    INT 16H
    JZ NO_KEY
    
    MOV AH, 00H
    INT 16H
    MOV KEY, AL
    
    CMP KEY, 'W'
    JE UP
    CMP KEY, 'w'
    JE UP
    
    CMP KEY, 'S'
    JE DOWN
    CMP KEY, 's'
    JE DOWN
    
    CMP KEY, 'Q'
    JE EXIT
    CMP KEY, 'q'
    JE EXIT
    
    JMP NO_KEY
    
  UP:
    CALL CLEAR_RACKET
    
    MOV AX, RACKET_Y
    SUB AX, RACKET_SPEED
    CMP AX, TOP_MARGIN
    JL HIT_TOP
    MOV RACKET_Y, AX
    JMP DRAW_NEW
    
  
  DOWN:         
    CALL CLEAR_RACKET
    
    MOV AX, RACKET_Y
    ADD AX, RACKET_SPEED
    MOV BX, WINDOW_W
    SUB BX, BOTTOM_MARGIN
    SUB BX, RACKET_L
    CMP AX, BX
    JG HIT_BOTTOM
    MOV RACKET_Y, AX
    JMP DRAW_NEW
    
  HIT_TOP:
  HIT_BOTTOM:
    JMP DRAW_NEW
    
  DRAW_NEW:
    CALL DRAW_RACKET
  
  NO_KEY:           
    RET
    
CHECK_KEY_PRESS ENDP  

;---------------
DELAY PROC       
        
    MOV AH, 86H
    MOV CX, 0H
    MOV DX, 0a028H  ; delay for 41 ms (for 24 fps)
    INT 15H
    
    RET
    
DELAY ENDP

;---------------
UPDATE_BALL PROC
    CALL CLEAR_BALL
    
    MOV AX, BALL_X
    ADD AX, BALL_SX
    MOV BALL_X, AX
    
    MOV AX, BALL_Y
    ADD AX, BALL_SY
    MOV BALL_Y, AX
    
    ; COLLISIONS : 
    ; if ball_y <= top_margin + 1
    
    MOV AX, TOP_MARGIN
    INC AX
    CMP BALL_Y, AX
    JG CHECK_BOTTOM
    
    MOV AX, TOP_MARGIN
    INC AX
    MOV BALL_Y, AX
    
    MOV AX, BALL_SY
    NEG AX
    MOV BALL_SY, AX
    
  CHECK_BOTTOM:
    ; if ball_y + ball_sz >= window_w - bottom_margin
    MOV AX, BALL_Y
    ADD AX, BALL_SZ
    
    MOV BX, WINDOW_W
    SUB BX, BOTTOM_MARGIN
    
    CMP AX, BX
    JL CHECK_LEFT
    
    MOV AX, WINDOW_W
    SUB AX, BOTTOM_MARGIN
    SUB AX, BALL_SZ
    MOV BALL_Y, AX
    
    MOV AX, BALL_SY
    NEG AX
    MOV BALL_SY, AX
    
  CHECK_LEFT:
    ; if ball_x <= left_margin + 1
    MOV AX, LEFT_MARGIN
    INC AX
    CMP BALL_X, AX
    JG CHECK_RACKET
    
    MOV AX, LEFT_MARGIN
    INC AX
    MOV BALL_X, AX
    
    MOV AX, BALL_SX
    NEG AX
    MOV BALL_SX, AX
    
  CHECK_RACKET:  
                         
    ; if ball_x + ball_sz >= window_l - right_margin - racket_w
    ; if ball_y + ball_sz > racket_y and ball_y < racket_y + racket_l  --> ok                     
                         
    MOV AX, BALL_X
    ADD AX, BALL_SZ
    MOV BX, WINDOW_L
    SUB BX, RIGHT_MARGIN
    SUB BX, RACKET_W
    CMP AX, BX
    JL UPDATE_DRAW  
    
    MOV AX, BALL_Y
    ADD AX, BALL_SZ     
    MOV BX, RACKET_Y
    CMP AX, BX
    JL OVER
    
    MOV AX, BALL_Y
    MOV BX, RACKET_Y
    ADD BX, RACKET_L
    CMP AX, BX
    JG OVER   
    
    MOV AX, WINDOW_L
    SUB AX, RIGHT_MARGIN
    SUB AX, RACKET_W
    SUB AX, BALL_SZ
    MOV BALL_X, AX
    
    MOV AX, BALL_SX
    NEG AX
    MOV BALL_SX, AX
    
    JMP UPDATE_DRAW
    
  OVER:
    MOV GAME_OVER, 1
   
  UPDATE_DRAW:
    CALL DRAW_BALL  
    
    RET
UPDATE_BALL ENDP
      
;---------------
CLEAR_BALL PROC
    MOV DX, BALL_Y

  CBALL_ROW:
    MOV CX, BALL_X

      CBALL_COL:
        MOV AH, 0Ch
        MOV AL, 00h
        MOV BH,0
        INT 10h

        INC CX
        MOV AX, BALL_X
        ADD AX, BALL_SZ
        CMP CX, AX
        JL CBALL_COL

        INC DX
        MOV AX, BALL_Y
        ADD AX, BALL_SZ
        CMP DX, AX
        JL CBALL_ROW

    RET
CLEAR_BALL ENDP

;---------------
DRAW_BALL PROC
    MOV DX, BALL_Y
    
  BALL_ROW:
    MOV CX, BALL_X
    
      DBALL_COL:
        MOV AH, 0CH
        MOV AL, BALL_COL
        MOV BH,0
        INT 10H
        
        INC CX
        MOV AX, BALL_X
        ADD AX, BALL_SZ
        CMP CX, AX
        JL DBALL_COL
        
        INC DX
        MOV AX, BALL_Y
        ADD AX, BALL_SZ
        CMP DX, AX
        JL BALL_ROW
        
     RET
DRAW_BALL ENDP        

;---------------
INIT_BALL PROC
    MOV AX, WINDOW_L
    SHR AX, 1
    MOV BX, BALL_SZ
    SHR BX, 1
    SUB AX, BX 
    MOV BX, RIGHT_MARGIN
    SUB BX, LEFT_MARGIN
    SHR BX, 1
    SUB AX, BX
    MOV BALL_X, AX
    
    MOV AX, WINDOW_W
    SHR AX, 1
    MOV BX, BALL_SZ
    SHR BX, 1
    SUB AX, BX
    MOV BX, TOP_MARGIN
    SUB BX, BOTTOM_MARGIN
    SHR BX, 1            
    ADD AX, BX
    MOV BALL_Y, AX
    
    RET
    
INIT_BALL ENDP

;---------------      
CLEAR_RACKET PROC   
    
    MOV DX, RACKET_Y
    
  CRL1:
    MOV CX, RACKET_X 
    
    CRL2:
      MOV AH, 0Ch
      MOV AL, 00h
      MOV BH,0
      INT 10h

      INC CX
      MOV AX, RACKET_X
      ADD AX, RACKET_W
      CMP CX, AX
      JNE CRL2

      INC DX
      MOV AX, RACKET_Y
      ADD AX, RACKET_L
      CMP DX, AX
      JNE CRL1

    ret 
    
CLEAR_RACKET ENDP 

;---------------
DRAW_RACKET PROC
   
    MOV DX, RACKET_Y 
    
    DRL1:
    MOV CX, RACKET_X
    
        DRL2:
        MOV AH, 0CH
        MOV AL, 0FH
        MOV BH,0
        INT 10H
        
        INC CX
        MOV AX, RACKET_X
        ADD AX, RACKET_W 
        CMP CX, AX
        JNE DRL2
        
        INC DX
        MOV AX, RACKET_Y
        ADD AX, RACKET_L
        CMP DX, AX
        JNE DRL1
    
    RET            
                
DRAW_RACKET ENDP
          
;---------------
DRAW_INITIAL_RACKET PROC
    MOV AX, WINDOW_L
    SUB AX, RIGHT_MARGIN
    MOV RACKET_X, AX
    
    MOV AX, WINDOW_W
    SUB AX, BOTTOM_MARGIN
    SUB AX, TOP_MARGIN
    MOV DX, 0
    MOV BX, 2
    DIV BX
    
    MOV BX, AX
    MOV AX, RACKET_L
    MOV CX, 2
    MOV DX, 0
    DIV CX
    
    MOV DX, TOP_MARGIN
    ADD DX, BX
    SUB DX, AX
    MOV RACKET_Y, DX
    
    DIRL1:
    MOV CX, RACKET_X
    
        DIRL2:
        MOV AH, 0CH
        MOV AL, 0FH
        MOV BH,0
        INT 10H
        
        INC CX
        MOV AX, RACKET_X
        ADD AX, RACKET_W 
        CMP CX, AX
        JNE DIRL2
        
        INC DX
        MOV AX, RACKET_Y
        ADD AX, RACKET_L
        CMP DX, AX
        JNE DIRL1
    
    RET            
                
DRAW_INITIAL_RACKET ENDP

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
    MOV BH,0
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
    MOV BH,0
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
    MOV AH, 0CH
    MOV AL, 0FH
    MOV BH,0
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
    MOV BH,0
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
