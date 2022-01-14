property pMember2D, pMember3D, pQuadLeft, pQuadRight, pScrollFrmsMem, pscrollDescMem, pInitFlag, pLastUpdate, pStepForward, pShowStep, pStepAction, pStepVariable, pScrollPhase, pLastPauseStart

on construct me 
  pMember2D = member(getmemnum("screen2d"))
  pMember3D = member(getmemnum("screen3d"))
  pScrollFrmsMem = void()
  pscrollDescMem = void()
  pShowStep = 0
  pLastPauseStart = the milliSeconds
  pStepAction = "pause"
  pStepVariable = 0
  pStepForward = 1
  pScrollPhase = 0
  pLastUpdate = the milliSeconds
  pQuadLeft = [point(0, 0), point(104, 52), point(104, 98), point(0, 46)]
  pQuadRight = [point(104, 52), point(208, 0), point(208, 46), point(104, 98)]
  pInitFlag = 0
  pMember2D.image.fill(pMember2D.rect, rgb(0, 0, 0))
  pMember3D.image.copyPixels(pMember2D.image, pQuadLeft, rect(0, 0, 52, 23), [#ink:0])
  pMember3D.image.copyPixels(pMember2D.image, pQuadRight, rect(52, 0, 104, 23), [#ink:0])
  return(me.loadResources())
end

on deconstruct me 
  if not voidp(pScrollFrmsMem) then
    removeMember(pScrollFrmsMem.name)
  end if
  if not voidp(pscrollDescMem) then
    removeMember(pscrollDescMem.name)
  end if
  return TRUE
end

on loadResources me 
  if not variableExists("entry.scroll.frms") then
    return FALSE
  end if
  if not variableExists("entry.scroll.desc") then
    return FALSE
  end if
  tImgUrl = getVariable("entry.scroll.frms")
  tTxtUrl = getVariable("entry.scroll.desc")
  tImgMemName = tImgUrl
  tTxtMemName = tTxtUrl
  tMemNum = queueDownload(tImgUrl, tImgMemName, #bitmap)
  pScrollFrmsMem = member(tMemNum)
  tMemNum = queueDownload(tTxtUrl, tTxtMemName, #field)
  pscrollDescMem = member(tMemNum)
  return TRUE
end

on update me 
  if not pInitFlag then
    if voidp(pScrollFrmsMem) then
      return FALSE
    end if
    if voidp(pscrollDescMem) then
      return FALSE
    end if
    if getDownLoadPercent(pScrollFrmsMem.name) < 1 then
      return FALSE
    end if
    if getDownLoadPercent(pscrollDescMem.name) < 1 then
      return FALSE
    end if
    pInitFlag = 1
  end if
  if (the milliSeconds - pLastUpdate) > 66 then
    if (pStepForward = 1) then
      pShowStep = (pShowStep + 1)
      if pShowStep > pscrollDescMem.text.count(#line) then
        pShowStep = 1
      end if
      tDelim = the itemDelimiter
      the itemDelimiter = ","
      tLine = pscrollDescMem.text.getProp(#line, pShowStep)
      pStepAction = tLine.getProp(#item, 1)
      pStepVariable = tLine.getProp(#item, 2)
      the itemDelimiter = tDelim
      if (pStepAction = "pause") then
        pLastPauseStart = the milliSeconds
      end if
      pStepForward = 0
    end if
    if (pStepAction = "show") then
      tTemp = ((pStepVariable - 1) * 104)
      pMember2D.image.copyPixels(pScrollFrmsMem.image, rect(0, 0, 104, 23), rect(tTemp, 0, (tTemp + 104), 23), [#ink:0])
      pStepForward = 1
    else
      if (pStepAction = "scroll") then
        pMember2D.image.copyPixels(pMember2D.image, rect(0, 0, 102, 23), rect(2, 0, 104, 23), [#ink:0])
        tTemp = (((pStepVariable - 1) * 104) + pScrollPhase)
        pMember2D.image.copyPixels(pScrollFrmsMem.image, rect(102, 0, 104, 23), rect(tTemp, 0, (tTemp + 2), 23), [#ink:0])
        pScrollPhase = (pScrollPhase + 2)
        if pScrollPhase > 103 then
          pScrollPhase = 0
          pStepForward = 1
        end if
      else
        if (pStepAction = "pause") then
          if the milliSeconds > (pLastPauseStart + (pStepVariable * 1000)) then
            pStepForward = 1
          end if
        else
          if (pStepAction = "wipe") then
            tTempImage = image(104, 23, 8)
            tTempImage.copyPixels(pMember2D.image, rect(0, 0, 104, 23), rect(0, 0, 104, 23), [#ink:0])
            pMember2D.image.copyPixels(tTempImage, rect(0, 1, 104, 23), rect(0, 0, 104, 22), [#ink:0])
            tTemp = ((pStepVariable - 1) * 104)
            pMember2D.image.copyPixels(pScrollFrmsMem.image, rect(0, 0, 104, 1), rect(tTemp, (22 - pScrollPhase), (tTemp + 104), (23 - pScrollPhase)), [#ink:0])
            pScrollPhase = (pScrollPhase + 1)
            if pScrollPhase > 22 then
              pScrollPhase = 0
              pStepForward = 1
            end if
          else
            pStepForward = 1
          end if
        end if
      end if
    end if
    pMember3D.image.copyPixels(pMember2D.image, pQuadLeft, rect(0, 0, 52, 23), [#ink:0])
    pMember3D.image.copyPixels(pMember2D.image, pQuadRight, rect(52, 0, 104, 23), [#ink:0])
    pLastUpdate = the milliSeconds
  end if
end
