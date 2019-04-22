property pPageItemDownloader, pTextElements, pWndObj, pImageElements

on construct me 
  pWndObj = void()
  pPageItemDownloader = getThread(#catalogue).getComponent().getPageItemDownloader()
  pImageElements = getStructVariable("layout.fields.image.default")
  pTextElements = getStructVariable("layout.fields.text.default")
  return(callAncestor(#construct, [me]))
end

on deconstruct me 
  pPageItemDownloader.removeCallback(me, #downloadCompleted)
  return(callAncestor(#deconstruct, [me]))
end

on define me, tdata 
  me.pPageData = tdata
  if variableExists("layout.fields.image." & me.getProp(#pPageData, #layout)) then
    pImageElements = getStructVariable("layout.fields.image." & me.getProp(#pPageData, #layout))
  end if
  if variableExists("layout.fields.text." & me.getProp(#pPageData, #layout)) then
    pTextElements = getStructVariable("layout.fields.text." & me.getProp(#pPageData, #layout))
  end if
end

on mergeWindow me, tParentWndObj 
  tLayoutMember = "ctlg_" & me.getProp(#pPageData, #layout) & ".window"
  if not memberExists(tLayoutMember) then
    return(error(me, "Layout member " & tLayoutMember & " missing.", #mergeWindow))
  end if
  tParentWndObj.merge(tLayoutMember)
  pWndObj = tParentWndObj
  tTextFields = me.getPropRef(#pPageData, #localization).getAt(#texts)
  i = 1
  repeat while i <= tTextFields.count
    if pTextElements.count >= i then
      me.setElementText(pWndObj, pTextElements.getAt(i), tTextFields.getAt(i))
    end if
    i = 1 + i
  end repeat
  tBitmaps = me.getPropRef(#pPageData, #localization).getAt(#images)
  pPageItemDownloader.defineCallback(me, #downloadCompleted)
  if pImageElements.count >= 1 then
    tBitmap = tBitmaps.getAt(1)
    if tParentWndObj.elementExists(pImageElements.getAt(1)) and tBitmap.length > 1 then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements.getAt(1)))
      else
        pPageItemDownloader.registerDownload(#bitmap, tBitmap, [#imagedownload:1, #element:pImageElements.getAt(1), #assetId:tBitmap, #pageid:me.getProp(#pPageData, #pageid)])
      end if
    end if
  end if
  if pImageElements.count >= 2 then
    tBitmap = tBitmaps.getAt(2)
    if tParentWndObj.elementExists(pImageElements.getAt(2)) and tBitmap.length > 1 then
      if memberExists(tBitmap) then
        me.centerBlitImageToElement(getMember(tBitmap).image, tParentWndObj.getElement(pImageElements.getAt(2)))
      else
        pPageItemDownloader.registerDownload(#topStoryImage, tBitmap, [#imagedownload:1, #element:pImageElements.getAt(2), #assetId:tBitmap, #pageid:me.getProp(#pPageData, #pageid)])
      end if
    end if
  end if
  pWndObj.getElement("redeem").deactivate()
  if me.getPropRef(#pPageData, #localization).getAt(#texts).getAt(8) <> #empty then
    tFont = pWndObj.getElement("ctlg_txt3").getFont()
    tFont.setAt(#color, rgb(me.getPropRef(#pPageData, #localization).getAt(#texts).getAt(8)))
    pWndObj.getElement("ctlg_txt3").setFont(tFont)
  end if
end

on clearVoucherCodeField me 
  if voidp(pWndObj) then
    return("\r", error(me, "Missing handle to window object!", #clearVoucherCodeField, #major))
  end if
  if pWndObj.elementExists("voucher_code") then
    pWndObj.getElement("voucher_code").setText("")
  end if
  if pWndObj.elementExists("redeem") then
    pWndObj.getElement("redeem").deactivate()
  end if
end

on downloadCompleted me, tProps 
  if tProps.getAt(#props).getAt(#pageid) <> me.getProp(#pPageData, #pageid) then
    return()
  end if
  tDlProps = tProps.getAt(#props)
  if tDlProps.getaProp(#imagedownload) then
    if voidp(pWndObj) then
      return("\r", error(me, "Missing handle to window object!", #downloadCompleted, #major))
    end if
    if not pWndObj.elementExists(tDlProps.getAt(#element)) then
      return(error(me, "Missing target element " & tDlProps.getAt(#element), #downloadCompleted, #minor))
    end if
    tmember = getMember(tProps.getaProp(#assetId))
    if tmember.type <> #bitmap then
      return(error(me, "Downloaded member was of incorrect type!", #downloadCompleted, #major))
    end if
    me.centerBlitImageToElement(tmember.image, pWndObj.getElement(tDlProps.getAt(#element)))
  end if
end

on handleClick me, tEvent, tSprID, tProp 
  if tEvent = #mouseUp then
    if tSprID = "ctlg_txt3" then
      getThread(#catalogue).getInterface().followLink(me.getPropRef(#pPageData, #localization).getAt(#texts).getAt(7))
    else
      if tSprID = "redeem" then
        if voidp(pWndObj) then
          return("\r", error(me, "Missing handle to window object!", #handleClick, #major))
        end if
        if pWndObj.elementExists("voucher_code") then
          tVoucherCode = pWndObj.getElement("voucher_code").getText()
          getThread(#catalogue).getHandler().sendRedeemVoucher(tVoucherCode)
        end if
      end if
    end if
  else
    if tEvent = #keyUp then
      if tSprID = "voucher_code" then
        if voidp(pWndObj) then
          return("\r", error(me, "Missing handle to window object!", #handleClick, #major))
        end if
        if pWndObj.elementExists("redeem") then
          if pWndObj.getElement("voucher_code").getText().length > 0 then
            pWndObj.getElement("redeem").Activate()
          else
            pWndObj.getElement("redeem").deactivate()
          end if
        end if
      end if
    end if
  end if
end
