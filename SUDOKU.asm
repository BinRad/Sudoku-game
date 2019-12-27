code segment 
assume CS:code 
	org 100h				;leaves room for stuff
start:
jmp realstart
	
	welcome db 40 dup(?),"    The City College of New York", 48 dup(?)						;28
			db " Project1: Assembly || Professor Vulis", 42 dup(?)			 	;37
			db "      Student: Binyamin Radensky", 130 dup(?)							;26
			db "      ___          __        ", 11 dup(?)             				;24
			db "      |__ | |  _| |  | |/ | |", 11 dup(?)
			db "      __| |_| (_| |__| |\ |_|", 131 dup(?)
			db "     use the arrow keys to move", 9 dup(?)
			db "    [up], [down], [left], [right]", 7 dup(?)
			db "Rules: A = 10 , B = 11, C = 12, {0-9}", 83 dup(?)
			db "          to exit use [esc]" , 54 dup(?)			;36  
			db "     PRESS ANY KEY TO [CONTINUE]", 200 dup(?)
    tline db  201, 11 dup(205,203), 205, 187, " BRadensky"
	mline1 db 186, 2 dup(?, 179, ?, 179,?, 179,?, 186), ?, 179, ?, 179,?, 179,?, 186
	mline2 db 204, 2 dup(196, 197,196, 197,196, 197,196, 206),196, 197,196, 197,196, 197,196, 185
	sepline db 204,11 dup(205, 206), 205, 185
	eline db  200, 11 dup(205,202),205, 188, " [ESC] TO LEAVE", 50 dup(?)
	board1 db ""
	soln1 db "112223344111233334111222344155223344555666664555566664888777779887777999888899999"
	board2 db "00005301B96006A0C0080300B0506020001A02B5000A060900072056000C09C0000B21500B4000600890000A0700050B07298CB300A0006200009A81100BA28000340080900C02B7"
drawmid:
		mov cx, 25
		mov si, offset mline1
		add di, 30
	h1: 						;BOX BORDERS on top and bottom
		mov al, [si]
		mov es:[di], ax			;should be beginning of the loop
		add si, 1
		add di, 2				;incrememnts di
		LOOP h1	
		mov cx, 25
		cmp dl, dh
		jne normalline
		add dh, 3				;next thick line
		mov si, offset sepline
		jmp skipnormal
normalline:		
		mov si, offset mline2
skipnormal:
		add di, 30
	h2: 						;BOX borers next to #s (just the | lines)
		mov al, [si]
		mov es:[di], ax			
		add si, 1
		add di, 2				;incrememnts di
		LOOP h2	
		ret
		
;allows user to put number into board (called at 197)
inputnumber:
	push ax
	push si
	push dx
	mov bx, es:[di]
	idiv bl
	;mov si, offset 
	cmp bl, 32
	jne illegalplacement
	mov bl, al
	mov bh, 8eh
	mov es:[di], bx
	illegalplacement:
	jmp getkey
		
;clear screen
clearscreen:
	mov di, 0				;to center the text
	mov cx, 2000			;for loop
	mov ah, 0fh				;clears af for clean background
	mov al, ?
clear:
	mov es:[di], ax			;puts ax into video memory to be displ on screen
	add di, 2
	loop clear
	ret
	
; REAL START ========================================================================
realstart:
	int 10h					;video interrupt
	mov ax,0B800h			;moves vid into the accu   
	mov es, ax  			;moves video mem to es so we can icnrement through it 
	mov ah, 3fh;71h			;sets color of output
	
;draw welcome screen
	mov si, offset welcome
	mov di, 0				;to start at beginning
	mov cx, 2000				;for loop
writewelc:
	mov al, [si]			;put incrememnted array in to al
	mov es:[di], ax			;puts ax into video memory to be displ on screen
	add si, 1
	add di, 2
	loop writewelc
	mov ax, 01h
	int 16h
	sub ax, ax
	call clearscreen

;draw grid ==========================================================================
; draw the top of the grid
	mov ah, 4fh				;sets color of output	
	mov si, offset tline	;points si to tline in mem
	mov cx, 35				;this sets the amount of times the loop goes for 
	mov di, 0				;clears di for use
toprow: 
	mov al, [si]			;put incrememnted array in to al
	mov es:[di], ax			;puts ax into video memory to be displ on screen
	add si, 1				;increments si to the next element in the array
	add di, 2				;incrememnts di
	LOOP toprow				;where to loop 
	sub di, 20
