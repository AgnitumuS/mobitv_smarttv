pateco.PlayerService =
  actionKey : ['backward', 'forward',
    'pause', 'stop', 'seekTo',
    'getState', 'getDuration',
    'getCurrentTime', 'play'
    'getVolume', 'setVolume'
  ]
  _configPlayer :
    env : 'development'
    platform : 'web'
    state : 'IDLE' #PAUSE , STOP, PLAY
    duration : 0
    position : 0
    skdVersion : 3
    drm : {}
    url : ''
    listener : {}
    browser :
      name : 'chrome'
      version : 40
    webos :
      isDrmClientLoaded : false
      clientId : undefined
      drmType : 'viewright_web'
      drmTypeInit : 'verimatrix'
      appId : 'com.yourdomain.app'
      msg : '{"company_name":"galaxy", "vcas_boot_address":"vm-acsm.pateco.vn:80"}'
      drmSystemId : '0x5601'
      msgId : null
    tv_tizen :
      drmServer :
        production : 'https://lic.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx?PlayRight=1&UseSimpleNonPersistentLicense=1'
        staging : 'https://lic.staging.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx?PlayRight=1&UseSimpleNonPersistentLicense=1'
        sandbox : 'https://lic.staging.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx?PlayRight=1&UseSimpleNonPersistentLicense=1'
        development : 'https://lic.staging.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx?PlayRight=1&UseSimpleNonPersistentLicense=1'
        sandbox : 'https://lic.staging.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx?PlayRight=1&UseSimpleNonPersistentLicense=1'
    web :
      player : undefined
      html :
        techs : ['html5hls']
      flash :
        silverlightFile : "/player_web/dashcs.xap?t=" + (new Date).getTime()
        flashFile : "./player_web/dashas.swf?t=" + (new Date).getTime()
        techs : ['dashjs', 'dashas', 'dashcs']
      drmServer :
        production :
          fairplayLicenseServerURL : "https://lic.drmtoday.com/license-server-fairplay/",
          fairplayCertificateURL : 'https://lic.drmtoday.com/license-server-fairplay/cert/',
          widevineLicenseServerURL : 'https://lic.drmtoday.com/license-proxy-widevine/cenc/'
          accessLicenseServerURL : 'https://lic.drmtoday.com/flashaccess/LicenseTrigger/v1'
          playReadyLicenseServerURL : 'https://lic.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx'
        development :
          widevineLicenseServerURL : 'https://lic.staging.drmtoday.com/license-proxy-widevine/cenc/'
          accessLicenseServerURL : 'https://lic.staging.drmtoday.com/flashaccess/LicenseTrigger/v1'
          playReadyLicenseServerURL : 'https://lic.staging.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx'
          fairplayLicenseServerURL : "https://lic.staging.drmtoday.com/license-server-fairplay/",
          fairplayCertificateURL : 'https://lic.staging.drmtoday.com/license-server-fairplay/cert/',
        staging :
          widevineLicenseServerURL : 'https://lic.staging.drmtoday.com/license-proxy-widevine/cenc/'
          accessLicenseServerURL : 'https://lic.staging.drmtoday.com/flashaccess/LicenseTrigger/v1'
          playReadyLicenseServerURL : 'https://lic.staging.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx'
          fairplayLicenseServerURL : "https://lic.staging.drmtoday.com/license-server-fairplay/",
          fairplayCertificateURL : 'https://lic.staging.drmtoday.com/license-server-fairplay/cert/',
        sandbox :
          widevineLicenseServerURL : 'https://lic.staging.drmtoday.com/license-proxy-widevine/cenc/'
          accessLicenseServerURL : 'https://lic.staging.drmtoday.com/flashaccess/LicenseTrigger/v1'
          playReadyLicenseServerURL : 'https://lic.staging.drmtoday.com/license-proxy-headerauth/drmtoday/RightsManager.asmx'
          fairplayLicenseServerURL : "https://lic.staging.drmtoday.com/license-server-fairplay/",
          fairplayCertificateURL : 'https://lic.staging.drmtoday.com/license-server-fairplay/cert/',
  listListener : [
    'onPlay',
    'onError',
    'onBufferingStart'
    'onBufferingComplete',
    'onStreamCompleted',
    'onCurrentPlaytime',
    'onVolumeChange',
    'onStateChange'
  ]
  triggerStateChange : ()->
    self = pateco.PlayerService
    self.onStateChange(self.getState())
  onStateChange : ()->
    console.log 'on state change'

  onBufferingStart : ()->
    console.log 'on Buffering Start'

  onBufferingProgress : (percent)->
    console.log "Buffering progress data : " + percent

  onBufferingComplete : ()->
    console.log "Buffering complete."

  onCurrentPlaytime : (position)->
    console.log position

  onStreamCompleted : ()->
    console.log "Stream Completed"

  onPlay : ()->
    console.log 'Player on Play'

  onError : (error)->
    console.error error

  onVolumeChange : (volume)->
    console.log volume

  preparePlayerElement : ()->
    console.info 'Prepare Element'
    self = @
    element = $(self.options.wrapper)
    switch self.options.platform
      when 'tv_tizen'
        self.tv_tizen.init(element)
      when 'web'
        self.web.init(element)
      when 'tv_webos'
        self.tv_webos.init(element)

  onSetActionKey : (action)->
    console.info 'Init Action Player : ' + action
    self = pateco.PlayerService
    self[action] = (data)->
      switch self.options.platform
        when 'tv_tizen'
          self.tv_tizen[action](data)
        when 'web'
          self.web[action](data)
        when 'tv_webos'
          self.tv_webos[action](data)

  setup : (options)->
    self = @
    _.map self.actionKey, self.onSetActionKey
    console.info 'Init Setup Player'
    self.options = _.extend _.clone(self._configPlayer), options

    _.map _.clone(self.options.listener), (func, key)->
      if _.isFunction(func) and key in self.listListener
        console.info "Init listener #{key} success!"
        self[key] = func
      else
        console.warn('Listener ' + key + ' is not function')
    unless self.options.url
      self.onError({
        message : ['connect-error-try', '#1100']
        detail : self.options.drm
      })
      return
    self.preparePlayerElement()
    self.play()

  tv_tizen :
    listener :
      onbufferingstart : ()->
        pateco.PlayerService.onBufferingStart()
      onbufferingprogress : (percent)->
        pateco.PlayerService.onBufferingProgress(percent)
      onbufferingcomplete : ()->
        pateco.PlayerService.onBufferingComplete()
      onstreamcompleted : ()->
        pateco.PlayerService.onStreamCompleted()
      oncurrentplaytime : (currentTime) ->
        pateco.PlayerService.onCurrentPlaytime(currentTime / 1000)
      onevent : (eventType, eventData) ->
        console.log "event type: " + eventType + ", data: " + eventData
      ondrmevent : (drmEvent, drmData) ->
        if drmData.name is "Challenge"
          drmParam = ResponseMessage : drmData.message
          webapis.avplay.setDrm "PLAYREADY", "InstallLicense", JSON.stringify(drmParam)
      onerror : (eventType) ->
        pateco.PlayerService.onError(
          code : 2
          message : 'Kết nối đến hệ thống bị gián đoạn vui lòng thử lại sau, #1700'
          detail : eventType
        )
    prepareDrm : ()->
      self = pateco.PlayerService
      data =
        LicenseServer : pateco.PlayerService.options.tv_tizen.drmServer[self.options.env]
        DeleteLicenseAfterUse : true
        CustomData : base64.encode JSON.stringify(self.options.drm)
      return  JSON.stringify(data)
    init : (element)->
      self = pateco.PlayerService
      element.html("""
            <object id='#{self.options.element}' type='application/avplayer' style="width:100%;height:100%"></object>
            """)
      console.log self.options.url
      webapis.avplay.close()
      console.log 'satetizen', webapis.avplay.getState()
      webapis.avplay.open(self.options.url)
      #      if (webapis.productinfo.isUdPanelSupported())
      #        console.log("4K UHD is supported");
      #        webapis.avplay.setStreamingProperty("SET_MODE_4K", "TRUE");
      #      else
      #        console.log("4K UHD is not supported");

      webapis.avplay.setDisplayRect(0, 0, 1920, 1080)
      unless _.isEmpty self.options.drm
        webapis.avplay.setDrm("PLAYREADY", "SetProperties", self.tv_tizen.prepareDrm())
      tizen.tvaudiocontrol.setVolumeChangeListener((volume)->
        self.onVolumeChange(volume)
      );
      webapis.avplay.setListener(self.tv_tizen.listener)
      webapis.avplay.prepareAsync(()->
        webapis.avplay.setDisplayMethod('PLAYER_DISPLAY_MODE_DST_ROI')
        webapis.avplay.pause()
        if self.options.position isnt 0
          webapis.avplay.seekTo(self.options.position * 1000)
        webapis.avplay.play()
        pateco.PlayerService.triggerStateChange()
        self.onPlay()
      )
    forward : (second = 60)->
      try
        webapis.avplay.jumpForward(second * 1000)
      catch e
        console.warn('This device isnt tv_tizen platform', e)

    backward : (second = 60)->
      try
        webapis.avplay.jumpBackward(second * 1000)
      catch e
        console.warn('This device isnt tv_tizen platform', e)

    getState : ()->
      try
        switch webapis.avplay.getState()
          when 'PLAYING'
            return 'PLAY'
          when 'PAUSED'
            return 'PAUSE'
          else
            webapis.avplay.getState()
      catch e
        console.warn('This device isnt tv_tizen platform', e)

    getCurrentTime : ()->
      try
        return webapis.avplay.getCurrentTime() / 1000
      catch e
        console.warn('This device isnt tv_tizen platform', e)

    getDuration : ()->
      try
        return webapis.avplay.getDuration() / 1000
      catch e
        console.warn('This device isnt tv_tizen platform', e)

    pause : ()->
      self = pateco.PlayerService
      try
        console.log 'call paause', webapis.avplay.getState()
        webapis.avplay.pause() if webapis.avplay.getState() is 'PLAYING'
      catch e
        console.warn('This device isnt tv_tizen platform', e)
      self.triggerStateChange()
    setVolume : (volume = 0) ->
      self = pateco.PlayerService
      try
        tizen.tvaudiocontrol.setVolume(volume);
        self.onVolumeChange(volume)
      catch e
        console.warn('This device isnt tv_tv_tizen platform', e)
    getVolume : (volume = 0) ->
      try
        return tizen.tvaudiocontrol.getVolume();
      catch e
        console.warn('This device isnt tizen platform', e)

    stop : ()->
      try
        webapis.appcommon.setScreenSaver(webapis.appcommon.AppCommonScreenSaverState.SCREEN_SAVER_ON);
      catch e
        console.info 'Can not on screen saver on tizen'
      try
        webapis.avplay.close()
      catch e
        console.warn('This device isnt tv_tizen platform', e)
      pateco.PlayerService.triggerStateChange()

    play : ()->
      console.log 'call tv_tizen play'
      try
        webapis.appcommon.setScreenSaver(webapis.appcommon.AppCommonScreenSaverState.SCREEN_SAVER_OFF);
      catch e
        console.info 'Can not off screen saver on tizen'

      try
        webapis.avplay.play() if webapis.avplay.getState() is 'PAUSED'
      catch e
        console.warn 'This device isnt tv_tizen platform -> can not play', e
      pateco.PlayerService.triggerStateChange()

    seekTo : (second = 0)->
      try
        console.log 'is seekto', second
        webapis.avplay.seekTo(second * 1000) if second isnt 0
      catch e
        console.warn('This device isnt tv_tizen platform', e)

  web :
    init : (element)->
      self = pateco.PlayerService
      console.info 'Init Player Web Element'
      element.append("<video id='#{self.options.element}'></video>")
      self.options.web.player = videojs self.options.element,
        autoplay : true,
        controls : false,
        dasheverywhere : self.web.prepareDrm(),
        techOrder : ['dasheverywhere']
      self.web.listener()
      self.options.state = "IDLE"

    prepareDrm : ()->
      self = pateco.PlayerService
      config =
        assetId : self.options.drm.assetId
        customData :
          userId : self.options.drm.userId
          sessionId : self.options.drm.sessionId
          merchant : self.options.drm.merchant
      config = _.extend config, self.options.web.drmServer[self.options.env]
      if self.options.browser.name in ['safari']
        config = _.extend config, self.options.web.html
      else
        config = _.extend config, self.options.web.flash

      return config
    listener : ()->
      self = pateco.PlayerService
      self.options.web.player.on 'volumechange', ()->
        self.onVolumeChange(self.web.getVolume())
      self.options.web.player.on 'loadedmetadata', ->
        self.onPlay()
        self.onBufferingStart()
        if self.options.position isnt 0
          self.web.seekTo self.options.position
        return
      self.options.web.player.on 'play', ->
        if self.options.state is 'IDLE' and self.options.position isnt 0
          self.web.seekTo self.options.position
        self.options.state = 'PLAY'
        self.triggerStateChange()
        return
      self.options.web.player.on 'pause', ->
        self.options.state = 'PAUSE'
        self.triggerStateChange()
        currentTime = self.web.getCurrentTime()
        duration = self.web.getDuration()
        if duration - currentTime < 10
          self.onStreamCompleted()
        return
      self.options.web.player.on 'timeupdate', ->
        position = self.web.getCurrentTime()
        buffer = self.options.web.player.buffered().end(0)
        if (position - buffer) > 1
          self.onBufferingStart()
        else
          self.onBufferingComplete()
        self.onCurrentPlaytime(position)
        return
      self.options.web.player.on 'error', (error) ->
        params =
          code : 2
          message : ["connect-error-try", "#1200"]
          detail : error
        self.options.state = 'STOP'
        self.triggerStateChange()
        self.onError params

    getCurrentTime : ()->
      self = pateco.PlayerService
      return self.options.web.player.currentTime()

    play : ()->
      self = pateco.PlayerService
      return self.options.web.player.play() if self.options.state is 'PAUSE'
      if self.options.state is 'IDLE'
        self.options.web.player.loadVideo(self.options.url, {});
    setVolume : (volume)->
      self = pateco.PlayerService
      volume = volume / 100
      self.options.web.player.volume(volume)
    getVolume : ()->
      self = pateco.PlayerService
      return self.options.web.player.volume() * 100
    seekTo : (second)->
      pateco.PlayerService.options.web.player.currentTime(second)

    forward : (second = 60)->
      pateco.PlayerService.options.web.player.currentTime(pateco.PlayerService.web.getCurrentTime() + second)

    backward : (second = 60)->
      pateco.PlayerService.options.web.player.currentTime(pateco.PlayerService.web.getCurrentTime() - second)

    pause : ()->
      pateco.PlayerService.options.web.player.pause()

    getState : ()->
      return pateco.PlayerService.options.state

    stop : ()->
      self = pateco.PlayerService
      self.options.state = 'STOP'
      self.triggerStateChange()
      delete videojs.getPlayers()[self.options.element]
      try
        document.getElementById(self.options.element).remove();
      catch e
        console.log e

    getDuration : ()->
      return pateco.PlayerService.options.web.player.duration()

  tv_webos :
    init : (element)->
      self = pateco.PlayerService
      tv_webos.unloadDrmClient()
      #      self.options.drm = {}
      #      self.options.url = 'http://103.205.104.214/hevc_hdr_dash/manifest.mpd'
      element.append("<video id='#{self.options.element}'></video>")
      self.options.webos.player = document.getElementById(self.options.element)
      self.options.state = 'IDLE'
      console.log 'version', self.options.skdVersion
      if self.options.skdVersion is 3
        tv_webos.listener()
      else
        tv_webos.listener20()
    requestDrm : (params)->
      try
        webOS.service.request('luna://com.webos.service.drm', params)
      catch e
        console.warn('This device isnt tv_webos platform', e)

    requestVolume : (params)->
      try
        webOS.service.request('luna://com.webos.audio', params)
      catch e
        console.warn('This device isnt tv_webos platform', e)

    setVolume : (volume = 30)->
      self = pateco.PlayerService
      self.onVolumeChange(30)
