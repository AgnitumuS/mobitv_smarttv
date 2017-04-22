unKnownData = 'Unknown'
config =
  config:
    env     : pateco.env
    platform: pateco.platform

  api:
    production :
      cm     : 'http://api.mobitv.io/v1/'
    development:
      cm     : 'http://dev.mobitv.io:1337/v1/'

  web:
    exit      : ()->
      location.reload()
    serialId  : ()->
      return unKnownData
    deviceId  : ()->
      fingerprint = new Fingerprint({canvas: true, screen_resolution: false})
      return fingerprint.get()
    macAddress: ()->
      return '00:00:00:00:00:00'
    modelName : ()->
      return navigator.userAgent
    modelId   : ()->
      return platform.description

  tv_tizen:
    exit      : ()->
      console.log 'exit tizen'
      tizen.application.getCurrentApplication().exit()
    serialId  : ()->
      try
        return tizen.systeminfo.getCapability("http://tizen.org/system/tizenid")
      catch e
        return unKnownData
    deviceId  : ()->
      try
        return webapis.productinfo.getDuid()
      catch e
        return unKnownData
    macAddress: ()->
      try
        return webapis.network.getMac()
      catch e
        return '00:00:00:00:00:00'
    modelName : ()->
      try
        os = tizen.systeminfo.getCapability("http://tizen.org/system/platform.name")
      catch e
        console.warn e
        os = 'Tizen'
      try
        year = webapis.productinfo.getSmartTVServerVersion().match(/\d+/)[0]
      catch e
        year = unKnownData
      return "Samsung #{os} #{year}"
    modelId   : ()->
      try
        return webapis.productinfo.getRealModel()
      catch e
        return unKnownData

  tv_webos:
    serialId  : ()->
      return unKnownData
    deviceId  : ()->
      try
        return window.pateco.lgDevice.idList[0].idValue
      catch e
        console.warn "Error when get tv_webos deviceId", e
        return unKnownData
    macAddress: ()->
      return '00:00:00:00:00:00'
    modelName : ()->
      try
        return "TV LG #{window.pateco.lgInfo.modelName}"
      catch e
        console.warn "Error when get tv_webos modelName", e
        return unKnownData
    modelId   : ()->
      try
        return window.pateco.lgInfo.modelName
      catch e
        console.warn "Error when get tv_webos modelId", e
        return unKnownData

  getConfig: ()->
    app =
      web     : @web
      tv_tizen: @tv_tizen
      tv_webos: @tv_webos
    prepareData =
      exit          : if app[@config.platform] then app[@config.platform].exit
      appInfo       :
        serialId  : app[@config.platform].serialId()
        deviceId  : app[@config.platform].deviceId()
        macAddress: app[@config.platform].macAddress()
        modelName : app[@config.platform].modelName()
        modelId   : app[@config.platform].modelId()
        version   : '1.0.0'
      api           : @api[@config.env]
      browser       :
        name   : if (window.platform && window.platform.name) then window.platform.name.toLowerCase() else ''
        version: if (window.platform && window.platform.version) then parseInt(window.platform.version.split('.')[0]) else ''

    config = _.extend @config, prepareData
    return config

pateco.config = config.getConfig()