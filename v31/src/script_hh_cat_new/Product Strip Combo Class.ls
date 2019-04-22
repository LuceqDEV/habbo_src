on construct(me)
  callAncestor(#construct, [me])
  return(1)
  exit
end

on deconstruct(me)
  return(callAncestor(#deconstruct, [me]))
  exit
end

on resolveSmallPreview(me, tOffer)
  if not objectp(tOffer) then
    return(error(me, "Invalid input format", #resolveSmallPreview, #minor))
  end if
  if tOffer.getCount() <> 1 then
    return(callAncestor(#resolveSmallPreview, [me]))
  end if
  ttype = tOffer.getContent(1).getType()
  if ttype = "e" then
    tPrefix = "ctlg_pic_small_fx_"
    tClassID = tOffer.getContent(1).getClassId()
    if memberExists(tPrefix & tClassID) then
      return(getMember(tPrefix & tClassID).image)
    end if
  else
    return(ancestor.resolveSmallPreview(tOffer))
  end if
  exit
end

on refreshDownloadingSlots(me)
  return(ancestor.refreshDownloadingSlots())
  exit
end