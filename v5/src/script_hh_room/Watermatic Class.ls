property pTokenList

on prepare me 
  tTokenList = getText("obj_" & me.pClass, "water")
  pTokenList = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  i = 1
  repeat while i <= tTokenList.count(#item)
    pTokenList.add(tTokenList.getPropRef(#item, i).getProp(#word, 1, tTokenList.getPropRef(#item, i).count(#word)))
    i = (1 + i)
  end repeat
  the itemDelimiter = tDelim
  return TRUE
end

on select me 
  if not threadExists(#room) then
    return(error(me, "Room thread not found!!!", #select))
  end if
  tUserObj = getThread(#room).getComponent().getUserObject(getObject(#session).get("user_name"))
  if not tUserObj then
    return(error(me, "User object not found:" && getObject(#session).get("user_name"), #select))
  end if
  if (me.getProp(#pDirection, 1) = 4) then
    if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = -1) then
      me.giveDrink()
    else
      getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.pLocX && (me.pLocY + 1))
    end if
  else
    if (me.getProp(#pDirection, 1) = 0) then
      if (me.pLocX = tUserObj.pLocX) and ((me.pLocY - tUserObj.pLocY) = 1) then
        me.giveDrink()
      else
        getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && me.locX && (me.pLocY - 1))
      end if
    else
      if (me.getProp(#pDirection, 1) = 2) then
        if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = -1) then
          me.giveDrink()
        else
          getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && (me.pLocX + 1) && me.pLocY)
        end if
      else
        if (me.getProp(#pDirection, 1) = 6) then
          if (me.pLocY = tUserObj.pLocY) and ((me.pLocX - tUserObj.pLocX) = 1) then
            me.giveDrink()
          else
            getThread(#room).getComponent().getRoomConnection().send(#room, "Move" && (me.pLocX - 1) && me.pLocY)
          end if
        end if
      end if
    end if
  end if
  return TRUE
end

on giveDrink me 
  getThread(#room).getComponent().getRoomConnection().send(#room, "LOOKTO" && me.pLocX && me.pLocY)
  getThread(#room).getComponent().getRoomConnection().send(#room, "CarryDrink" && pTokenList.getAt(random(pTokenList.count)))
end
