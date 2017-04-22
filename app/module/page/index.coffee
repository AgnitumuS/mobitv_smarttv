pateco._page =
  data :
    menu : []
    ribbon : []
    ribbonActive: 0
    layout : ''
    callback : ()->

  initPage : ()->
    self = pateco._page
    source = Templates['module.page']()
    template = Handlebars.compile(source);
    self.element = $('#main-app')
    self.element.html(template)
    self.getData(()->
      self.render()
      self.initKey()
    )


  show:()->
    self = pateco._page
    self.element.show()

  hide:()->
    self = pateco._page
    self.element.hide()

  onReturnPage:()->

  openDetail: ()->
    self = pateco._page
    currentItem = pateco._banner.getCurrentBanner(self.data.ribbon, self.data.ribbonActive)
    pateco._detail.initPage(currentItem, self.onReturnPage)


  removePage : ()->
    self = pateco._page
    self.data.callback() if _.isFunction(self.data.callback)

  render : ()->

  reRender : ()->

  handleKey: (keyCode, key)->
    self = pateco._page
    console.info 'Home Key:' + keyCode
    switch keyCode
      when key.LEFT
        break;
      when key.RIGHT
        break;
      when key.DOWN
        break;
      when key.ENTER
        break;
      when key.UP
        break;
      when key.RETURN
        break;

  initKey: ()->
    pateco.KeyService.initKey(pateco._page.handleKey)

  getData : (callback = null)->
    pateco.ApiService.getHome((error, result)->
      callback() if _.isFunction(callback)
    )


