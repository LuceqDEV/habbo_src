on select me 
  if threadExists(#photo) then
    tSprites = me.getSprites()
    if not listp(tSprites) then
      return FALSE
    end if
    if tSprites.count < 1 then
      return FALSE
    end if
    tloc = tSprites.getAt(1).loc
    getThread(#photo).getComponent().openPhoto(me.getID(), tloc.getAt(1), tloc.getAt(2))
    return TRUE
  else
    return FALSE
  end if
end
