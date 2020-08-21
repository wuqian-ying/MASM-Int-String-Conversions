TITLE Program 6: Designing Low-Level I/O Procedures    (Proj6.asm)

; Author: Alexa Langen
; Last Modified: 6/5/20
; OSU email address: langena@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 6                Due Date: 6/7/20
; Description: This program uses low-level I/O procedures to get numerical input
; from a user, including procedures that convert to/from string/integers. The
; program gets 10 integers from the user and performs basic arithmetic
; calculations on these inputs before displaying the numbers and the results
; back to the user.

INCLUDE Irvine32.inc

BUFFER_SIZE = 32
TRUE = 0
FALSE = -1

;-------------------------------------------------------------------------------
mGetString MACRO promptOffset:REQ, bufferOffset:REQ, byteCountOffset:REQ
;
; Prompts user for a number. Stores the user's input as a string. Also stores
; the length of user's input in bytes.
;
; Receives: promptOffset (addr) "Please enter a signed number: ", bufferOffset
; (addr) variable to contain user's string input, byteCountOffset (addr)
; variable to hold length of user's input in bytes.
; Returns: user's string in global variable and its length in global variable.
; Preconditions: None
; Registers changed: None
;-------------------------------------------------------------------------------
	push	edx
	push	ecx
	push	eax
	mov		edx, promptOffset
	call	WriteString				; "Please enter a signed number: "
	mov		edx, bufferOffset		; point to the buffer
	mov		ecx, BUFFER_SIZE		; set the counter for ReadString
	call	ReadString				; get the string
	mov		[byteCountOffset], eax	; save number of characters in user's string
	pop		eax
	pop		ecx
	pop		edx
ENDM

;-------------------------------------------------------------------------------
mDisplayString MACRO stringOffset:REQ
;
; Prints a string to the console.
;
; Receives: strinOffset (addr) address of string to be displayed
; Returns: None
; Preconditions: None
; Registers changed: None
;-------------------------------------------------------------------------------
    push	edx
    mov		edx, stringOffset
    call	WriteString
    pop		edx
ENDM

.data

introMessage		BYTE	"Designing and Implementing Low-Level I/O "
					BYTE	"procedures, by Alexa Langen.",10,13,0
description			BYTE	"Please provide 10 signed decimal integers. "
					BYTE	"Each number needs to be small enough "
					BYTE	"to fit in a 32-bit register.",10,13,"After you"
					BYTE	" have finished inputting the raw numbers I "
					BYTE	"will display the integers, "
					BYTE	"their sum, and their average value.",10,13,0
ECMsg				BYTE	"**EC: Number each line of user input and display a"
					BYTE	" running subtotal of the user's numbers.",10,13,0
inputPrompt			BYTE	"Please enter a signed number: ",0
invalidStrMsg		BYTE	"ERROR: You did not enter a valid signed number.",\
							10,13,0
invalidSizeMsg		BYTE	"Error: Your number does not fit in a 32 bit "
					BYTE	"register.",10,13,0
runTotalMsg			BYTE	"Running total: ",0
numberEchoMsg		BYTE	"You entered the following numbers: ",0
sumMessage			BYTE	"The sum of these numbers is: ",0
avgMessage			BYTE	"The average of these numbers is: ",0
goodbyeMsg			BYTE	"Have a splendid day!",10,13,0
inputBuffer			BYTE	BUFFER_SIZE DUP(0)
bufferBytes			DWORD	?
number				DWORD	?
numberStr			BYTE	BUFFER_SIZE DUP(0)
numericValues		DWORD	10 DUP(0)


.code
main PROC

; Introduce the program
	mDisplayString OFFSET introMessage
	mDisplayString OFFSET ECMsg
	call	CrLf
	mDisplayString OFFSET description

