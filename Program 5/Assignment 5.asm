TITLE Assignment 5     (Assignment 5.asm)

; Author: William Dang
; Last Modified: 5/26/2019
; OSU email address: dangw@oregonstate.edu 
; Course number/section: CS271/400
; Project Number: 5                Due Date: 5/26/2019
; Description: The program promopts user to enter number between 10 and 200 and generates that number of random integers, in range 
; from from 100 to 999. The numbers are printed before sorting, then sorted in descending order. The program then calculates and
; displays the median. Finally, the sorted list is printed.

INCLUDE Irvine32.inc

;Constants
MAX = 200
MIN = 10
HI = 999
LO = 100

.data
	programTitle		BYTE	"Sorting Random Integers", 0
	author				BYTE	"Programmed by William Dang", 0
	instruct1			BYTE	"The user will be prompted to enter a number between 10 and 200. ", 0
	instruct2			BYTE	"The program will generate that number of random integers in range [100..999] ", 0
	instruct3			BYTE	"The unsorted and sorted list of integers will be displayed. The median will also be calculated and displayed. ", 0
	errorMessage		BYTE	"The number you entered was out of range.", 0
	instructPrompt		BYTE	"Please enter a number between 10 and 200: ", 0
	median				BYTE	"The median is ", 0
	sorted				BYTE	"Sorted List: ", 0
	unsorted			BYTE	"Unsorted List: ", 0
	spaces				BYTE	"     ", 0
	request				DWORD	?
	array				DWORD	MAX	DUP(?)
	

.code

main PROC
	call	Randomize													; seed random number
	call	introduction
	
	push	OFFSET request												; pass by reference (request)
	call	getData														; get user input
	
	push	OFFSET array												; array, so pass by reference
	push	request														; pass by value user input
	call	fillArray													; put numbers into array
	
	push	OFFSET array												; array, so pass by reference
	push	request														; pass by value user input
	push	OFFSET unsorted												; pass string by reference
	call	displayList													; print list of unsorted integers

	push	OFFSET array												; array, so pass by reference
	push	request														; pass by value user input
	call	sortList													; sort values before printing again

	push	OFFSET array												; array, so pass by reference
	push	request														; pass by value user input
	call	displayMedian												; calculate and print median value

	push	OFFSET array												; array, so pass by reference
	push	request														; pass by value user input
	push	OFFSET sorted												; pass string by reference
	call	displayList													; print list of sorted integers

	exit

main ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: introduction
; Description: Introduce program title, author, and instructions for user. 
; Receives: global variables programTitle, author, instruct1, instruct2, instruct3
; Returns: prints program title, author, and instructions of program.
; Registers Changed: edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

introduction PROC
			
		mov		edx, OFFSET programTitle								; Display program title
		call	WriteString
		call	CrLf

		mov		edx, OFFSET	author										; Display author's name
		call	WriteString
		call	CrLf							

		mov		edx, OFFSET instruct1									; Display user instructions
		call	WriteString
		call	CrLf
		mov		edx, OFFSET instruct2							
		call	WriteString
		call	CrLf
		mov		edx, OFFSET instruct3							
		call	WriteString
		call	CrLf

	ret

introduction ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: getData
; Description: Prompt user to input number of random integers between 10 and 200 inclusive, validate, and save
;              input
; Receives: request variable (passed by reference)
; Returns: store user input to request variable
; Preconditions: none
; Registers Changed: eax, ebx, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

getData PROC

		push	ebp														; set up stack frame
		mov		ebp, esp												
		mov		ebx, [ebp+8]											; ebx points to number of integers

	numPrompt: 
		mov		edx, OFFSET instructPrompt								
		call	WriteString												; prompt user to input number
		call	ReadInt													; save user input
		cmp		eax, MIN												; check if input is less than 10								
		jl		invalidNumber											; if less than 10, jump to invalidNumber section for error message
		cmp		eax, MAX												; check if input is more than 200
		jg		invalidNumber											; if more than 200, jump to invalidNumber section for error message
		mov		[ebx], eax												; otherwise, if valid number, store value in ebx
		jmp		validNumber												; jump to validNumber section to continue 

	invalidNumber:
		mov		edx, OFFSET errorMessage								; display error message to user
		call	WriteString
		jmp		numPrompt												; jump back to numPrompt section to get another number

	validNumber:
		pop		ebp														; restore stack 
		ret 4															; 4 bytes returned (pushed before call)

getData ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: fillArray
; Description: Fill array with randomly generated integers in range [100..999].
; Receives: array (passed by reference), request variable (passed by value) 
; Returns: none
; Preconditions: None
; Registers Changed: eax, ecx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

fillArray	PROC

		push	ebp														; set up stack frame
		mov		ebp, esp												
		mov		ecx, [ebp+8]											; user input stored in ecx for count
		mov		esi, [ebp+12]											; pointer to address of start of array stored in esi
	
	fillArrayLoop:														; **CITATION: Lecture #20, nextRand PROC
		mov		eax, HI													; store 999 into eax
		sub		eax, LO													; 999-100 = 899 in eax
		inc		eax														; 899+1 = 900 in eax
		call	RandomRange												; generate random integer in range [0..899]
		add		eax, LO													; 100 added to int so that it is actually [100..999]
		mov		[esi], eax												; store int in current element of array
		add		esi, 4													; because type is DWORD, add by 4 bytes to get next element
		loop	fillArrayLoop											; repeat loop for all array integers

		pop ebp															; restore stack
		ret 8															; return 8 bytes that were pushed before call

