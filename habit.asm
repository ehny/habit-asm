%include "asm_io.inc"

; number of days to track habit
%define DAYS 7					

segment .data

	mainMenu				db		27,"[1m","Habit ASM > Main Menu",27,"[0m",10,"===================================",10,"Enter 1 ... to set up a new habit",10,"Enter 2 ... to record a daily entry",10,"Enter 3 ... to print a report",10,"Enter 0 ... to exit",10,"===================================",10,0
	optionPrompt			db		"Option: ",0
	mainError				db 		10,"Error: The value entered was invalid.",10,"The program will now exit.",10,0
	option1M				db 		27,"[1m","Main Menu > New Habit Setup",27,"[0m",10,0
	option2M				db		27,"[1m","Main Menu > Record Entry",27,"[0m",10,0
	option3M				db		27,"[1m","Main Menu > Show Report",27,"[0m",10,0
	option0M 				db 		27,"[1m","Goodbye!",27,"[0m",0
	singleLine				db		"-----------------------------------",10,0
	
	logoFile		 		db		"logo.txt",0
	habitFile				db		"habit.txt",0
	dataFile				db		"data.txt",0			
	readMode				db		"r",0
	writeMode				db		"w",0
	habitFormat 			db		"%d %s",0
	dataFormat				db		"%d",0
	writeDataFormat			db		"%d ",0
	stringDataFormat 		db		"%s",0

	tableHeaders 			db 		"| Day: | Min: |",10,0
	tablePattern			db		"+------+------+",10,0
	tableDataFormat			db		"| %4d | %4d |",10,0
	tableBlankFormat 		db		"| %4d |      |",10,0

	reportTableHeaders 		db 		"| Day: | Min: |  Met: |",10,0
	reportTablePattern		db		"+------+------+-------+",10,0
	reportTableDataFormat	db		"| %4d | %4d |   %s   |",10,0
	reportTableBlankFormat 	db		"| %4d |      |       |",10,0
	streakMarker			db		"*",0
	blankStreak				db		" ",0

	habitPrompt1			db 		"Enter a name for your new habit: ",0
	habitPrompt2			db		"For how many minutes: ",0
	habitResponse0 			db		"New habit:     %s",0
	habitResponse1			db		"Daily minutes: %d",10,0
	habitResponse2			db 		"Goal:    %s",10, "Minutes: %d",10,0
	habitRecord1			db		"Enter a day to record a habit: ",0
	habitRecord2			db 		"Enter the amount of minutes: ",0
	habitConfirm			db		"Success: %d minutes on day %d has been recorded.",10,0
	habitError				db		10,"Error: The value entered was invalid.",10,"Returning to main menu.",10,0

	barHeader				db		"Progress:",10,0
	bar						db		"▇▇",0
	barIndex				db		"__",0
	barComplete				db		"| 100%",0
	sumResponse				db		"Total days recorded: %d / %d",10,0
	sumResponse2			db		"Total time:          %d:%02d",10,0
	sumResponse3			db		"Total goal met:      %d / %d",10,0
	byeHeader				db		"███████████████████████████████████",0

segment .bss

	habitHandler	resd	1		; file handler for habit.txt file
	habitName		resb	22		; string to store habit name
	habitDuration	resd	1		; habit duration in minutes
	localData		resd	DAYS	; array to store habit data
	dataHandler		resd	1		; file handler for data.txt file
	logoString		resb	150		; array for logo text
	logoHandler		resd	1		; file handler for logo.txt file
	habitSum		resd	1		; total habit minutes recorded
	daysRecorded	resd	1		; total days data has been recorded
	goalCount		resd	1		; total days goal has been met

segment .text
	global  asm_main
	extern 	stdin
	extern	fgets
	extern 	printf
	extern	fprintf
	extern	fopen
	extern  fclose
	extern  fscanf