; Set up parameters and call testProgram to get 10 ints from user and display
; their sum and average.
	push	OFFSET avgMessage
	push	OFFSET sumMessage		; "The sum of these numbers is..."
	push	OFFSET numberEchoMsg	; "You entered the following numbers: "
	push	OFFSET numericValues
	push	OFFSET number
	push	OFFSET runTotalMsg
	call	testProgram

; Say goodbye
	mDisplayString OFFSET goodbyeMsg

	exit	; exit to operating system
main ENDP



;-------------------------------------------------------------------------------
testProgram	PROC USES eax ebx ecx esi edi,
		totalMsg:PTR BYTE,		; "Running total:"
		userNum:PTR DWORD,		; holds user's input
		numArray:PTR BYTE,		; points to array to store user's numbers
		echoMsg:PTR BYTE,		; "You entered the following numbers: "
		sumMsg:PTR BYTE,		; "The sum of these numbers is:"
		avgMsg:PTR BYTE			; "The rounded average is: "
		LOCAL validCount:DWORD,
		sum:DWORD,
		average:DWORD

; Gets 10 integers from the user using readVal, stores the numbers in an array,
; and displays the numbers along with their sum and average, using writeVal.
;
; Returns: None
; Preconditions: None
; Registers changed: None
;-------------------------------------------------------------------------------
	mov		ecx, 10			; initialize loop counter
	mov		edi, numArray	; point to array to store the numbers
	mov		validCount, 0	; used to store count of user's valid inputs
	mov		sum, 0			; sum of user's integers

GetInput:
;Set up parameters and call readVal to get user's input
	inc		validCount				; only incremented for valid inputs
	lea		esi, validCount			; get address of count
	push	userNum					; push addr of variable to hold user's int
	push	esi						; push count
	push	OFFSET invalidSizeMsg	; "Error: Your number does not fit in a 32..."
	push	OFFSET invalidStrMsg	; "ERROR: You did not enter a valid signed..."
	push	OFFSET inputPrompt		; "Please enter a signed number: "
	push	OFFSET inputBuffer
	push	OFFSET bufferBytes
	call	readVal					; value in userVal
; Add number to running total and store it in array
	mov		esi, userNum			; esi points at userNum
	mov		eax, [esi]				; eax = userNum
	add		sum, eax				; add number to running total
	mov		[edi], eax				; store number in Array?
	add		edi, TYPE userNum		; point to next element of array
; Display the running total for the user
	mDisplayString totalMsg			; "Running total:"
	lea		esi, sum				; get address of sum
	push	esi
	call	writeVal				; display sum
	xor		eax, eax				; clear eax
	call	CrLf
	loop	GetInput

; Calculate average (sum/10), rounded down to nearest integer
	mov		ebx, 10
	mov		eax, sum
	cdq
	div		ebx						; round down: ignore remainder
	mov		average, eax			; save average

; Display numbers, looping through array
	mDisplayString echoMsg			; "You entered the following numbers..."
	mov		ecx, 10					; set loop counter
	mov		esi, numArray			; point to array
	mov		eax, ' '
DisplayArrayVal:
	push	esi						; push address of element to print
	call	writeVal				; print value
	call	WriteChar				; print ' '
	add		esi, TYPE DWORD			; point to next element
	loop	DisplayArrayVal
	call	CrLf

; Display sum
	mDisplayString sumMsg
	lea		esi, sum
	push	esi			; push address of sum
	call	writeVal	; display sum
	call	CrLf
; Display average
	mDisplayString avgMsg
	lea		esi, average
	push	esi			; push address of average
	call	writeVal	; display average
	call	CrLf

	ret
testProgram ENDP


;-------------------------------------------------------------------------------
readVal	PROC USES eax ecx edx esi edi,
		byteCount:DWORD,		; number of bytes user enters
		userString:PTR BYTE,	; pointer to input buffer
		prompt:PTR BYTE,		; "Please enter a signed number: "
		errorMessage1:PTR BYTE,	; "Error: You did not enter a valid signed..."
		errorMessage2:PTR BYTE,	; "Error: Your number does not fit in a 32..."
		count:DWORD,
		userVal:DWORD			; to store user's number
