property pWindowID, pAlertSpr, pCurrCryID, pAlertTimer, pCurrCryData, pCurrCryNum

on construct me 
  pWindowID = getText("hobba_alert", "Hobba Alert")
  pAlertSpr = void()
  pAlertTimer = 0
  pCurrCryID = ""
  pCurrCryNum = 0
  pCurrCryData = [:]
  return TRUE
end

on deconstruct me 
  removeUpdate(me.getID())
  if windowExists(pWindowID) then
    removeWindow(pWindowID)
  end if
  if (pAlertSpr.ilk = #sprite) then
    releaseSprite(pAlertSpr.spriteNum)
  end if
  pCurrCryID = ""
  pCurrCryNum = 0
  pCurrCryData = [:]
  return TRUE
end

on ShowAlert me 
  if pAlertSpr.ilk <> #sprite then
    pAlertSpr = sprite(reserveSprite(me.getID()))
    pAlertSpr.memberNum = getmemnum("hobba_alert_0")
    pAlertSpr.ink = 8
    pAlertSpr.loc = point(5, 5)
    pAlertSpr.locZ = 200000000
    setEventBroker(pAlertSpr.spriteNum, me.getID() & "_alert_spr")
    pAlertSpr.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
    pAlertSpr.setcursor("cursor.finger")
    pAlertTimer = 0
  end if
  return(receiveUpdate(me.getID()))
end

on hideAlert me 
  if ilk(pAlertSpr, #sprite) then
    pAlertSpr.memberNum = getmemnum("hobba_alert_0")
  end if
  return(removeUpdate(me.getID()))
end

on showCryWnd me 
  if windowExists(pWindowID) then
    tWndObj = getWindow(pWindowID)
  else
    createWindow(pWindowID, "habbo_basic.window")
    tWndObj = getWindow(pWindowID)
    tWndObj.merge("habbo_hobba_alert.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcCryWnd, me.getID(), #mouseUp)
  end if
  tCryDB = me.getComponent().getCryDataBase()
  if (tCryDB.count = 0) then
    return TRUE
  end if
  tCryID = tCryDB.getPropAt(tCryDB.count)
  return(me.fillCryData(tCryID))
end

on hideCryWnd me 
  pCurrCryID = ""
  pCurrCryNum = 0
  pCurrCryData = [:]
  me.hideAlert()
  if windowExists(pWindowID) then
    return(removeWindow(pWindowID))
  else
    return FALSE
  end if
end

on updateCryWnd me 
  return(me.fillCryData(pCurrCryID))
end

on update me 
  pAlertTimer = ((pAlertTimer + 1) mod 4)
  if pAlertTimer <> 0 then
    return()
  end if
  if pAlertSpr.ilk <> #sprite then
    return(removeUpdate(me.getID()))
  end if
  tName = pAlertSpr.member.name
  tNum = integer(tName.getProp(#char, length(tName)))
  tName = tName.getProp(#char, 1, (length(tName) - 1)) & not tNum
  pAlertSpr.memberNum = getmemnum(tName)
end

on fillCryData me, tCryNumOrID 
  if not windowExists(pWindowID) then
    return FALSE
  end if
  tCryDB = me.getComponent().getCryDataBase()
  tCryCount = tCryDB.count
  if (tCryCount = 0) then
    return(error(me, "Hobba alerts not found!", #fillCryData))
  end if
  if stringp(tCryNumOrID) then
    tCryID = tCryNumOrID
    pCurrCryData = tCryDB.getAt(tCryID)
    i = 1
    repeat while i <= tCryCount
      if (tCryDB.getPropAt(i) = tCryID) then
        pCurrCryNum = i
      else
        i = (1 + i)
      end if
    end repeat
    exit repeat
  end if
  if integerp(tCryNumOrID) then
    if tCryNumOrID < 1 or tCryNumOrID > tCryCount then
      return FALSE
    end if
    tCryID = tCryDB.getPropAt(tCryNumOrID)
    pCurrCryData = tCryDB.getAt(tCryID)
    pCurrCryNum = tCryNumOrID
  else
    return(error(me, "String or integer expected:" && tCryNumOrID, #fillCryData))
  end if
  if voidp(pCurrCryData) then
    tNewID = tCryDB.getPropAt(count(tCryDB))
    return(me.fillCryData(tNewID))
  else
    pCurrCryID = tCryID
  end if
  tName = pCurrCryData.getAt(#sender)
  tPlace = pCurrCryData.getAt(#name)
  tMsg = pCurrCryData.getAt(#msg)
  tWndObj = getWindow(pWindowID)
  tWndObj.getElement("hobba_cry_text").setText(tName & "\r" & tPlace & "\r" & "\r" & tMsg)
  tWndObj.getElement("page_num").setText(pCurrCryNum & "/" & tCryCount)
  tWndObj.getElement("hobba_pickedby").setText(getText("hobba_pickedby") && pCurrCryData.picker)
  return TRUE
end

on eventProcCryWnd me, tEvent, tElemID, tParam 
  if (tElemID = "close") then
    return(me.hideCryWnd())
  else
    if (tElemID = "hobba_prev") then
      return(me.fillCryData((pCurrCryNum - 1)))
    else
      if (tElemID = "hobba_next") then
        return(me.fillCryData((pCurrCryNum + 1)))
      else
        if (tElemID = "hobba_seelog") then
          return(openNetPage(pCurrCryData.getAt(#url)))
        else
          if (tElemID = "hobba_pickup") then
            tCryID = pCurrCryID
            me.hideCryWnd()
            return(me.getComponent().send_cryPick(tCryID, 0))
          else
            if (tElemID = "hobba_pickup_go") then
              tCryID = pCurrCryID
              me.hideCryWnd()
              return(me.getComponent().send_cryPick(tCryID, 1))
            else
              return FALSE
            end if
          end if
        end if
      end if
    end if
  end if
end

on eventProcAlert me, tEvent, tElemID, tParam 
  me.showCryWnd()
  return TRUE
end
