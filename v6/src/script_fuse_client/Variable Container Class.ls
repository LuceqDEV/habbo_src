on construct me 
  me.pItemList = [:]
  me.pItemList.sort()
  return TRUE
end

on deconstruct me 
  me.pItemList = [:]
  return TRUE
end

on create me, tVariable, tValue 
  if not stringp(tVariable) and not symbolp(tVariable) then
    return(error(me, "String or symbol expected:" && tVariable, #create))
  end if
  me.setProp(#pItemList, tVariable, tValue)
  return TRUE
end

on set me, tVariable, tValue 
  if not stringp(tVariable) and not symbolp(tVariable) then
    return(error(me, "String or symbol expected:" && tVariable, #set))
  end if
  me.setProp(#pItemList, tVariable, tValue)
  return TRUE
end

on get me, tVariable, tDefault 
  tValue = me.getProp(#pItemList, tVariable)
  if voidp(tValue) then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    else
      tValue = 0
    end if
    error(me, tError, #get)
  end if
  return(tValue)
end

on getInt me, tVariable, tDefault 
  tValue = integer(me.getProp(#pItemList, tVariable))
  if not integerp(tValue) then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    end if
    error(me, tError, #getInt)
  end if
  return(tValue)
end

on getValue me, tVariable, tDefault 
  tValue = value(me.getProp(#pItemList, tVariable))
  if voidp(tValue) then
    tError = "Variable not found:" && "\"" & tVariable & "\""
    if not voidp(tDefault) then
      tValue = tDefault
      tError = tError & "\r" & "Using given default:" && tDefault
    end if
    error(me, tError, #getValue)
  end if
  return(tValue)
end

on remove me, tVariable 
  return(me.pItemList.deleteProp(tVariable))
end

on exists me, tVariable 
  return(not voidp(me.getProp(#pItemList, tVariable)))
end

on dump me, tField, tDelimiter 
  tStr = field(0)
  tDelim = the itemDelimiter
  if voidp(tDelimiter) then
    tDelimiter = "\r"
  end if
  the itemDelimiter = tDelimiter
  i = 1
  repeat while i <= tStr.count(#item)
    tPair = tStr.getProp(#item, i)
    if tPair.getPropRef(#word, 1).getProp(#char, 1) <> "#" and tPair <> "" then
      the itemDelimiter = "="
      tProp = tPair.getPropRef(#item, 1).getProp(#word, 1, tPair.getPropRef(#item, 1).count(#word))
      tValue = tPair.getProp(#item, 2, tPair.count(#item))
      tValue = tValue.getProp(#word, 1, tValue.count(#word))
      if not tValue contains space() then
        if (tValue.getProp(#char, 1) = "#") then
          tValue = symbol(chars(tValue, 2, length(tValue)))
        else
          if integerp(integer(tValue)) then
            if (length(string(integer(tValue))) = length(tValue)) then
              tValue = integer(tValue)
            end if
          end if
        end if
      else
        if floatp(float(tValue)) then
          tValue = float(tValue)
        end if
      end if
      if stringp(tValue) then
        j = 1
        repeat while j <= length(tValue)
          if (tField = 228) then
          else
            if (tField = 246) then
            end if
          end if
          j = (1 + j)
        end repeat
      end if
      me.setProp(#pItemList, tProp, tValue)
      the itemDelimiter = tDelimiter
    end if
    i = (1 + i)
  end repeat
  the itemDelimiter = tDelim
  return TRUE
end

on clear me 
  me.pItemList = [:]
end
