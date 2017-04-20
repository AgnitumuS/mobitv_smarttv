fimplus._player =
  video:
    state          : 'PLAY'
    currentTime    : 0
    duration       : 0
    currentTimeSeek: 0
    currentPrecent : 0
    getVolume      : ()->
      return fimplus.PlayerService.getVolume()
    getCurrentTime : ()->
      return fimplus.PlayerService.getCurrentTime()
    getDuration    : ()->
      return fimplus.PlayerService.getDuration()
    getState       : ()->
      return fimplus.PlayerService.getState()
    seekTo         : (second = 60)->
#      fimplus._player.pushProgressWhenHasEvent()
      fimplus.PlayerService.seekTo(second)
    play           : ()->
      fimplus.PlayerService.play()
    pause          : ()->
#      fimplus._player.pushProgressWhenHasEvent()
      fimplus.PlayerService.pause()
    stop           : ()->
#      fimplus._player.pushProgressWhenHasEvent()
      fimplus.PlayerService.stop()
    backward       : ()->
#      fimplus._player.pushProgressWhenHasEvent()
      fimplus.PlayerService.backward()
    forward        : ()->
#      fimplus._player.pushProgressWhenHasEvent()
      fimplus.PlayerService.forward()
  
  data:
    percentOld          : 0
    firstTrack          : false
    item                : {}
    retryTime           : 0
    callback            : ()->
      console.log 'callback'
    playlist            : []
    marker              : []
    subtitle            : []
    subtitleEnable      : false
    snapshot            : []
    step                : 12
    drm                 : {}
    view                : '' # control , subtitle, icback
    currentActionButtons: 0
    buttonActions       : []
    
    callback: ()->
      console.log 'login callback'
  
  initPage: (item, callback)->
    self = fimplus._player
    #    self.data.item = item
    self.data.item = _.clone item
    self.data.userSetting = fimplus.UserService.getUserSetting()
    self.data.callback = ()->
      console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.percentOld = 0
    self.firstTrack = false
    self.playlist = []
    self.data.retryTime = 0
    self.data.step = 12
    self.prepareButtonActions()
    self.render()
    self.initTriggerClickActionButton()
    self.displayControl()
    self.setSettingSubtitle()
    self.initKey()
    self.initSocket()
    self.initPlayer()
    fimplus._page.activeIconBack(false)
    fimplus.config.state = 'player'
    null
  
  triggerClickActionButtons: (event, value)->
    self = fimplus._player
    unless value
      self.data.currentActionButtons = $(@).index()
      self.enableButtonActions()
    self.data.buttonActions[self.data.currentActionButtons].action()
  
  enableButtonActions: (active = true)->
    self = fimplus._player
    button = self.element.find('.player-bt a')
    button.removeClass('active')
    if active
      button.eq(self.data.currentActionButtons).addClass('active')
  
  initTriggerClickActionButton: ()->
    self = fimplus._player
    button = self.element.find('.player-bt a')
    button.off 'click'
      .on 'click', self.triggerClickActionButtons
  
  displaySettingSubtitle: ()->
    self = fimplus._player
    self.video.pause()
    items =
      sounds  : []
      subtitle: self.data.subtitle
    
    fimplus._playerSetting.initPage(items, self.onReturnPlayer)
  
  prepareButtonActions: ()->
    self = fimplus._player
    console.log self.data.item
    soundAndSub =
      title : 'play-option-audio-sub'
      icon  : 'ic-sub'
      action: self.displaySettingSubtitle
    
    season =
      title : 'select-season'
      icon  : 'ic-season'
      action: ()->
        self.onClosePlayer()
        console.log 'on season click'
    self.data.currentActionButtons = 0
    
    if self.data.item.type is 'Movie'
      self.data.buttonActions = [soundAndSub]
      return
    
    self.data.buttonActions = [soundAndSub, season]
  
  setSubtitle: (currentTime)->
    self = fimplus._player
    unless self.data.subtitleEnable
      return
    data = self.data.subtitle["VI"]
    
    if _.isEmpty(data)
      return
    
    subEl = self.element.find('.player-sub')
    subText = subEl.find('span')
    sub = fimplus.SubtitleService.search(self.data.subtitle, currentTime)
    if sub
      subEl.show()
      subText.html(sub.text)
    else
      subEl.hide()
      subText.html('')
  
  changePositionSubtitle: (position = 'down')->
    self = @
    subEl = self.element.find('.player-sub')
    transform = 0
    transform = 0 if position is 'down'
    transform = 100 if position is 'up'
    subEl.css({
      transform: "translateY(-#{transform}%)"
    })
  
  setSettingSubtitle: ()->
    self = @
    
    setting = self.data.userSetting
    subEl = self.element.find('.player-sub')
    subText = subEl.find('span')
    if setting.subtitleState is 'off'
      self.data.subtitleEnable = false
      return subEl.hide()
    self.data.subtitleEnable = true
    subText.css({
      'background-color': "rgba(0,0,0,#{setting.subtitleOpacity})"
      'color'           : "#{setting.subtitleColor}"
    })
    subText.removeClass().addClass(setting.subtitleSize)
  
  
  render: ()->
    self = fimplus._player
    source = Templates['module.player']()
    template = Handlebars.compile(source);
    self.element = $('#player-wrapper')
    self.element.html(template(self.data))
  
  reRender: (item)->
    self = fimplus._player
    self.data.item = item
    self.saveProgress()
    self.video.stop()
    self.element.html('')
    self.prepareButtonActions()
    self.render()
    self.initTriggerClickActionButton()
    self.displayControl()
    self.setSettingSubtitle()
    self.initKey()
    self.initSocket()
    self.initPlayer()
  
  setLoading: (active = true) ->
    self = @
    loading = self.element.find('.player-loading')
    if active
      loading.show()
    else
      loading.hide()
  
  getFirstEpisode: (id, cb)->
    fimplus.ApiService.getFirstEpisode(id, cb)
  
  initSessionPlay: (id, cb)->
    fimplus.ApiService.initSessionPlay(id, cb)
  
  getLinkPlay: (session, cb)->
    self = fimplus._player
    params =
      id           : session.movieId
      sessionPlayId: session.sessionPlayId
      tokenPairing : self.data.item.tokenPairing?
    fimplus.ApiService.getPlayList(params, cb)
  
  getSubtitleDone: (subtitle)->
    self = fimplus._player
    self.data.subtitle = subtitle
  
  handleError: (error)->
    self = fimplus._player
    fimplus._error.initPage({
      onReturn   : self.data.callback()
      description: ['connect-error', '#1000']
      title      : 'notification'
      buttons    : [
        title   : 'button-try-again'
        callback: self.initTrailer()
      ]
    })
    return console.log error
  
  converPlaylist: (data)->
    self = fimplus._player
    playlist = _.pluck(_.flatten(_.pluck data, 'playlist'), 'url')
    return playlist
  
  finishedInitTrailer: (error, result)->
    self = fimplus._player
    return self.handleError(error) if error
    self.data.playlist = self.converPlaylist(result)
    self.data.drm = {}
    self.triggerPlayer()
  
  finishedInitPlayer: (error, result)->
    self = fimplus._player
    if error
      return console.log error
    self.data.playlist = self.converPlaylist(result.newPlaylist)
    
    self.data.snapshot =
      step: result.snapshotStep || 0
      data: result.snapshotImgs || []
    
    fimplus._playerSnapshot.initSnapshot(self.data.snapshot)
    
    unless _.isEmpty(result.subtitle)
      fimplus.SubtitleService.getContentSubFromServer(result.subtitle, self.getSubtitleDone)
    else
      self.data.subtitle = {}
    self.data.marker = result.marker || []
    self.data.drm =
      userId   : result.key.user_id
      sessionId: result.sessionPlayId
      merchant : result.key.mechant_id
      assetId  : result.key.source_id
    self.triggerPlayer()
  
  triggerPlayer: ()->
    self = fimplus._player
    fimplus.PlayerService.setup({
      url     : self.data.playlist[self.data.retryTime]
      wrapper : '#player'
      element : 'fp-player'
      env     : fimplus.config.env
      platform: fimplus.config.platform
      position: self.data.item.progress?.progress || 0
      percent : self.data.item.progress?.percent || 0
      drm     : self.data.drm || {}
      duration: 0
      listener:
        onError            : self.onError
        onPlay             : self.onPlay
        onCurrentPlaytime  : self.onCurrentPlaytime
        onBufferingStart   : self.onBufferingStart
        onStreamCompleted  : self.onStreamCompleted
        onBufferingComplete: self.onBufferingComplete
        onVolumeChange     : self.onVolumeChange
        onStateChange      : self.onStateChange
    })
    self.data.retryTime++
    self.data.retryTime = fimplus.KeyService.reCalc(self.data.retryTime, self.data.playlist.length)
  
  
  onReturnPlayer: ()->
    self = fimplus._player
    self.initKey()
    self.video.play() if self.video and _.isFunction(self.video.play)
  
  onStateChange: (state)->
    self = fimplus._player
    self.changeIconPlayer(state)
    
    param =
      type   : 'remote'
      action : 'onStateChange'
      state  : state
      message: ''
    
    fimplus.TizenService.socket.sendMessage(param)
  
  onError: (error)->
    console.error 'error', error
    message = "Kết nối đến hệ thống tạm thời bị gián đoạn,#1702"
    try
      message = error.message
    catch e
      console.log e
    self = fimplus._player
    fimplus._error.initPage({
      onReturn   : ()->
        self.onClosePlayer()
      description: error.message || "Kết nối đến hệ thống tạm thời bị gián đoạn,#1702"
      title      : 'Thông báo'
      buttons    : [
        title   : 'Hủy'
        callback: self.onClosePlayer
      ,
        title   : 'Thử lại'
        callback: ()->
          self.initKey()
          self.initPlayer()
      ]
    })
    # send error whene pairing
    
    param =
      type   : 'error'
      message: ''
      detail : error
    fimplus.TizenService.socket.sendMessage(param)
  
  onPlay: ()->
    self = fimplus._player
    console.info 'on play'
