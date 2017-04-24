pateco._detail =
  element : '#detail'
  data             :
    item         : {}
    buttons      : []
    layoutActive : 'button' #related trailer
    currentButton: 0
    callback     : ()->

  initPage:(item, callback)->
    self = pateco._detail
    self.data.item = item
    self.data.callback = callback if _.isFunction(callback)
    self.getData(()->
      self.render()
      self.initKey()
    )

  onReturnDetailPage : ()->

  removePage : ()->
    self = pateco._detail
    $(self.element).html('')
    self.data.callback() if _.isFunction(self.data.callback)


  render : ()->
    self = pateco._detail
    source = Templates['module.detail']()
    template = Handlebars.compile(source)
    console.log 'render detail', self.data.item
    $(self.element).html( template( self.data.item ))


  handleKeyUp : ()->
  handleKeyDown : ()->
  handleKeyLeft : ()->
  handleKeyRight : ()->

  initKey:()->
    self = pateco._detail
    pateco.KeyService.initKey(self.handleKey)

  handleKey: (keyCode, key)->
    self = pateco._detail
    console.info 'detail Key:' + keyCode
    switch keyCode
      when key.RIGHT
        self.handleKeyRight()
        break;
      when key.LEFT
        self.handleKeyLeft()
        break;
      when key.DOWN
        self.handleKeyDown()
        break;
      when key.UP
        self.handleKeyUp()
        break;
      when key.ENTER
        self.handleKeyEnter()
        break;
      when key.RETURN
        self.removePage()

        break;

  getData : (callback=null)->
    self=@
    params =
      slug : self.data.item.slug
      type : 'slug'
    pateco.ApiService.getDetailEntity(params, (error, result)->
      return console.error result if error
      self.data.item = result
      callback() if _.isFunction(callback)
    )

