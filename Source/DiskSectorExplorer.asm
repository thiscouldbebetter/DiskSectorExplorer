use16
org 0x7C00
	
BootStageOne:
	;
	mov ah,0x00		; reset disk
	mov dl,0		; drive number
	int 0x13
	;
	mov ah,0x02		; read sectors into memory
	mov al,1		; numberOfSectorsToRead
	mov dl,0		; driveNumber
	mov ch,0		; cylinderNumber
	mov dh,0		; headNumber
	mov cl,2		; startingSectorNumber
	mov bx,DoSomething	; returnBuffer
	int 0x13
	;
	mov ah,0x02		; read sectors into memory
	mov al,0x0E		; numberOfSectorsToRead
	mov dl,0		; driveNumber
	mov ch,0		; cylinderNumber
	mov dh,0		; headNumber
	mov cl,3		; startingSectorNumber
	mov bx,DoSomething2	; returnBuffer
	int 0x13
	;
	jmp DoSomething ; buffer
	;
	ret
	;

PreviousLabel:

PadOutWithZeroesSectorOne:
	times ((0x200 - 2) - ($ - $$)) db 0x00

BootSectorSignature:
	dw 0xAA55

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org 0x7E00

DoSomething:
	;
	push TextSectorExplorer
	call DisplayStringWriteToConsoleWithNewline
	;
	push StringHorizontalRule
	call DisplayStringWriteToConsoleWithNewline
	;
	push CommandPromptSession0
	call CommandPromptSessionRun
	;
	TextSectorExplorer: db 'Sector Explorer',0
	StringHorizontalRule: db '===============',0

PadOutWithZeroesSectorTwo:
	times ((0x200) - ($ - $$)) db 0x00

EndOfSectorTwo:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

org 0x8000

DoSomething2:

	CommandPromptSession0: dw CommandPromptDefnTest, CommandPromptSession0DiskLocation, CommandPromptSession0Command, 0

	CommandPromptSession0Command: dw CommandHelp, 0

	CommandPromptDefnTest: dw CommandPromptDefnTestCommands
		CommandPromptDefnTestCommands:
			dw CommandCalculate, CommandCylinderSet, CommandDiskSet, CommandExit, CommandFind, CommandHeadSet, CommandHelp, CommandLBA, CommandRead, CommandReadAscii, CommandReadNext, CommandSectorSet, CommandWrite, 0

		CommandCalculate: dw CommandCalculateName, CommandCalculateDescription, CommandProcedureCalculate
			CommandCalculateName: db 'calculate',0
			CommandCalculateDescription: db 'Performs a hexadecimal calculation (e.g. "calculate 2 * 2").',0

		CommandCylinderSet: dw CommandCylinderSetName, CommandCylinderSetDescription, CommandProcedureCylinderSet
			CommandCylinderSetName: db 'cylinder',0
			CommandCylinderSetDescription: db 'Sets the current cylinder number.',0

		CommandDiskSet: dw CommandDiskSetName, CommandDiskSetDescription, CommandProcedureDiskSet
			CommandDiskSetName: db 'disk',0
			CommandDiskSetDescription: db 'Sets the current disk number.',0

		CommandExit: dw CommandExitName, CommandExitDescription, CommandProcedureExit
			CommandExitName: db 'exit',0
			CommandExitDescription: db 'Ends the session.',0

		CommandFind: dw CommandFindName, CommandFindDescription, CommandProcedureFind
			CommandFindName: db 'find',0
			CommandFindDescription: db 'Searches the current track for the specified value.',0

		CommandHeadSet: dw CommandHeadSetName, CommandHeadSetDescription, CommandProcedureHeadSet
			CommandHeadSetName: db 'head',0
			CommandHeadSetDescription: db 'Sets the current head number.',0

		CommandHelp: dw CommandHelpName, CommandHelpDescription, CommandProcedureHelp
			CommandHelpName: db 'help',0
			CommandHelpDescription: db 'Displays this help text.',0

		CommandLBA: dw CommandLBAName, CommandLBADescription, CommandProcedureLBA
			CommandLBAName: db 'lba',0
			CommandLBADescription: db 'Converts a Logical Block Address to Cylinder-Head-Sector.',0

		CommandRead: dw CommandReadName, CommandReadDescription, CommandProcedureRead
			CommandReadName: db 'read',0
			CommandReadDescription: db 'Displays the contents of the current sector.',0

		CommandReadAscii: dw CommandReadAsciiName, CommandReadAsciiDescription, CommandProcedureReadAscii
			CommandReadAsciiName: db 'readAscii',0
			CommandReadAsciiDescription: db 'Displays the contents of the current sector as ASCII.',0

		CommandReadNext: dw CommandReadNextName, CommandReadNextDescription, CommandProcedureReadNext
			CommandReadNextName: db 'readnext',0
			CommandReadNextDescription: db 'Displays contents of the current sector and advances to the next.',0

		CommandSectorSet: dw CommandSectorSetName, CommandSectorSetDescription, CommandProcedureSectorSet
			CommandSectorSetName: db 'sector',0
			CommandSectorSetDescription: db 'Sets the current sector number.',0

		CommandWrite: dw CommandWriteName, CommandWriteDescription, CommandProcedureWrite
			CommandWriteName: db 'write',0
			CommandWriteDescription: db 'Writes bytes to the current sector.',0

	CommandPromptSession0DiskLocation:
		dw CommandPromptSession0Disk, 0, 0, 1, 0

	CommandPromptSession0Disk: dw 0, 0, 0, 0, CommandPromptSession0DiskFilesystem
		CommandPromptSession0DiskFilesystem: dw FilesystemDefnFAT16, CommandPromptSession0DiskFilesystemBootSectorBytes
			CommandPromptSession0DiskFilesystemBootSectorBytes: db 0x200 dup (0)


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ArrayEmpty:
	dw 0

ArrayPerformProcedureForEachItem:
	; (array, procedureToPerform, parametersToPass, unpackParameterArray)
	;
	push bp
	mov bp,sp
	push ax
	push si
	;
	mov si,[bp+0x0A] 	; array
	;
	ForEachArrayMember:
		lodsw
		cmp ax,0x0000
		je ElseIfArrayIsOutOfMembers
		; if array is not out of members
			push ax
			push si
			;
			push ax ; object
			;
			push word [bp+6] ; parametersToPass
			cmp word [bp+4],1
			jne DoNotUnpackParameterArray
				call ArrayPushAllItemsToStack
			DoNotUnpackParameterArray:
			;
			call word [bp+8] ; procedureToPerform
			;
			pop si
			pop ax
			jmp IfArrayNotOutOfMembersEnd
		ElseIfArrayIsOutOfMembers:
			jmp EndForEachArrayMember
		IfArrayNotOutOfMembersEnd:
	jmp ForEachArrayMember
	EndForEachArrayMember:
	;
	pop si
	pop ax
	pop bp
	ret 8

ArrayPerformProcedureForEachItemWithNoParameters:
	; (array, procedureToPerform)
	;
	pop word [ArrayPerformProcedureForEachItemWithNoParametersReturnAddress]
	;
	push ArrayEmpty
	push word 1
	call ArrayPerformProcedureForEachItem
	;
	push word [ArrayPerformProcedureForEachItemWithNoParametersReturnAddress]
	ret
	;
	ArrayPerformProcedureForEachItemWithNoParametersReturnAddress: dw 0x0000

