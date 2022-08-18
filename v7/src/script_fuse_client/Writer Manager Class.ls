property pItemList, pWriterClass, pPlainStruct

on construct me 
  pWriterClass = getClassVariable("writer.instance.class")
  pPlainStruct = getStructVariable("struct.font.plain")
  pItemList = [:]
  return TRUE
end

on deconstruct me 
  call(#deconstruct, pItemList)
  pItemList = [:]
  return TRUE
end

on create me, tid, tMetrics 
  if not voidp(pItemList.getAt(tid)) then
    return(error(me, "Writer already exists:" && tid, #create))
  end if
  tObj = getObjectManager().create(#temp, pWriterClass)
  if not tObj then
    return FALSE
  end if
  if (tMetrics.ilk = #struct) then
    tObj.setFont(tMetrics)
  else
    tObj.setFont(pPlainStruct)
    tObj.define(tMetrics)
  end if
  pItemList.setAt(tid, tObj)
  tObj.setID(tid)
  return TRUE
end

on remove me, tid 
  tObj = pItemList.getAt(tid)
  if voidp(tObj) then
    return(error(me, "Writer not found:" && tid, #remove))
  end if
  tObj.deconstruct()
  return(pItemList.deleteProp(tid))
end

on get me, tid 
  tObj = pItemList.getAt(tid)
  if voidp(tObj) then
    return FALSE
  end if
  return(tObj)
end

on exists me, tid 
  return(not voidp(pItemList.getAt(tid)))
end
