property pLastStartTime, pID, pAccumulatedTime

on new me 
  pID = void()
  pLastStartTime = void()
  pAccumulatedTime = 0
  return(me)
end

on setID me, tName 
  pID = tName
end

on start me 
  tTime = the milliSeconds
  pLastStartTime = tTime
end

on finish me 
  if voidp(pLastStartTime) then
    return(error(me, "Cannot finish task " & pID & " because it has not been started yet!", #finish))
  end if
  tTime = the milliSeconds
  pAccumulatedTime = pAccumulatedTime + tTime - pLastStartTime
  pLastStartTime = void()
end

on getTime me 
  return(pAccumulatedTime)
end

on print me, tText 
  if voidp(tText) then
    put(pAccumulatedTime && "ms" && ":" && pID)
    return(void())
  else
    return(tText)
  end if
end

on handlers  
  return([])
end