ArrayPushAllItemsToStack:
	; (arrayToPush)
	;
	; save the old values ax,dx,si in memory
	; because we can't use the stack like normal
	;	
	mov [ArrayPushAllItemsToStackAX],ax
	mov [ArrayPushAllItemsToStackDX],dx
	mov [ArrayPushAllItemsToStackSI],si
	;
	pop dx ; return address
	pop si ; arrayToPush
	ForEachItemToPush:
		lodsw
		cmp ax,0x0000
		je EndForEachItemToPush
		push ax		; item
	jmp ForEachItemToPush
	EndForEachItemToPush:
	;
	push dx
	;
	; restore the old values
	;
	mov ax,[ArrayPushAllItemsToStackAX]
	mov dx,[ArrayPushAllItemsToStackDX]
	mov si,[ArrayPushAllItemsToStackSI]
	;
	ret ; no need to pop the parameter
	;
	ArrayPushAllItemsToStackAX:
		dw 0
	ArrayPushAllItemsToStackDX:
		dw 0
	ArrayPushAllItemsToStackSI:
		dw 0

CommandProcedureCalculate:
	; (session, command)
	push bp
	mov bp,sp
	push ax
	push cx
	push dx
	push di
	;
	mov di,[bp+4]	; command
	mov di,[di+2]	; command.arguments
	;
	push CommandProcedureCalculateNumberTemp
	push word [di+2]	; operand1 = command.arguments[1]
	call NumberParseFromString
	;
	mov ax,[CommandProcedureCalculateNumberTemp]
	;
	push CommandProcedureCalculateNumberTemp
	push word [di+6]	; operand2 = command.arguments[3]
	call NumberParseFromString
	;
	mov cx,[CommandProcedureCalculateNumberTemp]
	;
	mov di,[di+4]		; operator = command.arguments[2] 
	mov dx,[di]
	;
	IfOperatorIsAdd:
		;
		cmp dx,'+'		
		jne IfOperatorIsSubtract
		;
		add ax,cx
		;
		jmp EndIfOperator
		;
	IfOperatorIsSubtract:
		;
		cmp dx,'-'		
		jne IfOperatorIsMultiply
		;
		sub ax,cx
		;
		jmp EndIfOperator
		;
	IfOperatorIsMultiply:
		;
		cmp dx,'*'
		jne IfOperatorIsDivide
		;
		mul cx
		;
		jmp EndIfOperator
		;
	IfOperatorIsDivide:
		;
		cmp dx,'/'
		jne EndIfOperator
		;
		div cl
		;
		mov [CommandProcedureCalculateNumberTemp],al
		;
		push CommandProcedureCalculateStringTemp
		push CommandProcedureCalculateNumberTemp
		push word 1
		call NumberConvertToStringHexadecimal
		;
		push CommandProcedureCalculateStringTemp
		call DisplayStringWriteToConsole
		;
		push TextR
		call DisplayStringWriteToConsole
		;
		mov [CommandProcedureCalculateNumberTemp],ah
		;
		push CommandProcedureCalculateStringTemp
		push CommandProcedureCalculateNumberTemp
		push word 1
		call NumberConvertToStringHexadecimal
		;
		push CommandProcedureCalculateStringTemp
		call DisplayStringWriteToConsoleWithNewline
		;
		jmp EndCommandProcedureCalculate
		;
	EndIfOperator:
	;
	mov [CommandProcedureCalculateNumberTemp],ax
	;
	push CommandProcedureCalculateStringTemp
	push CommandProcedureCalculateNumberTemp
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureCalculateStringTemp
	call DisplayStringWriteToConsoleWithNewline
	;
	EndCommandProcedureCalculate:
	;
	pop di
	pop dx
	pop cx
	pop ax
	pop bp
	ret 4
	;
	CommandProcedureCalculateNumberTemp: dw 0
	CommandProcedureCalculateStringTemp: db '????',0
	TextR: db 'R',0

CommandProcedureCylinderSet:
	; (session, command)
	push bp
	mov bp,sp
	;
	push word [bp+6]
	push word [bp+4]
	push word 2
	push word 0x03FF	; lowest 10 bits only
	call CommandProcedureDiskLocationComponentSet
	;
	pop bp
	ret 4

CommandProcedureDiskLocationComponentSet:
	; (session, command, componentIndex, bitMaskToApply)
	push bp
	mov bp,sp
	push bx
	push si
	push di
	;
	mov si,[bp+0xA] ; session
	mov si,[si+2] 	; session.diskLocationCurrent
	;
	mov di,[bp+8]	; command
	mov di,[di+2]	; command.arguments
	mov di,[di+2]	; command.arguments[1] (0 is command name)	
	;
	; if argument[1] is specified
		;
		cmp di,0
		je EndCommandProcedureDiskLocationComponentSet
		;
		push CommandProcedureDiskLocationComponentSetNumberTemp
		push di
		call NumberParseFromString
		;
		mov di,[CommandProcedureDiskLocationComponentSetNumberTemp]
		;
		mov bx,[si+0] 	; session.diskLocationCurrent.disk
		add bx,[bp+6]	; componentIndex
		;
		; if component value is out of range
			;
			cmp di,[bx]	; compare component value to disk's maximum
			jbe EndIfComponentValueOutOfRange
			;
			push CommandProcedureDiskLocationComponentSetStringValueOutOfRange
			call DisplayStringWriteToConsoleWithNewline
			;
			jmp EndCommandProcedureDiskLocationComponentSet
			;
		EndIfComponentValueOutOfRange:
		;
		and di,[bp+4] 	; bitMaskToApply (is this still necessary?)
		;
		add si,[bp+6] 	; componentIndex
		mov [si],di	; session.diskLocationCurrent.[component]
		;
	EndCommandProcedureDiskLocationComponentSet:
	pop di
	pop si
	pop bx
	pop bp
	ret 8
	;
	CommandProcedureDiskLocationComponentSetNumberTemp: 		dw 0
	CommandProcedureDiskLocationComponentSetStringValueOutOfRange: 	db 'The specified value is outside the allowed range for the disk.',0

CommandProcedureDiskSet:
	; (session, command)
	push bp
	mov bp,sp
	push ax
	push si
	push di
	;
	mov si,[bp+6] 	; session
	mov si,[si+2] 	; session.diskLocationCurrent
	mov si,[si+0]	; session.diskLocationCurrent.disk
	;
	mov di,[bp+4]	; command
	mov di,[di+2]	; command.arguments
	mov di,[di+2]	; command.arguments[1] (0 is command name)	
	;
	; if argument[1] is specified
		;
		cmp di,0
		je EndIfArgumentsSpecified
		;
		push CommandProcedureDiskSet_NumberTemp
		push di
		call NumberParseFromString
		;
		mov di,[CommandProcedureDiskSet_NumberTemp]
		;
		mov [si+0],di	; session.diskLocationCurrent.disk.diskNumber
		;
		push si 	; session.diskLocationCurrent.disk
		call DiskInitialize
	;
	mov di,[bp+4]	; command
	mov di,[di+2]	; command.arguments
	mov di,[di+4]	; command.arguments[2] (0 is command name)
	;
	; if argument[2] is specified (ignoreLimits)
		;
		push CommandProcedureDiskSet_IsArgument2IgnoreLimits
		push di
		push CommandProcedureDiskSet_TextIgnoreLimits
		call StringCompare
		;
		cmp word [CommandProcedureDiskSet_IsArgument2IgnoreLimits],0
		je EndIfIgnoreLimits
		;
		call DisplayNewline
		push CommandProcedureDiskSet_TextCylinderHeadSectorLimitsWillBeIgnored
		call DisplayStringWriteToConsoleWithNewline
		;
		mov word [si+2],0xFFFF
		mov word [si+4],0xFFFF
		mov word [si+6],0xFFFF
		;
	EndIfIgnoreLimits:
	EndIfArgumentsSpecified:
	;
	push si
	call DiskDisplay
	;
	EndCommandProcedureDiskSet:
	pop di
	pop si
	pop ax
	pop bp
	ret 4
	;
	CommandProcedureDiskSet_IsArgument2IgnoreLimits: dw 0
	CommandProcedureDiskSet_TextIgnoreLimits: db 'ignoreLimits',0
	CommandProcedureDiskSet_TextCylinderHeadSectorLimitsWillBeIgnored: db 'Cylinder, head, and sector limits will be ignored.',0
	CommandProcedureDiskSet_NumberTemp: dw 0

