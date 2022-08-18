property pTempPassword, pConnectionId

on construct me 
  pConnectionId = getVariable("connection.info.id")
  pTempPassword = []
  return TRUE
end

on deconstruct me 
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return TRUE
end

on showLogin me 
  getObject(#session).set(#userName, "")
  getObject(#session).set(#password, "")
  pTempPassword = []
  if createWindow(#login_a, "habbo_simple.window", 444, 100) then
    tWndObj = getWindow(#login_a)
    tWndObj.merge("login_a.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
  end if
  if createWindow(#login_b, "habbo_simple.window", 444, 230) then
    tWndObj = getWindow(#login_b)
    tWndObj.merge("login_b.window")
    tWndObj.registerClient(me.getID())
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #mouseUp)
    tWndObj.registerProcedure(#eventProcLogin, me.getID(), #keyDown)
    tWndObj.getElement("login_username").setFocus(1)
  end if
  return TRUE
end

on hideLogin me 
  if windowExists(#login_a) then
    removeWindow(#login_a)
  end if
  if windowExists(#login_b) then
    removeWindow(#login_b)
  end if
  return TRUE
end

on tryLogin me 
  if not windowExists(#login_b) then
    return(error(me, "Window not found:" && #login_b, #tryLogin))
  end if
  tWndObj = getWindow(#login_b)
  tUserName = tWndObj.getElement("login_username").getText()
  tPassword = ""
  repeat while pTempPassword <= undefined
    tChar = getAt(undefined, undefined)
  end repeat
  if (tUserName = "") then
    return FALSE
  end if
  if (tPassword = "") then
    return FALSE
  end if
  getObject(#session).set(#userName, tUserName)
  getObject(#session).set(#password, tPassword)
  tWndObj.getElement("login_ok").hide()
  tWndObj.getElement("login_connecting").setProperty(#blend, 100)
  tElem = tWndObj.getElement("login_forgotten")
  tElem.setProperty(#blend, 99)
  tElem.setProperty(#cursor, 0)
  tElem = getWindow(#login_a).getElement("login_createUser")
  tElem.setProperty(#blend, 99)
  tElem.setProperty(#cursor, 0)
  me.blinkConnection()
  getThread(#navigator).getComponent().updateState("connection")
  return TRUE
end

on blinkConnection me 
  if not windowExists(#login_b) then
    return FALSE
  end if
  if timeoutExists(#login_blinker) then
    return FALSE
  end if
  tElem = getWindow(#login_b).getElement("login_connecting")
  if not tElem then
    return FALSE
  end if
  if (getWindow(#login_b).getElement("login_ok").getProperty(#visible) = 1) then
    return FALSE
  end if
  tElem.setProperty(#visible, not tElem.getProperty(#visible))
  return(createTimeout(#login_blinker, 500, #blinkConnection, me.getID(), void(), 1))
end

on showUserFound me 
  if windowExists(#login_b) then
    getWindow(#login_b).unmerge()
  else
    createWindow(#login_b, "habbo_simple.window", 444, 230)
  end if
  tWndObj = getWindow(#login_b)
  tWndObj.merge("login_c.window")
  tTxt = tWndObj.getElement("login_c_welcome").getText()
  tTxt = tTxt && getObject(#session).get("user_name")
  tWndObj.getElement("login_c_welcome").setText(tTxt)
  if threadExists(#registration) then
    tBuffer = getThread(#registration).getComponent().createTemplateHuman("h", 3, "wave")
    tWndObj.getElement("login_preview").setProperty(#buffer, tBuffer)
    me.delay(800, #myHabboSmile)
  else
    me.hideLogin()
  end if
  return TRUE
end

on myHabboSmile me 
  if threadExists(#registration) then
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "gest", "temp sml")
  end if
  me.delay(1200, #stopWaving)
end

on stopWaving me 
  if threadExists(#registration) then
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "reset")
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "gest", "temp sml")
  end if
  if threadExists(#registration) then
    getThread(#registration).getComponent().createTemplateHuman("h", 3, "remove")
  end if
  me.delay(400, #hideLogin)
end

on forgottenpw me 
  if not createWindow(#login_b, "habbo_simple.window", 444, 230) then
    return FALSE
  end if
  getWindow(#login_b).merge("habbo_forgottenpw.window")
  getWindow(#login_b).registerProcedure(#eventProcForgottenpw, me.getID(), #mouseUp)
  if not connectionExists(pConnectionId) then
    getThread(#navigator).getComponent().updateState("connection")
  end if
  getThread(#navigator).getComponent().updateState("forgottenPassWord")
  return TRUE
end

on eventProcLogin me, tEvent, tSprID, tParam 
  if (tEvent = #mouseUp) then
    if (tEvent = "login_ok") then
      me.tryLogin()
      return TRUE
    else
      if (tEvent = "login_createUser") then
        if (getWindow(#login_a).getElement(tSprID).getProperty(#blend) = 100) then
          if windowExists(#login_a) then
            removeWindow(#login_a)
          end if
          if windowExists(#login_b) then
            removeWindow(#login_b)
          end if
          executeMessage(#show_registration)
          return TRUE
        end if
      else
        if (tEvent = "login_forgotten") then
          if (getWindow(#login_b).getElement(tSprID).getProperty(#blend) = 100) then
            return(me.forgottenpw())
          end if
        end if
      end if
    end if
  else
    if (tEvent = #keyDown) then
      if (the keyCode = 36) then
        me.tryLogin()
        return TRUE
      end if
      if (tEvent = "login_password") then
        if (tEvent = 48) then
          return FALSE
        else
          if (tEvent = 49) then
            return TRUE
          else
            if (tEvent = 51) then
              if pTempPassword.count > 0 then
                pTempPassword.deleteAt(pTempPassword.count)
              end if
            else
              if (tEvent = 117) then
                pTempPassword = []
              else
                tValidKeys = getVariable("permitted.name.chars", "1234567890qwertyuiopasdfghjklzxcvbnm_-=+?!@<>:.,")
                tASCII = charToNum(the key)
                if tASCII > 31 and tASCII < 128 then
                  if tValidKeys contains the key or (tValidKeys = "") then
                    if pTempPassword.count < getIntVariable("pass.length.max", 36) then
                      pTempPassword.append(the key)
                    end if
                  end if
                end if
              end if
            end if
          end if
        end if
        tStr = ""
        repeat while tEvent <= tSprID
          tChar = getAt(tSprID, tEvent)
        end repeat
        getWindow(#login_b).getElement(tSprID).setText(tStr)
        the selStart = pTempPassword.count
        the selEnd = pTempPassword.count
        return TRUE
      end if
    end if
  end if
  return FALSE
end

on eventProcForgottenpw me, tEvent, tSprID, tParm 
  if (tEvent = #mouseUp) then
    if (tSprID = "forgottenpw_back") then
      getThread(#navigator).getComponent().updateState("login")
    else
      if (tSprID = "forgottenpw_emailpw") then
        tName = getWindow(#login_b).getElement("forgottenpw_name").getText()
        tMail = getWindow(#login_b).getElement("forgottenpw_email").getText()
        if connectionExists(pConnectionId) then
          getConnection(pConnectionId).send(#info, "SEND_USERPASS_TO_EMAIL" && tName && tMail)
          removeConnection(pConnectionId)
        else
          error(me, "Couldn't find connection:" && pConnectionId, #eventProcForgottenpw)
        end if
        if not createWindow(#login_b, "habbo_simple.window", 444, 230) then
          return FALSE
        end if
        getWindow(#login_b).merge("habbo_forgotten2.window")
        getWindow(#login_b).registerProcedure(#eventProcForgottenpw, me.getID(), #mouseUp)
      else
        if (tSprID = "forgottenpw_ok") then
          getThread(#navigator).getComponent().updateState("login")
        end if
      end if
    end if
  end if
end
