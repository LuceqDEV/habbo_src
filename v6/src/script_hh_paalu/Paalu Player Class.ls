property pMember, pBuffer, pSprite, pPartList, pName, pDirection, pUpdate, pIsDropping, pDropCounter, pDropMaxCnt, pDropPoint, pDropOffset, pSplashPoint, pZeroLoc, pLocation, pMoveDir, pLocZFix, pBalance, pAction

on construct me 
  pName = ""
  pBalance = 0
  pLocation = 0
  pAction = "std"
  pDirection = 0
  pZeroLoc = point(0, 0)
  pMoveDir = [8, -4]
  pLocZFix = 0
  pPartList = [:]
  pSprite = sprite(reserveSprite(me.getID()))
  pMember = member(createMember(me.getID() && "CanvasX", #bitmap))
  pBuffer = image(40, 58, 32)
  pMember.image = pBuffer.duplicate()
  pMember.regPoint = point(-2, (pMember.height - 10))
  pSprite.member = pMember
  pSprite.visible = 0
  pSprite.ink = 36
  tObj = createObject(#temp, "Paalu Player - Hit")
  pPartList.setAt("fx", tObj)
  tObj = createObject(#temp, "Paalu Player - Hand")
  pPartList.setAt("lh", tObj)
  tObj = createObject(#temp, "Paalu Player - Torso")
  pPartList.setAt("bd", tObj)
  tObj = createObject(#temp, "Paalu Player - Hand")
  pPartList.setAt("rh", tObj)
  tObj = createObject(#temp, "Paalu Player - Head")
  pPartList.setAt("hd", tObj)
  tObj = createObject(#temp, "Paalu Player - Splash")
  pPartList.setAt("sp", tObj)
  pLastTime = the milliSeconds
  pAnimTime = 500
  pUpdate = 1
  pIsDropping = 0
  pDropCounter = 0
  pDropPoint = point(0, 0)
  pDropMaxCnt = 16
  pDropOffset = 0
  pSplashPoint = point(0, 0)
  setEventBroker(pSprite.spriteNum, me.getID())
  pSprite.registerProcedure(#peeloProc, me.getID(), #mouseUp)
  return TRUE
end

on deconstruct me 
  removePrepare(me.getID())
  call(#reset, pPartList)
  call(#deconstruct, pPartList)
  pBuffer = void()
  pPartList = [:]
  releaseSprite(pSprite.spriteNum)
  removeMember(pMember.name)
  return TRUE
end

on define me, tProps 
  pName = tProps.getAt(#name)
  pDirection = tProps.getAt(#dir)
  tUserObj = getThread(#room).getComponent().getUserObject(pName)
  if not tUserObj then
    return(error(me, "User object not found:" && pName & "!", #define))
  end if
  tloc = tUserObj.getLocation()
  tScrLoc = getThread(#room).getInterface().getGeometry().getScreenCoordinate(tloc.getAt(1), tloc.getAt(2), tloc.getAt(3))
  tZeroLoc = getVariableValue("paalu.zero.loc", [354, 382])
  pZeroLoc = point(tZeroLoc.getAt(1), tZeroLoc.getAt(2))
  pSprite.loc = tScrLoc
  pSprite.locZ = (tScrLoc.getAt(3) + 1000)
  pSprite.visible = 1
  tFigureData = tUserObj.getPelleFigure()
  tProps = [#dir:pDirection, #figure:tFigureData, #buffer:pBuffer]
  pPartList.getAt("fx").define("fx", tProps)
  pPartList.getAt("lh").define("lh", tProps)
  pPartList.getAt("bd").define("bd", tProps)
  pPartList.getAt("rh").define("rh", tProps)
  pPartList.getAt("hd").define("hd", tProps)
  pPartList.getAt("sp").define("sp", tProps)
  if (pDirection = 4) then
    pLocZFix = 5010
  else
    pLocZFix = 5020
    tPartList = [:]
    tPartList.setAt("fx", pPartList.getAt("fx"))
    tPartList.setAt("rh", pPartList.getAt("rh"))
    tPartList.setAt("bd", pPartList.getAt("bd"))
    tPartList.setAt("lh", pPartList.getAt("lh"))
    tPartList.setAt("hd", pPartList.getAt("hd"))
    tPartList.setAt("sp", pPartList.getAt("sp"))
    pPartList = tPartList
  end if
  pUpdate = 1
  pIsDropping = 0
  pDropCounter = 0
  pDropMaxCnt = 16
  pDropOffset = [0, 0]
  pDropPoint = point(0, 0)
  tUserObj.hide()
  receivePrepare(me.getID())
  return TRUE
end

on reset me 
  removePrepare(me.getID())
  call(#reset, pPartList)
  tUserObj = getThread(#room).getComponent().getUserObject(pName)
  if objectp(tUserObj) then
    tUserObj.show()
  end if
  pName = ""
  pBalance = 0
  pLocation = 0
  pDirection = 0
  pAction = "std"
  pIsDropping = 0
  pDropCounter = 0
  pDropMaxCnt = 16
  pDropOffset = [0, 0]
  pDropPoint = point(0, 0)
  pBuffer.fill(pBuffer.rect, rgb(255, 255, 255))
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
  pSprite.visible = 0
end

on prepare me 
  if pUpdate then
    call(#prepare, pPartList)
    me.render()
  end if
  if pIsDropping then
    pDropCounter = ((pDropCounter + 2) mod pDropMaxCnt)
    tOffset = (-50 * sin((float(pDropCounter) / 10)))
    pSprite.loc = ((pDropPoint + [0, tOffset]) + pDropOffset)
    pDropPoint = (pDropPoint + pDropOffset)
    if (pDropCounter = 0) then
      pIsDropping = 0
      pSprite.visible = 0
      pPartList.getAt("sp").splash(pSplashPoint, (pSprite.locZ + 10))
    end if
  end if
  pUpdate = not pUpdate
end

on render me 
  pBuffer.fill(pBuffer.rect, rgb(255, 255, 255))
  call(#render, pPartList, pBuffer)
  pMember.image.copyPixels(pBuffer, pBuffer.rect, pBuffer.rect)
end

on status me, tStatus 
  pLocation = tStatus.getAt(#loc)
  pBalance = tStatus.getAt(#bal)
  if (tStatus.getAt(#act) = "-") then
    pAction = "std"
  else
    if (tStatus.getAt(#act) = "X") then
      pAction = "wlk"
    else
      if (tStatus.getAt(#act) = "S") then
        pAction = "wlk"
      else
        if (tStatus.getAt(#act) = "W") then
          pAction = "hit1"
        else
          if (tStatus.getAt(#act) = "E") then
            pAction = "hit2"
          else
            if (tStatus.getAt(#act) = "A") then
              pAction = "std"
            else
              if (tStatus.getAt(#act) = "D") then
                pAction = "std"
              else
                pAction = "std"
              end if
            end if
          end if
        end if
      end if
    end if
  end if
  pSprite.loc = (pZeroLoc + (pLocation * pMoveDir))
  tWorldCrd = getThread(#room).getInterface().getGeometry().getWorldCoordinate(pSprite.locH, pSprite.locV)
  if tWorldCrd <> 0 then
    pSprite.locZ = (getThread(#room).getInterface().getGeometry().getScreenCoordinate(tWorldCrd.getAt(1), tWorldCrd.getAt(2), tWorldCrd.getAt(3)).getAt(3) + pLocZFix)
  else
    pSprite.locZ = -100000
  end if
  tAnimBal = ((pBalance / 20) + 2)
  if tAnimBal < 0 then
    tAnimBal = 0
  end if
  if tAnimBal > 4 then
    tAnimBal = 4
  end if
  call(#status, pPartList, pAction, tAnimBal, (pSprite.loc + [(pSprite.member.width / 2), -4]), pSprite.locZ, tStatus.getAt(#hit))
end

on drop me 
  pIsDropping = 1
  pDropCounter = 0
  pDropPoint = pSprite.loc
  pAction = "drp"
  if pBalance < 0 then
    pDropOffset = [-1, 0]
    pDropMaxCnt = 28
    tAnimBal = 0
    pSplashPoint = (pDropPoint + [-16, -8])
  else
    pDropOffset = [1, 0]
    pDropMaxCnt = 38
    tAnimBal = 4
    pSplashPoint = (pDropPoint + [16, 8])
  end if
  call(#status, pPartList, pAction, tAnimBal, (pSprite.loc + [(pSprite.member.width / 2), -4]), pSprite.locZ, 0)
end

on getBalance me 
  return(pBalance)
end

on setDir me, tdir 
  pDirection = tdir
end

on peeloProc me, tEvent, tSprID, tParam 
  getThread(#room).getInterface().eventProcUserObj(tEvent, pName, tParam)
end