CommandProcedureExit:
	; (session, command)
	push bp
	mov bp,sp
	push si
	;
	mov word si,[bp+6] 		; session
	mov word [si+6],1 		; session.isTerminated
	;
	pop si
	pop bp
	ret 4

CommandProcedureFind:
	; (session, command)
	push bp
	mov bp,sp
	push ax
	push bx
	push si
	push di
	;
	mov si,[bp+6] 	; session
	mov si,[si+2] 	; session.diskLocationCurrent
	;
	mov di,[bp+4]	; command
	mov di,[di+2]	; command.arguments
	mov di,[di+2]	; command.arguments[1] (0 is command name)	
	;
	push CommandProcedureFindNumberToFind
	push di
	call NumberParseFromString
	mov ax,[CommandProcedureFindNumberToFind]
	;
	inc word [si+8]
	cmp word [si+8],0x200
	jae EndForEachByteRead
	;
	ForEachSectorOnDiskToSearch:
		;
		push CommandProcedureReadBytesRead
		push si
		call DiskLocationSectorRead
		;
		ForEachByteRead:
			;
			mov bx,[si+8]
			cmp byte [CommandProcedureReadBytesRead+bx],al
			je EndForEachSectorOnDiskToSearch
			;
			inc word [si+8]
			cmp word [si+8],0x200
			jae EndForEachByteRead
			;
		jmp ForEachByteRead
		EndForEachByteRead:
		;
		push si			; session.diskLocationCurrent
		call DiskLocationSectorAdvance
		;
	jmp ForEachSectorOnDiskToSearch
	EndForEachSectorOnDiskToSearch:
	;
	push CommandProcedureReadBytesRead
	push word [si+8]
	push word 1
	call CommandProcedureReadDisplayHexadecimal
	;
	pop di
	pop si
	pop bx
	pop ax
	pop bp
	ret 4
	;
	CommandProcedureFindNumberTemp: db 0
	CommandProcedureFindNumberToFind: db 0
	CommandProcedureFindStringReadOffset: db '0000',0 
	CommandProcedureFindStringReadLength: db '0000',0 
	CommandProcedureFindCommandRead: dw 0, CommandProcedureFindCommandReadArguments
		CommandProcedureFindCommandReadArguments: dw CommandReadName, 0, 0

CommandProcedureHeadSet:
	; (session, command)
	push bp
	mov bp,sp
	;
	push word [bp+6]
	push word [bp+4]
	push word 4
	push word 0xFFFF
	call CommandProcedureDiskLocationComponentSet
	;
	pop bp
	ret 4

CommandProcedureHelp:
	; (session, command)
	push bp
	mov bp,sp
	push ax
	push bx
	push si
	;
	push CommandProcedureHelpTextLines		; array
	push DisplayStringWriteToConsoleWithNewline	; procedureToPerform
	call ArrayPerformProcedureForEachItemWithNoParameters
	;
	mov si,[bp+6] ; session
	mov si,[si+0] ; session.defn
	mov si,[si+0] ; session.defn.commandDefnsAvailable
	;
	ForEachCommandAvailableHelp:
		;
		lodsw		; ax = command, si++
		;
		IfNoMoreCommands:
			cmp ax,0x0000
			je EndForEachCommandAvailableHelp
		;
		mov bx,ax	
		push word [bx+0] 	; command.name
		call DisplayStringWriteToConsole
		;
		call DisplaySpace
		call DisplaySpace
		call DisplaySpace
		;
		push word [bx+2] 	; command.description
		call DisplayStringWriteToConsoleWithNewline
		;
	jmp ForEachCommandAvailableHelp
	EndForEachCommandAvailableHelp:
	;
	pop si
	pop bx
	pop ax
	pop bp
	ret 4
	;
	CommandProcedureHelpTextLines: dw HelpText0, HelpText1,0
		HelpText0: db 'Commands',0
		HelpText1: db '========',0

CommandProcedureLBA:
	; (session, command)
	push bp
	mov bp,sp
	push si
	push di
	;
	mov si,[bp+6] 	; session
	mov si,[si+2]	; session.diskLocationCurrent
	;
	mov di,[bp+4]	; command
	mov di,[di+2]	; command.arguments
	mov di,[di+2]	; command.arguments[1] (0 is command name)
	;
	push CommandProcedureLBA_NumberTemp
	push word di	; operand = command.arguments[1]
	call NumberParseFromString
	;
	push si						; returnDiskLocation
	push word [si+0]				; session.diskLocationCurrent.disk
	push word [CommandProcedureLBA_NumberTemp]	; lbaToConvert
	call DiskConvertLBAToCHS
	;
	pop di
	pop si
	pop bp
	ret 4
	;
	CommandProcedureLBA_NumberTemp: dw 0

CommandProcedureRead:
	; (session, command)
	push bp
	mov bp,sp
	push bx
	push dx
	push si
	push di
	;
	mov si,[bp+6] 	; session
	mov si,[si+2] 	; session.diskLocationCurrent
	;
	push CommandProcedureReadBytesRead
	push si
	call DiskLocationSectorRead
	;
	mov di,[bp+4]	; command
	mov di,[di+2]	; command.arguments
	;
	mov bx,0	; starting byte index
	mov dx,0x200	; number of bytes to display
	;
	; if argument 1 is specified
		;
		cmp word [di+2],0			; command.arguments[1]
		je EndIfByteIndexStartIsSpecified
		;
		push CommandProcedureReadNumberTemp
		push word [di+2]
		call NumberParseFromString
		; 
		mov bx,[CommandProcedureReadNumberTemp]
		;
	;
	; if argument 2 is specified
		;
		cmp word [di+4],0			; command.arguments[2]
		je EndIfByteIndexEndIsSpecified
		;
		push CommandProcedureReadNumberTemp
		push word [di+4]
		call NumberParseFromString
		; 
		mov dx,[CommandProcedureReadNumberTemp]
		;
	EndIfByteIndexEndIsSpecified:
	EndIfByteIndexStartIsSpecified:
	;
	push CommandProcedureReadBytesRead
	push bx				; startIndex
	push dx				; length
	call CommandProcedureReadDisplayHexadecimal
	;
	pop di
	pop si
	pop dx
	pop bx
	pop bp
	ret 4
	;
	CommandProcedureReadNumberTemp: 			dw 0
	CommandProcedureReadStringTemp: 			db '0000',0
	CommandProcedureReadBytesRead: 				db 0x200 dup (0)
	StringPeriodPeriod: 					db '..',0

CommandProcedureReadAscii:
	; (session, command)
	push bp
	mov bp,sp
	push si
	;
	mov si,[bp+6] 	; session
	mov si,[si+2] 	; session.diskLocationCurrent
	;
	push CommandProcedureReadBytesRead
	push si
	call DiskLocationSectorRead
	;
	push CommandProcedureReadBytesRead
	call CommandProcedureReadDisplayAscii
	;
	pop si
	pop bp
	ret 4

CommandProcedureReadDisplayAscii:
	; (byteBuffer)
	;
	push bp
	mov bp,sp
	push bx
	push cx
	push si
	;
	mov si,[bp+4] ; byteBuffer
	;
	call DisplayNewline
	;
	mov cx,4
	ForEach128BytesReadFromDiskAscii:
		;
		push cx
		;
		mov cx,4
		ForEachThirtyTwoBytesReadFromDiskAscii:
			;
			push cx
			;
			mov cx,0x20
			ForEachByteReadFromDiskAscii:
				;
				mov bl,[si]
				mov bh,0
				mov word [CommandProcedureReadStringTemp],bx
				;
				push CommandProcedureReadStringTemp
				call DisplayStringWriteToConsole
				;
				inc si
				;
			loop ForEachByteReadFromDiskAscii
			;
			call DisplayNewline
			;
			pop cx
			;
		loop ForEachThirtyTwoBytesReadFromDiskAscii
		;
		call DisplayNewline
		;
		pop cx
		;
	loop ForEach128BytesReadFromDiskAscii
	EndCommandProcedureReadAscii:
	;
	pop si
	pop cx
	pop bx
	pop bp
	ret 2
	;