; Gets a string of digits from a user and converts string to numeric form.
; Calls isNumericString to ensure string is a signed numeric value.
;
; Returns: user's numeric input, stored in global variable called number
; Preconditions: None
; Registers changed: None
;-------------------------------------------------------------------------------

; Get input from user, with line numbered.
GetInput:
	call	CrLf
	mov		esi, count
	mov		eax, [esi]						; Display # of input line
	call	WriteDec
	mov		eax, '.'
	call	WriteChar
	mGetString prompt, userString, byteCount	; input in userString

;Validate input: Ensure that string is a valid numeric string.
	push	byteCount
	push	userString
	call	isNumericString
	cmp		eax, TRUE
	je		ProcessInput
	mDisplayString errorMessage1	; "ERROR: You did not enter a signed..."
	jmp		GetInput			; reprompt for input

;Check first character to see if it is a sign
ProcessInput:
	xor		eax, eax			; clear eax
	xor		edx, edx			; clear edx
	cld
	mov		esi, userString		; source index: user's string
	mov		ecx, byteCount		; loop counter
	lodsb						; check first char for + or -
	cmp		al, '+'
	je		PositiveSign
	cmp		al, '-'
	je		NegativeSign
	jmp		Convert				; first char is a digit

; If the first character was a sign, adjust loop count to loop through remainder
	PositiveSign:
	sub		ecx, 1				; one char has already been processed ('+')
	jmp		ConversionLoopPositive
	NegativeSign:
	sub		ecx, 1				; one char has already been processed ('-')
	jmp		ConversionLoopNegative

; (For positive numbers) Loop through remainder of string, converting digits to
; numeric value and accumulating as a positive value in EDX
ConversionLoopPositive:
	imul	edx, 10				; shift current value into next tens place
	jo		InvalidSize		; if overflow, value doesn't fit in 32 bit reg
	lodsb								; get character byte into AL
Convert:
	mov		ebx, 48
	sub		al, 48				; get decimal value of ASCII digit char
	add		edx, eax			; add digit value to accumulator
	jo		InvalidSize
	cmp		ecx, 0				; if string contained only 1 digit, exit
	je		Save
	loop	ConversionLoopPositive
	jmp		Save

; (For negative numbers) Loop through remainder of string, converting digits to
; numeric value and accumulating as a negative value in EDX
ConversionLoopNegative:
	imul	edx, 10				; shift current value into next tens place
	jo		InvalidSize		; if overflow, value doesn't fit in 32 bit reg
	lodsb								; get character byte into AL
	mov		ebx, 48
	sub		al, 48				; get decimal value of ASCII digit char
	sub		edx, eax			; subtract digit value from accumulator
	jo		InvalidSize
	cmp		ecx, 0				; if string contained only 1 digit, exit
	je		Save
	loop	ConversionLoopNegative

; Store the number in the address of passed parameter
Save:
	mov		edi, userVal
	mov		[edi], edx		; save number
	jmp		Done

; If size was invalid, display error message and reprompt for input
InvalidSize:
	mDisplayString errorMessage2
	jmp		GetInput

Done:
	ret
readVal	ENDP


;-------------------------------------------------------------------------------
writeVal PROC USES eax ebx ecx edx esi edi,
		 numVal:DWORD			; numeric value to be converted to string
		 LOCAL	temp[BUFFER_SIZE]:BYTE,	; to hold reversed string
		 numStr[BUFFER_SIZE]:BYTE,		; to hold correct digit string
		 counter:DWORD,
		 isNeg:BYTE						; True if negative, false if positive

; Converts a numeric value to a string of digits, and invokes the mDisplayString
; macro to produce the output.
;
; Returns: None
; Preconditions: None
; Registers changed: None
;-------------------------------------------------------------------------------