#    params =
#      method  :'volumn
    getVolume : ()->
      self = pateco.PlayerService
      self.onVolumeChange(30)
      return 30

    unloadDrmClient : ()->
      return unless self.options.webos.isDrmClientLoaded
      params =
        method : 'unload'
        parameters :
          clientId : self.options.webos.clientId
        onSuccess : (result) ->
          self.options.webos.isDrmClientLoaded = false
        onFailure : (result) ->
          data =
            code : 2
            message : ["connect-error-try", "#1501"]
            default : result
          self.onError(data)

      tv_webos.requestDrm(params)
      null

    loadDrmClient : ()->
      params =
        method : 'load'
        parameters :
          drmType : self.options.webos.drmType
          appId : self.options.webos.appId
        onSuccess : (result) ->
          self.options.webos.clientId = result.clientId
          self.options.webos.isDrmClientLoaded = true
          tv_webos.sendRightInformation()
        onFailure : (result) ->
          data =
            code : 2
            message : ["connect-error-try", "#1502"]
            default : result
          self.onError(data)
      tv_webos.requestDrm(params)
      null

    sendRightInformation : ()->
      params =
        method : 'sendDrmMessage'
        parameters :
          clientId : self.options.webos.clientId
          msgType : 'json'
          msg : self.options.webos.msg
          drmSystemId : self.options.webos.drmSystemId

        onSuccess : (result) ->
          console.info 'LG request DRM success'
          self.options.webos.msgId = result.msgId
          tv_webos.setPlaybackOptions()

        onFailure : (result) ->
          console.info 'LG request DRM unsuccess', result
          data =
            code : 2
            message : ["connect-error-try", "#1503"]
            default : result
          self.onError(data)
      console.info 'LG request DRM with parameters', params.parameters
      tv_webos.requestDrm(params)
      null

    prepareSource : ()->
      params =
        option :
          drm :
            type : self.options.webos.drmTypeInit
            clientId : self.options.webos.clientId
      source = document.createElement('source')
      source.setAttribute 'src', self.options.url
      if _.isEmpty self.options.drm
        source.setAttribute 'type', 'application/x-mpegurl;'
      else
        source.setAttribute 'type', 'application/x-mpegurl;mediaOption=' + escape(JSON.stringify(params))
      return source

    setPlaybackOptions : () ->
      source = tv_webos.prepareSource()
      self.options.webos.player.appendChild source
      if self.options.skdVersion is 3
        self.options.webos.player.load()
      else
        self.options.webos.player.play()

    listener20 : ()->
      console.log 'init listener 2.0'
      timeoutload = setTimeout(()->
        data =
          code : 2
          message : ["connect-error-try", "#1520"]
          detail : "Can not load #{self.options.url}"
        self.onError(data)
      , 20000)
      self.options.webos.player.addEventListener 'durationchange', () ->
        setTimeout.clear(timeoutload)
        if self.options.state is 'STOP'
          return
        self.options.webos.player.play()
        self.options.state = 'PLAY'
        self.options.webos.player.currentTime = self.options.position if self.options.position isnt 0
        self.onPlay()

      self.options.webos.player.addEventListener 'pause', ()->
        console.log 'on pause'
        self.options.state = 'PAUSE'

      self.options.webos.player.addEventListener 'playing', ()->
        console.log 'on play'
        self.options.state = 'PLAY'

      self.options.webos.player.addEventListener 'timeupdate', ()->
        self.onCurrentPlaytime(tv_webos.getCurrentTime())

      self.options.webos.player.addEventListener 'error', (error)->
        data =
          code : 2
          message : ["connect-error-try", "#1500"]
          detail : error
        self.onError(data)

      self.options.webos.player.addEventListener 'waiting', ()->
        self.onBufferingStart()
      self.options.webos.player.addEventListener 'ended', ()->
        self.onStreamCompleted()

    listener : ()->
      console.log 'init listener 3.0'
      #      timeoutload = setTimeout(()->
      #        data =
      #          code   : 2
      #          message: 'Kết nối đến hệ thống bị gián đoạn vui lòng thử lại sau, #1520'
      #          detail : "Can not load #{self.options.url}"
      #        self.onError(data)
      #      , 20000)
      self.options.webos.player.onloadedmetadata = () ->