CommandProcedureReadDisplayHexadecimal:
	; (byteBuffer, startIndex, numberOfBytesToDisplay)
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	;
	mov si,[bp+8] ; byteBuffer
	mov bx,si
	add bx,[bp+6] ; startIndex
	mov dx,bx
	add dx,[bp+4] ; numberOfBytesToDisplay
	dec dx
	;
	call DisplayNewline
	;
	mov cx,4
	ForEach128BytesReadFromDiskHexadecimal:
		;
		push cx
		;
		mov cx,4
		ForEachThirtyTwoBytesReadFromDiskHexadecimal:
			;
			push cx
			;
			mov cx,0x8
			ForEachFourBytesReadFromDiskHexadecimal:
				;
				push cx
				;
				mov cx,4
				ForEachByteReadFromDiskHexadecimal:
					;
					; if byte index is between specified start and end 
						;
						cmp si,bx ; startIndex
						jb ElseIfByteNotWithinRangeSpecified
						;
						cmp si,dx ; endIndex
						ja ElseIfByteNotWithinRangeSpecified
						;
						push CommandProcedureReadStringTemp
						push si					; not al
						push word 1
						call NumberConvertToStringHexadecimal
						;
						jmp EndIfByteIsWithinRangeSpecified
						;
					ElseIfByteNotWithinRangeSpecified:
						;
						push CommandProcedureReadStringTemp
						push StringPeriodPeriod
						call StringCopy
						;
					EndIfByteIsWithinRangeSpecified:
					;
					push CommandProcedureReadStringTemp
					call DisplayStringWriteToConsole
					;
					inc si
					;
				loop ForEachByteReadFromDiskHexadecimal
				;
				call DisplaySpace
				;
				pop cx
				;
			loop ForEachFourBytesReadFromDiskHexadecimal
			;
			call DisplayNewline
			;
			pop cx
			;
		loop ForEachThirtyTwoBytesReadFromDiskHexadecimal
		;
		call DisplayNewline
		;
		pop cx
		;
	loop ForEach128BytesReadFromDiskHexadecimal
	EndCommandProcedureReadHexadecimal:
	;
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6

CommandProcedureReadNext:
	; (session, command)
	push bp
	mov bp,sp
	push cx
	push si
	push di
	;
	mov si,[bp+6] ; session
	;
	push si
	push word [bp+4]
	call CommandProcedureRead
	;
	push word [si+2] ; session.diskLocationCurrent
	call DiskLocationSectorAdvance
	;
	pop di
	pop si
	pop cx
	pop bp
	ret 4

CommandProcedureSectorSet:
	; (session, command)
	push bp
	mov bp,sp
	;
	push word [bp+6]
	push word [bp+4]
	push word 6
	push word 0x003F	; lowest 6 bits only
	call CommandProcedureDiskLocationComponentSet
	;
	pop bp
	ret 4

CommandProcedureWrite:
	; (session, command)
	;
	; to be fixed
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	;
	mov si,[bp+6] 	; session
	mov si,[si+2] 	; session.diskLocationCurrent
	;
	push CommandProcedureWriteTextWrite
	call DisplayStringWriteToConsoleWithNewline
	;
	mov ah,0x00	; reset disk
	mov dl,[si+0]	; drive number
	int 0x13
	;
	mov ah,0x02	; read sectors into memory
	mov al,1	; numberOfSectorsToRead
	mov dl,[si+0]	; driveNumber
	mov ch,[si+2]	; cylinderNumber
	mov dh,[si+4]	; headNumber
	mov cl,[si+6]	; startingSectorNumber
	mov bx,CommandProcedureReadBytesRead	; returnBuffer
	int 0x13
	;
	ForEachByteToWriteToDisk:
		;
		push CommandProcedureWriteStringPrompt
		call DisplayStringWriteToConsole
		;
		push CommandProcedureWriteStringTemp 
		push word 2
		call InputStringRead
		;
		cmp byte [CommandProcedureWriteStringTemp],0
		je EndForEachByteToWriteToDisk
		;
		mov ah,0x03	; write sectors to disk
		mov al,1	; numberOfSectorsToWrite
		mov dl,[si+0]	; driveNumber
		mov ch,[si+2]	; cylinderNumber
		mov dh,[si+4]	; headNumber
		mov cl,[si+6]	; startingSectorNumber
		mov bx,CommandProcedureReadBytesRead	; returnBuffer
		int 0x13
		;
	jmp ForEachByteToWriteToDisk
	EndForEachByteToWriteToDisk:
	;
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
	;
	CommandProcedureWriteStringTemp: db '??',0
	CommandProcedureWriteStringPrompt: db '-',0
	CommandProcedureWriteTextWrite: db 'write',0

CommandPromptCommand:
	; +0 = defn
	; +2 = arguments

CommandPromptDefn:
	; +0 = commandDefnsAvailable

CommandPromptDefnCommandDefn:
	; +0 = name
	; +2 = description
	; +4 = procedureToCall

CommandPromptSession:
	; +0 = commandPromptDefn
	; +2 = diskLocationCurrent
	; +4 = commandCurrent
	; +6 = isTerminated

CommandPromptSessionRun:
	; (instance)
	;
	push bp
	mov bp,sp
	push bx
	push si
	push di
	;
	mov si,[bp+4] 	; instance
	mov si,[si+2] 	; instance.diskLocationCurrent
	mov si,[si+0]	; instance.diskLocationCurrent.disk
	;
	push si
	call DiskInitialize
	;
	push si
	call DiskDisplay
	;
	mov si,[bp+4] 	; instance
	;
	LoopCommandPromptSessionRun:
		;
		mov bx,[si+2]			; instance.diskLocationCurrent
		mov byte [CommandPromptSessionRunStringTemp],0x00
		;
		push CommandPromptSessionRunStringTemp
		push bx
		call DiskLocationConvertToString
		;
		push CommandPromptSessionRunStringTemp
		call DisplayStringWriteToConsole		
		;
		push StringCommandPromptTerminator
		call DisplayStringWriteToConsole
		;
		push CommandPromptSessionRunUserInputString
		push word 22
		call InputStringRead
		;
		; if no command was entered at the prompt
			;
			cmp byte [CommandPromptSessionRunUserInputString],0
			jne ElseIfACommandWasEntered
			;
			;
			jmp EndIfNoCommandEntered
			;
		ElseIfACommandWasEntered:
			;
			push word [si+4] 				; returnCommand = session.commandCurrent
			push si						; instance
			push CommandPromptSessionRunUserInputString 	; stringToParse
			call CommandPromptSessionRunParseCommandString
			;
		EndIfNoCommandEntered:
		;
		IfCommandEnteredIsNotValid:
			mov di,[si+4] 						; instance.commandCurrent
			cmp word [di+0],0x0000	; command.defn
			jne ElseCommandEnteredIsValid
			;
			push TextCommandNotValid
			call DisplayStringWriteToConsoleWithNewline
			;
			jmp EndIfCommandEnteredIsNotValid
		ElseCommandEnteredIsValid:
			;
			push si						; instance
			mov di,[si+4]				 	; command
			push di	
			mov di,[di+0]					; command.defn
			call word [di+4]				; command.defn.procedureToCall
			;
		EndIfCommandEnteredIsNotValid:
		;
		call DisplayNewline
		;
		cmp word [si+6],1
		je EndLoopCommandPromptSessionRun
		;
	jmp LoopCommandPromptSessionRun
	EndLoopCommandPromptSessionRun:
	;
	push CommandPromptSessionRunStringExiting
	call DisplayStringWriteToConsoleWithNewline
	;
	pop di
	pop si
	pop bx
	pop bp
	ret 2
	;
	StringCommandPromptTerminator: 			db '>',0
	TextCommandNotValid:				db 'The text entered was not a valid command.  Enter "help" for help.',0
	CommandPromptSessionRunUserInputString:		db 0x200 dup (0)
	CommandPromptSessionRunStringExiting: 		db 'Exiting...',0
	CommandPromptSessionRunStringTemp: 		db 0x0100 dup (0)

