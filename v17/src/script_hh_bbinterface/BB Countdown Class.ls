property pWindowID, pTimeOutID, pEndTime, pDuration, pCountdownMember

on construct me 
  pWindowID = getText("gs_title_countdown")
  pTimeOutID = "bb_countdown_timeout"
  return(1)
end

on deconstruct me 
  return(me.removeGameCountdown())
end

on Refresh me, tTopic, tdata 
  if tTopic = #gamereset then
    return(me.startGameCountdown(tdata.getAt(#time_until_game_start), 0))
  else
    if tTopic = #fullgamestatus_time then
      if tdata.getAt(#state) = #started then
        return(me.removeGameCountdown())
      end if
      return(me.startGameCountdown(tdata.getAt(#time_to_next_state), tdata.getAt(#state_duration) - tdata.getAt(#time_to_next_state)))
    else
      if tTopic = #gamestart then
        return(me.removeGameCountdown())
      end if
    end if
  end if
  return(1)
end

on startGameCountdown me, tSecondsLeft, tSecondsNowElapsed 
  tMSecLeft = tSecondsLeft * 1000
  tDuration = tSecondsLeft + tSecondsNowElapsed * 1000
  if tMSecLeft <= 0 then
    return(0)
  end if
  pDuration = tDuration
  pEndTime = the milliSeconds + tMSecLeft
  if createWindow(pWindowID, "bb_cdown.window") then
    tWndObj = getWindow(pWindowID)
    if me.getGameSystem().getSpectatorModeFlag() then
      tWndObj.getElement("bb_button_cdown_exit").hide()
    else
    end if
    tWndObj.center()
    if me.getGameSystem().getTournamentFlag() then
      tWndObj.getElement("bb_gameprice").hide()
    end if
    tElem = tWndObj.getElement("bb_bar_cntDwn")
    tElem.setProperty(#member, member(getmemnum("bb_scrbar_4")))
    tElem.resizeTo(159, 13)
    tWndObj.lock()
    tWndObj.registerProcedure(#eventProc, me.getID(), #mouseUp)
    tElem = tWndObj.getElement("bb_amount_tickets")
    if tElem = 0 then
      return(0)
    end if
    if me.getGameSystem() = 0 then
      return(0)
    end if
    tNumTickets = string(me.getGameSystem().getNumTickets())
    if tNumTickets.length = 1 then
      tNumTickets = "00" & tNumTickets
    end if
    if tNumTickets.length = 2 then
      tNumTickets = "0" & tNumTickets
    end if
    tElem.setText(tNumTickets)
    me.setBar(0)
    createTimeout(pTimeOutID, 300, #setBar, me.getID())
    return(1)
  else
    return(0)
  end if
end

on setBar me 
  tWndObj = getWindow(pWindowID)
  if tWndObj = 0 then
    return(me.removeGameCountdown())
  end if
  tElem = tWndObj.getElement("bb_bar_cntDwn")
  if the milliSeconds >= pEndTime then
    return(me.removeGameCountdown())
  end if
  tProc = pEndTime - the milliSeconds / float(pDuration)
  tNextWidth = 159 * tProc
  tCurrWidth = tElem.getProperty(#width)
  if tNextWidth < 80 then
    if tNextWidth < 39 then
      tmember = "bb_scrbar_1"
    else
      tmember = "bb_scrbar_3"
    end if
  else
    tmember = "bb_scrbar_4"
  end if
  tSpr = tElem.getProperty(#sprite)
  if pCountdownMember <> tmember then
    pCountdownMember = tmember
    tElem.setProperty(#member, member(getmemnum(tmember)))
  end if
  tElem.resizeBy(integer(tNextWidth) - tCurrWidth, 0)
  return(1)
end

on removeGameCountdown me 
  if timeoutExists(pTimeOutID) then
    removeTimeout(pTimeOutID)
  end if
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  return(1)
end

on eventProc me, tEvent, tSprID, tParam 
  if tSprID = "bb_button_cdown_exit" then
    if me.getGameSystem() = 0 then
      return(0)
    end if
    me.removeGameCountdown()
    return(me.getGameSystem().enterLounge())
  end if
end