#    console.log 'self.video.currentTime',self.video.currentTime
#    console.log 'self.video.duration',self.video.getDuration()
  
  onCurrentPlaytime: (currentTime)->
    self = fimplus._player
    self.calcPercent(currentTime) if self.video.currentTimeSeek is 0
    self.video.duration = self.video.getDuration()
    self.setSubtitle(currentTime * 1000)
    return if self.data.item.isTrailer
    self.saveProgress()
    
    param =
      currentTime: self.video.currentTime
      duration   : self.video.duration
      type       : 'remote'
      action     : 'progress'
      movieId    : self.data.item.id
    fimplus.TizenService.socket.sendMessage(param)
  
  onBufferingComplete: ()->
    fimplus._player.setLoading(false)
  
  onBufferingStart: ()->
    fimplus._player.setLoading()
  
  contentMarker: ()->
    self = fimplus._player
    if !self.data.item.isTrailer
      marker = self.data.marker
      if marker.length isnt 0
        for item in [0..marker.length - 1]
          if marker[item].action is "NextMovie"
            movieId = marker[item].nextMovieId
            done = (error, result)->
              if error
                fimplus._error.initPage({
                  onReturn   : self.data.callback
                  description: 'Kết nối tới hệ thống bị chập chờn!,#1000'
                  title      : 'Thông báo'
                  buttons    : [
                    title   : 'Thử lại'
                    callback: self.initPlayer
                  ]
                })
                return
              self.reRender(result.episodeInfo.episode)
            fimplus.ApiService.getEntityDetail(movieId, done)
            return true
    return false
  
  onStreamCompleted: ()->
    self = fimplus._player
    return if self.contentMarker()
    self.onClosePlayer()
  
  onVolumeChange: (value)->
    param =
      type   : 'remote'
      action : 'onVolumeChange'
      volume : value
      message: ''
    fimplus.TizenService.socket.sendMessage(param)
  onClosePlayer : ()->
    self = fimplus._player
    self.saveProgress()
    self.video.stop()
    self.removePage()
    fimplus.config.state = ''
    paramPairing =
      type   : 'remote'
      message: 'Tv exit player'
      action : 'disconnect'
    fimplus.TizenService.socket.sendMessage(paramPairing)
  
  
  
  removePage: ()->
    self = fimplus._player
    self.element.html('')
    self.data.callback()
  
  converTime: (seconds)->
    hh = Math.floor(seconds / 3600)
    mm = Math.floor(seconds / 60) % 60
    ss = Math.floor(seconds) % 60
    return ((if hh then ((if hh < 10 then "0" else "")) + hh + ":" else "")) + ((if (mm < 10) then "0" else "")) + mm + ":" + ((if (ss < 10) then "0" else "")) + ss
  
  calcPercent: (currentTime)->
    self = @
    self.video.currentTime = currentTime
    self.video.currentPrecent = "#{currentTime / self.video.duration * 100}%"
    self.setStatusbar()
  
  changeIconPlayer: (state)->
    console.log state
    self = fimplus._player
    btn = self.element.find('.button-status')
    switch state
      when 'PLAY'
        self.setLoading(false)
        btn.removeClass('ic-play').addClass('ic-pause')
      when 'PAUSE'
        btn.removeClass('ic-pause').addClass('ic-play')
  
  enablePointer: (active = true)->
    self = fimplus._player
    pointer = self.element.find('.bar-pointer')
    if active
      pointer.show()
    else
      pointer.hide()
  
  pushProgressWhenHasEvent: ()->
    self = fimplus._player
    params =
      movieId : self.data.item.id
      progress: parseInt(self.video.currentTime)
      total   : parseInt(self.video.duration)
    fimplus.ApiService.trackProgress(params)
    console.info 'player._player pushProgressWhenHasEvent [seekTo, pause, stop]', params
  
  
  saveProgress: ()->
    self = fimplus._player
    params =
      movieId : self.data.item.id
      progress: parseInt(self.video.currentTime)
      total   : parseInt(self.video.duration)
    if Math.ceil(params.progress) < 2 and self.data.firstTrack is false
      self.data.firstTrack = true
      #      console.log 'saveProgress firstTrack=', params
      fimplus.ApiService.trackProgress(params)
    
    percent = Math.ceil(params.progress / params.total * 100)
    timeSaveProgress = percent % 5
    if timeSaveProgress is 0 and self.data.percentOld isnt percent
      self.data.percentOld = _.clone percent
      #      console.log 'fimplus._player percent % 5=0;  saveProgress=', params
      fimplus.ApiService.trackProgress(params)
  
  setStatusbar: ()->
    self = fimplus._player
    player = self.element
    currentTime = player.find('.current-time')
    durationTime = player.find('.duration-time')
    bufferBar = player.find('.buffer-bar')
    pointer = player.find('.bar-pointer')
    pointer.css({
      left: "#{self.video.currentPrecent}"
    })
    bufferBar.css({width: "#{self.video.currentPrecent}"})
    currentTime.html(self.converTime(self.video.currentTime))
    durationTime.html(self.converTime(self.video.duration))
  
  initTrailer: (item)->
    self = fimplus._player
    id = self.data.item.id
    fimplus.ApiService.getTrailer(id, self.finishedInitTrailer)
  
  
  initPlayer: (data)->
    self = fimplus._player
    self.setLoading()
    if data
      self.data.item = data
    item = self.data.item
    
    if item.isTrailer
      self.initTrailer(item)
      return
    
    tasks = []
    if item.type is 'Show' and !item.isEpisode
      tasks.push(self.getFirstEpisode.bind(@, item.id))
      tasks.push(self.initSessionPlay)
    else
      tasks.push(self.initSessionPlay.bind(@, item.id))
    
    tasks.push(self.getLinkPlay)
    
    async.waterfall(tasks, self.finishedInitPlayer)
  
  activeIcBack: (active = false)->
    self = fimplus._player
    icBack = self.element.find('.ic-back')
    if active is true
      icBack.addClass('active')
    else
      icBack.removeClass('active')
  
  displayControl: (active = false)->
    self = fimplus._player
    element = $('#player-wrapper')
    classControl = ".player-bottom, .player-header,.gradient-top,.gradient-bottom"
    if active
      self.view = 'control' if self.view is ''
      element.find(classControl).fadeIn()
      self.changePositionSubtitle("up")
    else
      self.view = ''
      self.enableButtonActions(false)
      element.find(classControl).fadeOut()
      self.changePositionSubtitle("down")
      self.video.currentTimeSeek = 0
      fimplus._playerSnapshot.enableSnapshot(false)
  
  enableControlBar: (timeEnable = true)->
    self = fimplus._player
    self.displayControl(true)
    clearTimeout(self.timeoutcloseview)
    return unless timeEnable
    self.timeoutcloseview = setTimeout(()->
      return if self.video.getState() is 'PAUSE'
      self.displayControl()
    , 5000)
  
  handleWhenKeyEnter: ()->
    self = fimplus._player
    switch self.view
      when 'icback'
        self.activeIcBack(false)
        self.onClosePlayer()
        break
      
      when 'subtitle'
        self.triggerClickActionButtons(null, 'enter')
        break;
      when 'control'
        if self.video.currentTimeSeek isnt 0
          self.video.seekTo(self.video.currentTimeSeek)
          self.displayControl()
          self.video.play()
          fimplus._player.pushProgressWhenHasEvent()
          return
        
        if self.video.getState() in ['PLAY']
          self.video.pause()
          self.enableControlBar(false)
          fimplus._player.pushProgressWhenHasEvent()
          return
        
        if self.video.getState() in ['PAUSE']
          self.video.play()
          self.displayControl()
          fimplus._player.pushProgressWhenHasEvent()
          return
  
  handleWhenKeyUpDown: (key) ->
    self = fimplus._player
    switch self.view
      when 'control'
        if key is 'down'
          fimplus._playerSnapshot.enableSnapshot(false)
          self.enablePointer(false)
          self.enableButtonActions()
          self.view = 'subtitle'
        if key is 'up'