#        setTimeout.clear(timeoutload)
        console.log 'onload metadata', self.options.state
        if self.options.state is 'STOP'
          console.log 'stop'
          return
        self.options.webos.player.play()
        self.options.state = 'PLAY'
        self.options.webos.player.currentTime = self.options.position if self.options.position isnt 0
        self.onPlay()
      self.options.webos.player.onpause = ()->
        console.log 'on pause'
        self.options.state = 'PAUSE'

      self.options.webos.player.onplay = ()->
        console.log 'on play'
        self.options.state = 'PLAY'

      self.options.webos.player.ontimeupdate = ()->
        self.onCurrentPlaytime(tv_webos.getCurrentTime())

      self.options.webos.player.onerror = (error)->
        console.log error
        data =
          code : 2
          message : ["connect-error-try", "#1500"]
          detail : error
        self.onError(data)

      self.options.webos.player.onloadstart = (da) ->
        self.onBufferingStart()
      self.options.webos.player.onended = (data)->
        self.onStreamCompleted()

    getState : ()->
      try
        self.options.state
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    getCurrentTime : ()->
      try
        return self.options.webos.player.currentTime
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    getDuration : ()->
      try
        return self.options.webos.player.duration
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    pause : ()->
      try
        self.options.webos.player.pause()
        self.options.state = 'PAUSE'
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    stop : ()->
      try
        self.options.state = 'STOP'
        #      self.options.webos.player.
        self.options.webos.player.remove()
        document.getElementById(self.options.element).remove();
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    seekTo : (second = 0)->
      try
        console.log 'is seekto', second
        self.options.webos.player.currentTime = second
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    forward : (second = 60)->
      try
        self.options.webos.player.currentTime = self.options.webos.player.currentTime + second
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    backward : (second = 60)->
      try
        self.options.webos.player.currentTime = self.options.webos.player.currentTime - second
      catch e
        console.warn('This device isnt TV_WEBOS platform', e)

    play : ()->
      return self.options.webos.player.play() if tv_webos.getState() is 'PAUSE'
      unless _.isEmpty self.options.drm
        tv_webos.loadDrmClient()
        return
      tv_webos.setPlaybackOptions()