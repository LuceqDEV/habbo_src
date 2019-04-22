on construct(me)
  pDiscoTimer = 0
  return(1)
  exit
end

on deconstruct(me)
  return(removeUpdate(me.getID()))
  exit
end

on prepare(me)
  return(receiveUpdate(me.getID()))
  exit
end

on update(me)
  if the milliSeconds < pDiscoTimer + 1000 then
    return(1)
  end if
  pDiscoTimer = the milliSeconds
  tThread = getThread(#room)
  if tThread = 0 then
    return(0)
  end if
  tRoomVis = tThread.getInterface().getRoomVisualizer()
  if tRoomVis = 0 then
    return(0)
  end if
  tNum = string(random(7))
  tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("show_discofloor")
  if tSpr <> 0 then
    member.paletteRef = member(getmemnum("chrome_floorpalette" & tNum))
  else
    error(me, "Sprite not found:" && "show_discofloor", #showprogram)
  end if
  exit
end

on showprogram(me, tMsg)
  if listp(tMsg) then
    tDst = tMsg.getAt(#show_dest)
    tCmd = tMsg.getAt(#show_command)
    tNum = tMsg.getAt(#show_params)
    tSpr = getThread(#room).getInterface().getRoomVisualizer().getSprById("show_" & tDst)
    if tSpr <> 0 then
      if me = "fade" then
        tSpr.color = rgb("#" & tNum)
      end if
    else
      error(me, "Sprite not found:" && "show_" & tDst, #showprogram)
    end if
  end if
  exit
end