asm_main:
	push	ebp
	mov		ebp, esp
	; ********** CODE STARTS HERE **********

	; display the logo

	call	print_nl
	call	showLogo
	call	print_nl

	toploop:

	; display the main menu
	mov		eax, mainMenu
	call	print_string

	; prompt for user input
	mov		eax, optionPrompt
	call	print_string

	; keep reading user input while != '0'

	call	read_char
	mov		dl, al		; dl = user input
	call	read_char	; gobble up the newline 

	cmp		dl, '0'
	je		exit

	; option 1: set up a new habit

	cmp		dl, '1'
	jne		option2

		; display menu bar
		call	print_nl
		mov		eax, option1M
		call	print_string
		mov		eax, singleLine
		call	print_string

		; create a new habit
		call	resetArray		; reset local array, set all values to -1
		call	writeData		; copy over values to data.txt file
		call 	createHabit		; create a new goal
		call	writeHabit		; write new goal data to habit.txt file
		call	print_nl
		call	read_char 		; gobble up the newline
		jmp		toploop 
	
	; option 2: record habit daily entry 
	
	option2:
	cmp		dl, '2'
	jne		option3

		; display menu bar
		call	print_nl
		mov		eax, option2M
		call	print_string
		mov		eax, singleLine
		call	print_string
		call	print_nl

		call 	readHabit		; read and display goal from habit.txt file
		call	readData		; load any previous data from data.txt file
		call	recordHabit		; record and user daily entry
		call	writeData		; update data.txt file with new entry
		call	read_char 		; gobble up the newline
		call	print_nl
		jmp		toploop
		
	; option 3: print summary report

	option3:
	cmp		dl, '3'
	jne		option4

		; display menu bar
		call	print_nl
		mov		eax, option3M
		call	print_string
		mov		eax, singleLine
		call	print_string
		call	print_nl

		call	readHabit 		; read and display goal from habit.txt file
		call	print_nl
	    call	readData 		; load any previous data from data.txt file
		call	printReportArr	; display the summary table
		call	progressBar		; display the progress bar
		call	print_nl

		; display a line separator 
		push	singleLine
		push	stringDataFormat
		call	printf
		add		esp, 8

		call	calcSum			; display total values
		call	print_nl

		jmp		toploop

	; show  error message for invalid entry
	
	option4:
	mov		eax, mainError
	call	print_string
	
	exit: 

	; display the goodbye message

	call	print_nl
	push	byeHeader
	push	stringDataFormat
	call	printf
	add 	esp, 8
	call	print_nl

	call	print_nl
	mov		eax, option0M
	call	print_string 
	call	print_nl

	; *********** CODE ENDS HERE ***********
	mov		eax, 0
	mov		esp, ebp
	pop		ebp
	ret

; read in and display logo from logo.txt
showLogo:

	push	ebp
	mov		ebp, esp

	; open the the logo.txt file
	push    readMode
    push    logoFile
    call    fopen
    add     esp, 8
 
	mov		DWORD [logoHandler], eax		; store file handler in logoHandler
	mov		ebx, 0							; initialize loop counter to zero

	; loop through logo.txt file
	logoTopLoop:
	cmp		ebx, 16				; logo is 16 lines of text
	jge 	endLogoLoop

		; read in one line at a time
		push    DWORD [logoHandler]
		push	150
   	 	push    logoString
    	call    fgets
    	add     esp, 12

		; print line of text
    	push	logoString
	   	push    stringDataFormat
    	call    printf  
		add     esp, 8
	
	inc 	ebx
	jmp 	logoTopLoop
	endLogoLoop:

	call	print_nl

	; close the logo.txt file
	push    DWORD [logoHandler]
	call	fclose
	add 	esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; create a new habit goal
createHabit:
	push	ebp
	mov		ebp, esp

		; prompt user for new habit name

		call	print_nl
		mov		eax, habitPrompt1
		call	print_string

		; read in a string from the terminal 
		push	DWORD [stdin]
		push	22
		push	habitName
		call	fgets
		add 	esp, 12

		; prompt user for habit duration

		mov		eax, habitPrompt2
		call	print_string
		call	read_int
		mov		DWORD [habitDuration], eax
		call	print_nl

		; display read in data

		push	habitName
		push	habitResponse0
		call	printf
		add		esp, 8

		push	DWORD [habitDuration]
		push	habitResponse1
		call	printf
		add		esp, 8

	mov		esp, ebp
	pop		ebp
	ret

