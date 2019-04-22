on construct(me)
  pDateFormat = "dd-mm-yyyy"
  pUseAMPM = 0
  return(1)
  exit
end

on deconstruct(me)
  return(1)
  exit
end

on define(me, tDateFormat)
  if voidp(tDateFormat) then
    tDateType = "dd-mm-yyyy"
  end if
  pDateFormat = tDateFormat
  exit
end

on getLocalDateFromStr(me, tDateStr)
  if not stringp(tDateStr) then
    return(0)
  end if
  tItemDeLim = the itemDelimiter
  the itemDelimiter = "-"
  if tDateStr.count(#item) < 3 then
    the itemDelimiter = "."
  end if
  tLocalDate = me.getLocalDate(tDateStr.getProp(#item, 1), tDateStr.getProp(#item, 2), tDateStr.getProp(#item, 3))
  the itemDelimiter = tItemDeLim
  return(tLocalDate)
  exit
end

on getLocalDate(me, tDay, tMonth, tYear)
  if voidp(tDay) or voidp(tMonth) or voidp(tYear) then
    return(pDateFormat)
  end if
  tDate = pDateFormat
  tDate = replaceChunks(tDate, "dd", integer(tDay))
  tDate = replaceChunks(tDate, "mm", integer(tMonth))
  tDate = replaceChunks(tDate, "yyyy", integer(tYear))
  return(tDate)
  exit
end