CommandPromptSessionRunParseCommandString:
	; (returnCommand, instance, stringToParse)
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push si
	push di
	;
	mov di,[bp+8]	; returnCommand
	mov ax,0x0000	
	stosw		; returnCommand.defn = null
	;
	push CommandPromptSessionRunParseCommandStringTokens
	push word [bp+4] ; stringToParse
	push StringSpace
	call StringSplitOnDelimiter
	;
	mov si,[bp+6] 		; instance
	mov si,[si+0]		; instance.defn
	mov si,[si+0]		; instance.defn.commandDefnsAvailable
	;
	ForEachCommandDefnAvailable:
		;
		lodsw		; ax = commandDefnsAvailable[si], si++
		;
		IfNoMoreCommandDefnsAvailable:
			cmp ax,0x0000
			je EndForEachCommandDefnAvailable
		;
		push CommandPromptSessionRunParseCommandStringIsMatch
		mov bx,ax
		push word [bx+0]						; commandDefn.name
		push word [CommandPromptSessionRunParseCommandStringTokens+0] 	; stringToParseTokens[0]
		call StringCompare
		;
		IfCommandDefnMatches:
			;
			cmp word [CommandPromptSessionRunParseCommandStringIsMatch],1
			jne ElseCommandDefnDoesNotMatch
			;
			mov di,[bp+8]				; returnCommand
			stosw					; returnCommand.defn = commandDefn
			mov ax,CommandPromptSessionRunParseCommandStringTokens	
			stosw					; returnCommand.arguments
			jmp EndForEachCommandDefnAvailable	; break
			;
		ElseCommandDefnDoesNotMatch:
		;
	jmp ForEachCommandDefnAvailable
	EndForEachCommandDefnAvailable:
	;
	pop di
	pop si
	pop bx
	pop ax
	pop bp
	ret 6
	;
	CommandPromptSessionRunParseCommandStringIsMatch: dw 0x0000
	CommandPromptSessionRunParseCommandStringTokens: dw 0x10 dup (0)

Disk:
	; +0 = diskNumber
	; +2 = cylinderNumberMax
	; +4 = headNumberMax
	; +6 = sectorNumberMax
	; +8 = filesystem

DiskConvertLBAToCHS:
	; (returnDiskLocation, disk, lbaToConvert)
	;
	; converts a logical block address to a cylinder-head-sector address
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	;
	mov si,[bp+6] 		; disk
	mov di,[bp+8]		; returnDiskLocation
	;
	mov [di+0],si		; returnDiskLocation.disk
	;
	mov dx,0		; dx is upper 16 bits of dividend for div instruction
	mov ax,[bp+4]		; lbaToConvert
	;	
	mov cx,[si+6]		; disk.sectorNumberMax
	div cx			; ax = ax / disk.sectorNumberMax, dx = remainder
	mov [di+6],dx		; returnDiskLocation.sector
	;
	mov cx,[si+4]		; disk.headNumberMax
	inc cx			; total number of heads
	;
	mov dx,0		; dx is upper 16 bits of dividend for div instruction
	div cx			; ax = ax / number of heads, dx = remainder
	mov [di+4],dx		; returnDiskLocation.head
	mov [di+2],ax		; returnDiskLocation.cylinder
	;
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6
	;
	NumberTemp dw 0
	StringTemp: db 'nnnn',0

DiskDisplay:
	; (disk)
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push es
	push si
	push di
	;
	mov si,[bp+4] 	; disk
	;
	call DisplayNewline
	;
	push TextDiskNumber
	call DisplayStringWriteToConsole
	;
	mov bx,[si+0]			; disk.diskNumber
	mov [DiskDisplay_NumberTemp],bx
	push DiskDisplay_StringTemp	
	push DiskDisplay_NumberTemp	
	push word 1
	call NumberConvertToStringHexadecimal
	;
	push DiskDisplay_StringTemp
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextMaximumCylinderNumber
	call DisplayStringWriteToConsole
	;
	mov bx,[si+2]			; disk.cylinderNumberMax
	mov [DiskDisplay_NumberTemp],bx
	push DiskDisplay_StringTemp	
	push DiskDisplay_NumberTemp	
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push DiskDisplay_StringTemp
	call DisplayStringWriteToConsoleWithNewline	
	;
	push TextMaximumHeadNumber
	call DisplayStringWriteToConsole
	;
	mov bx,[si+4]			; disk.headNumberMax
	mov [DiskDisplay_NumberTemp],bx
	push DiskDisplay_StringTemp	
	push DiskDisplay_NumberTemp	
	push word 1
	call NumberConvertToStringHexadecimal
	;
	push DiskDisplay_StringTemp
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextMaximumSectorNumber
	call DisplayStringWriteToConsole
	;
	mov bx,[si+6]			; disk.sectorNumberMax
	mov [DiskDisplay_NumberTemp],bx
	push DiskDisplay_StringTemp	
	push DiskDisplay_NumberTemp	
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push DiskDisplay_StringTemp
	call DisplayStringWriteToConsoleWithNewline
	;
	call DisplayNewline
	;
	mov si,[si+8] 		; disk.filesystem
	push si
	mov si,[si+0]		; disk.filesystem.defn
	call word [si+2]	; disk.filesystem.defn.methodDescribe
	;
	call DisplayNewline
	;
	pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
	;
	DiskDisplay_StringTemp: 	db 'nnnn',0
	DiskDisplay_NumberTemp: 	dw 0
	TextDiskNumber: 		db 'Disk Number            : ',0
	TextMaximumHeadNumber: 		db 'Maximum Head Number    : ',0
	TextMaximumCylinderNumber: 	db 'Maximum Cylinder Number: ',0
	TextMaximumSectorNumber: 	db 'Maximum Sector Number  : ',0

DiskInitialize:
	; (disk)
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push es
	push si
	push di
	;
	mov si,[bp+4] 	; disk
	;
	push es
	mov bx,0
	mov es,bx	; "to guard against BIOS bugs"
	;
	mov ah,0x08 	; read drive parameters
	mov bx,si 	; disk
	mov dl,[bx+0]	; disk.diskNumber
	mov di,0	; "to guard against BIOS bugs"
	int 0x13
	;
	pop es
	;
	; if the read failed
		;
		jnc EndIfDiskParametersReadFailed
		;
		push DiskInitialize_StringError
		call DisplayStringWriteToConsoleWithNewline		
		;
		jmp EndCommandProcedureDiskInitialize
		;
	EndIfDiskParametersReadFailed:
	;
	mov bx,cx
	push bx
	;
	mov cx,8
	ror bx,cl	
	rol bh,1	; move the two highest bits to two lowest of byte
	rol bh,1
	and bx,0x03FF 	; low 10 bits only
	mov [si+2],bx	; disk.cylinderNumberMax
	;
	pop bx
	;
	mov [si+4],dh	; disk.headNumberMax
	;
	and bx,0x3F 	; low 6 bits
	mov [si+6],bx 	; disk.sectorNumberMax
	;
	; hack: filesystem currently hardcoded
	;
	mov [DiskInitialize_DiskLocationBootSector+0],si
	;
	mov word [si+8],CommandPromptSession0DiskFilesystem
	;
	mov si,[si+8]	; disk.filesystem
	mov si,[si+2] 	; disk.filesystem.bootSectorBytes
	;
	push si		; disk.filesystem.bootSectorBytes
	push DiskInitialize_DiskLocationBootSector
	call DiskLocationSectorRead
	;
	EndCommandProcedureDiskInitialize:
	;
	pop di
	pop si
	pop es
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
	;
	DiskInitialize_DiskLocationBootSector: dw 0, 0, 0, 1, 0
	DiskInitialize_StringError: db 'An error occurred while attempting to read disk parameters.',0