pateco._page =
  data:
    ribbon      : []
    ribbonActive: 0
    home        : []
    package     : []
    page        : []
    tvod        : []
    layout      : 'home' #home, package,page,tvod
    watchlater  : []
    activeRibbon:
      home   : 0
      package: 0
      page   : 0
      tvod   : 0
    menu        :
      categoryType : 'Menu'
      isSelectMenu : 0
      currentActive: 0
      items        : [
        id             : 'search'
        isMenu         : true
        knownAs        : 'search'
        description    : 'header-search'
        title          : 'Search'
        image3x        :
          bannerAppletv: 'https://ast.pateco.io/files/header-search_1489466131214.png'
        posterLandscape: 'https://ast.pateco.io/files/header-ic-search_1489466875495.png'
        action         : ()->
          self = pateco._page
          pateco._search.initPage(self.onReturnPage)
      ,
        id             : 'package-fim'
        isMenu         : true
        knownAs        : 'menu-pack'
        description    : 'header-package'
        title          : 'menu-pack'
        image3x        :
          bannerAppletv: 'https://ast.pateco.io/files/header-package_1489466139856.png'
        posterLandscape: 'https://ast.pateco.io/files/header-ic-package_1489466883222.png'
        action         : ()->
          pateco._page.getPackage()
      ,
        id             : 'have-fee'
        isMenu         : true
        knownAs        : 'menu-fee'
        description    : 'header-fee'
        title          : 'menu-fee'
        image3x        :
          bannerAppletv: 'https://ast.pateco.io/files/header-price_1489466146644.png'
        posterLandscape: 'https://ast.pateco.io/files/header-ic-price_1489466889392.png'
        action         : ()->
          id = 'a2348246-f2ae-4307-8769-cc5016d85198'
          pateco._page.getPage(id, 'tvod')
      ,
        id             : 'watch-later'
        isMenu         : true
        knownAs        : 'watch-later'
        description    : 'header-watchlater'
        title          : 'watch-later'
        image3x        :
          bannerAppletv: 'https://ast.pateco.io/files/header-watch_1489466156484.png'
        posterLandscape: 'https://ast.pateco.io/files/header-ic-watch_1489466929334.png'
        action         : ()->
          self = pateco._page
          pateco._viewmore.initPage({}, self.onReturnPage)
      ,
        id             : 'setting'
        isMenu         : true
        knownAs        : 'menu-setting'
        description    : 'header-setting'
        title          : 'menu-setting'
        image3x        :
          bannerAppletv: 'https://ast.pateco.io/files/header-user_1489466163298.png'
        posterLandscape: 'https://ast.pateco.io/files/header-ic-user_1489466966067.png'
        action         : ()->
          self = pateco._page
          pateco._setting.initPage(self.onReturnPage)
      ]
  
  setCurrentLayout: () ->
    self = @
    self.data.ribbon = _.clone(self.data[self.data.layout])
    self.data.ribbonActive = _.clone(self.data.activeRibbon[self.data.layout])
  
  initPage: ()->
    self = pateco._page
    source = Templates['module.page']()
    template = Handlebars.compile(source);
    self.element = $('#main-app')
    self.element.html(template)
    console.log pateco
    pateco.config.state = self.data.layout
    pateco.UserService.saveSettingStorage()
    pateco._backButton.enable(false)
    self.getData()
    self.initKey()
    #This code will check move have going by promotion slot or not
    if pateco.config.platform is 'tv_tizen'
      pateco.TizenService.initConfig()
      pateco.KeyService.registeKeyTizen()
  
  
  activeIconBack: (active = true)->
    self = pateco._page
    backButton = self.element.find('.back-button')
    backButton.hide()
    if active then backButton.show()
  
  addClassIntoIcBack: (active = true, callback)->
    self = pateco._page
    backButton = self.element.find('.back-button')
    backButton.removeClass('active')
    if active
      backButton.addClass('active')
  
  
  updateCurrentRibbon: ()->
    self = @
    self.data[self.data.layout] = _.clone(self.data.ribbon)
    self.data.activeRibbon[self.data.layout] = _.clone(self.data.ribbonActive)
  
  reRender: ()->
    self = pateco._page
    self.setCurrentLayout()
    pateco._ribbon.render(self.data.ribbon, self.data.ribbonActive)
    pateco._ribbon.onItemClick(self.openDetail)
    pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
    self.initKey()
  
  handleBackbutton: (keyCode, key) ->
    self = pateco._page
    switch keyCode
      when key.DOWN
        pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
        self.initKey()
      when key.RETURN,key.ENTER
        self.handReturn()
  
  handleKey: (keyCode, key)->
    self = pateco._page
    console.info 'Home Key:' + keyCode
    actionLeftRight = ()->
      self.setCurrentBanner()
      pateco._ribbon.setActivePointer(self.data.ribbon, self.data.ribbonActive)
    
    switch keyCode
      when key.LEFT
        if self.data.ribbon[self.data.ribbonActive].currentActive > 0
          self.data.ribbon[self.data.ribbonActive].currentActive--
          actionLeftRight()
        break;
      when key.RIGHT
        if self.data.ribbon and self.data.ribbon[self.data.ribbonActive] and self.data.ribbon[self.data.ribbonActive].items
          if self.data.ribbon[self.data.ribbonActive].currentActive < self.data.ribbon[self.data.ribbonActive].items.length - 1
            self.data.ribbon[self.data.ribbonActive].currentActive++
            actionLeftRight()
        break;
      when key.DOWN
        if self.data.ribbonActive < self.data.ribbon.length - 1
          self.data.ribbonActive++
          pateco._ribbon.setRibbonPosition(self.data.ribbonActive)
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
        
        if self.data.layout isnt 'home'
          pateco._ribbon.removeActivePointer()
          pateco._backButton.setActive(true, self.handleBackbutton)
        
        break;
      when key.RETURN
        self.handReturn()
    self.updateCurrentRibbon()
  
  initKey: ()->
