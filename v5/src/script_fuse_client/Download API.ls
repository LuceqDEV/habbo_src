on constructDownloadManager()
  return(createManager(#download_manager, getClassVariable("download.manager.class")))
  exit
end

on deconstructDownloadManager()
  return(removeManager(#download_manager))
  exit
end

on getDownloadManager()
  tObjMngr = getObjectManager()
  if not tObjMngr.managerExists(#download_manager) then
    return(constructDownloadManager())
  end if
  return(tObjMngr.getManager(#download_manager))
  exit
end

on queueDownload(tURL, tMemName, tFileType, tForceFlag)
  return(getDownloadManager().queue(tURL, tMemName, tFileType, tForceFlag))
  exit
end

on abortDownLoad(tMemNameOrNum)
  return(getDownloadManager().abort(tMemNameOrNum))
  exit
end

on registerDownloadCallback(tMemNameOrNum, tMethod, tClientID, tArgument)
  return(getDownloadManager().registerCallback(tMemNameOrNum, tMethod, tClientID, tArgument))
  exit
end

on getDownLoadPercent(tid)
  return(getDownloadManager().getLoadPercent(tid))
  exit
end

on downloadExists(tid)
  return(getDownloadManager().exists(tid))
  exit
end

on printDownloads()
  return(getDownloadManager().print())
  exit
end