fillArray ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: displayList
; Description: Print list of integers in array.
; Receives: array (passed by reference), request variable (passed by value), title (passed by reference) 
; Returns: none. Displays title and values in array.
; Preconditions: none
; Registers Changed: eax, ebx, ecx, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

displayList PROC

		push	ebp														; **CITATION: demo5.asm following lecture #20
		mov		ebp, esp												; stack frame pointer set
		mov		edx, [ebp+8]											; title stored in edx
		mov		esi, [ebp+16]											; first array element value stored in esi 
		mov		ecx, [ebp+12]											; store number of array elements in ecx for loop count
		mov		ebx, 0													; initialize ebx to 0 for count per line
		call	CrLf
		call	WriteString												; print title
		call	CrLf

	displayInteger:	
		cmp		ebx, 10												
		je		newRow													; if 10 values are in the row, jump to newRow section to begin new row
		mov		eax, [esi]												; store current element of array in eax
		call	WriteDec												; print integer
		mov		edx, OFFSET spaces										
		call	WriteString												; print 5 spaces between integers
		add		esi, 4													; increment by 4 to locate next array element
		inc		ebx														; increment count of integers in row
		loop	displayInteger											; loop to display more integers
		jmp		continue												; jump to continue section when no more array elements to display

	NewRow:
		mov		ebx, 0
		call	CrLf
		loop	displayInteger											; loop back to displayInteger section to display more integers

	continue: 
		pop		ebp														
		ret		12														; return 12 bytes (3 DWORD parameters) that were pushed

displayList ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: sortList
; Description: Using bubble sort, sorts the list of random integers.
; Receives: array (passed by reference), request variable (passed by value) 
; Returns: Contents of array at passed address are sorted (ordered descending) 
; Preconditions: none
; Registers Changed: eax, ecx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

sortList PROC															

		push	ebp														;**CITATION: Irvine textbook 9.5.1, pg. 375, BubbleSort.asm
		mov		ebp, esp												
		mov		ecx, [ebp+8]											; store counter (array elements) in ecx
		dec		ecx														; decrement counter by 1

	L1: push	ecx														; store count for outer loop
		mov		esi, [ebp+12]											; address of array stored in esi

	L2: mov		eax,[esi]												; store array element value to eax
		cmp		[esi+4],eax												; compare next array element to current 
		jl		L3														; if [esi] is less than [esi+4], jump to L3 for no exchange
		xchg	eax, [esi+4]											
		mov		[esi], eax												; otherwise, exchange the two integers

	L3: add esi,4														; increment by 4 to move pointer to next array element
		loop L2															; repeat inner loop
		pop ecx															; retrieve outer loop count
		loop L1															; repeat outer loop
	
		pop		ebp
		ret		8														; return 8 bytes that were pushed

sortList ENDP

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Procedure: displayMedian
; Description: Calculates and displays median of sorted integers
; Receives: sorted array (passed by reference), request variable (passed by value) 
; Returns: none
; Registers Changed: eax, ebx, ecx, edx
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


displayMedian PROC

		push	ebp														; set up stack frame
		mov		ebp, esp												
		mov		eax, [ebp+8]											; store number of array elements in eax 
		mov		esi, [ebp+12]											; store value of first sorted array element in esi
		
		; check if odd or even number of array elements by division
		mov		edx, 0													; initialize edx to 0 for division
		mov		ebx, 2													; for divisor, store 2 to ebx 
		div		ebx														; eax holds quotient
		cmp		edx, 0
		je		printMedian												; if remainder equals zero, go to printMedian section 
		
		; if remainder not equal to zero, there is odd number of elements. Find middle number
		mov		ebx, 4													; multiply by 4 bytes for type DWORD for memory location
		mul		ebx
		add		esi, eax												; store address in esi
		mov		eax, [esi]												; store value of median in eax 
		call	CrLf
		mov		edx, OFFSET median
		call	WriteString												; display median string before value
		call	WriteDec												; print median value
		call	CrLf
		jmp		ending													; go to ending section 

	printMedian:
		
		mov		ebx, 4
		mul		ebx														; multiply by 4 for DWORD for memory location in array
		add		esi, eax												; store address in esi
		mov		edx, [esi]												; store value of right middle value in edx

		mov		eax, esi												; store right middle value address
		sub		eax, 4													; go down a memory location to locate the left middle value
		mov		esi, eax												; store new address in esi
		mov		eax, [esi]												; store value of left middle value in eax
		
		; average two middle values
		add		eax, edx												; add two middle values to average for median calculation
		mov		edx, 0													; restore edx and ebx for division 
		mov		ebx, 2
		div		ebx														; divide eax by 2
		cmp		edx, 1													; if remainder is at least 1, round up to next integer
		jge		roundup													; jump to roundup section if remainder is at least 1
		jmp		realprintmedian											; if remainder is zero, print the calculated average

	roundup:
		inc		eax														; increment integer by 1 

	realprintmedian:
		call	CrLf
		mov		edx, OFFSET median										
		call	WriteString												; print string for displaying median value
		call	WriteDec												; print median value
		call	CrLf
		
	ending:
		pop		ebp
		ret		8

displayMedian ENDP

END main
