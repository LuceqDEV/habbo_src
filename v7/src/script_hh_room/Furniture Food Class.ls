on prepare me, tdata 
  if (tdata.count = 0) then
    tdata = ["foo":"0"]
  end if
  return(me.updateStuffdata(tdata.getPropAt(1), tdata.getAt(1)))
end

on updateStuffdata me, tProp, tValue 
  tCount = integer(tValue)
  if not ilk(tCount, #integer) then
    tCount = 0
  end if
  i = 1
  repeat while i <= me.count(#pSprList)
    tMemName = me.getPropRef(#pSprList, i).member.name
    me.getPropRef(#pSprList, i).member = member(getmemnum(tMemName & tCount))
    me.getPropRef(#pSprList, i).width = me.getPropRef(#pSprList, i).member.width
    me.getPropRef(#pSprList, i).height = me.getPropRef(#pSprList, i).member.height
    i = (1 + i)
  end repeat
  return TRUE
end
