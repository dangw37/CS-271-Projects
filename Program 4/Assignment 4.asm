TITLE Assignment 4     (Assignment 4.asm)

; Author: William Dang
; Last Modified: 5/13/2019
; OSU email address: dangw@oregonstate.edu 
; Course number/section: CS271/400
; Project Number: 4                Due Date: 5/12/2019
; Description: The program promopts user to enter number of composite numbers to be dipslayed, an integer in range [1-400]. 
; If entered integer is out of range, program reprompts user to enters number within range. All composites numbers up to and including 
; the nth composite are calculated and displayed, with 10 composites per line and at least 3 spaces between numbers. 

INCLUDE Irvine32.inc

;Constants
UPPER = 400
LOWER = 1

.data
	programTitle		BYTE	"Composite Numbers", 0
	author				BYTE	"Programmed by William Dang", 0
	instructPrompt1		BYTE	"Enter number of composites you would like to display between 1 and 400.", 0
	instructPrompt2		BYTE	"Please enter a number now: ", 0
	errorMessage		BYTE	"The number you entered was out of range.", 0
	exitGreeting		BYTE	"Results certified by Will. Goodbye for now!", 0
	showNextPage		BYTE	"Press enter to show next page.", 0
	extraCredit1		BYTE	"**EC: Align the output columns.", 0
	extraCredit2		BYTE	"**EC: Display more composites, but show them one page at a time.", 0
	userNum				DWORD	?
	spaces				BYTE	"   ", 0
	lineCount			DWORD	0
	compositeNum		DWORD	?


.code
main PROC
	call	introduction
	call	getUserData
	call	showComposites
	call	farewell
	exit

main ENDP

; Display introduction prompts

introduction PROC
			
		mov		edx, OFFSET programTitle								; Display program title
		call	WriteString
		call	CrLf

		mov		edx, OFFSET	author										; Display author's name
		call	WriteString
		call	CrLf							

		mov		edx, OFFSET	extraCredit1								; Display extra credit 1 message 
		call	WriteString
		call	CrLf
		
		mov		edx, OFFSET	extraCredit2								; Display extra credit 2 message 
		call	WriteString
		call	CrLf							

		mov		edx, OFFSET instructPrompt1								; Display instruction
		call	WriteString
		call	CrLf
		call	CrLf

	ret

introduction ENDP

; Get user data

getUserData PROC

	numPrompt: 
		mov		edx, OFFSET instructPrompt2								; prompt user for number
		call	WriteString
		call	ReadInt													; save entered number
		mov		userNum, eax											
		call	inputValidation

	ret

getUserData ENDP

; validate that entered number is within range (between 1 and 400)

inputValidation	PROC

		cmp		eax, LOWER												; if input entered is less than 1, jump to errorLoop section
		jb		errorLoop
		cmp		eax, UPPER												; if input entered is more than 1, jump to errorLoop section
		ja		errorLoop			
		
		ret

		errorLoop:
				mov		edx, OFFSET errorMessage
				call	WriteString
				call	getUserData

inputValidation ENDP

; display composites

showComposites PROC

		mov		ecx, userNum											; store user data into loop counter register
		mov		eax, 4													; initialize as 4 for lowest composite number
		mov		compositeNum, eax
		mov		ebx, 2													; initialize ebx register as 2 for the lowest divider

	CompositeSearch:													; outer loop
		call	isComposite												
		mov		eax, compositeNum
		call	WriteDec												; print next composite number to user
		inc		compositeNum											; increment 	
		; count number of integers in a line
		inc		lineCount
		mov		eax, lineCount
		mov		ebx, 10
		cdq
		div		ebx
		cmp		edx, 0													
		je		NewRow													; if there are 10 integers in the line, add a new line
		jne		NewSpaces												; otherwise, add 3 spaces

	NewRow:
		call	CrLf
		mov		edx, OFFSET showNextPage								; EC: Prompt user to show next page by pressing enter
		call	WriteString
		call	ReadInt
		mov		lineCount, 0
		call	CrLf
		jmp		Continue

	NewSpaces:
		mov		edx, OFFSET spaces
		call	WriteString

	Continue:
		mov		ebx, 2													; initialize to lowest divider again before searching again
		mov		eax, compositeNum
		loop	CompositeSearch

		ret

showComposites ENDP

isComposite PROC														; searches for next composite for showComposite procedure

	CheckComposite:														; inner nested loop
		cmp		ebx, eax
		je		NotComposite											; if not composite, jump to NotComposite section
		
		cdq
		div		ebx														; divide and compare remainder to 0 to check if it is composite
		cmp		edx, 0
		je		ValidComposite											; if composite, jump to ValidComposite section
		jne		NotCompositewithdivisor									; if not composite with divisor, jump to NotCompositewithdivisor section

	ValidComposite:
		ret																; no more looping if number is composite

	NotCompositewithdivisor:											; since not composite with divisor, reinitialize eax and increment the divisor for next loop
		mov		eax, compositeNum
		inc		ebx
		jmp		CheckComposite

	NotComposite:														; since not composite, increment composite and reinitalize lowest divisor for next loop
		inc		compositeNum
		mov		eax, compositeNum
		mov		ebx, 2
		jmp		CheckComposite

isComposite ENDP

; print farewell message

farewell PROC

		mov		edx, OFFSET exitGreeting
		call	CrLf
		call	CrLf
		call	CrLf
		call	WriteString

		ret

farewell ENDP

END main
