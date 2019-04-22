on select(me)
  if not threadExists(#room) then
    return(error(me, "Room thread not found!!!", #select, #major))
  end if
  if not threadExists(#roomkiosk) then
    if FindCastNumber("habbo_kiosk_room") > 0 then
      initThread(FindCastNumber("habbo_kiosk_room"))
    else
      return(error(me, "Room kiosk cast not found!!!", #select, #major))
    end if
  end if
  tUserObj = getThread(#room).getComponent().getOwnUser()
  if not tUserObj then
    return(error(me, "User object not found:" && getObject(#session).GET("user_name"), #select, #major))
  end if
  if me = 4 then
    if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = -1 then
      me.useRoomKiosk()
    else
      getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY + 1])
    end if
  else
    if me = 0 then
      if me.pLocX = tUserObj.pLocX and me.pLocY - tUserObj.pLocY = 1 then
        me.useRoomKiosk()
      else
        getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX, #short:me.pLocY - 1])
      end if
    else
      if me = 2 then
        if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = -1 then
          me.useRoomKiosk()
        else
          getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX + 1, #short:me.pLocY])
        end if
      else
        if me = 6 then
          if me.pLocY = tUserObj.pLocY and me.pLocX - tUserObj.pLocX = 1 then
            me.useRoomKiosk()
          else
            getThread(#room).getComponent().getRoomConnection().send("MOVE", [#short:me.pLocX - 1, #short:me.pLocY])
          end if
        end if
      end if
    end if
  end if
  return(1)
  exit
end

on useRoomKiosk(me)
  getThread(#room).getComponent().getRoomConnection().send("LOOKTO", me.pLocX && me.pLocY)
  executeMessage(#open_roomkiosk)
  exit
end