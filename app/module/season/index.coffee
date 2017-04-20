Handlebars.registerPartial('seasonList', Templates['module.season.season_list']());
Handlebars.registerPartial('episodeList', Templates['module.season.episode_list']());

fimplus._season =
  data    :
    id                  : '#season'
    seasonListId        : '#season .seasons'
    episodeListId       : '#season .episodes'
    isLoading           : false
    timeAnimate         : 300
    item                : {}
    seasons             : []
    episodes            : []
    template            : Templates['module.season']()
    currentSeasonActive : 0
    currentEpisodeActive: 0
    layoutActive        : 'season' # episode
    callback            : ()->
  
  initPage: (item, callback)->
    self = fimplus._season
    self.data.item = item
    self.data.callback = callback if _.isFunction(callback)
    self.getData()
    self.initKey()
    self.data.layoutActive = 'season' # episode
    self.data.currentSeasonActive = 0
    self.data.currentEpisodeActive = 0
    fimplus._page.activeIconBack()
  
  render: (item = {})->
    self = @
    self.data.item = item
    self.data.item.seasons = self.data.seasons
    self.data.item.episodes = self.data.episodes
    self.data.item.model4K = fimplus.config.appInfo.model4K
    template = Handlebars.compile(self.data.template)
    self.element = $(self.data.id)
    self.element.html(template(self.data.item))
    
    seasonItemEl = $(self.data.seasonListId).find('ul.list-item').find('.item.active')
    seasonItemEl.off 'click'
    seasonItemEl.on 'click', self.eventSeasonItemClick
    episodeItemEl = $(self.data.episodeListId).find('ul.list-item').find('.item.active')
    episodeItemEl.off 'click'
    episodeItemEl.on 'click', self.eventEpisodeItemClick
  
  
  removeSeasonPage: ()->
    self = fimplus._season
    self.element.html('')
    self.data.currentSeasonActive = 0
    self.data.currentEpisodeActive = 0
    self.data.callback() if _.isFunction(self.data.callback)
  
  
  opacityListItem: (type = 'season')->
    self = fimplus._season
    seasonsList = $(self.data.seasonListId).find('ul.list-item')
    episodesList = $(self.data.episodeListId).find('ul.list-item')
    if type is 'on_all'
      seasonsList.css({opacity: 0.5})
      episodesList.css({opacity: 0.5})
      return
    if type is 'off_all'
      seasonsList.css({opacity: 1})
      episodesList.css({opacity: 1})
      return
    if type is 'season'
      seasonsList.css({opacity: 1})
      episodesList.css({opacity: 0.5})
    else
      seasonsList.css({opacity: 0.5})
      episodesList.css({opacity: 1})
  
  
  animateScroll: ()->
    self = fimplus._season
    episodeListElement = $(self.data.episodeListId).find('ul.list-item')
    seasonEl = $(self.data.seasonListId).find('ul.list-item').find('li.item')
    currentEpisode = self.data.episodes[self.data.currentEpisodeActive]
    currentSeason = self.data.seasons[self.data.currentSeasonActive]
    if self.data.layoutActive is 'episode'
      length = episodeListElement.find('.item').length
      tranlateData = self.data.currentEpisodeActive / length * 100
      css = {
        transform          : "translateY(-#{tranlateData}%)"
        "-webkit-transform": "translateY(-#{tranlateData}%)"
      }
      episodeListElement.css(css)
    
    self.data.currentSeasonActive = currentEpisode.indexBelongSeason
    seasonEl.removeClass('active selected')
    seasonEl.eq(self.data.currentSeasonActive).addClass('active selected')
    
    if self.data.layoutActive is 'season'
      self.data.currentEpisodeActive = currentSeason.indexStartEpisode
    seasonEl.removeClass('active').eq(self.data.currentSeasonActive).addClass('active')

  
  eventEpisodeItemClick: ()->
    self = fimplus._season
    unless fimplus.UserService.isLogin()
      fimplus._login.initPage(()->
        fimplus._season.initPage(self.data.item, self.data.callback)
      )
      return
    currentEpisode = self.data.episodes[self.data.currentEpisodeActive]
    $(self.data.id).html('')
    fimplus._player.initPage(currentEpisode, ()->
      fimplus._season.initPage(self.data.item, self.data.callback)
    )
  
  
  eventSeasonItemClick: ()->
    self = fimplus._season
    seasonEl = $(self.data.seasonListId).find('ul.list-item').find('li.item')
    seasonEl.removeClass('selected')
    seasonEl.eq(self.data.currentSeasonActive).addClass('selected')

    currentSeason = self.data.seasons[self.data.currentSeasonActive]
    if self.data.layoutActive is 'season'
      self.data.currentEpisodeActive = currentSeason.indexStartEpisode
    episodeListElement = $(self.data.episodeListId).find('ul.list-item')
    length = episodeListElement.find('.item').length
    tranlateData = self.data.currentEpisodeActive / length * 100
    css = {
      transform          : "translateY(-#{tranlateData}%)"
      "-webkit-transform": "translateY(-#{tranlateData}%)"
    }
    episodeListElement.css(css)

  hanldeBackbutton:(keyCode, key)->
    self = fimplus._season
    switch keyCode
      when key.DOWN
        if self.data.layoutActive is 'season'
          self.opacityListItem(self.data.layoutActive)
          self.data.currentSeasonActive = self.setActiveButton(self.data.layoutActive, self.data.currentSeasonActive, self.data.seasons.length)
        if self.data.layoutActive is 'episode'
          self.opacityListItem(self.data.layoutActive)
          self.data.currentEpisodeActive = self.setActiveButton(self.data.layoutActive, self.data.currentEpisodeActive, self.data.episodes.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removeSeasonPage()


  keyUpToActiveBack : ()->
    self = fimplus._season
    seasonItemElement = $(self.data.seasonListId).find('li.item')
    episodeItemElement = $(self.data.episodeListId).find('li.item')
    if(self.data.layoutActive is 'season' and self.data.currentSeasonActive is 0) or (self.data.layoutActive is 'episode' and self.data.currentEpisodeActive is 0)
      fimplus._backButton.setActive(true, self.hanldeBackbutton)
      self.opacityListItem('on_all')
      if self.data.layoutActive is 'season'
        seasonItemElement.removeClass('active')
      if self.data.layoutActive is 'episode'
        episodeItemElement.removeClass('active')
      return true
    return false

  
  handleKey: (keyCode, key)->
    self = fimplus._season
    console.info 'Detail Key:' + keyCode
    seasonItemElement = $(self.data.seasonListId).find('li.item')
    episodeItemElement = $(self.data.episodeListId).find('li.item')
    switch keyCode
      when key.LEFT
        return if self.data.layoutActive is 'season'
        if self.data.layoutActive is 'episode'
          self.data.layoutActive = 'season'
          episodeItemElement.removeClass('active')
          self.opacityListItem(self.data.layoutActive)
          self.data.currentSeasonActive = self.setActiveButton(self.data.layoutActive, self.data.currentSeasonActive, self.data.seasons.length)
        break;
      when key.RIGHT
        return if self.data.layoutActive is 'episode'
        if self.data.layoutActive is 'season'
          self.data.layoutActive = 'episode'
          seasonItemElement.removeClass('active')
          self.opacityListItem(self.data.layoutActive)
          self.data.currentEpisodeActive = self.setActiveButton(self.data.layoutActive, self.data.currentEpisodeActive, self.data.episodes.length)
        break;
      when key.DOWN
        return if self.data.isLoading is true
        self.data.isLoading = true
        if self.data.layoutActive is 'season'
          self.data.currentSeasonActive = self.setActiveButton(self.data.layoutActive, ++self.data.currentSeasonActive, self.data.seasons.length)
          self.eventSeasonItemClick()
        if self.data.layoutActive is 'episode'
          self.data.currentEpisodeActive = self.setActiveButton(self.data.layoutActive, ++self.data.currentEpisodeActive, self.data.episodes.length)
          self.animateScroll()
        break;
      when key.UP
        return if self.data.isLoading is true
        if self.keyUpToActiveBack() is true
          return
        self.data.isLoading = true
        if self.data.layoutActive is 'season'
          self.data.currentSeasonActive = self.setActiveButton(self.data.layoutActive, --self.data.currentSeasonActive, self.data.seasons.length)
          self.eventSeasonItemClick()
        if self.data.layoutActive is 'episode'
          self.data.currentEpisodeActive = self.setActiveButton(self.data.layoutActive, --self.data.currentEpisodeActive, self.data.episodes.length)
          self.animateScroll()
        break;
      when key.RETURN
        self.removeSeasonPage()
        break;
      when key.ENTER
        if self.data.layoutActive is 'season'
          self.eventSeasonItemClick()
        if self.data.layoutActive is 'episode'
          self.eventEpisodeItemClick()
        break;
    setTimeout(()->
      self.data.isLoading = false
    , self.data.timeAnimate + 1)
  
  
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)
  
  
  
  
  
  setActiveButton: (type = '', current = 0, length = 0)->
    self = fimplus._season
    if type is 'season'
      button = $(self.data.seasonListId).find('ul.list-item').find('li.item')
    if type is 'episode'
      button = $(self.data.episodeListId).find('ul.list-item').find('li.item')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current
  
  
  
  getListSeasonsAndListEpisodes: (callback)->
    self = @
    mergeListEpisode = ()->
      listEpisode = []
      async.each(self.data.seasons, ((season, cb) ->
        index = self.data.seasons.indexOf(season)
        async.each(season.episodes, ((episode, cbEpisode) ->
          episode.knownAs = season.knownAs + ' - ' + episode.knownAs
          episode.indexBelongSeason = index
          listEpisode.push(episode)
          cbEpisode()
        ), (err) ->
          cb()
        )
      ), (err) ->
        return callback() if err and _.isFunction(callback)
        self.data.episodes = if listEpisode then listEpisode else []
        callback() if _.isFunction(callback)
      )
    
    doneParallelEpidose = (errParalle, resParalle)->
      return callback() if errParalle and _.isFunction(callback)
      indexStartEpisode = 0
      async.each(self.data.seasons, ((season, cb) ->
        season.indexStartEpisode = indexStartEpisode
        season.episodes = if resParalle then  resParalle[season.id].episode else []
        indexStartEpisode += season.episodes.length
        cb()
      ), (err) ->
        return callback() if err and _.isFunction(callback)
        mergeListEpisode()
      )
    
    doneGetSeason = (error, resSeasons)->
      return callback() if error and _.isFunction(callback)
      self.data.seasons = resSeasons.season
      asyncParallelObject = {}
      async.each(self.data.seasons, ((seasonItem, cb) ->
        asyncParallelObject[seasonItem.id] = (cback)->
          fimplus.ApiService.getEpisodes({seasonId: seasonItem.id}, (error, resEpisode)->
            cback(null, resEpisode)
          )
        cb()
      ), (err) ->
        return callback() if err and _.isFunction(callback)
        async.parallel(asyncParallelObject, doneParallelEpidose)
      )
    
    params =
      movieId: self.data.item.id
    fimplus.ApiService.getSeasons(params, doneGetSeason)
  
  
  getData: ()->
    self = @
    exitApp = ()->
      self = fimplus._season
      fimplus._error.initPage({
        onReturn   : self.initKey
        description: 'exit-confirm'
        title      : 'notification'
        buttons    : [
          title   : 'exit'
          callback: fimplus.config.exit
        ,
          title   : 'button-cancel'
          callback: self.initKey
        ]
      })
    
    retry = ()->
      self.initKey()
      fimplus.ApiService.getEntityDetail(self.data.item.id, done)
    
    done = (error, result)->
      if error
        fimplus._error.initPage({
          onReturn   : exitApp
          description: 'Kết nối tới hệ thống bị chập chờn!,#1001'
          title      : 'Thông báo'
          buttons    : [
            title   : 'Thử lại'
            callback: retry
          ,
            title   : 'Exit'
            callback: exitApp
          ]
        })
        return console.log error
      
      self.data.item = result
      self.getListSeasonsAndListEpisodes(()->
        $('#ribbon').html('')
        $('#banner').html('')
        fimplus._season.render(self.data.item)
        self.opacityListItem('season')
      )
    
    fimplus.ApiService.getEntityDetail(self.data.item.id, done)
