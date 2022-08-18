property pConvList, pDigits

on construct me 
  pConvList = [:]
  pDigits = "0123456789ABCDEF"
  me.initConvList()
  return TRUE
end

on convertToPropList me, tStr, tDelim 
  tOldDelim = the itemDelimiter
  if (tDelim = void()) then
    tDelim = ","
  end if
  the itemDelimiter = tDelim
  tProps = [:]
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getPropRef(#item, i).getProp(#word, 1, tStr.getPropRef(#item, i).count(#word))
    tProp = tPair.getProp(#char, 1, (offset("=", tPair) - 1))
    tValue = tPair.getProp(#char, (offset("=", tPair) + 1), length(tStr))
    tProps.setAt(tProp.getProp(#word, 1, tProp.count(#word)), tValue.getProp(#word, 1, tValue.count(#word)))
    i = (1 + i)
  end repeat
  the itemDelimiter = tOldDelim
  return(tProps)
end

on convertToLowerCase me, tString 
  tValueStr = ""
  i = 1
  repeat while i <= length(tString)
    tChar = tString.getProp(#char, i)
    tNum = charToNum(tChar)
    if tNum >= 65 and tNum <= 90 then
      tChar = numToChar((tNum + 32))
    end if
    tValueStr = tValueStr & tChar
    i = (1 + i)
  end repeat
  return(tValueStr)
end

on convertToHigherCase me, tString 
  tValueStr = ""
  i = 1
  repeat while i <= length(tString)
    tChar = tString.getProp(#char, i)
    tNum = charToNum(tChar)
    if tNum >= 97 and tNum <= 122 then
      tChar = numToChar((tNum - 32))
    end if
    tValueStr = tValueStr & tChar
    i = (1 + i)
  end repeat
  return(tValueStr)
end

on convertSpecialChars me, tString 
  i = count(pConvList)
  repeat while i >= 1
    tChunkA = pConvList.getPropAt(i)
    tChunkB = pConvList.getAt(tChunkA)
    tTmpStr = tString
    tNewStr = ""
    repeat while tTmpStr contains tChunkA
      tPos = (offset(tChunkA, tTmpStr) - 1)
      if tPos > 0 then
      end if
      (tPos + length(tChunkA)).getPropRef().delete()
    end repeat
    tString = tNewStr
    i = (255 + i)
  end repeat
  return(tString)
end

on convertIntToHex me, tInt 
  if tInt <= 0 then
    return("00")
  else
    repeat while tInt > 0
      tD = (tInt mod 16)
      tInt = (tInt / 16)
      tHexstr = pDigits.getProp(#char, (tD + 1)) & tHexstr
    end repeat
  end if
  if ((length(tHexstr) mod 2) = 1) then
    tHexstr = "0" & tHexstr
  end if
  return(tHexstr)
end

on convertHexToInt me, tHex 
  tBase = 1
  tValue = 0
  repeat while length(tHex) > 0
    tLc = the last char in tHex
    tVl = (offset(tLc, pDigits) - 1)
    tValue = (tValue + (tBase * tVl))
    tBase = (tBase * 16)
  end repeat
  return(tValue)
end

on replaceChars me, tString, tCharA, tCharB 
  if (tCharA = tCharB) then
    return(tString)
  end if
  repeat while offset(tCharA, tString) > 0
  end repeat
  return(tString)
end

on replaceChunks me, tString, tChunkA, tChunkB 
  tStr = ""
  repeat while tString contains tChunkA
    tPos = (offset(tChunkA, tString) - 1)
    if tPos > 0 then
    end if
    (tPos + length(tChunkA)).getPropRef().delete()
  end repeat
  return(tStr)
end

on initConvList me 
  if the platform contains "win" then
    tMachineType = ".win"
  else
    tMachineType = ".mac"
  end if
  pConvList = [:]
  tCharList = getVariableValue("char.conversion" & tMachineType, [:])
  i = 1
  repeat while i <= tCharList.count
    tKey = tCharList.getPropAt(i)
    tVal = tCharList.getAt(i)
    if integerp(integer(tKey)) then
      tKey = numToChar(integer(tKey))
    end if
    if integerp(integer(tVal)) then
      tVal = numToChar(integer(tVal))
    end if
    pConvList.setAt(tKey, tVal)
    i = (1 + i)
  end repeat
  return TRUE
end
