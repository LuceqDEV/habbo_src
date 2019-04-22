property pItemList

on construct me 
  pItemList = []
  pItemList.sort()
  return(1)
end

on deconstruct me 
  tObjMngr = getObjectManager()
  i = 1
  repeat while i <= pItemList.count
    if tObjMngr.exists(pItemList.getAt(i)) then
      tObjMngr.Remove(pItemList.getAt(i))
    end if
    i = 1 + i
  end repeat
  pItemList = []
  return(1)
end

on create me, tID, tClass 
  if getObjectManager().exists(tID) then
    return(error(me, "Object already exists:" && tID, #create, #major))
  end if
  if not getObjectManager().create(tID, tClass) then
    return(0)
  end if
  pItemList.add(tID)
  return(1)
end

on GET me, tID 
  return(getObjectManager().GET(tID))
end

on getIDList me 
  tIDList = []
  tListMode = ilk(me.pItemList)
  i = 1
  repeat while i <= me.count(#pItemList)
    if tListMode = #list then
      tID = me.getProp(#pItemList, i)
    else
      tID = me.getPropAt(i)
    end if
    tIDList.add(tID)
    i = 1 + i
  end repeat
  return(tIDList)
end

on Remove me, tID 
  if not me.exists(tID) then
    return(0)
  end if
  pItemList.deleteOne(tID)
  return(getObjectManager().Remove(tID))
end

on exists me, tID 
  return(me.getOne(tID) > 0)
end

on print me 
  tListMode = ilk(me.pItemList)
  i = 1
  repeat while i <= me.count(#pItemList)
    if tListMode = #list then
      tID = me.getProp(#pItemList, i)
    else
      tID = me.getPropAt(i)
    end if
    tObj = me.GET(tID)
    if symbolp(tID) then
      tID = "#" & tID
    end if
    put(tID && ":" && tObj)
    i = 1 + i
  end repeat
  return(1)
end

on handlers  
  return([])
end
