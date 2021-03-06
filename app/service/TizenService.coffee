pateco.TizenService =
  initConfig : ()->
    self = pateco.TizenService
    self.previewFeature()
    self.appResume()
    self.socket.init()
    self.checkDeeplink()
    self.initNetworkDetect()

  initNetworkDetect : ()->
    if pateco.platform is 'tv_tizen'
      try
        webapis.network.addNetworkStateChangeListener((data)->
          if data == 5
            pateco.UtitService.handleDisconnect()
        )
      catch err


  appResume : ()->
    onVisiable = ()->
      status = 1
      status = 0 if document.hidden
      pateco.UtitService.handleAppResume(status)
      console.log 'appresume', status
    $(document).on 'visibilitychange', onVisiable

  checkDeeplink : ()->
    reqAppControl = tizen.application.getCurrentApplication().getRequestedAppControl()
    return unless reqAppControl
    launchData = reqAppControl.appControl.data

    return unless  _.isArray launchData
    _.map launchData, (item)->
      if item.key is 'PAYLOAD'
        actionData = JSON.parse(JSON.parse(item.value[0]).values)
        return if actionData.id is undefined
        done = (error, result)->
          return if error
          pateco._banner.reRender(result)
          pateco._detail.initPage(result, pateco._page.onReturnPage)
        pateco.ApiService.getEntityDetail(actionData.id, done)

    #        $state.go 'movie-detail', {id: actionData.id}
    return

  previewFeature : ()->
    self = pateco.TizenService
    try
      acceleratorSupport = tizen.systeminfo.getCapability('http://tizen.org/custom/accelerator')
    catch e
      console.info 'not support accelerator', e
    if acceleratorSupport
      console.info 'support accelerator'
      window.addEventListener 'appcontrol', self.checkDeeplink

  socket :
    channel : null
    sendMessage : (param = {})->
      self = pateco.TizenService.socket
      return if _.isEmpty(param)
      if self.channel is null
        return
      self.channel.publish('msg', param)

    remote :
      onDisconnect : ()->
        console.info 'Tizen on dis'
      setup : (param = {})->
        self = pateco.TizenService.socket
        _.map param, (func, key)->
          if _.isFunction(func)
            console.info "Init listener socket #{key} success!"
            self.remote[key] = func
          else
            console.warn('Listener ' + key + ' is not function')
      onSeekTo : (data)->
        console.log data
      onSetVolume : (data)->
        console.log data
      onGetVolume : (data)->
        return 30
      getCurrentTime : ()->
        return 30
      getDuration : ()->
        return 3000

      onOpen : (data)->
        done = (error, result)->
          return if error
          pateco._banner.reRender(result)
          if result.progress
            result.progress.progress = data.currentTime
          result.tokentPairing = data.tokens.hd1_cm
          if pateco.config.state isnt 'player'
            pateco._player.initPage(result, pateco._page.initPage)
          else
            pateco._player.initPlayer(result)
        pateco.ApiService.getEntityDetail(data.movieId, done)

      onPlay : (data)->
        console.log data
      onStop : (data)->
        console.log data
      onPause : (data)->
        console.log data
      onForward : (data)->
        console.log data
      onBackward : (data)->
        console.log data
      onGetState : (data)->
        return 'IDLE'
    handleAuthen : (data)->
      self = pateco.TizenService.socket
      param =
        type : 'authen'
        message : ''
      switch data.action
        when 'login'
          params = pateco.UtitService.formatTicket data.tickets
          pateco.ApiService.loginServices params, (error, result)->
            if error
              param.action = 'login_error'
              param.detail = error
              self.sendMessage(param)
              return console.error(error)

            param.action = 'login_success'
            param.detail = result
            param.tokens =
              hd1_cm : result.hd1_cm.access_token
              hd1_billing : result.hd1_billing.access_token
              hd1_payment : result.hd1_payment.access_token
              hd1_cas : result.hd1_cas.access_token

            if pateco.UserService.isLogin()
              console.log 'user is login', param
              return self.sendMessage(param)

            pateco.UserService.saveToken(result)
            pateco.ApiService.getUserProfile((error, user)->
              unless error
                pateco.UserService.saveProfile(user)
              self.sendMessage(param)
#            $rootScope.ticker = true
#            $state.go 'home'
            )
        else
          param.action = 'action_not_allow'
          self.sendMessage(param)
    handleRemote : (data = {})->
      self = pateco.TizenService.socket
      if data.action is 'open'
        unless data.tokens
          param =
            type : 'remote'
            message : 'Tokens must be define'
            action : 'remote_success'
          return self.sendMessage(param)

        self.remote.onOpen(data)
        return
      return if pateco.config.state isnt 'player'

      param =
        type : 'remote'
        message : ''
        action : 'remote_success'
      switch data.action
        when 'open'
          self.remote.onOpen(data)
        when 'play'
          self.remote.onPlay()
        when 'stop'
          self.remote.onStop()
        when 'forward'
          self.remote.onForward()
        when 'backward'
          self.remote.onBackward()
        when 'pause'
          self.remote.onPause()
        when 'seekto'
          self.remote.onSeekTo(data)
        when 'setVolume'
          self.remote.onSetVolume(data)
        when 'getVolume'
          param.volume = self.remote.onGetVolume()
          param.action = data.action
          self.sendMessage(param)
        when 'getState'
          param.state = self.remote.onGetState()
          param.action = data.action
        else
          param.action = 'action_not_allow'
      self.sendMessage(param)

    handleMessage : (data = {}) ->
      self = pateco.TizenService.socket
      param = data
      switch data.type
        when 'status'
          param.action = ''
          param.message = ''
          param.isLogin = pateco.UserService.isLogin()
          param.profile = pateco.UserService.getProfile()
          param.tokens =
            hd1_cm : localStorage.hd1_cm
            hd1_billing : localStorage.hd1_billing
            hd1_payment : localStorage.hd1_payment
            hd1_cas : localStorage.hd1_cas

          if pateco.config.state is 'player'
            param.movieId = pateco._player.data.item.id
            param.currentTime = self.remote.getCurrentTime()
            param.duration = self.remote.getDuration() #second
            param.volume = self.remote.onGetVolume() #second
            param.state = self.remote.onGetState() #second
          self.sendMessage(param)
        when 'authen' #have message
          self.handleAuthen(param)
          break
        when 'remote'
          self.handleRemote(param)
          break
        else
          param.action = 'action_not_allow'
          self.sendMessage(param)
          break
    init : ()->
      self = pateco.TizenService.socket
      self.channel = null
      onDisconnect = ()->
        console.info 'You are now disconnected'

      connectChannelSuccess = (err) ->
#        self.channel.off 'msg'
        self.channel.on 'msg', self.handleMessage
        #        self.channel.off 'disconnect'
        self.channel.on 'disconnect', onDisconnect

      connectSuccess = (err, service) ->
        if err
          console.log 'connect error', err
          return
        self.channel = service.channel('vn.pateco')
        self.channel.connect {name : 'TV'}, connectChannelSuccess

      msf.local connectSuccess