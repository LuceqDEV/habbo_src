property pLogoSpr

on construct me 
  tSession = createObject(#session, getClassVariable("variable.manager.class"))
  tSession.set("client_startdate", the date)
  tSession.set("client_starttime", the long time)
  tSession.set("client_version", getVariable("system.version"))
  tSession.set("client_url", the moviePath)
  tSession.set("client_lastclick", "")
  createObject(#headers, getClassVariable("variable.manager.class"))
  createObject(#cache, getClassVariable("variable.manager.class"))
  createBroker(#Initialize)
  return(me.updateState("load_variables"))
end

on deconstruct me 
  return(me.hideLogo())
end

on showLogo me 
  if memberExists("Logo") then
    tmember = member(getmemnum("Logo"))
    pLogoSpr = sprite(reserveSprite(me.getID()))
    pLogoSpr.ink = 36
    pLogoSpr.blend = 60
    pLogoSpr.member = tmember
    pLogoSpr.locZ = -20000001
    pLogoSpr.loc = point((the stage.rect.width / 2), ((the stage.rect.height / 2) - tmember.height))
  end if
  return TRUE
end

on hideLogo me 
  if (pLogoSpr.ilk = #sprite) then
    releaseSprite(pLogoSpr.spriteNum)
    pLogoSpr = void()
  end if
  return TRUE
end

on updateState me, tstate 
  if (tstate = "load_variables") then
    pState = tstate
    me.showLogo()
    cursor(4)
    if the runMode contains "Plugin" then
      tDelim = the itemDelimiter
      the itemDelimiter = "="
      i = 1
      repeat while i <= 9
        tParam = externalParamValue("sw" & i)
        if not voidp(tParam) then
          if tParam.count(#item) > 1 then
            if (tParam.getProp(#item, 1) = "external.variables.txt") then
              getVariableManager().set("external.variables.txt", tParam.getProp(#item, 2, tParam.count(#item)))
            end if
          end if
        end if
        i = (1 + i)
      end repeat
      the itemDelimiter = tDelim
    end if
    tURL = getVariableManager().get("external.variables.txt")
    tMemName = tURL
    if tURL contains "?" then
      tParamDelim = "&"
    else
      tParamDelim = "?"
    end if
    if the moviePath contains "http://" then
      tURL = tURL & tParamDelim & the milliSeconds
    else
      if tURL contains "http://" then
        tURL = tURL & tParamDelim & the milliSeconds
      end if
    end if
    tMemNum = queueDownload(tURL, tMemName, #field, 1)
    return(registerDownloadCallback(tMemNum, #updateState, me.getID(), "load_params"))
  else
    if (tstate = "load_params") then
      pState = tstate
      dumpVariableField(getVariable("external.variables.txt"))
      removeMember(getVariable("external.variables.txt"))
      if the runMode contains "Plugin" then
        tDelim = the itemDelimiter
        the itemDelimiter = "="
        i = 1
        repeat while i <= 9
          tParam = externalParamValue("sw" & i)
          if not voidp(tParam) then
            if tParam.count(#item) > 1 then
              getVariableManager().set(tParam.getProp(#item, 1), tParam.getProp(#item, 2, tParam.count(#item)))
            end if
          end if
          i = (1 + i)
        end repeat
        the itemDelimiter = tDelim
      end if
      setDebugLevel(getIntVariable("system.debug", 0))
      getStringServices().initConvList()
      puppetTempo(getIntVariable("system.tempo", 30))
      if variableExists("client.reload.url") then
        getObject(#session).set("client_url", getVariable("client.reload.url"))
      end if
      return(me.updateState("load_texts"))
    else
      if (tstate = "load_texts") then
        pState = tstate
        tURL = getVariable("external.texts.txt")
        tMemName = tURL
        if (tMemName = "") then
          return(me.updateState("load_casts"))
        end if
        if tURL contains "?" then
          tParamDelim = "&"
        else
          tParamDelim = "?"
        end if
        if the moviePath contains "http://" then
          tURL = tURL & tParamDelim & the milliSeconds
        else
          if tURL contains "http://" then
            tURL = tURL & tParamDelim & the milliSeconds
          end if
        end if
        tMemNum = queueDownload(tURL, tMemName, #field)
        return(registerDownloadCallback(tMemNum, #updateState, me.getID(), "load_casts"))
      else
        if (tstate = "load_casts") then
          pState = tstate
          tTxtFile = getVariable("external.texts.txt")
          if tTxtFile <> 0 then
            if memberExists(tTxtFile) then
              dumpTextField(tTxtFile)
              removeMember(tTxtFile)
            end if
          end if
          tCastList = []
          i = 1
          repeat while 1
            if not variableExists("cast.entry." & i) then
            else
              tFileName = getVariable("cast.entry." & i)
              tCastList.add(tFileName)
              i = (i + 1)
            end if
          end repeat
          if count(tCastList) > 0 then
            tLoadID = startCastLoad(tCastList, 1)
            if getVariable("loading.bar.active") then
              showLoadingBar(tLoadID, [#buffer:#window])
            end if
            return(registerCastloadCallback(tLoadID, #updateState, me.getID(), "validate_resources"))
          else
            return(me.updateState("init_threads"))
          end if
        else
          if (tstate = "validate_resources") then
            pState = tstate
            tCastList = []
            tNewList = []
            tVarMngr = getVariableManager()
            i = 1
            repeat while 1
              if not tVarMngr.exists("cast.entry." & i) then
              else
                tFileName = tVarMngr.get("cast.entry." & i)
                tCastList.add(tFileName)
                i = (i + 1)
              end if
            end repeat
            if count(tCastList) > 0 then
              repeat while tstate <= undefined
                tCast = getAt(undefined, tstate)
                if not castExists(tCast) then
                  tNewList.add(tCast)
                end if
              end repeat
            end if
            if count(tNewList) > 0 then
              tLoadID = startCastLoad(tNewList, 1)
              if getVariable("loading.bar.active") then
                showLoadingBar(tLoadID, [#buffer:#window])
              end if
              return(registerCastloadCallback(tLoadID, #updateState, me.getID(), "validate_resources"))
            else
              return(me.updateState("init_threads"))
            end if
          else
            if (tstate = "init_threads") then
              pState = tstate
              cursor(0)
              the stage.title = getVariable("client.window.title")
              me.hideLogo()
              getThreadManager().initAll()
              return(executeMessage(#Initialize, "initialize"))
            else
              return(error(me, "Unknown state:" && tstate, #updateState))
            end if
          end if
        end if
      end if
    end if
  end if
end