;Setup: Get value to convert, prepare to store converted number backward in temp
	lea		edi, temp			; get addr of temp
	mov		BYTE PTR [edi], 0	; append null-terminator
	mov		counter, 1			; track how many bytes in temp.
	mov		esi, numVal			; point to numeric value
	mov		eax, [esi]			; get number to convert in eax
	mov		isNeg, FALSE		; assume number is positive
	mov		ebx, 10				; to divide numeric value by 10
	test	eax, eax			; check if it's negative
	jns		Convert				; if positive, skip to conversion
	mov		isNeg, TRUE			; if negative, take note to append '-' later
	jmp		Convert

;Repeatedly divide by 10 to isolate digits and move them into temp storage
Convert:
	inc		edi						; point to next element of temp
	cdq
	idiv	ebx						; least significant digit in EDX
	cmp		isNeg, TRUE				; if value is negative, dl is negative
	jne		Continue
	neg		dl						; so, make positive for ascii conversion
Continue:
	add		dl, 48					; convert to character ascii code
	mov		BYTE PTR [edi], dl		; store character
	inc		counter					; count byte
	cmp		eax, 0					; check if number has been fully processed
	jnz		Convert

;Temp holds the number backward, so reverse it into numStr
	mov		esi, edi				; last digit of temp becomes source
	lea		edi, numStr				; point to the number string
	mov		ecx, counter			; set loop counter to number of bytes
	cmp		isNeg, TRUE				; check if number is negative
	jne		Reverse
	mov		al, '-'
	mov		BYTE PTR [edi], al		; if negative, append '-' to numStr
	inc		edi
Reverse:
	mov		dl, [esi]				; get character from temp
	mov		BYTE PTR [edi], dl		; Copy char from temp to numStr
	inc		edi						; move forward in numStr
	dec		esi						; move backward in temp
	loop	Reverse

;Display the numeric string
	lea		edx, numStr				; get address of numStr
	mDisplayString edx

Done:
	ret
writeVal ENDP



;-------------------------------------------------------------------------------
isNumericString PROC USES ecx esi,
				string:PTR BYTE,	; character string
				counter:DWORD,		; size of character string in bytes,
;									  excluding null-terminator
;
; Validates character string: If string contains characters other than numeric
; digits or leading '+' or '-' to indicate sign, input is invalid.
;
; Returns: TRUE if input is valid (0 in EAX), FALSE if invalid (-1 in EAX)
; Preconditions: None
; Registers changed: EAX
;-------------------------------------------------------------------------------

	mov		esi, string				; esi points to string
	cld								; direction: forward

;Validate first digit, which may be '+' or '-'
	lodsb
	cmp		al, 57					; compare to '9'
	jg		NotValid				; greater than '9': not valid
	cmp		al, 48					; compare to '0'
	jl		CheckForSigns			; less than '0' : may be a '+' or '-'

;Check rest of string. The rest of the string can only be numeric digits.
CheckRemaining:
	dec		counter			; one char has been processed
	cmp		counter, 0		; Input is valid if only char is a digit
	je		Valid
	mov		ecx, counter	; ecx = number of characters left in the string
ValidateDigits:
	lodsb
	cmp		al, 57					; compare to '9'
	jg		NotValid
	cmp		al, 48					; compare to '0'
	jl		NotValid
	loop	ValidateDigits
	jmp		Valid

; Check if first character was a + or -
CheckForSigns:
	cmp		al, 45					; '+'
	je		OnlyOneChar
	cmp		al, 43					; '-'
	je		OnlyOneChar
; If the first digit is a + or - and there are no other digits, invalid
OnlyOneChar:
	cmp		counter, 1
	jne		CheckRemaining

; EAX contains TRUE or FALSE as return value
NotValid:
	mov		eax, FALSE
	jmp		Done
Valid:
	mov		eax, TRUE
Done:
	ret

isNumericString ENDP


END main