; write habit data to habit.txt file
writeHabit:
	push	ebp
	mov		ebp, esp

	; open habit.txt file for writing
	push	writeMode
	push	habitFile
	call	fopen
	add		esp, 8
	mov		DWORD [habitHandler], eax		; habitHandler contains habit.txt file handler

	; write goal details to file
	push	habitName
	push	DWORD [habitDuration]
	push	habitFormat
	push	DWORD [habitHandler]
	call	fprintf
	add		esp, 16

	; close the file
	push	DWORD [habitHandler]
	call	fclose
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; read in stored goal data from habit.txt file and print
readHabit:

	push	ebp
	mov		ebp, esp

	; open file for reading 
	push	readMode
	push	habitFile
	call	fopen
	add		esp, 8
	mov		DWORD [habitHandler], eax

	; read in data
	push	habitName
	push	habitDuration
	push	habitFormat
	push	DWORD [habitHandler]
	call	fscanf
	add		esp, 16

	; close habit.txt file
	push	DWORD [habitHandler]
	call	fclose
	add		esp, 4

	; print goal data
	push	DWORD [habitDuration]
	push	habitName
	push	habitResponse2
	call	printf
	add		esp, 8

	mov		esp, ebp
	pop		ebp
	ret

; record a daily habit entry
recordHabit:

	push	ebp
	mov		ebp, esp

	; local variable to store the day for entry
	sub		esp, 4

	call	print_nl
	call	printArr		; display table with previously recorded data

	; prompt user to select a day to record a value for
	mov		eax, habitRecord1
	call	print_string
	call	read_int

	; check for invalid entries 
	cmp		eax, DAYS		
	jg		invalidEntry
	cmp		eax, 0
	jle		invalidEntry

	sub		eax, 1					; adjust entry to store in appropriate array index
	mov		DWORD [ebp-4], eax  	; ebp-4 -> array index for day to record value

	; prompt user to enter minutes, store value
	mov		eax, habitRecord2
	call	print_string
	call	read_int				; eax -> amount of minutes 
	mov		ecx, DWORD [ebp-4]		; ecx -> array index day to record value
	mov		DWORD [localData + ecx * 4], eax

	; display entry confirmation
	call	print_nl
	inc		DWORD [ebp -4]					; adjust the day 
	push	DWORD [ebp -4]					; day  
	push	DWORD [localData + ecx * 4]		; minutes for day
	push	habitConfirm
	call	printf
	add		esp, 12
	jmp		done

	; show error message for invalid day entry
	invalidEntry:
	mov		eax, habitError
	call	print_string
	call	print_nl

	done:

	mov		esp, ebp
	pop		ebp
	ret

; read habit data from data.txt file into localData array
readData:

	push	ebp
	mov		ebp, esp

	; open data.txt file for reading
	push	readMode
	push	dataFile
	call	fopen
	add		esp, 8
	mov		DWORD [dataHandler], eax

	sub		esp, 4		; ebp - 4 -> loop counter
	mov 	DWORD [ebp - 4], 0

	; loop through and read values into localData array
	topReadLoop:
	cmp		DWORD [ebp - 4], DAYS,
	je		endReadLoop

		mov		eax, DWORD [ebp - 4]
		mov		ebx, localData
		lea		ecx, [ebx + eax * 4]
		push	ecx
		push	dataFormat
		push	DWORD [dataHandler]
		call	fscanf
		add		esp, 12

	inc		DWORD [ebp - 4]
	jmp		topReadLoop
	endReadLoop:

	; close file
	push	DWORD [dataHandler]
	call	fclose
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; update  data.txt file with values from localData array
writeData:

	push	ebp
	mov		ebp, esp

	; open data.txt file for writing
	push	writeMode
	push	dataFile
	call	fopen
	add		esp, 8
	mov		DWORD [dataHandler], eax

	sub		esp, 4		; ebp - 4 -> loop counter
	mov 	DWORD [ebp - 4], 0

	; loop through and write localData values to file (overwriting any previous data)
	topWriteLoop:
	cmp		DWORD [ebp - 4], DAYS
	je		endWriteLoop

		mov		eax, DWORD [ebp - 4]				; eax -> loop counter
		mov		ebx, DWORD [localData + eax * 4]	; ebx -> array[eax] value
		push	ebx
		push	writeDataFormat
		push	DWORD [dataHandler]
		call	fprintf
		add		esp, 12

	inc		DWORD [ebp - 4]
	jmp		topWriteLoop
	endWriteLoop:

	; close file
	push	DWORD [dataHandler]
	call	fclose
	add		esp, 4

	mov		esp, ebp
	pop		ebp
	ret

