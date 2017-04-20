pateco._viewmore =
  data:
    item: {}
  
  initPage: (item, callback)->
    pateco._ribbon.displayRibbon(false)
    self = pateco._viewmore
    self.data.item = item
    self.data.ribbon = []
    self.data.callback = ()->
      console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.data.positionEntity =
      length : 0
      active : false
      col    : 0
      row    : 0
      current: 0
      maxCol : 4
    self.element = $('#viewmore')
    self.initKey()
    self.getData()
  
  
  onLeavePage: ()->
    pateco._ribbon.displayRibbon(true)
    self = pateco._viewmore
    self.element.html('')
  
  handleBackbutton: (keyCode, key)->
    self = pateco._viewmore
    switch keyCode
      when key.DOWN
        positionEntity = self.data.positionEntity
        self.setActivePointer(positionEntity.col, positionEntity.row)
        self.initKey()
      
      when key.RETURN,key.ENTER
        self.removePage()
  
  handleKey: (keyCode, key)->
    self = pateco._viewmore
    console.info 'View More Key:' + keyCode
    positionEntity = self.data.positionEntity
    actionLeftRight = ()->
      return if positionEntity.length is 0
      self.setCurrentBanner()
      self.setActivePointer(positionEntity.col, positionEntity.row)
    
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.LEFT
        if positionEntity.current > 0
          positionEntity.current--
          actionLeftRight()
        break;
      
      when key.RIGHT
        if positionEntity.current < positionEntity.length - 1
          positionEntity.current++
          actionLeftRight()
        break;
      when key.UP
        if positionEntity.row is 0
          positionEntity.active = false
          self.setActivePointer(positionEntity.col, positionEntity.row, false)
          pateco._backButton.setActive(true, self.handleBackbutton)
          return
        
        positionEntity.current -= positionEntity.maxCol
        positionEntity.current = 0 if positionEntity.current < 0
        actionLeftRight()
        break;
      when key.DOWN
        positionEntity.current += positionEntity.maxCol
        if positionEntity.current > positionEntity.length - 1
          positionEntity.current = positionEntity.length - 1
        actionLeftRight()
        break;
      
      when key.ENTER
        self.openDetail()
        break;
      when key.UP
        if self.data.ribbonActive > 0
          self.data.ribbonActive--
          pateco._ribbon.setRibbonPosition(self.data.ribbonActive)
          actionLeftRight()
        break;
    # calcualate position of pointer when change key
    if keyCode in [key.LEFT, key.RIGHT, key.UP, key.DOWN]
      positionEntity.row = Math.floor(positionEntity.current / positionEntity.maxCol)
      positionEntity.col = positionEntity.current - positionEntity.row * positionEntity.maxCol
      self.data.positionEntity = positionEntity
      self.setActivePointer(positionEntity.col, positionEntity.row)
  
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)
  
  setCurrentBanner: (inFirst = false)->
    self = @
    #    if inFirst
    currentBanner = self.data.ribbon.items[self.data.positionEntity.current]
    if inFirst
      pateco._banner.render(currentBanner)
    else
      pateco._banner.reRender(currentBanner)
  
  removePage: ()->
    self = pateco._viewmore
    self.element.html('')
    pateco._ribbon.displayRibbon()
    if self.data.callback() and _.isFunction(self.data.callback)
      self.data.callback()
    else
      pateco._page.onReturnPage()
  
  onRetrunPage: ()->
    self = pateco._viewmore
    $('#banner').find('.home-main').html('')
    #    pateco._page.activeIconBack(false)
    pateco._ribbon.displayRibbon(false)
    self.initPage(self.data.item, self.data.callback)
  
  
  onRetrunPageLogin: ()->
    self = pateco._viewmore
    if pateco.UserService.isLogin()
      pateco._ribbon.displayRibbon(false)
      self.initPage(pateco._page.onReturnPage)
      
      setTimeout(()->
        self.initActivePointer()
        self.setActivePointer(self.data.positionEntity.col, self.data.positionEntity.row)
      , 500)
      self.initKey()
    else
      self.removePage()
      pateco._page.initKey()
  
  openDetail: ()->
    self = pateco._viewmore
    self.onLeavePage()
    currentItem = self.data.ribbon.items[self.data.positionEntity.current]
    pateco._detail.initPage(currentItem, self.onRetrunPage)
  
  onActiveEntity: ()->
    self = @
    positionEntity = self.data.positionEntity
    if positionEntity.length > 0
      positionEntity.active = true
      self.initActivePointer()
      self.setActivePointer(positionEntity.col, positionEntity.row)
      return
  
  initActivePointer: (current = 0)->
    self = @
    
    entityDetail = self.element.find('.entity-detail').eq(current)
    width = entityDetail.outerWidth()
    height = entityDetail.outerHeight()
    pointer = self.element.find(".active-pointer")
    css =
      display: 'block'
      width  : width
      height : height
    
    pointer.css(css)
  
  setActivePointer: (col = 0, row = 0, active = true)->
    self = @
    pointer = self.element.find(".active-pointer")
    viewmore = self.element.find('.viewmore-movie')
    currentResultSearch = 0
    maxRow = 0
    if row > maxRow
      itemHeight = viewmore.find('.entity-detail').outerHeight()
      currentResultSearch = itemHeight * (row - maxRow)
      row = maxRow
    
    viewmore.css({
      transform: "translateY(-#{currentResultSearch}px)"
    })
    css =
      transform: "translate(#{col * 100}%,#{row * 100}%)"
    pointer.css(css)
    if active is false
      pointer.hide()
    else
      pointer.show()
  
  
  render: ()->
    self = @
    source = Templates['modulemore.view']()
    template = Handlebars.compile(source);
    self.element.html(template(self.data.ribbon))
  
  setNotifyViewmore: (active = true)->
    text = "movie-empty"
    self = pateco._viewmore
    notify = self.element.find('.viewmore-notify')
    lang = pateco.UserService.getValueStorage('userSettings', 'language')
    text = pateco.LanguageService.convert(text, lang)
    notify.html(text)
    
    if active
      notify.show()
    else
      notify.hide()
  
  getData: ()->
    self = @
    loadBannerInViewMore = (banner)->
      source = Templates['module.banner.home-main']()
      template = Handlebars.compile(source)
      currentTitleLangguage = pateco.UserService.getValueStorage('userSettings', 'movieTitleLanguage')
      if currentTitleLangguage is 'en' then banner.knownAs = banner.title
      $('#banner').find('.home-main').html(template(banner))
    
    done = (error, result) ->
      if error
        console.error error
        return
      console.log result
      self.data.ribbon = result
      
      # config for watchlater if not exits ribbon
      unless result.ribbon
        self.data.ribbon.ribbon =
          name: result.categoryType
      self.data.positionEntity.length = result.items.length
      self.render()
      if self.data.ribbon.items.length is 0
        self.setNotifyViewmore()
        banner =
          id             : 'watch-later'
          isMenu         : true
          knownAs        : 'watch-later'
          description    : 'header-watchlater'
          title          : 'watch-later'
          image3x        :
            bannerAppletv: 'https://ast.pateco.io/files/header-watch_1489466156484.png'
          posterLandscape: 'https://ast.pateco.io/files/header-ic-watch_1489466929334.png'
        #        pateco._page.activeIconBack()
        #        loadBannerInViewMore(banner)
        pateco._banner.reRender(banner)
      else
        pateco._page.activeIconBack()
        self.setNotifyViewmore(false)
        self.initActivePointer()
        loadBannerInViewMore(self.data.ribbon.items[self.data.positionEntity.current])
        self.setCurrentBanner(true)
    
    params =
      limit: 40
      page : 0
    
    if _.isEmpty(self.data.item)
      if pateco.UserService.isLogin()
        if pateco.UserService.data.watchLater.items.length is 0
          self.removePage()
        else
          done(null, pateco.UserService.data.watchLater)
      else
        pateco._login.initPage(pateco._viewmore.onRetrunPageLogin)
      return
    
    params.id = self.data.item.categoryId
    pateco.ApiService.getRibbonDetail(params, done)