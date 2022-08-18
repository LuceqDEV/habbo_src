on construct me 
  me.pItemList = [:]
  return TRUE
end

on deconstruct me 
  tObjMngr = getObjectManager()
  i = 1
  repeat while i <= me.count(#pItemList)
    tid = me.getPropRef(#pItemList, i).getAt(#timerid)
    if tObjMngr.exists(tid) then
      tObjMngr.get(tid).forget()
    end if
    i = (1 + i)
  end repeat
  me.pItemList = [:]
  return TRUE
end

on create me, tid, tTime, tHandler, tClientID, tArgument, tIterations 
  if me.exists(tid) then
    return(error(me, "Timeout already registered:" && tid, #create))
  end if
  if not integerp(tTime) then
    return(error(me, "Integer expected:" && tTime, #create))
  end if
  if not symbolp(tHandler) then
    return(error(me, "Symbol expected:" && tHandler, #create))
  end if
  tObjMngr = getObjectManager()
  if tObjMngr.exists(tClientID) then
    if not tObjMngr.get(tClientID).handler(tHandler) then
      return(error(me, "Handler not found in object:" && tHandler && tClientID, #create))
    end if
  else
    if not voidp(tClientID) then
      return(error(me, "Object ID or VOID expected:" && tClientID, #create))
    end if
  end if
  tUniqueId = "Timeout" && getUniqueID()
  tObjMngr.create(tUniqueId, timeout(tUniqueId).new(tTime, #executeTimeOut, me))
  tList = [:]
  tList.setAt(#uniqueid, tUniqueId)
  tList.setAt(#handler, tHandler)
  tList.setAt(#client, tClientID)
  tList.setAt(#argument, tArgument)
  tList.setAt(#iterations, tIterations)
  tList.setAt(#count, 0)
  me.setProp(#pItemList, tid, tList)
  return TRUE
end

on get me, tid 
  if not me.exists(tid) then
    return(error(me, "Item not found:" && tid, #get))
  end if
  tTask = me.getProp(#pItemList, tid)
  if voidp(tTask.getAt(#client)) then
    value(tTask.getAt(#handler) & "(" & tTask.getAt(#argument) & ")")
  else
    tObjMngr = getObjectManager()
    if tObjMngr.exists(tTask.getAt(#client)) then
      call(tTask.getAt(#handler), tObjMngr.get(tTask.getAt(#client)), tTask.getAt(#argument))
    else
      return(me.remove(tid))
    end if
  end if
end

on remove me, tid 
  if not me.exists(tid) then
    return(error(me, "Item not found:" && tid, #remove))
  end if
  tObjMngr = getObjectManager()
  tObject = tObjMngr.get(me.getPropRef(#pItemList, tid).getAt(#uniqueid))
  if tObject <> 0 then
    tObject.target = void()
    tObject.forget()
    tObject = void()
    tObjMngr.remove(me.getPropRef(#pItemList, tid).getAt(#uniqueid))
  end if
  return(me.pItemList.deleteProp(tid))
end

on exists me, tid 
  return(listp(me.getProp(#pItemList, tid)))
end

on executeTimeOut me, tTimeout 
  i = 1
  repeat while i <= me.count(#pItemList)
    if (me.getPropRef(#pItemList, i).getAt(#uniqueid) = tTimeout.name) then
      tid = me.pItemList.getPropAt(i)
      tTask = me.getProp(#pItemList, tid)
    else
      i = (1 + i)
    end if
  end repeat
  if voidp(tid) then
    tTimeout.forget()
    return FALSE
  end if
  me.getPropRef(#pItemList, tid).setAt(#count, (me.getPropRef(#pItemList, tid).getAt(#count) + 1))
  if (me.getPropRef(#pItemList, tid).getAt(#count) = me.getPropRef(#pItemList, tid).getAt(#iterations)) then
    me.remove(tid)
  end if
  if voidp(tTask.getAt(#client)) then
    value(tTask.getAt(#handler) & "(" & tTask.getAt(#argument) & ")")
  else
    tObject = getObject(tTask.getAt(#client))
    if objectp(tObject) then
      call(tTask.getAt(#handler), tObject, tTask.getAt(#argument))
    else
      return(me.remove(tid))
    end if
  end if
  return TRUE
end