;draw the middle of the grid
	mov dh, 2				;will be used to determin where thick lines should go
	mov dl, 0
	mov cx, 11				;length of loop
middle:
	push cx					;save cx so loop can work properly
	call drawmid			;draws the middle 12 sqare of the grid
	pop cx					;bring back cx
	add dl, 1
	loop middle
;draw the bottom of the grid 
	mov cx, 25
	mov si, offset mline1
	add di, 30
lasttop: 					;this draws the middle of the boxes
	mov al, [si]
	mov es:[di], ax			;should be beginning of the loop
	add si, 1
	add di, 2				;incrememnts di
	LOOP lasttop
	
	mov cx, 50
	mov si, offset eline
	add di, 30
lastbottom: 				;draws the actual bttom of the boxes	
	mov al, [si]
	mov es:[di], ax			;should be beginning of the loop
	add si, 1
	add di, 2				;incrememnts di
	loop lastbottom
		
;load in board ==============================================================================
	mov cx, 144 			;it will loop for 144 spots in the board
	mov di, 82				;put where t writes back to the beginning (which si the 2nd line)
	mov si, offset board2	;where our string of unsolved board is
	mov bx, 126				;the end of the line so that we know when t start putting #s on new line
load:
	mov al, [si]			;increment through the board array and put each value into al
	cmp al, "0"				;if that value is 0 leave blank
	jne actualnum
	mov al, 32				;if 0 put in the " "space char
actualnum:
	mov es:[di], ax			;should be beginning of the loop
	cmp di, bx
	jnz skip
	add bx, 160				;so that can find new end of line
	add di, 112				; beginning of next line 160- 48 
skip:
	add si, 1
	add di, 4				;incrementby 4 so that dont draw on box borders
	loop load
	
; GET KEY STARTS HERE ====================================================================
	mov di, 82				;moves cursor to first position in the board
	sub bx, bx				;BX will hold the LOCATION of our cursor
	mov dx, 128				;end of line location for cursor to know when to wrap cursor
getkey:							
	;write cursor to new location
	mov bx, es:[di]			;gets current value in that spots (where cursor is)
	mov bh, 8eh				;add cursor styling
	mov al, [si]			;put incrememnted array in to al
	mov es:[di], bx			;puts bx into video memory to be displ on screen
	
	;actual get key. ip waits here
	mov ax, 01h				;so int 16h can get key
	int 16h					;get key press

	;restores color, had to go here so color doesnt get restored instantly
	mov bx, es:[di]			;gets current value in that spots (where cursor was)
	mov bh, 4fh				;put styling back for that spot
	mov es:[di], bx			;puts spot back to normal color
	
	;find out which key was pressed
	cmp ah, 75				; compare with 37 left
	je left					; 37 left arrow
	cmp ah, 72				; 38 is up
	je up					; 38 up arrow
	cmp ah, 77				; find if right arrow
	je right				; 39 right arrow
	cmp ah, 80				; find if down arrow
	je down					; 40 is down arrow
	cmp al, 27				; find if esc
	je exit					; is esc, then exit
	
;if none of the directional keys were pressed then they are trying to input a number
	jmp inputnumber			; this will allow you to edit filds with a # in them'
	
left:
	sub di, 4				;go left
		;endline stuff had to go here to not mess with restore color
	push dx
	sub dx, 48
	cmp di, dx				;compare where the pointer is with the array of bounds
	pop dx
	jge getkey				; go to the next entry in the array if its safe
	sub di, 112				;if it was safe then go to the next line
	sub dx, 160
	jmp getkey
up:
	sub di, 160				;go right
	sub dx, 160				;so it knows where the bounds are
	jmp getkey
right:
	add di, 4				;go right
	;endline stuff had to go here to not mess with restore color
	cmp di, dx				;compare where the pointer is with the array of bounds
	jl getkey				; go to the next entry in the array if its safe
	add di, 112				;if it was safe then go to the next line
	add dx, 160
	jmp getkey
down:
	add di, 160				;go right
	add dx, 160				;so it knows where the bounds are
	jmp getkey
exit:
;close program	
	call clearscreen
	;mov ax, 00h 			;makes sure to just get keypress
	;int 16h					;stops scrolling
	int 20h					;clsoes program
code ends
end start