; print the table showing values in the localData array
printArr:

	push	ebp
	mov		ebp, esp
	
	; print header row
	push	tablePattern
	push	stringDataFormat
	call	printf
	add		esp, 8
	
	push	tableHeaders
	push 	stringDataFormat
	call	printf
	add		esp, 8
	
	push	tablePattern
	push	stringDataFormat
	call	printf
	add		esp, 8

	sub		esp, 8		
	mov 	DWORD [ebp - 4], 0   	; ebp - 4 -> loop counter
	mov 	DWORD [ebp - 8], 1		; ebp - 8 -> table header

	; loop through and print any values stored in the localData array
	topPrintLoop:
	cmp		DWORD [ebp - 4], DAYS
	je		endPrintLoop

		mov		eax, DWORD [ebp - 4]				; eax -> loop counter
		mov		ebx, DWORD [localData + eax * 4]	; ebx -> array[eax] value
		add		eax, DWORD [ebp - 8]				; increment loop val by 1

			; print empty cell if no data has been recorded for that day
			cmp		ebx, -1		; -1 represents an empty value in the array
			jne		continue
				push	eax
				push 	tableBlankFormat
				call	printf
				add		esp, 8
				jmp		endif
			continue:

			; print values for non-empty days
			push	ebx
			push	eax
			push	tableDataFormat
			call	printf
			add		esp, 12

		endif:
		push	tablePattern
		push	stringDataFormat
		call	printf
		add		esp, 8

	inc		DWORD [ebp - 4]
	jmp		topPrintLoop
	endPrintLoop:

	call	print_nl

	mov		esp, ebp
	pop		ebp
	ret

; set all the values in the array to -1

resetArray:

	push	ebp
	mov		ebp, esp

	sub		esp, 4
	mov 	DWORD [ebp - 4], 0  	; ebp - 4 -> loop counter

	topResetLoop:
	cmp		DWORD [ebp - 4], DAYS
	je		endResetLoop

		mov		eax, DWORD [ebp - 4]			; eax -> loop counter
		mov		DWORD [localData + eax * 4], -1	; arr[eax] = -1

	inc		DWORD [ebp - 4]
	jmp		topResetLoop
	endResetLoop:

	mov		esp, ebp
	pop		ebp
	ret

; print the values in the localData array along with summary data
printReportArr:

	push	ebp
	mov		ebp, esp
	
	; print table header row
	push	reportTablePattern
	push	stringDataFormat
	call	printf
	add		esp, 8
	
	push	reportTableHeaders
	push 	stringDataFormat
	call	printf
	add		esp, 8
	
	push	reportTablePattern
	push	stringDataFormat
	call	printf
	add		esp, 8

	; loop through array and print any recorded values
	; along with indicators if the goal for the day has been met
	sub		esp, 8		
	mov 	DWORD [ebp - 4], 0   	; ebp - 4 -> loop counter
	mov 	DWORD [ebp - 8], 1		; ebp - 8 -> table header

	mov		DWORD [goalCount], 0 	; initialize goal count as zero

	topReportPrintLoop:
	cmp		DWORD [ebp - 4], DAYS
	je		endReportPrintLoop

		mov		eax, DWORD [ebp - 4]				; eax -> loop counter
		mov		ebx, DWORD [localData + eax * 4]	; ebx -> array[eax] value
		add		eax, DWORD [ebp - 8]				; increment loop val by 1

			; print empty cell if no data has been recorded for that day
			cmp		ebx, -1
			jne		continue2
				push	eax
				push 	reportTableBlankFormat
				call	printf
				add		esp, 8
				jmp		endif2
			
			continue2:

			; check if goal has been met for the day
			cmp		ebx, DWORD [habitDuration]
			jl		goalNotMet

				; print an asterisk if true
				push	streakMarker
				push	ebx
				push	eax
				push	reportTableDataFormat
				call	printf
				add		esp, 12
				inc		DWORD [goalCount]		; increment the goal counter
				jmp		endif2
			
			; print empty cell if data has not been recorded for that day
			goalNotMet:
				push	blankStreak
				push	ebx
				push	eax
				push	reportTableDataFormat
				call	printf
				add		esp, 12

			endif2:
				push	reportTablePattern
				push	stringDataFormat
				call	printf
				add		esp, 8

	inc		DWORD [ebp - 4]
	jmp		topReportPrintLoop
	endReportPrintLoop:

	call	print_nl

	mov		esp, ebp
	pop		ebp
	ret	

