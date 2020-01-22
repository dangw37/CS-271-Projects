TITLE Assignment 6a     (Assignment 6a.asm)

; Author: William Dang
; Last Modified: 6/9/2019
; OSU email address: dangw@oregonstate.edu 
; Course number/section: CS271/400
; Project Number: 6a                Due Date: 6/9/2019
; Description: The program prompts user to enter ten unsigned integers. The integers are printed in an array with the sum and average calculated
; and displayed. Input must be validated by reading input as string, and converting string to numeric form. Integers must be converted to string
; the hard way as well when printed. When user enters non-digits or number is too large for 32-bit registers, error message should be displayed and 
; integer discarded in the calculation. Program must appropriately use lodsb and/or stosb operators. Registers must also be saved and restored by 
; called procedures and macros. 


INCLUDE Irvine32.inc

;Constants
MAX = 10																; 10 integers max in array
MAXBITS = 32															; 32 bit maximum
LO = 0
HI = 4294967295															; max of possible unsigned integers

; Macro Definitions
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACRO: getString
; Description: Get string from user
; Receives: prompt asking user for string and the memory address to store string to
; Returns: save string to memory location 
; Preconditions: none
; Registers changed: none
; REFERENCE: Code borrowed from Lecture #26
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getString	MACRO string, inString

	push	edx															; push registers
	push	ecx

	displayString string
	mov		edx, inString												; **REFERENCE: code from lecture #26 to read input, move location to edx
	mov		ecx, MAXBITS - 1											; set string length as loop counter
	call	ReadString													; get number in string form, save to memory Location

	mov		[inString], edx

	pop		ecx															; pop registers
	pop		edx

ENDM

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; MACRO: displayString
; Description: Display string stored in specific memory location
; Receives: memory address where string stored
; Returns: none
; Preconditions: none
; Registers changed: none
; REFERENCE: Code borrowed from Lecture #26
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

displayString	MACRO outString

	push	edx		
	
	mov		edx, outString												; print string stored at memory address
	call	WriteString

	pop		edx

ENDM


.data
	programTitle		BYTE	"Low-level I/O procedures", 0
	author				BYTE	"Programmed by William Dang", 0
	instruct1			BYTE	"The user will be prompted to enter 10 unsigned integers. ", 0
	instruct2			BYTE	"Each integer must be small enough to fit inside a 32 bit register. ", 0
	instruct3			BYTE	"After 10 valid integers have been inputted, display the array of integers, and calculate and print the average and sum. ", 0
	errorMessage		BYTE	"ERROR: The number entered was too big or not a valid unsigned number. Please try again: ", 0
	instructPrompt		BYTE	"Please enter an unsigned integer: ", 0
	youEntered			BYTE	"You entered the following numbers: ", 0
	theSum				BYTE	"The sum of the valid numbers is: ", 0
	theAverage			BYTE	"The average is: ", 0
	exitGreeting		BYTE	"Thank you for your input. Goodbye for now! ", 0
	inString			BYTE	MAXBITS DUP(?)
	outString			BYTE	MAXBITS DUP(?)
	intIn				DWORD	?
	intOut				DWORD	?
	
	array				DWORD	MAX DUP(?)								; array with maximum capacity of 10 
	sum					DWORD	?
	average				DWORD	?


	

	

.code

main PROC
	
	; push strings for instructions, author, and title for the introduction
	push	OFFSET instruct3 											; +24, push 5 prompts onto the stack for displaying intro
	push	OFFSET instruct2											; +20
	push	OFFSET instruct1											; +16
	push	OFFSET author												; +12
	push	OFFSET programTitle											; +8
	call	introduction												; call introduction procedure to display instructions
	
	; get user input and place in array
	push	OFFSET errorMessage											; +24, prompt for error message pushed onto stack
	push	OFFSET instructPrompt										; +20, prompt for instructions passed by reference
	push	OFFSET array												; +16, array passed by reference
	push	OFFSET intOut												; +12, after conversion, integer result
	push	OFFSET inString												; +8, string to be converted to int
	call	getInput													; call procedure to fill array

	push	OFFSET array												; +16, pass array by reference
	push	OFFSET sum													; +12, pass sum by reference
	push	OFFSET average												; +8, pass average by reference
	call	calculations												; call procedure to calculate average and sum

	; push strings for displaying calculations
	push	OFFSET average												; +32, average passed by value for displaying	
	push	OFFSET youEntered											; +28, push for prompt to display list of user inputs
	push	OFFSET sum													; +24, sum passed by value for displaying
	push	OFFSET theAverage											; +20, push prompt for average
	push	OFFSET theSum												; +16, push prompt for sum
	push	OFFSET outString											; +12, reverse used for printing
	push	OFFSET array												; +8, array passed (by reference) for displaying
	call	printCalculations											; call procedure to display calculations

	; exit greeting for program
	push	OFFSET exitGreeting											; +8, push exit greeting onto stack												
	call	goodBye														; call procedure to display exit greeting

	exit
	
	

main ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: introduction
; Description: Introduce program title, author, and instructions for user. 
; Receives: programTitle, author, instruct1, instruct2, instruct3 (pushed onto the stack) 
; Returns: none
; Preconditions: none
; Registers Changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

introduction PROC
			
		push	ebp
		mov		ebp, esp												; set up stack frame
		
		displayString	[ebp+8]											; display program title using macro
		call CrLf
		displayString	[ebp+12]										; display author
		call CrLf
		displayString	[ebp+16]										; display instruct1
		call CrLf
		displayString	[ebp+20]										; display instruct2
		call CrLf
		call CrLf
		displayString	[ebp+24]										; display instruct3
		call CrLf
		call CrLf

		pop		ebp														; restore stack
		ret		20														; return 20 bytes since 5 parameters passed

introduction ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: readVal
; Description: validates, Calls macro getString to get user input and converts string to int. 
; Receives: inString (by reference), numOut (by reference), instructPrompt (by reference), errorMessage (by refence)
; Returns: numeric value of inString
; Preconditions: none
; Registers Changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

readVal PROC

		push	ebp														; set up stack frame
		mov		ebp, esp												
		pushad															; push registers
		jmp		getInteger
	
	notValid:
		displayString	[ebp+20]										; display error message to user
		call	CrLf
		
	getInteger: 

		getString	[ebp+16], [ebp+8]									; call macro to read user input	and print prompt
		call	CrLf
		mov		edx, 0
		mov		ebx, 10													; multiply by 10s factor
		mov		ecx, eax												; store string length to ecx to set counter
		mov		esi, [ebp+8]											; store user entered string in esi
		cld																; clear direction flag

	load:
		lodsb															; loads digit from memory at ESI
		cmp		al, 48													
		jb		notValid												; if less than 48 (ascii for 0), then digit is not valid
		cmp		al, 57													; if greater than 57 (ascii for 9), then digit is not valid
		ja		notValid
		sub		al, 48													; otherwise, it is valid, so subtract 48 from ascii for integer
		movzx	edi, al													; store converted string to edi
		mov		eax, edx												; store this converted value to eax
		mul		ebx														; multiply by 10s factor for digit's place
		add		eax, edi												; add last digit
		mov		edx, eax												; store result in edx
		loop	load													; loop until reach end of string

	; validate if within range of unsigned 32 bit integers
		cmp		edx, HI												
		ja		notValid												; if above top limit of unsigned integer range, jump to notValid section
		cmp		edx, LO												
		jb		notValid												; if below bottom limit of unsigned integer range, jump to notValid section
	; otherwise, store input in address of eax
		mov		eax, [ebp+12]											; store intOut in eax
		mov		[eax], edx												; store integer value in memory of eax
		popad															; restore registers
		pop ebp															; restore stack

		ret 16															; return 16 bytes for 4 parameters

readVal ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: writeVal
; Description: Converts integer to string output and uses the displayString macro to print.
; Receives: integer converted to string, and memory location (string) for output
; Returns: string (converted from integer)
; Preconditions: None
; Registers Changed: none
; **REFERENCE: Code borrowed from demo6.asm
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

writeVal	PROC

		push	ebp														; set up stack frame
		mov		ebp, esp
		pushad															; save all registers

		; initialize to loop through integers for conversion
		mov		ecx, 0													; initalize loop count
		mov		esi, [ebp+8]											; store stringOut value in esi
		mov		eax, [esi]												; store that value into eax 
		cdq
		mov		ebx, 10													; initialize ebx to 10 to set up for division
		
	getLength:
		mov		edx, 0													; clear remainder for division
		div		ebx
		cdq
		inc		ecx														; increment loop count
		cmp		eax, 0													; check for end of string
		jg		getLength												; loop until end of the string
		mov		eax, [esi]												; store value in eax
		cdq
		mov		edi, [ebp+12]											; store location of outString to edi
		dec		ecx														; decrement loop count 
		add		edi, ecx												; add address of last digit to edi

	charConversion:														
		mov		edx, 0													; clear remainder for division
		div		ebx														; divide to get digit
		mov		ecx, eax												; move result to ecx
		mov		eax, edx												; store remainder in eax
		add		al, 48													; add 48 for ascii representation
		std																; set direction flag to switch direction
		stosb															; eax stored into address of edi
		mov		eax, ecx												; move result back to eax
		cdq
		cmp		eax, 0													; if there are zero remaining numbers to convert, jump to doneConversion section
		ja		charConversion											; otherwise, loop again for converting remaining digits
		displayString	[ebp+12]										; print string
		mov		eax, 0
		mov		[edi], eax												; clear value of outString
		
		popad															; restore all registers	
		pop		ebp
		ret		8														; return 8 bytes since 2 parameters passed

