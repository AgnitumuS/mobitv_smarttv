fimplus._viewmore =
  data:
    item: {}
  
  initPage: (item, callback)->
    fimplus._ribbon.displayRibbon(false)
    self = fimplus._viewmore
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
    fimplus._ribbon.displayRibbon(true)
    self = fimplus._viewmore
    self.element.html('')
  
  handleBackbutton: (keyCode, key)->
    self = fimplus._viewmore
    switch keyCode
      when key.DOWN
        positionEntity = self.data.positionEntity
        self.setActivePointer(positionEntity.col, positionEntity.row)
        self.initKey()
      
      when key.RETURN,key.ENTER
        self.removePage()
  
  handleKey: (keyCode, key)->
    self = fimplus._viewmore
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
          fimplus._backButton.setActive(true, self.handleBackbutton)
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
          fimplus._ribbon.setRibbonPosition(self.data.ribbonActive)
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
    fimplus.KeyService.initKey(self.handleKey)
  
  setCurrentBanner: (inFirst = false)->
    self = @
    #    if inFirst
    currentBanner = self.data.ribbon.items[self.data.positionEntity.current]
    if inFirst
      fimplus._banner.render(currentBanner)
    else
      fimplus._banner.reRender(currentBanner)
  
  removePage: ()->
    self = fimplus._viewmore
    self.element.html('')
    fimplus._ribbon.displayRibbon()
    if self.data.callback() and _.isFunction(self.data.callback)
      self.data.callback()
    else
      fimplus._page.onReturnPage()
  
  onRetrunPage: ()->
    self = fimplus._viewmore
    $('#banner').find('.home-main').html('')
    #    fimplus._page.activeIconBack(false)
    fimplus._ribbon.displayRibbon(false)
    self.initPage(self.data.item, self.data.callback)
  
  
  onRetrunPageLogin: ()->
    self = fimplus._viewmore
    if fimplus.UserService.isLogin()
      fimplus._ribbon.displayRibbon(false)
      self.initPage(fimplus._page.onReturnPage)
      
      setTimeout(()->
        self.initActivePointer()
        self.setActivePointer(self.data.positionEntity.col, self.data.positionEntity.row)
      , 500)
      self.initKey()
    else
      self.removePage()
      fimplus._page.initKey()
  
  openDetail: ()->
    self = fimplus._viewmore
    self.onLeavePage()
    currentItem = self.data.ribbon.items[self.data.positionEntity.current]
    fimplus._detail.initPage(currentItem, self.onRetrunPage)
  
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
    self = fimplus._viewmore
    notify = self.element.find('.viewmore-notify')
    lang = fimplus.UserService.getValueStorage('userSettings', 'language')
    text = fimplus.LanguageService.convert(text, lang)
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
      currentTitleLangguage = fimplus.UserService.getValueStorage('userSettings', 'movieTitleLanguage')
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
            bannerAppletv: 'https://ast.fimplus.io/files/header-watch_1489466156484.png'
          posterLandscape: 'https://ast.fimplus.io/files/header-ic-watch_1489466929334.png'
        #        fimplus._page.activeIconBack()
        #        loadBannerInViewMore(banner)
        fimplus._banner.reRender(banner)
      else
        fimplus._page.activeIconBack()
        self.setNotifyViewmore(false)
        self.initActivePointer()
        loadBannerInViewMore(self.data.ribbon.items[self.data.positionEntity.current])
        self.setCurrentBanner(true)
    
    params =
      limit: 40
      page : 0
    
    if _.isEmpty(self.data.item)
      if fimplus.UserService.isLogin()
        if fimplus.UserService.data.watchLater.items.length is 0
          self.removePage()
        else
          done(null, fimplus.UserService.data.watchLater)
      else
        fimplus._login.initPage(fimplus._viewmore.onRetrunPageLogin)
      return
    
    params.id = self.data.item.categoryId
    fimplus.ApiService.getRibbonDetail(params, done)