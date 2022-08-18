property pXFactor, pSprList, pClass, pCustom, pLocX, pLocY, pLocH, pDirection, pPartColors, pDimensions, pAnimFrame, pLoczList, pCorrectLocZ

on construct me 
  pClass = ""
  pCustom = ""
  pSprList = []
  pDirection = []
  pDimensions = []
  pLoczList = []
  pPartColors = []
  pAnimFrame = 0
  pLocX = 0
  pLocY = 0
  pLocH = 0
  pAltitude = 0
  pXFactor = getThread(#room).getInterface().getGeometry().pXFactor
  if (pXFactor = 32) then
    pCorrectLocZ = 0
  else
    pCorrectLocZ = 1
  end if
  return TRUE
end

on deconstruct me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    releaseSprite(tSpr.spriteNum)
  end repeat
  pSprList = []
  return TRUE
end

on define me, tdata 
  pClass = tdata.getAt(#class)
  pDirection = tdata.getAt(#direction)
  pDimensions = tdata.getAt(#dimensions)
  pLocX = tdata.getAt(#x)
  pLocY = tdata.getAt(#y)
  pLocH = tdata.getAt(#h)
  me.solveColors(tdata.getAt(#colors))
  if (me.solveMembers() = 0) then
    return FALSE
  end if
  if (me.prepare(tdata.getAt(#props)) = 0) then
    return FALSE
  end if
  me.updateLocation()
  return TRUE
end

on prepare me, tdata 
  return TRUE
end

on getInfo me 
  tInfo = [:]
  tInfo.setAt(#name, pClass)
  tInfo.setAt(#class, pClass)
  tInfo.setAt(#custom, pCustom)
  return(tInfo)
end

on getLocation me 
  return([pLocX, pLocY, pLocH])
end

on getDirection me 
  return(pDirection)
end

on getSprites me 
  return(pSprList)
end

on select me 
  return FALSE
end

on solveColors me, tpartColors 
  if voidp(tpartColors) then
    tpartColors = "0,0,0"
  end if
  pPartColors = []
  tDelim = the itemDelimiter
  the itemDelimiter = ","
  t = 1
  repeat while t <= tpartColors.count(#item)
    pPartColors.add(string(tpartColors.getProp(#item, t)))
    t = (1 + t)
  end repeat
  j = pPartColors.count
  repeat while j <= 4
    pPartColors.add("*ffffff")
    j = (1 + j)
  end repeat
  the itemDelimiter = tDelim
end

on solveInk me, tPart 
  if not memberExists(pClass & ".props") then
    return(8)
  end if
  tPropList = value(field(0))
  if voidp(tPropList.getAt(tPart)) then
    return(8)
  end if
  if not voidp(tPropList.getAt(tPart).getAt(#ink)) then
    return(tPropList.getAt(tPart).getAt(#ink))
  end if
  return(8)
end

on solveBlend me, tPart 
  if not memberExists(pClass & ".props") then
    return(100)
  end if
  tPropList = value(field(0))
  if voidp(tPropList.getAt(tPart)) then
    return(100)
  end if
  if not voidp(tPropList.getAt(tPart).getAt(#blend)) then
    return(tPropList.getAt(tPart).getAt(#blend))
  end if
  return(100)
end

on solveLocZ me, tPart, tdir 
  if not memberExists(pClass & ".props") then
    return FALSE
  end if
  tPropList = value(field(0))
  if voidp(tPropList.getAt(tPart)) then
    return FALSE
  end if
  if voidp(tPropList.getAt(tPart).getAt(#zshift)) then
    return FALSE
  end if
  if tPropList.getAt(tPart).getAt(#zshift).count <= tdir then
    tdir = 0
  end if
  return(tPropList.getAt(tPart).getAt(#zshift).getAt((tdir + 1)))
end

on solveMembers me 
  if listp(pDirection) then
    tTmpDirection = pDirection.duplicate()
  else
    tTmpDirection = pDirection
  end if
  if pSprList.count > 0 then
    repeat while pSprList <= undefined
      tSpr = getAt(undefined, undefined)
      releaseSprite(tSpr.spriteNum)
    end repeat
    pSprList = []
  end if
  tMemNum = 1
  i = charToNum("a")
  j = 1
  repeat while tMemNum > 0
    if (pClass = "null") then
      opopop = 0
    end if
    tFound = 0
    repeat while (tFound = 0)
      tMemNameA = pClass & "_" & numToChar(i) & "_" & "0"
      if listp(pDimensions) then
        tMemNameA = tMemNameA & "_" & pDimensions.getAt(1) & "_" & pDimensions.getAt(2)
      end if
      if not voidp(tTmpDirection) then
        if count(tTmpDirection) >= j then
          tMemName = tMemNameA & "_" & tTmpDirection.getAt(j) & "_" & pAnimFrame
        else
          tMemName = tMemNameA & "_" & tTmpDirection.getAt(1) & "_" & pAnimFrame
        end if
      else
        tMemName = tMemNameA & "_" & pAnimFrame
      end if
      tMemNum = getmemnum(tMemName)
      tOldMemName = tMemName
      if (tMemNum = 0) then
        tMemName = tMemNameA & "_0_" & pAnimFrame
        tMemNum = getmemnum(tMemName)
      end if
      if (tMemNum = 0) and (j = 1) then
        tFound = 0
        if listp(pDirection) then
          tdir = 1
          repeat while tdir <= tTmpDirection.count
            tTmpDirection.setAt(tdir, integer((tTmpDirection.getAt(tdir) + 1)))
            tdir = (1 + tdir)
          end repeat
          if (tTmpDirection.getAt(1) = 8) then
            return FALSE
          end if
        else
          return(error(me, "No good object:" && pClass, #solveMembers))
        end if
        next repeat
      end if
      tFound = 1
    end repeat
    if tMemNum <> 0 then
      if count(pSprList) >= j then
        tSpr = pSprList.getAt(j)
      else
        tSpr = sprite(reserveSprite(me.getID()))
        pSprList.add(tSpr)
        setEventBroker(tSpr.spriteNum, me.getID())
        tTargetID = getThread(#room).getInterface().getID()
        tSpr.registerProcedure(#eventProcPassiveObj, tTargetID, #mouseDown)
      end if
      if not voidp(pDirection) then
        if count(pDirection) >= j then
          pLoczList.add(me.solveLocZ(numToChar(i), pDirection.getAt(j)))
        else
          pLoczList.add(me.solveLocZ(numToChar(i), void()))
        end if
      else
        pLoczList.add(me.solveLocZ(numToChar(i), void()))
      end if
      if not voidp(tSpr) and tSpr <> sprite(0) then
        if tMemNum < 1 then
          tMemNum = abs(tMemNum)
          tSpr.rotation = 180
          tSpr.skew = 180
        end if
        tSpr.castNum = tMemNum
        tSpr.width = member(tMemNum).width
        tSpr.height = member(tMemNum).height
        tSpr.ink = me.solveInk(numToChar(i))
        tSpr.blend = me.solveBlend(numToChar(i))
        if j <= pPartColors.count then
          if (string(pPartColors.getAt(j)).getProp(#char, 1) = "#") then
            tSpr.bgColor = rgb(pPartColors.getAt(j))
          else
            tSpr.bgColor = paletteIndex(integer(pPartColors.getAt(j)))
          end if
        end if
      else
        return(error(me, "Out of sprites!!!", #solveMembers))
      end if
    end if
    i = (i + 1)
    j = (j + 1)
  end repeat
  tShadowName = pClass & "_sd"
  if listp(pDirection) then
    tShadowName = tShadowName & "_" & pDirection.getAt(1)
  end if
  tShadowNum = getmemnum(tShadowName)
  if not tShadowNum and listp(tTmpDirection) then
    tShadowNum = getmemnum(pClass & "_sd")
  end if
  if tShadowNum <> 0 then
    tSpr = sprite(reserveSprite(me.getID()))
    pSprList.add(tSpr)
    pLoczList.add(-4000)
    if tShadowNum < 0 then
      tShadowNum = abs(tShadowNum)
      tSpr.rotation = 180
      tSpr.skew = 180
      tSpr.locH = (tSpr.locH + pXFactor)
    end if
    tSpr.castNum = tShadowNum
    tSpr.width = member(tShadowNum).width
    tSpr.height = member(tShadowNum).height
    tSpr.ink = me.solveInk("sd")
    tSpr.blend = me.solveBlend("sd")
    if (tSpr.blend = 100) then
      tSpr.blend = 20
    end if
  end if
  if pSprList.count > 0 then
    return TRUE
  else
    return(error(me, "Couldn't define members:" && pClass, #solveMembers))
  end if
end

on updateLocation me 
  tScreenLocs = getThread(#room).getInterface().getGeometry().getScreenCoordinate(pLocX, pLocY, pLocH)
  i = 0
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    i = (i + 1)
    tSpr.locH = tScreenLocs.getAt(1)
    tSpr.locV = tScreenLocs.getAt(2)
    if (tSpr.rotation = 180) then
      tSpr.locH = (tSpr.locH + pXFactor)
    end if
    if i <= pLoczList.count then
      tZ = pLoczList.getAt(i)
    else
      tZ = 0
    end if
    if pCorrectLocZ then
      tSpr.locZ = ((tScreenLocs.getAt(3) + (pLocH * 1000)) + tZ)
    else
      tSpr.locZ = (tScreenLocs.getAt(3) + tZ)
    end if
  end repeat
end

on show me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    tSpr.visible = 1
  end repeat
end

on hide me 
  repeat while pSprList <= undefined
    tSpr = getAt(undefined, undefined)
    tSpr.visible = 0
  end repeat
end