DiskLocation:
	; +0 = disk
	; +2 = cylinderNumber
	; +4 = headNumber
	; +6 = sectorNumber
	; +8 = byteOffsetWithinSector

DiskLocationConvertToString:
	; (returnString, diskLocationToConvert)
	;
	push bp
	mov bp,sp
	push bx
	push cx
	push si
	;
	mov si,[bp+4] 	; diskLocationToConvert
	;
	mov bx,2 	; offset of string representation of component
	;
	push word [DiskLocationConvertToStringArrayTemp+bx]
	push word [si+0] 	; diskLocationToConvert.disk.diskNumber
	push word 2
	call NumberConvertToStringHexadecimal	
	;
	add bx,4
	add si,2
	mov cx,3
	ForEachDiskLocationComponent:
		;
		push word [DiskLocationConvertToStringArrayTemp+bx]
		push word si ; diskLocationToConvert.[component]
		push word 2
		call NumberConvertToStringHexadecimal
		;
		add si,2
		add bx,4
		;
	loop ForEachDiskLocationComponent
	;
	push word [bp+6] ; returnString
	push DiskLocationConvertToStringArrayTemp
	push StringColon
	call StringJoinMany
	;
	pop si
	pop cx
	pop bx
	pop bp
	ret 4
	;
	DiskLocationConvertToStringArrayTemp:	dw TextD,StringDiskNumber,TextC,StringCylinderNumber,TextH,StringHeadNumber,TextS,StringSectorNumber,0

	StringDiskNumber: 	db '0000',0
	StringCylinderNumber: 	db '0000',0
	StringHeadNumber: 	db '0000',0
	StringSectorNumber: 	db '0000',0

	StringColon:		db ':',0

	TextD:			db 'D',0
	TextC:			db 'C',0
	TextH:			db 'H',0
	TextNN:			db 'nn',0
	TextS:			db 'S',0
	TextXX:			db 'xx',0

DiskLocationSectorRead:
	; (returnByteBuffer, instance)
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si
	;
	mov si,[bp+4] 	; instance
	;
	mov ah,0x00	; reset disk
	mov dl,[si+0]	; drive number
	int 0x13
	;
	mov ah,0x02	; read sectors into memory
	mov al,1	; numberOfSectorsToRead
	mov bx,[si+0]	; drive
	mov bx,[bx+0]	; drive.driveNumber
	mov dl,bl
	;
	mov bx,[si+2] 	; cylinderNumber
	mov ch,bl	; cylinderNumber (low 8 bits)
	mov cl,bh	; cylinderNumber (high 2 bits)
	and cl,0x03	; mask all except low two bits
	ror cl,1	; shift the lowest two bits to the highest two positions
	ror cl,1	; 
	;
	mov dh,[si+4]	; headNumber
	or cl,[si+6]	; startingSectorNumber
	mov bx,[bp+6]	; returnByteBuffer
	int 0x13
	;
	; if there was an error during read
		;
		jnc EndIfErrorOnSectorRead
		;
		push TextErrorOccurredDuringReadAttempt
		call DisplayStringWriteToConsoleWithNewline
		;
		jmp EndIfErrorOnSectorRead
		;
	EndIfErrorOnSectorRead:
	;
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4
	;
	TextErrorOccurredDuringReadAttempt: db 'An error occurred during the read attempt.',0

DiskLocationSectorAdvance:
	; (diskLocation)
	;
	push bp
	mov bp,sp
	push cx
	push si
	push di
	;
	mov si,[bp+4] 		; diskLocation
	mov di,[si+0]		; diskLocation.disk
	;
	inc word [si+6] 	; diskLocation.sector++
	mov word [si+8],0 	; diskLocation.byteOffsetWithinSector = 0
	;
	; if sector is out of range
		;
		mov cx,[di+6]
		cmp word [si+6],cx
		jbe EndDiskLocationSectorAdvance
		;
		mov word [si+6],1 	; sector = 1
		inc word [si+4]		; head++
		;
	; if head is out of range
		;
		mov cx,[di+4]
		cmp word [si+4],cx
		jbe EndDiskLocationSectorAdvance
		;
		mov word [si+4],0 	; head = 0
		inc word [si+2]		; cylinder++	
		;
	; if cylinder is out of range
		;
		mov cx,[di+2]
		cmp word [si+2],cx
		jbe EndDiskLocationSectorAdvance
		;
		mov word [si+2],0 	; cylinder = 0
		;
	EndDiskLocationSectorAdvance:
	;
	pop di
	pop si
	pop cx
	pop bp
	;
	ret 2
	
DisplayNewline:
	;
	push StringNewline
	call DisplayStringWriteToConsole
	ret
	;
	StringNewline: db 0x0D,0x0A,0

DisplaySpace:
	;
	push StringSpace
	call DisplayStringWriteToConsole
	ret
	;	
	StringSpace: db ' ',0

DisplayTab:
	;
	push StringTab
	call DisplayStringWriteToConsole
	ret
	;
	StringTab: db '    ',0

DisplayCharacterWriteToConsole:
	; (charToWrite)
	;
	push bp
	mov bp,sp
	push ax
	;
	mov al,[bp+4]		; charToWrite
	;
	mov ah,0x0E ; write character in teletype mode
	int 0x10
	;
	pop ax
	pop bp
	ret 2

DisplayBackspace:
	push ax
	push bx
	push cx
	push dx
	;
	mov ah,0x03	; get the cursor position
	mov bh,0x00	; page 0
	int 0x10
	;
	dec dl		; cursorPos.x--
	;
	mov ah,0x02	; set the cursor position back
	mov bh,0x00	; page 0
	int 0x10
	;
	call DisplaySpace
	;
	mov ah,0x02	; set the cursor position back (again)
	mov bh,0x00	; page 0
	int 0x10
	;
	pop dx
	pop cx
	pop bx
	pop ax
	ret

DisplayStringWriteToConsole:
	; (stringToWrite)
	;
	push bp
	mov bp,sp
	push ax
	push si
	;
	mov si,[bp+4]		; stringToWrite
	;
	mov ah,0x0E ; write character in teletype mode
	;
	ForEachChar:
		lodsb
		cmp al,0x00
		je EndForEachChar
		int 0x10
	jmp ForEachChar
	EndForEachChar:
	;
	pop si
	pop ax
	pop bp
	ret 2

DisplayStringWriteToConsoleWithNewline:
	; (stringToWrite)
	;
	pop word [DisplayStringWriteToConsoleWithNewlineReturnAddress]
	;
	call DisplayStringWriteToConsole
	call DisplayNewline
	;
	push word [DisplayStringWriteToConsoleWithNewlineReturnAddress]
	ret
	;
	DisplayStringWriteToConsoleWithNewlineReturnAddress: dw 0x0000

Filesystem:
	; +0 = defn
	; +2 = bootSectorBytes

FilesystemDefn:
	; +0 = name
	; +2 = methodDescribe
	; +4 = methodConvertLBAToCHS
	ret

FilesystemDefnFAT16: 
	dw FilesystemDefnFAT16Name, FilesystemDefnFAT16Describe
		FilesystemDefnFAT16Name: db 'FAT16',0