; calculate and print the progress bar
progressBar:

	push	ebp
	mov		ebp, esp

	sub		esp, 4
	mov 	DWORD [ebp - 4], 0  	; ebp - 4 -> loop counter

	mov 	eax, singleLine
	call	print_string

	mov		eax, barHeader
	call	print_string
	call	print_nl

	; loop through and check if a value (greater than zero) has been recorded for the day
	topProgressLoop:
	cmp		DWORD [ebp - 4], DAYS
	je		endProgressLoop

		mov		eax, DWORD [ebp - 4]				; eax -> loop counter
		mov		ebx, DWORD [localData + eax * 4]	; ebx -> arr[eax]
		cmp		ebx, 1
		
		; increment the bar if data has been recorded
		jl		noBar
			mov		eax, bar
			call	print_string
		noBar:

	inc		DWORD [ebp - 4]
	jmp		topProgressLoop
	endProgressLoop:

	; print the bar index
	call	print_nl

	mov 	DWORD [ebp - 4], 0  	; reset loop counter

	topIndexLoop:
	cmp		DWORD [ebp - 4], DAYS
	je		endIndexLoop

		mov		eax, barIndex
		call	print_string

	inc		DWORD [ebp - 4]
	jmp		topIndexLoop
	endIndexLoop:

	; print the progress bar index marker
	push	barComplete
	push	stringDataFormat
	call	printf
	add		esp, 8

	call print_nl

	mov		esp, ebp
	pop		ebp
	ret

; calculate total minutes and days recorded 

calcSum:

	push	ebp
	mov		ebp, esp

	mov		DWORD [daysRecorded], 0 	; initialize days recorded as zero
	mov		DWORD [habitSum], 0         ; initialize total minutes as zero

	sub		esp, 8
	mov		DWORD [ebp - 4], 0		; ebp - 4 -> loop counting variable
	mov		DWORD [ebp - 8], 60 	; 60 minutes/hour

	topTotalLoop:
	cmp		DWORD [ebp - 4], DAYS
	je		endTotalLoop

		mov		eax, DWORD [ebp - 4]				; eax -> loop counter
		mov		ebx, DWORD [localData + eax * 4]	; ebx -> arr[eax]
		
		; check if a value has been recorded for that day
		cmp		ebx, 0
		jle		noData
			add		DWORD [habitSum], ebx	; add value to sum
			inc		DWORD [daysRecorded]	; increment days recorded value
		noData:
	
	inc		DWORD [ebp - 4]
	jmp		topTotalLoop
	endTotalLoop:

	; print summary data
	push	DAYS
	push	DWORD [daysRecorded]
	push	sumResponse
	call	printf
	add		esp, 12

	push	DAYS
	push	DWORD [goalCount]
	push	sumResponse3
	call	printf
	add		esp, 12

	; convert total minutes to hours + minutes
	mov		eax, DWORD [habitSum]		; eax -> total minutes
	cdq
	mov		edi, DWORD [ebp - 8]		; edi -> 60 (1 hour)
	idiv	edi							; eax -> quotient, remainder -> edx

	push	edx
	push	eax
	push	sumResponse2
	call	printf
	add		esp, 12

	mov		esp, ebp
	pop		ebp
	ret
