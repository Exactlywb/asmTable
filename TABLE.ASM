.model tiny

.code

org 100h

marginTopBorder 	= 5
marginLeftBorder	= 20

widthBorder		= 40
heightBorder		= 10

videoSegment		= 0b800h

displayHeight		= 40
displayWidth		= 80

Start:

	;--------------------------
	;
	;Moving into video segment
	;^^^^^^^^^^^^^^^^^^^^^^^^^
	;--------------------------
	mov bx, videoSegment
	mov es, bx

	;---------------------------------
	;
	;Fill background with black color
	;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	;---------------------------------

    mov si, 0			  ;margin top
    mov cx, displayHeight         ;height
    mov bx, displayWidth	  ;width
    mov dx, 0			  ;marginLeft
    call FillBlock

    jmp HorDraw

	FillBlock   	proc
			
			JmpOnHeightLoop:
			
			mov di, si ;here we put our y coordinate
			add di, dx ;here we put our x coordinate			
			
			mov ah, 0h
			mov al, ' '
			
			push cx
			
			mov cx, bx
			cld
			rep stosw
			
			pop cx	
			add si, DisplayWidth * 2
			
			loop JmpOnHeightLoop

			ret
			endp
			    
			

	HorDraw:
			
		mov di, (marginTopBorder * displayWidth + marginLeftBorder) * 2
		mov bh, 201
		mov bl, 187
		call DrawHorLine
		
		mov di, ((marginTopBorder + heightBorder) * displayWidth + marginLeftBorder) * 2
		mov bh, 200
		mov bl, 188
		call DrawHorLine		

		jmp VerDraw		
			
		;------------------------------------------------------------
		;Enty: 	BH, BL = angles symbol (BH - left and BL - right)
		;	DI     = position to start draw
		;Exit: none
		;
		;Destr: cx, di
		;------------------------------------------------------------
		DrawHorLine proc 
			mov ah, 10			;our color
			mov al, BH			;here we put symbol we want to out
			cld
			stosw				;put our angle

			mov ah, 10
			mov al, 205			;our general horizontal border symbol

			mov cx, widthBorder - 2
			cld
			rep stosw
		
			mov ah, 10
			mov al, BL			;second angle
			cld
			stosw
			
			ret
			endp	
	
	VerDraw:
				
		mov di, ((marginTopBorder + 1) * displayWidth + marginLeftBorder) * 2
		call DrawVerLine
		
		mov di, ((marginTopBorder + 1) * displayWidth + (marginLeftBorder + widthBorder - 1)) * 2
		call DrawVerLine

		jmp LoaderDraw

		;--------------------------------------------------------
		;Entry: di = position, to start
		;
		;Exit: none
		;
		;Destr: di
		;--------------------------------------------------------
		DrawVerLine 	proc
		
				mov cx, heightBorder - 1

				HorLoop:
					mov ah, 10
					mov al, 186
					
					stosw
				
					add di, displayWidth * 2 - 2
					loop HorLoop
				ret
				endp

     	LoaderDraw:
			
		mov cx, 33
		mov di, ( (marginTopBorder + 3) * displayWidth + 23) * 2
		mov si, offset loaderMessage
		call PrintString
		
		mov di, ( (marginTopBorder + 5) * displayWidth + 23 ) * 2

		RunLine:
		
		push cx
	
		mov ah, 86h
		mov cx, 3
		mov dx, 1000
		int 15h
		
		pop cx		

		mov ah, 10
		mov al, 219
		cld	
		stosw

		loop RunLine

    	mov si, (marginTopBorder + 1) * displayWidth * 2			  ;margin top
    	mov cx, (heightBorder - 1)       	                       	          ;height
    	mov bx, widthBorder - 2		             	               	          ;width
    	mov dx, (marginLeftBorder + 1) * 2                       		  ;marginLeft
  	call FillBlock

	StringOutput:
		
		mov ah, 10
		
		mov di, (marginTopBorder + 2) * 160 + (marginLeftBorder + 4) * 2
		mov si, offset nameMessage
		call PrintString	

		mov di, (marginTopBorder + 3) * 160 + (marginLeftBorder + 4) * 2
		mov si, offset akaMessage
		call PrintString

		mov di, (marginTopBorder + 4) * 160 + (marginLeftBorder + 4) * 2
		mov si, offset gitHref
		call PrintString

		jmp EndProgram
		
		;------------------------------------------
		;Entry: di = position to start write
		;^^^^^	si = your message
		;
		;Exit: none
		;^^^^
		;Destr: di, ax
		;^^^^^
		;------------------------------------------
		
		PrintString  	proc 			

				lodsb	
				stosw
			
				cmp al, 0
				jne PrintString
			
				ret

				endp		
		
	EndProgram:
		mov ax, 4c00h
		int 21h

;------------------------------------------
;
;Initialize message block
;
;Here we initialize our messages
;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;------------------------------------------

nameMessage	db 	'Frolov Daniil', 0
akaMessage	db	'aka Exactly', 0
gitHref		db	'github.com/ExactlyWb', 0
loaderMessage   db      'Hacking your computer...', 0


end Start