writeVal ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: getInput
; Description: Gets user input, converts integer value to string of digits using macro. 
; Receives: array, instructPromopt, errorMessage, inString, intOut (all passed by reference)
; Returns: none
; Preconditions: none
; Registers Changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getInput PROC

		push	ebp														; set up stack frame
		mov		ebp, esp
		mov		ecx, MAX												; set max limit as ten integers for the array
		mov		edi, [ebp+16]											; store array in edi

	getInputloop:
		push	[ebp+24]												; push errorMessage 
		push	[ebp+20]												; push instructPrompt 
		push	[ebp+12]												; push intOut
		push	[ebp+8]													; push inString
		call	readVal													; get and read user input
		; after getting input, put into array
		mov		ebx, [ebp+12]											; store intOut address to ebx
		mov		eax, [ebx]												; store this value in eax
		mov		[edi], eax												
		add		edi, 4													; increment to next DWORD for next array element
		loop	getInputloop

		pop		ebp
		ret		20														; Return 20 bytes for 5 parameters passed

getInput ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: calculations
; Description: calculates average of ten integers
; Receives: sum (passed by value), memory address of average 
; Returns: average (stored in memory address) 
; Preconditions: none
; Registers Changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

calculations PROC

		push	ebp														; set up stack frame
		mov		ebp, esp
		
		; initialize registers for sum 
		mov		eax, 0
		mov		ecx, MAX												; loop count set
		mov		edi, [ebp+16]											; address of array stored into edi
		

	sumloop:
		mov		ebx, [edi]												; store array element value to edx
		add		eax, ebx												; add to current sum in eax
		add		edi, 4													; access next array element
		loop	sumloop													; continue loop to add all integers
		mov		ebx, [ebp+12]											; store address of sum to ebx
		mov		[ebx], eax												; store sum value to address of ebx

		mov		ebx, MAX												; set ebx to 10 to divide sum for average	
		mov		edx, 0													; clear remainder for division
		div		ebx														; eax contains calculated average
		mov		ebx, [ebp+8]											; store address of average into ebx
		mov		[ebx], eax												; store value of average into that memory location

		pop		ebp
		ret		12														; return 12 bytes (3 parameters passed)

calculations ENDP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: printCalculations
; Description: display calculated average and sum of array elements with string prompts. 
; Receives: array, sum (by value), average (by value), string prompts, outString, inString (all passed by reference unless indicated)
; Returns: none
; Preconditions: none
; Registers Changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

printCalculations PROC

		push	ebp														; set up stack frame
		mov		ebp, esp

		displayString	[ebp+28]										; print youEntered string
		mov		ecx, MAX												; set loop count to max size of array
		mov		edi, [ebp+8]											; move array address to edi
		jmp		printArray
		call	CrLf
		
	printArray:
		push	[ebp+12]												; push OFFSET of outString
		push	edi														; push OFFSET of array
		call	writeVal
		cmp		ecx, 1													; check for punctuation needed
		je		noComma													; if last digit, jump to noComma section
		mov		al, 44													; otherwise, add comma (44 is comma in ASCII)
		call	WriteChar
		mov		al, 32													; and add space (32 is a space in ASCII)			
		call	WriteChar
		add		edi, 4													; increment by 4 to access next array element
		
	noComma:
		loop	printArray												; go back to loop without printing comma
		call	CrLf

	; print prompt and calculated sum
		displayString	[ebp+16]										; print theSum prompt
		mov		ebx, [ebp+24]											; store address of calculated average in ebx
		mov		eax, [ebx]												; store value of average in eax to display
		call	WriteDec
		call	CrLf
	
	; print prompt and calculated average
		displayString	[ebp+20]										; print theAverage prompt
		mov		ebx, [ebp+32]											; store address of calculated average in ebx
		mov		eax, [ebx]												; store value of average in eax to display
		call	WriteDec												; print average
		call	CrLf

		pop		ebp														; restore
		ret		32														; Return 32 bytes (8 parameters passed) 
	
printCalculations ENDP


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: goodBye
; Description: Exit greeting for the user before program exit. 
; Receives: exitGreeting string 
; Returns: none
; Preconditions: none
; Registers Changed: none
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

goodBye PROC

		push	ebp
		mov		ebp, esp												; set up stack frame
		displayString	[ebp+8]											; call macro to display exit greeting string
		pop		ebp														; restore ebp
		ret		4														; return 4 bytes because of 1 parameter passed

goodBye ENDP

END main
