property pSprList, pClass, pType, pName, pCustom, pWallX, pWallY, pDirection, pXFactor, pFormatVer, pLocX, pLocY, pLocH, pLocalX, pLocalY, pParentWallLocZ

on construct me 
  pClass = ""
  pName = ""
  pCustom = ""
  pType = ""
  pSprList = []
  pLocX = 0
  pLocY = 0
  pLocH = 0
  pLocZ = 0
  pWallX = 0
  pWallY = 0
  pLocalX = 0
  pLocalY = 0
  pFormatVer = 0
  pDirection = 0
  pParentWallLocZ = void()
  return(1)
end

on deconstruct me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr.spriteNum)
  end repeat
  pParentWallLocZ = void()
  pSprList = []
  return(1)
end

on define me, tProps 
  pClass = tProps.getAt(#class)
  pLocX = tProps.getAt(#x)
  pLocY = tProps.getAt(#y)
  pLocH = tProps.getAt(#h)
  pLocZ = tProps.getAt(#z)
  pLocalX = tProps.getAt(#local_x)
  pLocalY = tProps.getAt(#local_y)
  pWallX = tProps.getAt(#wall_x)
  pWallY = tProps.getAt(#wall_y)
  pFormatVer = tProps.getAt(#formatVersion)
  pDirection = tProps.getAt(#direction)
  pType = tProps.getAt(#type)
  pXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  if pClass = "poster" then
    pName = getText("poster_" & pType & "_name", "poster_" & pType & "_name")
    pCustom = getText("poster_" & pType & "_desc", "poster_" & pType & "_desc")
  else
    if pClass <> "post.it.vd" then
      if pClass = "post.it" then
        pName = getText("wallitem_" & pClass & "_name", "wallitem_" & pClass & "_name")
        pCustom = getText("wallitem_" & pClass & "_desc", "wallitem_" & pClass & "_desc")
      else
        if pClass = "photo" then
          pName = getText("wallitem_" & pClass & "_name", "wallitem_" & pClass & "_name")
          pCustom = getText("wallitem_" & pClass & "_desc", "wallitem_" & pClass & "_desc")
        end if
      end if
      me.solveMembers()
      me.updateLocation()
      return(1)
    end if
  end if
end

on getClass me 
  return(pClass)
end

on setDirection me, tDirection 
  me.pDirection = tDirection
end

on getInfo me 
  tInfo = [:]
  tInfo.setAt(#name, pName)
  tInfo.setAt(#class, pClass)
  tInfo.setAt(#custom, pCustom)
  tInfo.setAt(#smallmember, pClass & "_small")
  if memberExists(pClass & "_small") then
    tInfo.setAt(#image, member(getmemnum(pClass & "_small")).image)
  else
    if pSprList.count > 0 then
      tTestMem2 = name.getProp(#char, 1, length(undefined.name) - 11) & "small"
      if memberExists(tTestMem2) then
        tInfo.setAt(#image, getMember(tTestMem2).image)
      else
        tInfo.setAt(#image, undefined.image)
      end if
    else
      tInfo.setAt(#image, getMember("no_icon_small").image)
    end if
  end if
  return(tInfo)
end

on getLocation me 
  return([pWallX, pWallY])
end

on getCustom me 
  return(pCustom)
end

on getSprites me 
  return(pSprList)
end

on select me 
  return(1)
end

on solveMembers me 
  if pClass <> "post.it" then
    if pClass = "post.it.vd" then
      tMemName = pDirection && pClass
    else
      if pClass = "poster" then
        tMemName = pDirection && pClass && pType
      else
        if pClass = "photo" then
          tMemName = pDirection && pClass
        else
          return(error(me, "Unknown item class:" && pClass, #solveMembers))
        end if
      end if
    end if
    if pXFactor = 32 then
      tMemName = "s_" & tMemName
    end if
    tMemNum = getmemnum(tMemName)
    if tMemNum <> 0 then
      if pSprList.count = 0 then
        tSpr = sprite(reserveSprite(me.getID()))
        tTargetID = getThread(#room).getInterface().getID()
        setEventBroker(tSpr.spriteNum, me.getID())
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.flipH = 1
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
        tSpr.registerProcedure(#eventProcItemObj, tTargetID, #mouseDown)
        tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseEnter)
        tSpr.registerProcedure(#eventProcItemRollOver, tTargetID, #mouseLeave)
        pSprList.add(tSpr)
      else
        tSpr = pSprList.getAt(1)
      end if
      me.updateColor(pType)
      return(1)
    end if
    return(0)
  end if
end

on updateColor me, tHexstr 
  if not listp(pSprList) then
    return(0)
  end if
  if pSprList.count < 1 then
    return(0)
  end if
  tSpr = pSprList.getAt(1)
  tSpr.ink = 8
  if pClass = "post.it" then
    if tHexstr = "" then
      tHexstr = "#FFFF33"
    end if
    tSpr.bgColor = rgb(tHexstr)
    tSpr.color = paletteIndex(255)
  else
    if pClass = "post.it.vd" then
      tHexstr = "FFFFFF"
      tSpr.bgColor = rgb(tHexstr)
      tSpr.color = rgb(0, 0, 0)
    end if
  end if
end

on updateLocation me 
  if pFormatVer = #old then
    tGeometry = getThread(#room).getInterface().getGeometry()
    tScreenLocs = tGeometry.getScreenCoordinate(pLocX, pLocY, ((pLocH * 18) / 32))
    repeat while pFormatVer <= undefined
      tSpr = getAt(undefined, undefined)
      tSpr.locH = tScreenLocs.getAt(1)
      tSpr.locV = tScreenLocs.getAt(2)
    end repeat
  else
    if pFormatVer = #new then
      tWallObjs = getThread(#room).getComponent().getPassiveObject(#list)
      tWallObjFound = 0
      if tWallObjs.count > 0 then
        repeat while pFormatVer <= undefined
          tWallObj = getAt(undefined, undefined)
          if tWallObj.getLocation().getAt(1) = pWallX and tWallObj.getLocation().getAt(2) = pWallY then
            tWallSprites = tWallObj.getSprites()
            repeat while pFormatVer <= undefined
              tSpr = getAt(undefined, undefined)
              tSpr.locH = tWallSprites.getAt(1).locH - undefined.getProp(#regPoint, 1) + pLocalX
              tSpr.locV = tWallSprites.getAt(1).locV - undefined.getProp(#regPoint, 2) + pLocalY
            end repeat
            tWallObjFound = 1
          else
          end if
        end repeat
      end if
      if not tWallObjFound then
        tVisualizer = getThread(#room).getInterface().getRoomVisualizer()
        if not voidp(tVisualizer) then
          if pFormatVer = "leftwall" then
            tPartTypes = [#wallleft]
          else
            if pFormatVer = "rightwall" then
              tPartTypes = [#wallright]
            end if
          end if
          tLounge = tVisualizer.getProperty(#layout)
          if tLounge = "model_a.room" and pWallY = 1 and pClass contains "post.it" and pWallX > 0 and pDirection = #right then
            pWallY = 0
          end if
          tPartProps = tVisualizer.getPartAtLocation(pWallX, pWallY, tPartTypes)
          if ilk(tPartProps) = #propList then
            tWallObjFound = 1
            repeat while pFormatVer <= undefined
              tSpr = getAt(undefined, undefined)
              tMem = member(getmemnum(tPartProps.member))
              tFixNegativeLoc = 0
              if tLounge = "model_b.room" then
                if pWallX = 4 and pWallY = 4 and pLocalX < 0 then
                  tFixNegativeLoc = 1
                end if
              else
                if tLounge = "model_f.room" then
                  if pWallX = 2 and pWallY = 6 and pLocalX < 0 then
                    tFixNegativeLoc = 1
                  end if
                  if pWallX = 6 and pWallY = 2 and pLocalX < 0 then
                    tFixNegativeLoc = 1
                  end if
                else
                  if tLounge = "model_g.room" then
                    if pWallX = 6 and pWallY = 4 and pLocalX < 0 then
                      tFixNegativeLoc = 1
                    end if
                  else
                    if tLounge = "model_h.room" then
                      if pWallX = 4 and pWallY = 8 and pLocalX < 0 then
                        tFixNegativeLoc = 1
                      end if
                    end if
                  end if
                end if
              end if
              if tFixNegativeLoc then
                pLocalX = 32 + pLocalX
              end if
              tSpr.locH = tPartProps.locH - tMem.getProp(#regPoint, 1) + pLocalX
              tSpr.locV = tPartProps.locV - tMem.getProp(#regPoint, 2) + pLocalY
            end repeat
            pParentWallLocZ = tPartProps.getAt(#locZ)
          end if
        end if
      end if
      if not pClass contains "post.it" then
        if not tWallObjFound and getObject(#session).get(#room_owner) then
          tComponent = getThread(#room).getComponent()
          if not tComponent = 0 then
            tComponent.getRoomConnection().send("ADDSTRIPITEM", "new item" && me.getID())
          end if
        end if
      end if
    end if
  end if
  tObjMover = getThread(#room).getInterface().getObjectMover()
  if not voidp(pParentWallLocZ) then
    i = 1
    repeat while i <= pSprList.count
      pSprList.getAt(i).locZ = pParentWallLocZ + 20000 + i
      i = 1 + i
    end repeat
    exit repeat
  end if
  repeat while pFormatVer <= undefined
    tSpr = getAt(undefined, undefined)
    tItemRp = tSpr.regPoint
    tItemR = rect(tSpr.locH, tSpr.locV, tSpr.locH, tSpr.locV) + rect(-tItemRp.getAt(1), -tItemRp.getAt(2), tSpr.width - tItemRp.getAt(1), tSpr.height - tItemRp.getAt(2))
    tPieceUnderSpr = tObjMover.getPassiveObjectIntersectingRect(tItemR).getAt(1)
    if objectp(tPieceUnderSpr) then
      tlocz = tPieceUnderSpr.getSprites().getAt(1).locZ
      if tPieceUnderSpr.getSprites().count > 1 then
        if tPieceUnderSpr.getSprites().getAt(2).locZ > tPieceUnderSpr.getSprites().getAt(1).locZ then
          tlocz = tPieceUnderSpr.getSprites().getAt(2).locZ
        end if
      end if
      tSpr.locZ = tlocz + 2
    else
      tSpr.locZ = getIntVariable("window.default.locz") - 10000
    end if
  end repeat
end
