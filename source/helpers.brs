' Get limit-livesream

function LoadLimitStream()
    rawData = GetZObjects({"zobject_type": "limit_livestream"})
    print rawData.count()
    if rawData <> invalid and rawData.count() > 0
        data = rawData[0]
        SetLimitStreamObject(data)
    end if
end function

function LoadHeroCarousels()
    rawData = GetZObjects({"zobject_type": "top_playlists"})
    if rawData <> invalid AND rawData.Count()>0
      return rawData
    end if
    return invalid
end function

function GetLimitStreamObject() as Object
    if m.limitStream <> invalid then
        return m.limitStream
    end if

    return invalid
end function

function SetLimitStreamObject(data as Object)
    m.limitStream = invalid

    m.limitStream = {
        "limit": data.limit,
        "message": data.message,
        "refresh_rate": data.refresh_rate,
        "played": 0
    }
end function

function IsPassedLimit(position as Integer, limit as Integer) as Boolean
    return position >= limit
end function

function readManifest()
  result = {}

  raw = ReadASCIIFile("pkg:/manifest")
  lines = raw.Tokenize(Chr(10))
  for each line in lines
    bits = line.Tokenize("=")
    if bits.Count() > 1
      result.AddReplace(bits[0], bits[1])
    end if
  next

  return result
end function

Function firmwareSupportsCachefs() as Boolean
    majorRequirement = 8
    minorRequirement = 0
    buildRequirement = 0
    version = CreateObject("roDeviceInfo").GetVersion()
    major = Mid(version, 3, 1)
    minor = Mid(version, 5, 2)
    build = Mid(version, 8, 5)
    supportsCachefs = false
    If ((Val(major) > majorRequirement) or (Val(major) = majorRequirement))
        supportsCachefs = true
    End If
    return supportsCachefs
End Function

Function GetEncryptedUrlString(inputString as String) as String
    ba1 = CreateObject("roByteArray")
    ba1.FromAsciiString(inputString)
    digest = CreateObject("roEVPDigest")
    digest.Setup("sha256")
    digest.Update(ba1)
    hash = digest.Final()
    return hash
End Function

Function CheckAndGetImagePathIfAvailable(inputString as String) as object
    result = {}

    cacheFileSys = "cachefs:/myImages/"
    tmpFileSys = "tmp:/myImages/"

    cachePath = cacheFileSys + inputString
    tempPath = tmpFileSys + inputString

    result.foundPath = ""
    result.newCachePath = cachePath
    result.newTempPath = tempPath

    ' First Check in Temp'
    x = MatchFiles(tmpFileSys,inputString)
    If x.Count() <> 0
        result.foundPath = tempPath
        result.newCachePath = ""
        result.newTempPath = ""
    else if firmwareSupportsCachefs() = true
        ' Check in CacheFS'
        x = MatchFiles(cacheFileSys,inputString)
        If x.Count() <> 0
            ' Copy file in temp from cache
            copyfile(cachePath,tempPath)

            result.foundPath = tempPath
            result.newCachePath = ""
            result.newTempPath = ""
        end if
    else
        result.newCachePath = ""
    end if

    return result
End Function

Function CheckAndCreateCacheAndTempDirectories()
  print "CheckAndCreateCacheAndTempDirectories=-=======================================================>"
  cacheFileSys = "cachefs:/myImages"
  tmpFileSys = "tmp:/myImages"

  cacheImagesList = ListDir(cacheFileSys)

  if (cacheImagesList = invalid OR cacheImagesList.count() <= 0)
      print "-----------------------------------------------"
      print "No Cached Imaged Found, Creating Cache directory "
      print "-----------------------------------------------"
      CreateDirectory(cacheFileSys)
  else
      print "-----------------------------------------------"
      print "Total Cached Images : " cacheImagesList.count()
      print "-----------------------------------------------"
  end if

  ' Always create temp folder'
  CreateDirectory(tmpFileSys)
End Function
