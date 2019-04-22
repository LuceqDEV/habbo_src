property pPersistentCatalogDataId, pPageCache, pWaitingForData, pWaitingForFrontPage, pCatalogIndex, pCreditInfoNodeName, pPixelInfoNodeName, pCreditInfoPageID, pPixelInfoPageID, pPageItemDownloader, pPurchaseProcessor

on construct me 
  pPageCache = [:]
  pCatalogIndex = void()
  pWaitingForData = -1
  pWaitingForFrontPage = 0
  pPersistentCatalogDataId = "Persistent Catalog Data"
  createObject(pPersistentCatalogDataId, ["Persistent Product Data Container"])
  pPageItemDownloader = createObject(getUniqueID(), "Page Item Downloader Class")
  pCreditInfoNodeName = "magic.credits"
  pPixelInfoNodeName = "magic.pixels"
  pCreditInfoPageID = void()
  pPixelInfoPageID = void()
  pPurchaseProcessor = void()
end

on deconstruct me 
  if objectExists(pPersistentCatalogDataId) then
    removeObject(pPersistentCatalogDataId)
  end if
end

on updatePageData me, tPageID, tdata 
  pPageCache.setaProp(tPageID, me.groupOffersByProducts(tdata.duplicate()))
  if tPageID = pWaitingForData then
    me.getInterface().displayPage(tPageID)
  end if
end

on updateCatalogIndex me, tdata 
  pPageCache = [:]
  pCatalogIndex = tdata
  if pWaitingForFrontPage then
    tNode = me.getFirstNavigateableNode(pCatalogIndex)
    if voidp(tNode) then
      return()
    else
      me.preparePage(tNode.getAt(#pageid))
      pWaitingForFrontPage = 0
    end if
    tCreditInfoNode = me.getNodeByName(pCreditInfoNodeName, pCatalogIndex)
    tPixelInfoNode = me.getNodeByName(pPixelInfoNodeName, pCatalogIndex)
    if not voidp(tCreditInfoNode) then
      pCreditInfoPageID = tCreditInfoNode.getAt(#pageid)
    end if
    if not voidp(tPixelInfoNode) then
      pPixelInfoPageID = tPixelInfoNode.getAt(#pageid)
    end if
  end if
end

on preparePage me, tPageID 
  me.initCatalogData()
  if voidp(pPageCache.getaProp(tPageID)) then
    me.getHandler().requestPage(tPageID)
    pWaitingForData = tPageID
  else
    me.getInterface().displayPage(tPageID)
  end if
end

on prepareFrontPage me 
  if not voidp(pCatalogIndex) then
    tNode = me.getFirstNavigateableNode(pCatalogIndex)
    if voidp(tNode) then
      return()
    else
      me.preparePage(tNode.getAt(#pageid))
      pWaitingForFrontPage = 0
    end if
  else
    pWaitingForFrontPage = 1
    me.initCatalogData()
  end if
end

on prepareCreditsInfoPage me 
  if voidp(pCreditInfoPageID) then
    return(error(me, "Credits info page not found in node tree.", #prepareCreditsInfoPage, #major))
  end if
  me.preparePage(pCreditInfoPageID)
end

on preparePixelsInfoPage me 
  if voidp(pPixelInfoPageID) then
    return(error(me, "Pixels info page not found in node tree.", #preparePixelsInfoPage, #major))
  end if
  me.preparePage(pPixelInfoPageID)
end

on getPageData me, tPageID 
  return(pPageCache.getaProp(tPageID))
end

on getPageDataByLayout me, tLayout 
  repeat while pPageCache <= undefined
    tPage = getAt(undefined, tLayout)
    if tPage.getAt(#layout) = tLayout then
      return(tPage)
    end if
  end repeat
  return([:])
end

on getCatalogIndex me 
  return(pCatalogIndex)
end

on getPersistentCatalogDataObject me 
  if voidp(getObject(pPersistentCatalogDataId)) then
    error(me, "Persistent Catalog Data Missing!", #getPersistentCatalogDataObject, #major)
  end if
  return(getObject(pPersistentCatalogDataId))
end

on getPageItemDownloader me 
  return(pPageItemDownloader)
end

on getFirstNavigateableNode me, tNode 
  if ilk(tNode) <> #propList then
    error(me, "Node type was invalid.", #getFirstNavigateableNode, #critical)
    return(void())
  end if
  if tNode.getAt(#navigateable) and tNode.getAt(#pageid) <> -1 then
    return(tNode)
  else
    if not voidp(tNode.getaProp(#subnodes)) then
      repeat while tNode.getAt(#subnodes) <= undefined
        tSubNode = getAt(undefined, tNode)
        tResult = me.getFirstNavigateableNode(tSubNode)
        if not voidp(tResult) then
          return(tResult)
        end if
      end repeat
    end if
  end if
end

on getNodeByName me, tName 
  return(me.getFirstNodeByName(tName, pCatalogIndex))
end

on getFirstNodeByName me, tName, tNode 
  if ilk(tNode) <> #propList then
    error(me, "Node type was invalid.", #getNodeByName, #major)
    return(void())
  end if
  if tNode.getAt(#nodename) = tName then
    return(tNode)
  else
    if not voidp(tNode.getaProp(#subnodes)) then
      repeat while tNode.getAt(#subnodes) <= tNode
        tSubNode = getAt(tNode, tName)
        tResult = me.getFirstNodeByName(tName, tSubNode)
        if not voidp(tResult) then
          return(tResult)
        end if
      end repeat
    end if
  end if
end

on initCatalogData me 
  if voidp(pCatalogIndex) then
    me.getHandler().requestCatalogIndex()
  end if
end

on groupOffersByProducts me, tPageData 
  tGroupedOffers = [:]
  repeat while tPageData.getAt(#offers) <= undefined
    tOffer = getAt(undefined, tPageData)
    tProductCode = tOffer.getAt(#offername)
    if voidp(tGroupedOffers.getaProp(tProductCode)) then
      tGroupedOffers.setaProp(tProductCode, [#offerList:[]])
    end if
    tGroupedOffers.getAt(tProductCode).getAt(#offerList).add(tOffer)
  end repeat
  tPageData.setAt(#offers, tGroupedOffers)
  return(tPageData)
end

on findOfferByOldpageSelection me, tSelectedProduct, tPageID 
  tPageData = me.getaProp(tPageID)
  tOffer = void()
  i = 1
  repeat while i <= tPageData.getAt(#offers).count
    if tSelectedProduct.getAt("purchaseCode") = tPageData.getAt(#offers).getPropAt(i) then
      tOffer = tPageData.getAt(#offers).getAt(i).getAt(#offerList).getAt(1).duplicate()
    else
      i = 1 + i
    end if
  end repeat
  if voidp(tOffer) then
    error(me, "Could not map old page's product code to a current product id", #findOfferByOldpageSelection, #major)
  else
    tOffer.getAt(#content).getAt(1).setAt(#extra_param, tSelectedProduct.getAt("extra_parm"))
  end if
  return(tOffer)
end

on checkProductOrder me, tSelectedProduct 
  if not listp(tSelectedProduct) then
    return(error(me, "Selected product was not valid", #checkProductOrder, #major))
  end if
  tPageID = me.getInterface().getLastOpenedPage()
  tOffer = me.findOfferByOldpageSelection(tSelectedProduct, tPageID)
  if not objectp(pPurchaseProcessor) then
    pPurchaseProcessor = createObject(getUniqueID(), "Purchase Processor Class")
  end if
  pPurchaseProcessor.startPurchase([#offerType:#credits, #pageid:tPageID, #item:tOffer, #method:#sendPurchaseFromCatalog])
end

on requestPurchase me, tOfferType, tPageID, tSelectedItem, tMethod, tExtraProps 
  if not objectp(pPurchaseProcessor) then
    pPurchaseProcessor = createObject(getUniqueID(), "Purchase Processor Class")
  end if
  tProps = [#offerType:tOfferType, #pageid:tPageID, #item:tSelectedItem, #method:tMethod]
  if listp(tExtraProps) then
    repeat while tExtraProps <= tPageID
      tProp = getAt(tPageID, tOfferType)
      tProps.setaProp(tProp, 1)
    end repeat
  end if
  pPurchaseProcessor.startPurchase(tProps)
end

on getArePixelsEnabled me 
  if getVariableValue("pixels.enabled") = 1 then
    return(1)
  else
    return(0)
  end if
end

on refreshCatalogue me 
  if me.getInterface().isVisible() then
    me.getInterface().hideCatalogue()
    me.getInterface().showCatalogWasPublishedDialog()
  end if
  me.getHandler().requestCatalogIndex()
end