FilesystemDefnFAT16Describe:
	; (filesystem)
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si
	;
	mov si,[bp+4] ; filesystem
	mov si,[si+2] ; filesystem.bootSectorBytes
	;
	push TextFilesystemType
	call DisplayStringWriteToConsole
	;
	push TextFAT16
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextBytesPerSector
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp	
	mov bx,si ; filesystem.bootSectorBytes
	add bx,0x0B
	push bx
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextSectorsPerCluster
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp
	mov bx,si
	add bx,0x0D	
	push bx
	push word 1
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextReservedSectors
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp	
	mov bx,si
	add bx,0x0E
	push bx
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextNumberOfFATs
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp	
	mov bx,si
	add bx,0x10	
	push bx
	push word 1
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextRootDirectoryEntriesMax
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp	
	mov bx,si
	add bx,0x11	
	push bx
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextSectorsTotal
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp
	mov bx,si
	add bx,0x20	
	push bx
	push word 4
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextSectorsPerFAT
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp	
	mov bx,si
	add bx,0x16	
	push bx
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextSectorsPerTrack
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp	
	mov bx,si
	add bx,0x18	
	push bx
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextNumberOfHeads
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp	
	mov bx,si
	add bx,0x1A
	push bx
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextNumberOfHiddenSectors
	call DisplayStringWriteToConsole
	;
	push CommandProcedureFilesystem_StringTemp
	mov bx,si
	add bx,0x1C
	push bx
	push word 4
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextRootDirectorySector
	call DisplayStringWriteToConsole
	;
	mov bx,si
	add bx,0x10	; numberOfFATs
	mov cx,[bx]
	mov bx,si
	add bx,0x16	; sectorsPerFAT
	mov ax,[bx]	
	mul cl
	mov bx,si
	add bx,0x0E	; reservedSectors	
	add ax,[bx]
	;
	; hidden sectors don't seem to count
	;
	add ax,1	; for the boot sector
	;
	mov [CommandProcedureFilesystem_NumberTemp],ax
	;
	push CommandProcedureFilesystem_StringTemp
	push CommandProcedureFilesystem_NumberTemp
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;
	push TextDataStartingSector
	call DisplayStringWriteToConsole
	;
	; ax still contains the root directory sector
	mov bx,si
	add bx,0x11 	; maximum root directory entries
	mov bx,[bx]	
	push ax
	mov ax,bx
	mov cx,0x20	; 32 bytes per directory entry
	mul cx
	mov cx,0x0200	; hack: 512 bytes per sector
	div cx
	mov bx,ax
	pop ax
	add ax,bx
	;
	mov bx,si
	add bx,0x1C
	mov bx,[bx]	; hidden sectors
	;add ax,bx
	;
	mov [CommandProcedureFilesystem_NumberTemp],ax
	;
	push CommandProcedureFilesystem_StringTemp
	push CommandProcedureFilesystem_NumberTemp
	push word 2
	call NumberConvertToStringHexadecimal
	;
	push CommandProcedureFilesystem_StringTemp	
	call DisplayStringWriteToConsoleWithNewline
	;	
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 2
	;
	CommandProcedureFilesystem_NumberTemp: dw 0x1234
	CommandProcedureFilesystem_StringTemp: db 'nnnnnnnn',0
	TextBytesPerSector: 		db 'Bytes per Sector     : ',0
	TextDataStartingSector:		db 'Data Starting Sector : ',0
	TextFAT16: 			db 'FAT16',0
	TextFilesystemType: 		db 'Filesystem Type      : ',0
	TextReservedSectors: 		db 'Reserved Sectors     : ',0
	TextNumberOfFATs: 		db 'FATs                 : ',0
	TextNumberOfHeads:		db 'Heads                : ',0
	TextNumberOfHiddenSectors:	db 'Hidden Sectors       : ',0
	TextRootDirectoryEntriesMax: 	db 'Root Dir Entries Max : ',0
	TextRootDirectorySector: 	db 'Root Dir Sector      : ',0
	TextSectorsPerCluster: 		db 'Sectors per Cluster  : ',0
	TextSectorsTotal: 		db 'Sectors Total        : ',0
	TextSectorsPerFAT:		db 'Sectors per FAT      : ',0
	TextSectorsPerTrack:		db 'Sectors per Track    : ',0

InputKeyPressed:
	db 0x00,0x00

InputKeyRead:
	push ax
	;
	mov ah,0x01	; check for keystroke
	int 0x16
	;
	jz EndIfKeyPressed
		;
		mov [InputKeyPressed],al
		;
		mov ah,0x00	; remove the keystroke from the buffer
		int 0x16
		;
	EndIfKeyPressed:
	;
	pop ax
	ret

InputStringRead:
	; (returnString, numberOfCharactersMax)
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push di
	;
	mov di,[bp+6] ; returnString
	mov cx,0
	;
	WhileCharEnteredIsNotReturn:
		;
		call InputKeyRead
		;
		mov ax,[InputKeyPressed]
		mov word [InputKeyPressed],0x0000
		cmp al,0x00
		je NoKeyPressed
			;
			IfKeyReturn:
				cmp al,0xD
				jne IfKeyBackspace
				;
				mov al,0x00
				stosb
				;
				call DisplayNewline
				;
				jmp EndWhileCharEnteredIsNotReturn
			IfKeyBackspace:
				cmp al,0x8
				jne IfKeyOther
				;
				; IfNotAtBeginningOfLineAlready:
					cmp di,[bp+6]
					jle EndIfNotAtBeginningOfLineAlready
					;
					dec di	; back up the cursor
					dec cx
					;
					call DisplayBackspace
					;
				EndIfNotAtBeginningOfLineAlready:
				;
				jmp EndIfKey
			IfKeyOther:
				cmp word cx,[bp+4] ; numberOfCharactersMax
				jae WhileCharEnteredIsNotReturn
				;
				push ax
				call DisplayCharacterWriteToConsole
				stosb
				;
				inc cx
				;
			EndIfKey:
			;
		NoKeyPressed:
		;
	jmp WhileCharEnteredIsNotReturn
	EndWhileCharEnteredIsNotReturn:
	;
	pop di
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4

NumberConvertToStringHexadecimal:
	; (returnString, addressOfValueToConvert, numberOfBytesToConvert)
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push dx
	push si
	push di
	;
	mov si,[bp+6] 	; addressOfValueToConvert
	;
	mov di,[bp+8] 	; di = returnString
	add di,[bp+4]	; 
	add di,[bp+4]	; di = end of string (2 chars per byte)
	dec di		; account for null terminator
	;
	mov cx,[bp+4] ; numberOfBytesToConvert
	ForEachByte:
		;
		push cx
		lodsb		; ax = byte to convert, si = next byte
		mov cx,0x0002	; nibbles per byte
		std	; reverse direction
		ForEachNibble:
			;
			push ax ; save the original byte value
			;
			; shift bits 4 over if on second nibble
			cmp cx,0x0001
			jne DoNotShift
				shr ax,1
				shr ax,1
				shr ax,1
				shr ax,1
			DoNotShift:
			;
			and ax,0x000F 	; mask all but last 4 bits
			;
			cmp ax,0x000A	
			jb EndIfNibbleGreaterThan9
			; if nibble > 9
				add ax,0x0007 ; jump from numerals to letters
			EndIfNibbleGreaterThan9:
			add ax,0x0030 	; ascii '0'
			;
			stosb		; returnValue += nibble char, di--
			;
			pop ax 	; restore the original byte value
			;
		loop ForEachNibble
		cld 	; restore forward direction
		pop cx
		;
	loop ForEachByte
	; append a null
	mov di,[bp+8] 	; di = returnString
	add di,[bp+4]
	add di,[bp+4]	; di = end of string (2 chars per byte)
	mov ax,0x0000
	stosb
	;
	pop di
	pop si
	pop dx
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6