#    console.error 'init home page key'
    self = pateco._page
    pateco.KeyService.initKey(self.handleKey)
  
  exitApp   : ()->
    self = pateco._page
    pateco._error.initPage({
      onReturn   : self.initKey
      description: 'exit-confirm'
      title      : 'notification'
      buttons    : [
        title   : 'exit'
        callback: pateco.config.exit
      ,
        title   : 'button-cancel'
        callback: self.initKey
      ]
    })
  handReturn: ()->
    self = pateco._page
    if self.data.layout is 'home'
      self.exitApp()
      return
    
    if self.data.layout in ['tvod', 'package']
      pateco._backButton.enable(false)
      self.data.layout = 'home'
      self.reRender()
      self.setCurrentBanner()
    if self.data.layout is 'page'
      pateco._backButton.enable(true)
      self.data.layout = 'package'
      self.setCurrentBanner(false)
    self.reRender()
  
  checkTypeMenu: (banner)->
    return banner unless banner.isMenu
    return banner unless pateco.UserService.isLogin()
    console.log banner
    if banner.id is 'watch-later'
      try
        if pateco.UserService.data.watchLater.items.length is 0
          banner.description = 'header-watchlater-empty'
          banner.deactive = true
        else
          banner.description = 'header-watchlater'
          banner.deactive = false
      catch
    return banner
  
  
  setCurrentBanner: (inFirst = false)->
    self = @
    #    if inFirst
    currentBanner = pateco._banner.getCurrentBanner(self.data.ribbon, self.data.ribbonActive)
    currentBanner.model4K = pateco.config.appInfo.model4K if currentBanner
    currentBanner = self.checkTypeMenu(currentBanner)
    #change data description when logged in
    if currentBanner.id is "setting"
      if pateco.UserService.isLogin()
        currentBanner.description = 'header-setting-logged-in'
      else
        currentBanner.description = 'header-setting'
    if inFirst
      pateco._banner.render(currentBanner)
    else
      currentBanner.ribbonCategoryId = self.data.ribbon[self.data.ribbonActive].categoryId
      pateco._banner.reRender(currentBanner)
  
  onReturnPage: ()->
    self = pateco._page
    pateco._page.loadDataRibonOfUser({}, (err, res)->
      if self.data.layout is 'home'
        pateco._backButton.enable(false)
      self.setCurrentBanner()
      self.reRender()
      pateco.config.state = self.data.layout
    )
  
  
  openDetail: ()->
    self = pateco._page
    currentItem = pateco._banner.getCurrentBanner(self.data.ribbon, self.data.ribbonActive)
    return if currentItem.deactive
    if currentItem.isMenu is true
      return currentItem.action()
    
    if currentItem.isViewmore is true
      if currentItem.pageId
        self.getPage(currentItem.pageId)
      else
        pateco._viewmore.initPage(currentItem, self.onReturnPage)
      return
    
    currentItem.model4K = pateco.config.appInfo.model4K
    pateco._detail.initPage(currentItem, self.onReturnPage)
  
  
  getPackage: ()->
    self = @
    
    retry = ()->
      self.initKey()
      pateco._page.getPackage()
    
    done = (error, result)->
      if error
        pateco._error.initPage({
          onReturn   : pateco.config.exit
          description: 'connect-error'
          title      : 'notification'
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ,
            title   : 'exit'
            callback: pateco.config.exit
          ]
        })
        return console.log error
      self.data.layout = 'package'
      pateco._backButton.enable()
      self.data.package = pateco._ribbon.addViewMoreButton(result)
      #      self.data.package.unshift(self.data.menu)
      self.data.activeRibbon.package = 0
      self.reRender()
      self.setCurrentBanner()
    
    async.waterfall([
      (cb)-> pateco.ApiService.getMenu(cb)
      (result, cb)->
        ids = _.pluck result.items, 'id'
        pateco.ApiService.getPackage(ids, cb)
    ], done)
  
  
  
  insertRibbonPaidToDataPage: (callback)->
    unless pateco.UserService.isLogin()
      callback() if _.isFunction(callback)
      return
    pateco.ApiService.getListPaid({}, (error, resRibbon)->
      if error
        callback() if _.isFunction(callback)
        return
      if !resRibbon or !resRibbon.items or resRibbon.items.length <= 0
        callback() if _.isFunction(callback)
        return
      indexRibbon = _.findIndex(pateco._page.data['tvod'], {categoryId: 'paid'})
      dataRibbon = _.findWhere(pateco._page.data['tvod'], {categoryId: 'paid'})
      if indexRibbon isnt -1 and dataRibbon isnt undefined
        dataRibbon.items = resRibbon.items
        pateco._page.data['tvod'][indexRibbon] = dataRibbon
      else
        resRibbon.currentActive = 0
        pateco._page.data['tvod'].splice(1, 0, resRibbon)
      return callback() if _.isFunction(callback)
    )
  
  getPage: (id, page = 'page')->
    self = @
    
    retry = ()->
      self.initKey()
      pateco.ApiService.getPage(id, done)
    
    done = (error, result)->
      if error
        pateco._error.initPage({
          onReturn   : pateco.config.exit
          description: 'connect-error'
          title      : 'notification'
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ,
            title   : 'exit'
            callback: pateco.config.exit
          ]
        })
        return console.log error
      banner =
        items        : result.banners
        currentActive: 0
        categoryType : 'recommend-movie'
        categoryId   : 'banner'
      self.data.layout = page
      pateco._backButton.enable()
      self.data[page] = pateco._ribbon.addViewMoreButton(result.ribbons)
      self.data[page].unshift(banner)
      self.data.activeRibbon[page] = 0
      self.insertRibbonPaidToDataPage(()->
        self.reRender()
        self.setCurrentBanner()
      )
    pateco.ApiService.getPage(id, done)
  
  
  
  insertUserRibbonToPageHome: (type, resRibbon)->
    return unless pateco.UserService.isLogin()
    return if !resRibbon
    if resRibbon.items and resRibbon.items.length <= 0
      pateco._page.data.home = _.without(pateco._page.data.home, _.findWhere(pateco._page.data.home, {categoryId: type}))
      console.log 'remove ribbon if items.length = 0'
      return
    
    indexRibbon = _.findIndex(pateco._page.data.home, {categoryId: type})
    dataRibbon = _.findWhere(pateco._page.data.home, {categoryId: type})
    if indexRibbon isnt -1 and dataRibbon isnt undefined
      dataRibbon.items = resRibbon.items
      pateco._page.data.home[indexRibbon] = dataRibbon
    else
      resRibbon.currentActive = 0
      if type is 'paid'
        indexRecentRibbon = _.findIndex(pateco._page.data.home, {categoryId: 'recent'})
        if indexRecentRibbon isnt -1
          indexRecentRibbon += 1
        else
          indexRecentRibbon = 2
        pateco._page.data.home.splice(indexRecentRibbon, 0, resRibbon)
      else
        pateco._page.data.home.splice(2, 0, resRibbon)
  
  
  loadDataRibonOfUser: (params, callback)->
    self = pateco._page
    unless pateco.UserService.isLogin()
      callback(null, null) if _.isFunction(callback)
      return
    async.parallel({
      recent  : (cb)->
        pateco.ApiService.getListRecent({}, (error, resRecent)->
          console.info 'resRecent=', resRecent
          return cb(null, null) if error
          self.insertUserRibbonToPageHome('recent', resRecent)
          return cb(null, resRecent)
        )
      ,
      favorite: (cb)->
        pateco.ApiService.getListFavorite({}, (error, resFavorite)->
          console.info 'resFavorite=', resFavorite
          return cb(null, null) if error
          return cb(null, resFavorite)
        )
      ,
      paid    : (cb)->
        pateco.ApiService.getListPaid({}, (error, resPaid)->
          console.info 'resPaid=', resPaid
          return cb(null, null) if error
          self.insertUserRibbonToPageHome('paid', resPaid)
          return cb(null, resPaid)
        )
    }, (error, resultUser)->
      return callback(null, null) if error and _.isFunction(callback)
      callback(null, resultUser) if _.isFunction(callback)
    )
  
  
  getData: ()->
    self = @
    
    retry = ()->
      self.initKey()
      pateco.ApiService.getHome(done)
    
    done = (error, resultHome)->
      if error
        pateco._error.initPage({
          onReturn   : pateco.config.exit
          description: 'connect-error'
          title      : 'notification'
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ,
            title   : 'exit'
            callback: pateco.config.exit
          ]
        })
        return console.log error
      banner =
        items        : resultHome.banners
        currentActive: 0
        categoryType : 'recommend-movie'
        categoryId   : 'banner'
      
      self.data.layout = 'home'
      pateco._page.data.home = []
      pateco._page.data.home = pateco._ribbon.addViewMoreButton(resultHome.ribbons)
      pateco._page.data.home.unshift(banner)
      pateco._page.data.home.unshift(self.data.menu)
      self.loadDataRibonOfUser({}, (errorRibbonOfUser, resultRibbonOfUser)->
        console.info 'loadDataRibonOfUser=', resultRibbonOfUser
        console.info 'self.data.ribbon=', self.data.ribbon
        pateco._page.data.activeRibbon.home = 1
        pateco._page.reRender()
        pateco._page.setCurrentBanner(true)
      )
    
    pateco.ApiService.getHome(done)