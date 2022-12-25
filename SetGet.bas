Function Initialize () Uint64
  ' Check if contract has already been initialized
  10    IF EXISTS(SCID()) THEN RETURN 1
  ' Set initial values
  20    message = ""
  30    owner = ""
  ' Return success message
  40    RETURN 0
End Function

Function SetMessage(newMessage String) Uint64
  ' Check if contract has been initialized
  10    IF !EXISTS(SCID()) THEN RETURN 1
  ' Check if caller is owner
  20    IF owner != caller() THEN RETURN 2
  ' Set message
  30    message = newMessage
  ' Return success message
  40    RETURN 0
End Function

Function GetMessage() String
  ' Check if contract has been initialized
  10    IF !EXISTS(SCID()) THEN RETURN ""
  ' Return message
  20    RETURN message
End Function