NumberParseFromString:
	; (returnValue, stringToParse)
	push bp
	mov bp,sp
	push ax
	push cx
	push dx
	push si
	push di
	;
	mov dx,0 	; returnValue = 0
	;
	mov si,[bp+4] 	; stringToParse
	mov ax,0
	;
	ForEachCharInStringToParse:
		;
		lodsb
		;
		cmp al,0
		je EndForEachCharInStringToParse
		;
		; if digit to parse is a lowercase letter
			cmp al,0x60
			jb EndIfDigitToParseIsLowercase
			;
			sub al,0x20 ; make it uppercase
			;
		EndIfDigitToParseIsLowercase:
		;
		; if digit to parse is a letter
			cmp al,0x40
			jb EndIfDigitToParseIsAOrGreater
			;
			sub ax,0x7 ; jump from ascii letters back to numerals
			;
		EndIfDigitToParseIsAOrGreater:
		;
		sub al,0x30 ; ascii code of 0
		;
		mov cx,4
		shl dx,cl
		;
		add dx,ax
		;
	jmp ForEachCharInStringToParse
	EndForEachCharInStringToParse:
	;
	mov di,[bp+6]	; returnValue
	mov [di],dx	; returnValue = dx
	;
	pop di
	pop si
	pop dx
	pop cx
	pop ax
	pop bp
	ret 4

StringAppend:
	; (stringToAppendTo, stringToAppend)
	push bp
	mov bp,sp
	push ax
	push cx
	push si
	push di
	;
	push StringAppendLengthOriginal
	push word [bp+6] ; stringToAppendTo
	call StringLength
	;
	mov cx,[StringAppendLengthOriginal]
	mov si,[bp+6] ; stringToAppendTo
	rep lodsb
	;
	push StringAppendLengthOriginal
	push word [bp+4] ; stringToAppend
	call StringLength
	;
	mov di,si	; di = end of stringToAppendTo
	mov si,[bp+4] 	; si = stringToAppend
	mov cx,[StringAppendLengthOriginal]
	rep movsb
	;
	pop di
	pop si
	pop cx
	pop ax
	pop bp
	ret 4
	;
	StringAppendLengthOriginal:
		dw 0x0000

StringCompare:	
	; (returnValue, string0, string1)
	;
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push si
	push di
	;
	mov di,[bp+8]			
	mov word [di],0  ; returnValue = false
	;
	mov si,[bp+6] ; string0
	mov di,[bp+4] ; string1
	;
	; determine the length of string0 first (hack)
	; also, now that StringLength exists, should use that
	;
	mov bx,si
	FindLength:
		lodsb
		cmp al,0x00
	jne FindLength
	mov cx,si
	sub cx,bx
	mov si,bx ; reset si 
	;
	inc cx
	;
	repe cmpsb
	;
	mov di,[bp+8]
	;
	; if strings are equal
		cmp cx,0
		jne ElseStringsAreNotEqual
		;
		mov word [di],1 ; returnValue = true
		;
		jmp EndIfStringsAreEqual
		;
	ElseStringsAreNotEqual:
		;
		mov word [di],0 ; returnValue = false
		;
	EndIfStringsAreEqual:
	;
	pop di
	pop si
	pop cx
	pop bx
	pop ax
	pop bp
	ret 6

StringCopy:
	; (returnValue, stringToCopyFrom)
	push bp
	mov bp,sp
	push ax
	push si
	push di
	;
	mov si,[bp+4] ; stringToCopyFrom
	mov di,[bp+6] ; returnValue
	;
	ForEachCharStringCopy:
		lodsb
		stosb
		cmp al,0x00
		je EndForEachCharStringCopy
		; if char is null, break
	jmp ForEachCharStringCopy
	EndForEachCharStringCopy:
	;
	pop di
	pop si
	pop ax
	pop bp
	ret 4

StringJoinMany:
	; (returnString, stringsToJoin, delimiter)
	push bp
	mov bp,sp
	push ax
	push dx
	push si
	push di
	;
	mov si,[bp+4]	; delimiter
	mov dx,[si]	; single delimiter for now
	mov si,[bp+6] 	; stringsToJoin
	mov di,[bp+8]	; returnString
	ForEachStringToJoin:
		lodsw
		cmp ax,0x0000
		je EndForEachStringToJoin 
		; if string is null, break
		; else
			push si
			mov si,ax ; first char of string to join
			ForEachCharInStringToJoin:
				lodsb
				cmp al,0x00
				jne ElseFESTJ
				; if char is null
					mov ax,dx ; delimiter
					stosb
					jmp EndForEachCharInStringToJoin
				ElseFESTJ:
					stosb
				; endIf
			jmp ForEachCharInStringToJoin
			EndForEachCharInStringToJoin:
			pop si
		;endIf
	jmp ForEachStringToJoin
	EndForEachStringToJoin:
	; terminate with a null
	mov al,0x00
	stosb
	;
	pop di
	pop si
	pop dx
	pop ax
	pop bp
	ret 6

StringLength:
	; (returnValue, stringToFindLengthOf)
	;
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push cx
	push si
	;
	mov si,[bp+4] 	; stringToFindLengthOf
	mov bx,si
	FindStringLength:
		lodsb
		cmp al,0x00
	jne FindStringLength
	mov cx,si
	sub cx,bx
	sub cx,0x0001 ; don't count the terminating null
	;
	mov si,[bp+6] ; returnValue
	mov [si+0],cx ; returnValue (or returnValue.x) = cx
	;
	pop si
	pop cx
	pop bx
	pop ax
	pop bp
	ret 4

StringPrepend:
	; (stringToPrependTo, stringToPrepend)
	push bp
	mov bp,sp
	push ax
	push cx
	push dx
	push si
	push di
	;
	push StringPrependLengthOriginal
	push word [bp+6] ; stringToPrependTo
	call StringLength
	mov cx,[StringPrependLengthOriginal]
	;
	push StringPrependLengthOriginal
	push word [bp+4] ; stringToPrepend
	call StringLength
	mov dx,[StringPrependLengthOriginal]	; not counting the null terminator yet
	;
	mov si,[bp+6]	; stringToPrependTo
	add si,cx	; advance to end of stringToPrependTo
	mov di,si	
	add di,dx 	; advance even further to make room for stringToPrepend
	inc cx
	;
	std		; reverse direction
	rep movsb	; shift the stringToPrependTo forward by stringToPrepend.length
	cld		; forward direction
	;
	mov si,[bp+4]	; stringToPrepend
	mov di,[bp+6]	; stringToPrependTo
	mov cx,dx	; stringToPrepend.length
	inc dx
	rep movsb
	;
	pop di
	pop si
	pop dx
	pop cx
	pop ax
	pop bp
	ret 4
	;
	StringPrependLengthOriginal:
		dw 0x0000


StringSplitOnDelimiter:
	; (returnStringArray, stringToSplit, delimiter)
	;
	; modifies the original string
	;
	push bp
	mov bp,sp
	push ax
	push bx
	push si
	push di
	;
	mov bx,[bp+4]	; delimiter
	mov bx,[bx]	; single delimiter for now
	mov si,[bp+6]	; stringToSplit
	mov di,[bp+8]	; returnStringArray
	;
	mov ax,si
	stosw	; returnStrings[0] = stringToParse[0], di++
	;
	ForEachCharInStringToSplit:
		lodsb
		; IfCharIsNull:
			cmp al,0x00	
			je EndForEachCharInStringToSplit ; break
		; ElseIfCharIsDelimiter:
			cmp al,bl ; delimiter
			jne EndIfCharIsDelimiter
			;
			mov ax,si ; returnStrings[di] = beginning of next string, di++
			stosw
			;
			push di
			;
			mov di,si	; in the original string
			dec di
			mov al,0x00
			stosb		; replace the delimiter with a null
			;
			pop di
			;
		EndIfCharIsDelimiter:
	jmp ForEachCharInStringToSplit
	EndForEachCharInStringToSplit:
	;
	mov ax,0x0000 ; terminate returnStrings with a null
	stosw
	;
	pop di
	pop si
	pop bx
	pop ax
	pop bp
	ret 6

PadOutWithZeroesSectorsThreeThroughN:
	times ((0x2000) - ($ - $$)) db 0x00

EndOfSectorsThreeThroughN:
