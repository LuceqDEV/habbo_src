on constructBinaryManager()
  return(createManager(#binary_data_manager, getClassVariable("binary.manager.class")))
  exit
end

on deconstructBinaryManager()
  return(removeManager(#binary_data_manager))
  exit
end

on getBinaryManager()
  tMgr = getObjectManager()
  if not tMgr.managerExists(#binary_data_manager) then
    return(constructBinaryManager())
  end if
  return(tMgr.getManager(#binary_data_manager))
  exit
end

on retrieveBinaryData(tID, tAuth, tCallBackObject)
  return(getBinaryManager().retrieveData(tID, tAuth, tCallBackObject))
  exit
end

on storeBinaryData(tdata, tCallBackObject)
  return(getBinaryManager().storeData(tdata, tCallBackObject))
  exit
end

on addMessageToBinaryQueue(tMsg)
  return(getBinaryManager().addMessageToQueue(tMsg))
  exit
end

on handlers()
  return([])
  exit
end