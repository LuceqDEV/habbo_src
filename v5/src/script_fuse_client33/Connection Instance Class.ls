property pMsgStruct, pXtra, pHost, pPort, pLogMode, pConnectionOk, pConnectionSecured, pDecoder, pCommandsPntr, pEncryptionOn, pListenersPntr, pConnectionShouldBeKilled, pLastContent, pLogfield

on construct me 
  pEncryptionOn = 0
  pMsgStruct = getStructVariable("struct.message")
  pMsgStruct.setaProp(#connection, me.getID())
  pDecoder = 0
  pLastContent = ""
  pConnectionShouldBeKilled = 0
  pCommandsPntr = getStructVariable("struct.pointer")
  pListenersPntr = getStructVariable("struct.pointer")
  me.setLogMode(getIntVariable("connection.log.level", 0))
  return TRUE
end

on deconstruct me 
  return(me.disconnect(1))
end

on connect me, tHost, tPort 
  pHost = tHost
  pPort = tPort
  pXtra = new(xtra("Multiuser"))
  pXtra.setNetBufferLimits((16 * 1024), (100 * 1024), 100)
  tErrCode = pXtra.setNetMessageHandler(#xtraMsgHandler, me)
  if (tErrCode = 0) then
    pXtra.connectToNetServer("*", "*", pHost, pPort, "*", 1)
  else
    return(error(me, "Creation of callback failed:" && tErrCode, #connect))
  end if
  pLastContent = ""
  if pLogMode > 0 then
    me.log("Connection initialized:" && me.getID() && pHost && pPort)
  end if
  return TRUE
end

on disconnect me, tControlled 
  if tControlled <> 1 then
    me.forwardMsg(-1)
  end if
  pConnectionShouldBeKilled = 1
  if objectp(pXtra) then
    pXtra.sendNetMessage(0, 0, numToChar(0))
    pXtra.setNetMessageHandler(void(), void())
  end if
  pXtra = void()
  if not tControlled then
    error(me, "Connection disconnected:" && me.getID(), #disconnect)
  end if
  return TRUE
end

on connectionReady me 
  return(pConnectionOk and pConnectionSecured)
end

on setDecoder me, tDecoder 
  if not objectp(tDecoder) then
    return(error(me, "Decoder object expected:" && tDecoder, #setDecoder))
  else
    pDecoder = tDecoder
    return TRUE
  end if
end

on getDecoder me 
  return(pDecoder)
end

on setLogMode me, tMode 
  if tMode.ilk <> #integer then
    return(error(me, "Invalid argument:" && tMode, #setLogMode))
  end if
  pLogMode = tMode
  if (pLogMode = 2) then
    if memberExists("connectionLog.text") then
      pLogfield = member(getmemnum("connectionLog.text"))
    else
      pLogfield = void()
      pLogMode = 1
    end if
  end if
  return TRUE
end

on getLogMode me 
  return(pLogMode)
end

on setEncryption me, tBoolean 
  pEncryptionOn = tBoolean
  pConnectionSecured = 1
  return TRUE
end

on send me, tCmd, tMsg 
  if (tMsg.ilk = #propList) then
    return(me.sendNew(tCmd, tMsg))
  end if
  if not pConnectionOk and objectp(pXtra) then
    return(error(me, "Connection not ready:" && me.getID(), #send))
  end if
  if tMsg.ilk <> #string then
    tMsg = string(tMsg)
  end if
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if (tCmd.ilk = #void) then
    return(error(me, "Unrecognized command!", #send))
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  getObject(#session).set("con_lastsend", tStr && tMsg && "-" && the long time)
  if pEncryptionOn and objectp(pDecoder) then
    tMsg = pDecoder.encipher(tMsg)
  end if
  tLength = 0
  tChar = 1
  repeat while tChar <= length(tMsg)
    tCharNum = charToNum(tMsg.char[tChar])
    tLength = ((tLength + 1) + tCharNum > 255)
    tChar = (1 + tChar)
  end repeat
  tL1 = numToChar(bitOr(bitAnd(tLength, 127), 128))
  tL2 = numToChar(bitOr(bitAnd((tLength / 128), 127), 128))
  tL3 = numToChar(bitOr(bitAnd((tLength / 16384), 127), 128))
  tMsg = tCmd & tL3 & tL2 & tL1 & tMsg
  pXtra.sendNetMessage(0, 0, tMsg)
  return TRUE
end

on sendNew me, tCmd, tParmArr 
  if not pConnectionOk and objectp(pXtra) then
    return(error(me, "Connection not ready:" && me.getID(), #send))
  end if
  tMsg = ""
  tLength = 0
  if listp(tParmArr) then
    i = 1
    repeat while i <= tParmArr.count
      ttype = tParmArr.getPropAt(i)
      tParm = tParmArr.getAt(i)
      if (ttype = #string) then
        tLen = 0
        tChar = 1
        repeat while tChar <= length(tParm)
          tNum = charToNum(tParm.char[tChar])
          tLen = ((tLen + 1) + tNum > 255)
          tChar = (1 + tChar)
        end repeat
        tBy1 = numToChar(bitOr(128, (tLen / 128)))
        tBy2 = numToChar(bitOr(128, bitAnd(127, tLen)))
        tMsg = tMsg & tBy1 & tBy2 & tParm
        tLength = ((tLength + tLen) + 2)
      else
        if (ttype = #integer) then
          tBy1 = numToChar(bitOr(128, (tParm / 32820)))
          tBy2 = numToChar(bitOr(128, (tParm / 16384)))
          tBy3 = numToChar(bitOr(128, (tParm / 128)))
          tBy4 = numToChar(bitOr(128, bitAnd(127, tParm)))
          tMsg = tMsg & tBy1 & tBy2 & tBy3 & tBy4
          tLength = (tLength + 4)
        else
          if (ttype = #short) then
            tBy1 = numToChar(bitOr(128, (tParm / 128)))
            tBy2 = numToChar(bitOr(128, bitAnd(127, tParm)))
            tMsg = tMsg & tBy1 & tBy2
            tLength = (tLength + 2)
          else
            error(me, "Unsupported param type:" && tParm, #send)
          end if
        end if
      end if
      i = (1 + i)
    end repeat
  end if
  if tCmd.ilk <> #integer then
    tStr = tCmd
    tCmd = pCommandsPntr.getaProp(#value).getaProp(tStr)
  end if
  if (tCmd.ilk = #void) then
    return(error(me, "Unrecognized command!", #send))
  end if
  if pLogMode > 0 then
    me.log("<--" && tStr && "(" & tCmd & ")" && tMsg)
  end if
  getObject(#session).set("con_lastsend", tStr && tMsg && "-" && the long time)
  if pEncryptionOn and objectp(pDecoder) then
    tMsg = pDecoder.encipher(tMsg)
    tLength = (tLength * 2)
  end if
  tL1 = numToChar(bitOr(bitAnd(tLength, 127), 128))
  tL2 = numToChar(bitOr(bitAnd((tLength / 128), 127), 128))
  tL3 = numToChar(bitOr(bitAnd((tLength / 16384), 127), 128))
  tMsg = tCmd & tL3 & tL2 & tL1 & tMsg
  pXtra.sendNetMessage(0, 0, tMsg)
  return TRUE
end

on getWaitingMessagesCount me 
  return(pXtra.getNumberWaitingNetMessages())
end

on processWaitingMessages me, tCount 
  if voidp(tCount) then
    tCount = 1
  end if
  return(pXtra.checkNetMessages(tCount))
end

on getProperty me, tProp 
  if (tProp = #xtra) then
    return(pXtra)
  else
    if (tProp = #host) then
      return(pHost)
    else
      if (tProp = #port) then
        return(pPort)
      else
        if (tProp = #decoder) then
          return(me.getDecoder())
        else
          if (tProp = #logmode) then
            return(me.getLogMode())
          else
            if (tProp = #listener) then
              return(pListenersPntr)
            else
              if (tProp = #commands) then
                return(pCommandsPntr)
              else
                if (tProp = #message) then
                  return(pMsgStruct)
                end if
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on setProperty me, tProp, tValue 
  if (tProp = #decoder) then
    return(me.setDecoder(tValue))
  else
    if (tProp = #logmode) then
      return(me.setLogMode(tValue))
    else
      if (tProp = #listener) then
        if (tValue.ilk = #struct) then
          pListenersPntr = tValue
          return TRUE
        else
          return FALSE
        end if
      else
        if (tProp = #commands) then
          if (tValue.ilk = #struct) then
            pCommandsPntr = tValue
            return TRUE
          else
            return FALSE
          end if
        end if
      end if
    end if
  end if
  return FALSE
end

on print me 
  tStr = ""
  if symbolp(me.getID()) then
  end if
  tMsgsList = pListenersPntr.getaProp(#value)
  if listp(tMsgsList) then
    i = 1
    repeat while i <= count(tMsgsList)
      tCallbackList = tMsgsList.getAt(i)
      repeat while "#" <= undefined
        tCallback = getAt(undefined, undefined)
      end repeat
      i = (1 + i)
    end repeat
  end if
  put(tStr & "\r")
  return TRUE
end

on GetIntFrom me, tByStrPtr 
  tByteStr = tByStrPtr.getAt(1)
  tByte = bitAnd(charToNum(tByteStr.char[1]), 63)
  tByCnt = bitOr((bitAnd(tByte, 56) / 8), 0)
  tNeg = bitAnd(tByte, 4)
  tInt = bitAnd(tByte, 3)
  if tByCnt > 1 then
    tPowTbl = [4, 256, 16384, 1048576, 67108864]
    i = 2
    repeat while i <= tByCnt
      tByte = bitAnd(charToNum(tByteStr.char[i]), 63)
      tInt = bitOr((tByte * tPowTbl.getAt((i - 1))), tInt)
      i = (1 + i)
    end repeat
  end if
  if tNeg then
    tInt = -tInt
  end if
  tByStrPtr.setAt(1, tByteStr.getProp(#char, (tByCnt + 1), length(tByteStr)))
  return(tInt)
end

on GetStrFrom me, tByStrPtr 
  tLen = GetIntFrom(tByStrPtr)
  tArr = tByStrPtr.getAt(1)
  tStr = tArr.char[1..tLen]
  tByStrPtr.setAt(1, tArr.char[(tLen + 1)..length(tArr)])
  return(tStr)
end

on xtraMsgHandler me 
  if pConnectionShouldBeKilled <> 0 then
    return FALSE
  end if
  pConnectionOk = 1
  tNewMsg = pXtra.getNetMessage()
  tErrCode = tNewMsg.getaProp(#errorCode)
  tContent = tNewMsg.getaProp(#content)
  if tErrCode <> 0 then
    if pLogMode > 0 then
      me.log("Connection" && me.getID() && "was disconnected")
      me.log("host = " & pHost && ", port = " & pPort)
      me.log(tNewMsg)
    end if
    me.disconnect()
    return FALSE
  end if
  me.msghandler(tContent)
end

on msghandler me, tContent 
  if tContent.ilk <> #string then
    return FALSE
  end if
  if pLastContent.length > 0 then
    tContent = pLastContent & tContent
    pLastContent = ""
  end if
  if tContent.length < 3 then
    pLastContent = pLastContent & tContent
    return()
  end if
  tByte1 = bitAnd(charToNum(tContent.char[2]), 63)
  tByte2 = bitAnd(charToNum(tContent.char[1]), 63)
  tMsgType = bitOr((tByte2 * 64), tByte1)
  tLength = offset("#", tContent)
  if (tLength = 0) then
    pLastContent = tContent
    return()
  end if
  tParams = tContent.char[3..(tLength - 1)]
  tContent = tContent.char[(tLength + 1)..tContent.length]
  me.forwardMsg(tMsgType, tParams)
  if tContent.length > 0 then
    me.msghandler(tContent)
  end if
end

on forwardMsg me, tSubject, tParams 
  if pLogMode > 0 then
    me.log("-->" && tSubject & "\r" & tParams)
  end if
  getObject(#session).set("con_lastreceived", tSubject && "-" && the long time)
  tParams = getStringServices().convertSpecialChars(tParams)
  tCallbackList = pListenersPntr.getaProp(#value).getaProp(tSubject)
  if tCallbackList.ilk <> #list then
    return(error(me, "Listener not found:" && tSubject && "/" && me.getID(), #forwardMsg))
  end if
  tObjMgr = getObjectManager()
  i = 1
  repeat while i <= count(tCallbackList)
    tCallback = tCallbackList.getAt(i)
    tObject = tObjMgr.get(tCallback.getAt(1))
    if tObject <> 0 then
      pMsgStruct.setaProp(#subject, tSubject)
      pMsgStruct.setaProp(#content, tParams)
      call(tCallback.getAt(2), tObject, pMsgStruct)
    else
      error(me, "Listening obj not found, removed:" && tCallback.getAt(1), #forwardMsg)
      tCallbackList.deleteAt(1)
      i = (i - 1)
    end if
    i = (1 + i)
  end repeat
end

on log me, tMsg 
  if (pLogMode = 1) then
    put("[Connection" && me.getID() & "] :" && tMsg)
  else
    if (pLogMode = 2) then
      if ilk(pLogfield, #member) then
      end if
    end if
  end if
end
