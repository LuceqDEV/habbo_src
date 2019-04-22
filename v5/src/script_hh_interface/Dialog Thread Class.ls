property pReadyFlag, pWindowList, pAlertList, pWriterPlain, pWriterLink, pDefWndType

on construct me 
  pWindowList = []
  pAlertList = []
  pDefWndType = "habbo_basic.window"
  pReadyFlag = 0
  registerMessage(#openGeneralDialog, me.getID(), #showDialog)
  registerMessage(#alert, me.getID(), #ShowAlert)
  return(1)
end

on deconstruct me 
  if pReadyFlag then
    repeat while pWindowList <= undefined
      tid = getAt(undefined, undefined)
      if windowExists(tid) then
        removeWindow(tid)
      end if
    end repeat
    repeat while pWindowList <= undefined
      tid = getAt(undefined, undefined)
      if windowExists(tid) then
        removeWindow(tid)
      end if
    end repeat
    if writerExists(pWriterPlain) then
      removeWriter(pWriterPlain)
    end if
    if writerExists(pWriterLink) then
      removeWriter(pWriterLink)
    end if
  end if
  pWindowList = []
  pAlertList = []
  pReadyFlag = 0
  unregisterMessage(#openGeneralDialog, me.getID())
  unregisterMessage(#alert, me.getID())
  return(1)
end

on ShowAlert me, tProps 
  if not pReadyFlag then
    me.buildResources()
  end if
  if voidp(tProps) then
    return(error(me, "Properties for window expected!", #showHideWindow))
  end if
  if stringp(tProps) then
    tProps = [#msg:tProps]
  end if
  tText = getText(tProps.getAt(#msg))
  tWndTitle = getText("win_error", "Notice!")
  tTextImg = getWriter(pWriterPlain).render(tText).duplicate()
  if voidp(tProps.getAt(#id)) then
    tActualID = "alert" && the milliSeconds
  else
    tActualID = "alert" && tProps.getAt(#id)
  end if
  if pAlertList.getOne(tActualID) then
    me.removeDialog(tActualID, pAlertList)
  end if
  if not createWindow(tActualID) then
    return(0)
  end if
  tWndObj = getWindow(tActualID)
  tWndObj.setProperty(#title, tWndTitle)
  tWndObj.merge(pDefWndType)
  if stringp(tProps.getAt(#title)) then
    tWndObj.merge("habbo_alert_a.window")
    tTitle = getText(tProps.getAt(#title), "...")
  else
    tWndObj.merge("habbo_alert_b.window")
    tTitle = ""
  end if
  tElem = tWndObj.getElement("alert_text")
  tWidth = tElem.getProperty(#width)
  tHeight = tElem.getProperty(#height)
  tOffW = 0
  tOffH = 0
  tElem.feedImage(tTextImg)
  if tWidth < tTextImg.width then
    tOffW = tTextImg.width - tWidth
  end if
  if tHeight < tTextImg.height then
    tOffH = tTextImg.height - tHeight
  end if
  tWndObj.resizeBy(tOffW, tOffH)
  tWndObj.center()
  tLocOff = pAlertList.count * 10
  tWndObj.moveBy(tLocOff, tLocOff)
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(#eventProcAlert, me.getID(), #mouseUp)
  pAlertList.add(tActualID)
  if tTitle <> "" then
    if tWndObj.elementExists("alert_title") then
      tWndObj.getElement("alert_title").setText(tTitle)
    end if
  end if
  return(1)
end

on showDialog me, tWndID, tProps 
  if not pReadyFlag then
    me.buildResources()
  end if
  if tWndID <> #alert then
    if tWndID <> "alert" then
      if tWndID <> #modal_alert then
        if tWndID = "modal_alert" then
          return(me.ShowAlert(tProps))
        else
          if tWndID <> #purse then
            if tWndID = "purse" then
              tWndTitle = getText("win_purse", "Purse")
              if windowExists(tWndTitle) then
                return(me.removeDialog(tWndTitle, pWindowList))
              end if
              me.createDialog(tWndTitle, pDefWndType, "habbo_purse.window", #eventProcPurse)
              tWndObj = getWindow(tWndTitle)
              if getObject(#session).exists("user_walletbalance") then
                tCash = getObject(#session).get("user_walletbalance")
              else
                tCash = void()
              end if
              if getObject(#session).get("user_rights").getOne("can_buy_credits") then
                if not voidp(tCash) then
                  tTxt1 = replaceChunks(tWndObj.getElement("purse_cash").getText(), "\\x1", tCash)
                else
                  tTxt1 = getText("loading", "Loading...")
                end if
                tTxt2 = getText("purse_link")
                tLink = getText("url_purselink")
              else
                if not voidp(tCash) then
                  tTxt1 = replaceChunks(getText("purse_cantbuy"), "\\x1", tCash)
                else
                  tTxt1 = getText("loading", "Loading...")
                end if
                tTxt2 = getText("purse_link_subscribe")
                tLink = getText("url_purse_subscribe")
              end if
              if tWndObj.elementExists("purse_cash") then
                tWndObj.getElement("purse_cash").setText(tTxt1)
              end if
              if tWndObj.elementExists("purse_cash") then
                tWndObj.getElement("purse_link_text").setText(tTxt2)
              end if
            else
              if tWndID <> #help then
                if tWndID = "help" then
                  tWndTitle = getText("win_help", "Help")
                  if windowExists(tWndTitle) then
                    return(me.removeDialog(tWndTitle, pWindowList))
                  end if
                  me.createDialog(tWndTitle, pDefWndType, "habbo_help.window", #eventProcHelp)
                  tWndObj = getWindow(tWndTitle)
                  tStr = ""
                  i = 0
                  repeat while 1
                    i = i + 1
                    if textExists("help_txt_" & i) then
                      tStr = tStr & getText("help_txt_" & i) & "\r"
                      next repeat
                    end if
                  end repeat
                  tStr = tStr.getProp(#line, 1, tStr.count(#line) - 1)
                  tLinkImg = getWriter(pWriterLink).render(tStr).duplicate()
                  tWndObj.getElement("link_list").feedImage(tLinkImg)
                  if threadExists(#room) then
                    if not getThread(#room).getComponent().getRoomConnection() then
                      tWndObj.getElement("help_callforhelp_textlink").hide()
                    end if
                  end if
                else
                  if tWndID <> #call_for_help then
                    if tWndID = "call_for_help" then
                      tWndTitle = getText("win_callforhelp", "Alert a Hobba")
                      if windowExists(tWndTitle) then
                        return(me.removeDialog(tWndTitle, pWindowList))
                      end if
                      me.createDialog(tWndTitle, pDefWndType, "habbo_hobba_compose.window", #eventProcCallHelp)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
end

on buildResources me 
  pWriterPlain = "dialog_writer_plain"
  pWriterLink = "dialog_writer_link"
  tFontPlain = getStructVariable("struct.font.plain")
  tFontLink = getStructVariable("struct.font.link")
  tFontPlain.setaProp(#lineHeight, 14)
  tFontLink.setaProp(#lineHeight, 14)
  createWriter(pWriterPlain, tFontPlain)
  createWriter(pWriterLink, tFontLink)
  pReadyFlag = 1
  return(1)
end

on createDialog me, tWndTitle, tWndType, tContentType, tEventProc 
  if not createWindow(tWndTitle, tWndType) then
    return(0)
  end if
  tWndObj = getWindow(tWndTitle)
  tWndObj.merge(tContentType)
  tWndObj.center()
  tWndObj.registerClient(me.getID())
  tWndObj.registerProcedure(tEventProc, me.getID(), #mouseUp)
  pWindowList.add(tWndTitle)
  return(1)
end

on removeDialog me, tWndTitle, tWndList 
  if tWndList.getOne(tWndTitle) then
    tWndList.deleteOne(tWndTitle)
    return(removeWindow(tWndTitle))
  else
    return(error(me, "Attempted to remove unknown dialog:" && tWndTitle, #removeDialog))
  end if
end

on eventProcAlert me, tEvent, tElemID, tParam, tWndID 
  if tEvent = #mouseUp then
    if tElemID <> "alert_ok" then
      if tElemID = "close" then
        return(me.removeDialog(tWndID, pAlertList))
      end if
    end if
  end if
end

on eventProcPurse me, tEvent, tElemID, tParam, tWndID 
  if tEvent = #mouseUp then
    if tElemID <> "close" then
      if tElemID = "purse_close" then
        return(me.removeDialog(tWndID, pWindowList))
      else
        if tElemID = "purse_link_text" then
          tSession = getObject(#session)
          if tSession.get("user_rights").getOne("can_buy_credits") then
            tURL = getText("url_purselink")
          else
            tURL = getText("url_purse_subscribe")
          end if
          tURL = tURL & urlEncode(tSession.get("user_name"))
          if tSession.exists("user_checksum") then
            tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
          end if
          openNetPage(tURL, "_new")
        end if
      end if
    end if
  end if
end

on eventProcHelp me, tEvent, tElemID, tParam, tWndID 
  if tEvent = #mouseUp then
    if tElemID = "link_list" then
      tLineNum = tParam.getAt(2) / 14 + 1
      if textExists("url_help_" & tLineNum) then
        tSession = getObject(#session)
        tURL = getText("url_help_" & tLineNum)
        tName = urlEncode(tSession.get("user_name"))
        if tURL = "" then
          return(1)
        end if
        if tURL contains "\\user_name" then
          tURL = replaceChunks(tURL, "\\user_name", tName)
          if tSession.exists("user_checksum") then
            tURL = tURL & "&sum=" & urlEncode(tSession.get("user_checksum"))
          end if
        end if
        openNetPage(tURL, "_new")
      end if
      return(1)
    else
      if tElemID <> "close" then
        if tElemID = "help_ok" then
          return(me.removeDialog(tWndID, pWindowList))
        else
          if tElemID = "help_callforhelp_textlink" then
            me.removeDialog(tWndID, pWindowList)
            me.showDialog(#call_for_help)
            return(1)
          end if
        end if
      end if
    end if
  end if
end

on eventProcCallHelp me, tEvent, tElemID, tParam, tWndID 
  if tEvent = #mouseUp then
    if tElemID <> "close" then
      if tElemID <> "callhelp_cancel" then
        if tElemID = "alertsent_ok" then
          return(me.removeDialog(tWndID, pWindowList))
        else
          if tElemID = "callhelp_send" then
            tWndObj = getWindow(tWndID)
            executeMessage(#sendCallForHelp, tWndObj.getElement("callhelp_text").getText())
            tWndObj.unmerge()
            tWndObj.merge("habbo_hobba_alertsent.window")
            return(1)
          end if
        end if
      end if
    end if
  end if
end
