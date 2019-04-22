property pProhibitedCharCodes, pLastFailedCharacter

on construct me 
  if not memberExists("prohibited_name_chars") then
    error(me, "Resource containing prohibited chars not found!", #construct)
    removeObject(me.getID())
  end if
  pProhibitedCharCodes = []
  pLastFailedCharacter = ""
  tCharCodeList = member(getmemnum("prohibited_name_chars")).text
  i = 1
  repeat while i <= tCharCodeList.count(#line)
    pProhibitedCharCodes.add(integer(tCharCodeList.getProp(#line, i)))
    i = 1 + i
  end repeat
  sort(pProhibitedCharCodes)
  return(1)
end

on validateString me, tString 
  if tString.ilk <> #string then
    return(error(me, "String expected:" && tString, #validate))
  end if
  pLastFailedCharacter = ""
  i = 1
  repeat while i <= length(tString)
    tChar = tString.char[i]
    if pProhibitedCharCodes.getOne(charToNum(tChar)) then
      pLastFailedCharacter = tChar
      return(0)
    else
      i = 1 + i
    end if
  end repeat
  return(1)
end

on getFailedChar me 
  return(pLastFailedCharacter)
end
