unKnownData = 'Unknown'
config =
  config:
    env     : fimplus.env
    platform: fimplus.platform
  
  
  api:
    production :
      cm     : "https://api.fimplus.io/cm/hd1/v1/"
      cas    : "https://api.fimplus.io/cas/hd1cas/v1.1/"
      payment: "https://api.fimplus.io/payment/hd1payment/v1.1/"
      billing: "https://api.fimplus.io/billing/hd1billing/v1/"
      ubs    : "https://ubs.fimplus.io/hd1ubs/v1/"
      log    : "https://logs.fimplus.io/v1/"
    development:
      cm     : "http://dev.fimplus.io/hd1/v1/"
      cas    : "http://dev.fimplus.io/hd1cas/v1.1/"
      payment: "http://dev.fimplus.io/hd1payment/v1.1/"
      billing: "http://dev.fimplus.io/hd1billing/v1/"
      ubs    : "http://dev.fimplus.io/hd1ubs/v1/"
      log    : "https://logs.fimplus.io/v1/"
    staging    :
      cm     : "https://staging-api.fimplus.io/cm/hd1/v1/"
      cas    : "https://staging-api.fimplus.io/cas/hd1cas/v1.1/"
      payment: "https://staging-api.fimplus.io/payment/hd1payment/v1.1/"
      billing: "https://staging-api.fimplus.io/billing/hd1billing/v1/"
      ubs    : "https://staging-ubs.fimplus.io/hd1ubs/v1/"
      log    : "https://logs.fimplus.io/v1/"
    sandbox    :
      cm     : "https://sandbox-api.fimplus.io/cm/hd1/v1/"
      cas    : "https://sandbox-api.fimplus.io/cas/hd1cas/v1.1/"
      payment: "https://sandbox-api.fimplus.io/payment/hd1payment/v1.1/"
      billing: "https://sandbox-api.fimplus.io/billing/hd1billing/v1/"
      ubs    : "https://sandbox-ubs.fimplus.io/hd1ubs/v1/"
      log    : "https://logs.fimplus.io/v1/"
  
  paymentInfo:
    production :
      stripe_key: 'pk_live_sl4ekCBMRgX8bZtrZ6rq3raI'
    development:
      stripe_key: 'pk_test_btPCH3f3B9kU72k3PL1tN9gR'
    staging    :
      stripe_key: 'pk_test_btPCH3f3B9kU72k3PL1tN9gR'
    sandbox    :
      stripe_key: 'pk_test_btPCH3f3B9kU72k3PL1tN9gR'
  
  web:
    exit      : ()->
      console.log 'exit'
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
    getModel4K: ()->
      return 0
  
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
    getModel4K: ()->
      if webapis.productinfo.isUdPanelSupported()
        return 1
      return 0
  
  tv_webos:
    serialId  : ()->
      return unKnownData
    deviceId  : ()->
      try
        return window.fimplus.lgDevice.idList[0].idValue
      catch e
        console.warn "Error when get tv_webos deviceId", e
        return unKnownData
    macAddress: ()->
      return '00:00:00:00:00:00'
    modelName : ()->
      try
        return "TV LG #{window.fimplus.lgInfo.modelName}"
      catch e
        console.warn "Error when get tv_webos modelName", e
        return unKnownData
    modelId   : ()->
      try
        return window.fimplus.lgInfo.modelName
      catch e
        console.warn "Error when get tv_webos modelId", e
        return unKnownData
    getModel4K: ()->
      return 0
  
  getConfig: ()->
    viewMoreRibbon = 'https://ast.fimplus.io/files/xem-them_1488968348945.png'
    try
      lang = JSON.parse(localStorage.userSettings).language
      if lang is 'en'
        viewMoreRibbon = 'https://ast.fimplus.io/files/view-more_1492485660763.png'
    catch
    app =
      web     : @web
      tv_tizen: @tv_tizen
      tv_webos: @tv_webos
    prepareData =
      exit          : if app[@config.platform] then app[@config.platform].exit
      viewmoreButton:
        id             : 1
        knownAs        : 'view-more-text-lower'
        title          : 'View More'
        image3x        :
          bannerAppletv: 'https://ast.fimplus.io/files/welcome_1488334595081.png'
        bannerAppletv  : 'https://ast.fimplus.io/files/welcome_1488334595081.png'
        posterLandscape: viewMoreRibbon
        isViewmore     : true
      appInfo       :
        serialId  : app[@config.platform].serialId()
        deviceId  : app[@config.platform].deviceId()
        macAddress: app[@config.platform].macAddress()
        modelName : app[@config.platform].modelName()
        modelId   : app[@config.platform].modelId()
        version   : '2.0.0'
        model4K   : app[@config.platform].getModel4K()
      api           : @api[@config.env]
      paymentInfo   : @paymentInfo[@config.env]
      browser       :
        name   : if (window.platform && window.platform.name) then window.platform.name.toLowerCase() else ''
        version: if (window.platform && window.platform.version) then parseInt(window.platform.version.split('.')[0]) else ''
      services      : ["hd1_cas", "hd1_cm", "hd1_payment", "hd1_billing"]
    
    config = _.extend @config, prepareData
    return config

fimplus.config = config.getConfig()