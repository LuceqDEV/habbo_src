property pToggleParts

on prepare me, tdata 
  pToggleParts = ["0":[[#sprite:"c", #member:void()]], "1":[[#sprite:"c", #member:"0"]]]
  me.setState(tdata.getAt(#stuffdata))
  return(1)
end

on updateStuffdata me, tValue 
  me.setState(tValue)
end

on setState me, tValue 
  if not listp(pToggleParts) then
    return(0)
  end if
  if tValue = void() then
    tValue = pToggleParts.getPropAt(1)
  end if
  tValue = integer(tValue)
  tPartStates = pToggleParts.getAt(string(tValue))
  if not listp(tPartStates) then
    tPartStates = pToggleParts.getAt(1)
    tValue = integer(pToggleParts.getPropAt(1))
  end if
  pState = tValue
  repeat while tPartStates <= undefined
    tPart = getAt(undefined, tValue)
    tPartId = tPart.sprite
    tmember = tPart.member
    if tmember <> void() then
      me.switchMember(tPartId, tmember)
    end if
    me.setPartVisible(tPartId, tmember <> void())
  end repeat
  return(1)
end

on select me 
  if the doubleClick then
    getThread(#room).getComponent().getRoomConnection().send("USEFURNITURE", [#integer:integer(me.getID()), #integer:0])
  end if
  return(1)
end

on switchMember me, tPart, tNewMem 
  tSprNum = charToNum(tPart) - charToNum("a") - 1
  if me.count(#pSprList) < tSprNum or tSprNum <= 0 then
    return(0)
  end if
  tName = member.name
  tName = tName.getProp(#char, 1, tName.length - 1) & tNewMem
  if memberExists(tName) then
    tmember = member(getmemnum(tName))
    me.getPropRef(#pSprList, tSprNum).castNum = tmember.number
    me.getPropRef(#pSprList, tSprNum).width = tmember.width
    me.getPropRef(#pSprList, tSprNum).height = tmember.height
  end if
  return(1)
end

on setPartVisible me, tPart, tstate 
  tSprNum = charToNum(tPart) - charToNum("a") - 1
  if me.count(#pSprList) < tSprNum or tSprNum <= 0 then
    return(0)
  end if
  me.getPropRef(#pSprList, tSprNum).visible = tstate
  return(1)
end