#pateco._detail =
#  data             :
#    item         : {}
#    ribbon       : []
#    ribbonActive : 0
#    buttons      : []
#    layoutActive : 'button' #button , ribbon, viewmore
#    currentButton: 0
#    addListStatus: 0
#    callback     : ()->
#
#  initPageByMovieId: (id)->
#    self = pateco._detail
#    self.data.item =
#      id: id
#    pateco.config.state = 'detail'
#    self.initPage(self.data.item, self.removePage)
#
#  initPage: (item, callback)->
#    self = @
#    self.data.item = item
#    self.data.callback = ()->
#    self.data.callback = callback if _.isFunction(callback)
#    self.data.layoutActive = 'button'
#    self.data.currentButton = 0
#    self.data.ribbonActive = 0
#    self.ribbon = []
#    self.getData()
#    self.initKey()
#    self.element = $("#banner,#ribbon")
#    pateco._backButton.enable(true)
#    pateco.config.state = 'detail'
#    #    pateco._banner.activeLabelViewMore()
#    null
#
#
#  removePage: ()->
#    self = pateco._detail
#    pateco.config.state = ''
#    pateco._banner.activeLabelViewMore(false)
#    pateco._banner.removeButton()
#    pateco._page.addClassIntoIcBack(false)
#    self.data.callback() if _.isFunction(self.data.callback)
#
#
#  playMovie: (item)->
#    self = pateco._detail
#    self.element.fadeOut()
#    pateco._backButton.enable(false)
#    if self.data.item and self.data.item.visibleOn and self.data.item.visibleOn.status is false
#      finish = ()->
#        self.initKey()
#        self.element.fadeIn()
#
#      pateco._error.initPage({
#        title      : "notification"
#        onReturn   : finish
#        description: self.data.item.visibleOn.message
#        buttons    : [
#          title   : 'OK'
#          callback: finish
#        ]
#      })
#      return
#    pateco._player.initPage(item, self.onReturnPage)
#
#
#  viewmoreActive: (active = false)->
#    element = $('#banner').find('.description-viewmore')
#    element.removeClass('active')
#    if active is true then element.addClass('active')
#
#  checkShowIcUpDownFullDes: (type = '')->
#    self = pateco._detail
#    timeOutValue = 300
#    desFullElement = $('#banner').find('.description-full')
#    maxScrollHeight = desFullElement[0].scrollHeight
#    clientHeight = desFullElement[0].clientHeight
#    scrollTop = desFullElement[0].scrollTop
#    upIcon = desFullElement.find('.fa-angle-up')
#    downIcon = desFullElement.find('.fa-angle-down')
#    value = 0
#    if type is 'down'
#      value = if (scrollTop + clientHeight) >= maxScrollHeight then maxScrollHeight else (scrollTop + clientHeight)
#    if type is 'up'
#      value = if (scrollTop - clientHeight) < 0 then 0 else (scrollTop - clientHeight)
#    desFullElement.animate({scrollTop: value}, timeOutValue)
#    setTimeout(()->
#      maxScrollHeight = desFullElement[0].scrollHeight
#      clientHeight = desFullElement[0].clientHeight
#      scrollTop = desFullElement[0].scrollTop
#      if scrollTop > 0 then upIcon.show() else upIcon.hide()
#      if (scrollTop + clientHeight) < maxScrollHeight then downIcon.show() else downIcon.hide()
#    , timeOutValue + 100)
#
#  activeViewMoreLayout: (active = false)->
#    self = pateco._detail
#    desElement = $('#banner').find('.description')
#    desFullElement = $('#banner').find('.description-full')
#    bannerDetailButton = $('#banner').find('.detail-buttons')
#    ribbonElment = $('#ribbon')
#    if active is true
#      desElement.hide()
#      bannerDetailButton.hide()
#      desFullElement.show()
#      ribbonElment.hide()
#    else
#      desElement.show()
#      bannerDetailButton.show()
#      desFullElement.hide()
#      ribbonElment.show()
#    self.checkShowIcUpDownFullDes()
#
#
#  enterMovieRelatedRibbon: ()->
#    self = pateco._detail
#
#    indexCurrentRibbon = self.data.ribbonActive || 0
#    indexCurrentItemOfRibbon = self.data.ribbon[indexCurrentRibbon].currentActive
#    currentRibbon = self.data.ribbon[indexCurrentRibbon]
#    item = currentRibbon.items[indexCurrentItemOfRibbon]
#    if currentRibbon.isTrailer is true
#      item.isTrailer = true
#      item.title = self.data.item.title
#      item.knownAs = self.data.item.knownAs
#      item.type = 'Movie'
#      item.movie = self.data.item
#      self.data.layoutActive = 'button'
#      self.data.currentButton = 0
#      self.data.ribbonActive = 0
#      pateco._ribbon.removeActivePointer()
#      self.playMovie(item)
#      return
#    if item
#      self.data.item = item
#      pateco.ApiService.getEntityDetail(self.data.item.id, (error, result)->
#        self.data.item = result
#        pateco._banner.render(self.data.item)
#        self.data.layoutActive = 'button'
#        self.data.currentButton = 0
#        self.data.ribbonActive = 0
#        pateco._ribbon.removeActivePointer()
#        self.getData()
#      )
#
#  handleKeyLeft: ()->
#    self = pateco._detail
#    return if self.data.layoutActive is 'icback'
#    if self.data.layoutActive is 'button'
#      self.data.currentButton = pateco._banner.setActiveButton(--self.data.currentButton, self.data.buttons.length)
#      return
#    if self.data.ribbon[self.data.ribbonActive].currentActive > 0
#      self.data.ribbon[self.data.ribbonActive].currentActive--
#      pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
#      return
#
#  handleKeyRight: ()->
#    self = pateco._detail
#    return if self.data.layoutActive is 'icback'
#    if self.data.ribbon.length > 0
#      lengthRibbon = self.data.ribbon.length
#      if self.data.ribbon[self.data.ribbonActive] and self.data.ribbon[self.data.ribbonActive].items
#        lengthItem = self.data.ribbon[self.data.ribbonActive].items.length
#    if self.data.layoutActive is 'button'
#      self.data.currentButton = pateco._banner.setActiveButton(++self.data.currentButton, self.data.buttons.length)
#      return;
#    if self.data.ribbon[self.data.ribbonActive].currentActive < lengthItem - 1
#      self.data.ribbon[self.data.ribbonActive].currentActive++
#      pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
#      return;
#
#  handleKeyDown: ()->
#    self = pateco._detail
#    if self.data.layoutActive is 'icback' and $(pateco._banner.data.id).find('.description-full').is(':visible') is false
#      self.data.layoutActive = 'viewmore'
#      pateco._page.addClassIntoIcBack(false)
#      self.viewmoreActive(true)
#      return
#    if self.data.ribbon.length > 0
#      lengthRibbon = self.data.ribbon.length
#      if self.data.ribbon[self.data.ribbonActive] and self.data.ribbon[self.data.ribbonActive].items
#        lengthItem = self.data.ribbon[self.data.ribbonActive].items.length
#    if self.data.layoutActive is 'viewmore'
#      if $(pateco._banner.data.id).find('.description-full').is(':visible')
#        self.checkShowIcUpDownFullDes('down')
#        return
#      self.data.layoutActive = 'button'
#      pateco._banner.setActiveButton(self.data.currentButton, self.data.buttons.length)
#      pateco._ribbon.removeActivePointer()
#      self.viewmoreActive(false)
#      return
#    if self.data.layoutActive is 'button' and self.data.ribbon.length > 0
#      pateco._banner.setActiveButton(0, 0)
#      pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
#      self.data.layoutActive = 'ribbon'
#      return;
#    if self.data.ribbonActive < lengthRibbon - 1
#      self.data.ribbonActive++
#      pateco._ribbon.setRibbonPosition(self.data.ribbonActive)
#      pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
#      return;
#    return;
#
#  handleKeyUp: ()->
#    self = pateco._detail
#    if self.data.layoutActive is 'viewmore' and $(pateco._banner.data.id).find('.description-full').is(':visible') is false
#      self.data.layoutActive = 'icback'
#      pateco._page.addClassIntoIcBack()
#      self.viewmoreActive(false)
#      return
#    if self.data.layoutActive is 'viewmore'
#      if $(pateco._banner.data.id).find('.description-full').is(':visible')
#        self.checkShowIcUpDownFullDes('up')
#        return
#    if self.data.layoutActive is 'button'
#      self.data.layoutActive = 'viewmore'
#      self.viewmoreActive(true)
#      $(self.data.id).find('.detail-buttons').find('li').removeClass('active')
#      pateco._banner.setActiveButton(0, 0)
#      return
#    if self.data.layoutActive is 'ribbon' and self.data.ribbonActive is 0
#      self.data.layoutActive = 'button'
#      pateco._banner.setActiveButton(self.data.currentButton, self.data.buttons.length)
#      pateco._ribbon.removeActivePointer()
#      return;
#    if self.data.ribbonActive > 0
#      self.data.ribbonActive--
#      pateco._ribbon.setRibbonPosition(self.data.ribbonActive)
#      pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
#      return;
#
#
#  handleKey: (keyCode, key)->
#    self = pateco._detail
#    console.info 'Detail Key:' + keyCode
#    switch keyCode
#      when key.LEFT
#        return if self.data.layoutActive is 'viewmore'
#        self.handleKeyLeft()
#        break
#
#      when key.RIGHT
#        return if self.data.layoutActive is 'viewmore'
#        self.handleKeyRight()
#        break
#
#      when key.DOWN
#        self.handleKeyDown()
#        break;
#
#      when key.UP
#        self.handleKeyUp()
#        break;
#
#      when key.RETURN
#        if self.data.layoutActive is 'viewmore'
#          if $(pateco._banner.data.id).find('.description-full').is(':visible')
#            return self.activeViewMoreLayout(false)
#        self.removePage()
#        break;
#
#      when key.ENTER
#        if self.data.layoutActive is 'icback'
#          self.removePage()
#          return
#        if self.data.layoutActive is 'viewmore'
#          self.activeViewMoreLayout(true)
#          return
#        if self.data.layoutActive is 'button'
#          return self.onClickButton(self.data.currentButton)
#        if self.data.layoutActive is 'ribbon'
#          self.enterMovieRelatedRibbon()
#          return
#
#
#
#  initKey: ()->
#    self = pateco._detail
#    pateco.KeyService.initKey(self.handleKey)
#
#  onClickButton: (index)->
#    self = pateco._detail
#    self.data.buttons[index].action()
#
#  onReturnPage: ()->
#    self = pateco._detail
#    self.element.fadeIn()
#
#    pateco.ApiService.getEntityDetail(self.data.item.id, (error, result)->
#      pateco._detail.data.item = result
#      pateco._detail.prepareButton()
#      pateco._detail.checkMovieCountTime(self.data.item)
#      pateco._detail.initKey()
#    )
#    pateco._backButton.enable()
#    pateco.config.state = 'detail'
#
#  actionPlayMovie: ()->
#    self = pateco._detail
#    unless pateco.UserService.isLogin()
#      pateco._banner.element.find('.detail-buttons ul.bt-movie-detail').html('')
#      pateco._login.initPage(self.onReturnPage)
#      return
#
#    if self.data.item.subscribed is true
##      if(self.data.item and self.data.item.progress and self.data.item.progress.progress > 0)
#      self.playMovie(self.data.item)
#      return
#
#    if self.data.item.subscribed is false
#      if self.data.item.ppvPrice > 0
#        console.log 'mua TVOD'
#      else
#        pateco._banner.element.find('.detail-buttons ul.bt-movie-detail').html('')
#        pateco._payment.initPage('buyPackage', self.onReturnPage)
#      return
#    return
#
#  actionPlayFromStart: ()->
#    self = pateco._detail
#    unless pateco.UserService.isLogin()
#      pateco._banner.element.find('.detail-buttons ul.bt-movie-detail').html('')
#      pateco._login.initPage(self.onReturnPage)
#      return
#    if self.data.item.subscribed is true
#      item = self.data.item
#      item.progress =
#        percent : 0
#        progress: 0
#      self.playMovie(item)
#      #      pateco._player.initPage(item,self.onReturnPage)
#      return
#    return
#
#  actionWatchLater: ()->
#    self = pateco._detail
#    unless pateco.UserService.isLogin()
#      pateco._banner.element.find('.detail-buttons ul.bt-movie-detail').html('')
#      pateco._login.initPage(self.onReturnPage)
#      return
#    done = (error, result) ->
#      favoriteEl = $('#banner').find('.bt-movie-detail .favorite')
#      return console.error error if error
#      self.data.addListStatus = if self.data.addListStatus is 1 then 0 else 1
#      lang = pateco.UserService.getValueStorage('userSettings', 'language')
#      if self.data.addListStatus is 1
#        textBtn = pateco.LanguageService.convert('remove', lang)
#        favoriteEl
#          .removeClass('add')
#          .addClass('remove')
#          .find('a span').text(textBtn)
#        pateco.UserService.addDataWatchLater(self.data.item)
#
#      else if self.data.addListStatus is 0
#        favoriteEl.removeClass('remove').addClass('add')
#        textBtn = pateco.LanguageService.convert('watch-later', lang)
#        favoriteEl.find('a span').text(textBtn)
#        pateco.UserService.addDataWatchLater(self.data.item, false)
#
#      pateco._page.loadDataRibonOfUser({}, (errorRibbonOfUser, resultRibbonOfUser)->)
#
#    params =
#      like   : if self.data.addListStatus is 1 then 0 else 1
#      movieId: self.data.item.id
#    pateco.ApiService.updateFavorite(params, done)
#    return
#
#
#  actionBtnTVOD: ()->
#    self = pateco._detail
#    unless pateco.UserService.isLogin()
#      pateco._banner.element.find('.detail-buttons ul.bt-movie-detail').html('')
#      pateco._login.initPage(self.onReturnPage)
#      return
#    if self.data.item.subscribed is true
#      return
#    if self.data.item.subscribed is false
#      if self.data.item.ppvPrice > 0
#        pateco._banner.element.find('.detail-buttons ul.bt-movie-detail').html('')
#        pateco._payment.initPage('rentMovie', self.onReturnPage)
#      else
#        console.log 'subscribed is false, SVOD'
#    return
#
#  actionShowSeason: ()->
#    self = pateco._detail
#    return if self.data.item.type isnt 'Show'
#    pateco._season.initPage(self.data.item, ()->
#      pateco._banner.render(self.data.item)
#      pateco._detail.initPage(self.data.item, self.data.callback)
#    )
#
#  coverTime: (second)->
#    lang = pateco.UserService.getValueStorage('userSettings', 'language')
#    unless second
#      return '0'
#    now = new Date()
#    sec = (second * 1000) - now.getTime()
#    sec = sec / 1000
#    sec = parseInt(sec)
#    totalSec = sec
#    hours = Math.floor(totalSec / 3600);
#    totalSec = totalSec % 3600;
#    minutes = Math.floor(totalSec / 60);
#    seconds = Math.round(totalSec % 60);
#    resText = ''
#    if hours > 0
#      if hours < 10
#        resText = '0' + hours.toString()
#      else
#        resText = hours.toString()
#      resText = resText + ' ' + pateco.LanguageService.convert('hours-watch', lang)
#      return resText.toString()
#    if minutes > 0
#      if minutes < 10
#        resText = '0' + minutes.toString()
#      else
#        resText = minutes.toString()
#      resText = resText + ' ' + pateco.LanguageService.convert('minutes-watch', lang)
#      return resText.toString()
#    if seconds > 0
#      if seconds < 10
#        resText = '0' + seconds.toString()
#      else
#        resText = seconds.toString()
#      resText = resText + ' ' + pateco.LanguageService.convert('seconds-watch', lang)
#      return resText.toString()
#
#  checkMovieCountTime: (item)->
#    self = pateco._detail
#    self.data.movieCountTime = item
#    expiryDate = item.expiryDate or null
#    timeLeft = item.timeLeft or null
#
#    if expiryDate > 0 && timeLeft > 0
#      time = self.coverTime(expiryDate)
#      text = '<p>' + pateco.LanguageService.convert('you-have', pateco.UserService.getValueStorage('userSettings', 'language')) + ' ' + time + '</p>'
#      self.element.find('.bt-movie-detail li:first-child').addClass('two-line')
#      self.element.find('.bt-movie-detail li:first-child a').append(text)
#
#
#  prepareButton: ()->
#    self = pateco._detail
#    item = self.data.item
#    self.data.buttons = []
#    lang = pateco.UserService.getValueStorage('userSettings', 'language')
#    playmovie =
#      title : if(self.data.item and self.data.item.progress and self.data.item.progress.progress > 0) then 'watchContinue' else 'watch'
#      slug  : 'btn-watch'
#      action: pateco._detail.actionPlayMovie
#
#    playFromStart =
#      title : 'watchBegin'
#      slug  : 'btn-watch-start'
#      action: pateco._detail.actionPlayFromStart
#
#    watchlater =
#      title : if self.data.addListStatus is 0 then 'watch-later' else 'remove'
#      slug  : 'btn-favorite'
#      action: pateco._detail.actionWatchLater
#
#    btnTVOD =
#      title : pateco.UtitService.currency({displayType: 'text', value: self.data.item.ppvPrice})
#      slug  : 'btn-tvod'
#      action: pateco._detail.actionBtnTVOD
#
#    showSeason =
#      title : 'select-season'
#      slug  : 'show-season'
#      action: pateco._detail.actionShowSeason
#
#    #xem tiep, xem phim
#    if self.data.item.subscribed is false and self.data.item.ppvPrice > 0
#      self.data.buttons.push(btnTVOD)
#    else
#      self.data.buttons.push(playmovie)
#
#    #xem tu dau
#    if pateco.UserService.isLogin() and self.data.item.subscribed is true
#      if(self.data.item and self.data.item.progress and self.data.item.progress.progress > 0)
#        self.data.buttons.push(playFromStart)
#
#    #xem sau(favorite)
#    self.data.buttons.push(watchlater)
#
#    #mua TVOD
#
#    if self.data.item.type is 'Show'
#      self.data.buttons.push(showSeason)
#
#    data =
#      director: item.director || []
#      cast    : item.topCast || []
#      buttons : self.data.buttons
#      movie   : self.data.item
#      favorite: self.data.addListStatus
#    pateco._banner.renderButton(data)
#    pateco._banner.setActiveButton((self.data.currentButton || 0), self.data.buttons.length)
#    pateco._banner.setEventClickButton(self.onClickButton)
#    # if en add class ento btn to fix css
#    if lang is 'en'
#      self.element.find('.bt-movie-detail li').addClass('eng')
##    pateco._banner.activeIconBack(true)
#
#  setCurrentBanner: (inFirst = false)->
#    self = pateco._detail
#    #    if inFirst
#    currentBanner = pateco._banner.getCurrentBanner(self.data.ribbon, self.data.ribbonActive)
#    currentBanner.model4K = pateco.config.appInfo.model4K if currentBanner
##    console.log 'detail setCurrentBanner', currentBanner
#    if inFirst
#      pateco._banner.render(currentBanner)
#    else
#      pateco._banner.reRender(currentBanner)
#
#
#  getData: ()->
#    self = pateco._detail
#
#    retry = ()->
#      self.initKey()
#      pateco.ApiService.getHome(done)
#
#    done = (error, result)->
#      self.data.item = result
#      self.data.addListStatus = self.data.item.favorite
#      if error
#        pateco._error.initPage({
#          onReturn   : pateco.config.exit
#          description: ['connect-error', '#1001']
#          title      : 'notification'
#          buttons    : [
#            title   : 'button-try-again'
#            callback: retry
#          ,
#            title   : 'exit'
#            callback: pateco.config.exit
#          ]
#        })
#        return console.log error
#      self.data.ribbon = []
#      if result.extendedMovie
#        if result.extendedMovie.behindTheScene and result.extendedMovie.behindTheScene.length > 0
#          items = []
#          _.map(result.extendedMovie.behindTheScene, (item)->
#            items.push({posterLandscape: item.image, id: item.id})
#          )
#          self.data.ribbon.push({
#            items        : items,
#            isTrailer    : true,
#            categoryType : 'backstage',
#            currentActive: 0
#          })
#
#        if result.extendedMovie.trailer.length > 0
#          items = []
#          _.map(result.extendedMovie.trailer, (item)->
#            items.push({posterLandscape: item.image, id: item.id})
#          )
#          self.data.ribbon.push({
#            items        : items,
#            isTrailer    : true,
#            categoryType : 'Trailer',
#            currentActive: 0
#          })
#      if result and result.related and result.related.length > 0
#        self.data.ribbon.push {
#          items        : result.related
#          categoryType : 'related'
#          currentActive: 0
#        }
#
#      pateco._ribbon.render(self.data.ribbon, self.data.ribbonActive, false)
#      self.prepareButton()
#      self.checkMovieCountTime(self.data.item)
#      if pateco.config.state is 'detail'
#        if self.data.item and self.data.item.descriptionShort.length > 162
#          pateco._banner.activeLabelViewMore(true)
#
#    pateco.ApiService.getEntityDetail(self.data.item.id, done)