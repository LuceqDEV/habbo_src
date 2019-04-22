property pKeyAcceptTime

on construct me 
  receiveUpdate(me.getID())
  return(1)
end

on deconstruct me 
  releaseSprite(me.spriteNum)
  removeUpdate(me.getID())
  return(1)
end

on update me 
  if voidp(pKeyAcceptTime) then
    pKeyAcceptTime = the milliSeconds - 101
  end if
  if the milliSeconds >= pKeyAcceptTime then
    if the keyPressed <> "" then
      me.MykeyDown(the key, the milliSeconds - pKeyAcceptTime)
    else
      me.NotKeyDown(the milliSeconds - pKeyAcceptTime)
    end if
    pKeyAcceptTime = the milliSeconds + 100 - the milliSeconds - pKeyAcceptTime
  end if
end