#          console.log 'add class active into icback'
          self.activeIcBack(true)
          fimplus._playerSnapshot.enableSnapshot(false)
          self.enablePointer(false)
          self.view = 'icback'
      
      when 'subtitle'
        if key is 'up'
          fimplus._playerSnapshot.enableSnapshot()
          self.enablePointer()
          self.enableButtonActions(false)
          self.view = 'control'
      when 'icback'
        if key is 'down'
#          console.log 'remove class active from icback'
          self.activeIcBack(false)
          fimplus._playerSnapshot.enableSnapshot(true)
          self.enablePointer(true)
          self.view = 'control'
  
  handleWhenKeyLeftRight: (key)->
    self = fimplus._player
    switch self.view
      when 'icback'
        return
      when  'subtitle'
        fimplus._playerSnapshot.enableSnapshot(false)
        if key is 'left'
          self.data.currentActionButtons--
        if key is 'right'
          self.data.currentActionButtons++
        self.data.currentActionButtons = fimplus.KeyService.reCalc(self.data.currentActionButtons, self.data.buttonActions.length)
        self.enableButtonActions()
        break;
      
      when 'control'
#        self.data.step = 120
        
        currentTime = self.video.getCurrentTime()
        duration = self.video.getDuration()
        return if duration < 1
        fimplus._playerSnapshot.enableSnapshot()
        self.video.currentTimeSeek = currentTime if self.video.currentTimeSeek is 0
        if key is 'left'
          self.video.pause()
          self.enableControlBar(false)
          self.video.currentTimeSeek -= self.data.step if self.video.currentTimeSeek > 0
          self.video.currentTimeSeek = 1 if self.video.currentTimeSeek < 0
        
        if key is 'right'
          self.video.pause()
          self.enableControlBar(false)
          self.video.currentTimeSeek += self.data.step
          if self.video.currentTimeSeek > duration
            self.video.currentTimeSeek = duration - 12
        
        if self.data.step < 120
          self.data.step += 1
        clearTimeout(self.data.timeoutClearStep)
        self.data.timeoutClearStep = setTimeout(()->
          self.data.step = 12
        , 100)
        if self.video.currentTimeSeek > 12
          self.video.currentTimeSeek = Math.round(self.video.currentTimeSeek / 12) * 12
        fimplus._playerSnapshot.calcPositionSnapshot(self.video.currentTimeSeek)
        self.calcPercent(self.video.currentTimeSeek)
  
  handleKey: (keyCode, key)->
    self = fimplus._player
    console.info 'Player Key:' + keyCode
    
    # This code is only show layout'control when keypress is down and up and do not do any action more
    if keyCode in [key.DOWN, key.UP] and self.view is ''
      self.enableControlBar()
      return
    
    # This code detech if any touch will enable the control layout
    unless keyCode in [key.RETURN, key.STOP]
      self.enableControlBar()
    
    switch keyCode
      when key.RETURN
        if self.view isnt ''
          self.video.play()
          return self.displayControl()
        return self.onClosePlayer()
      when key.ENTER
        self.handleWhenKeyEnter()
        break;
      when key.LEFT
        self.handleWhenKeyLeftRight('left')
        break;
      when key.RIGHT
        self.handleWhenKeyLeftRight('right')
        break;
      when key.DOWN
        self.handleWhenKeyUpDown('down')
        break;
      when key.UP
        self.handleWhenKeyUpDown('up')
        break;
      when key.PLAY
        self.video.play()
        break;
      when key.PAUSE
        self.video.pause()
        self.enableControlBar(false)
        self.enablePointer()
        
        break;
      when key.BACKWARD
        self.video.backward()
        break;
      when key.FORWARD
        self.video.forward()
        break;
      when key.PLAY_PAUSE
        if self.video.getState() is 'PLAY'
          return self.video.pause()
        if self.video.getState() is 'PAUSE'
          return self.video.play()
      when key.STOP
        return self.onClosePlayer()
  
  initKey: ()->
    self = fimplus._player
    fimplus.KeyService.initKey(self.handleKey)
  
  
  initSocket: ()->
    self = fimplus._player
    remoteOptions =
      onDisconnect       : ()->
        self.onClosePlayer()
      onBufferingProgress: ()->
      
      onGetVolume        : ()->
        return self.video.getVolume()
      
      onPlay        : ()-> self.video.play()
      onSeekTo      : (data)-> self.video.seekTo(data.time)
      onSetVolume   : (data)-> self.video.setVolume(data.volume)
      onGetState    : ()-> self.video.getState()
      onPause       : ()-> self.video.pause()
      onStop        : ()-> self.onClosePlayer()
      onForward     : ()-> self.video.forward()
      onBackward    : ()-> self.video.backward()
      getCurrentTime: ()-> self.video.getCurrentTime()
      getDuration   : ()-> self.video.getDuration()
    
    fimplus.TizenService.socket.remote.setup(remoteOptions)
  