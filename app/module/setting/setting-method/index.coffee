fimplus._settingMethod =
  data:
    id: '#setting-method'
    template  : Templates['module.setting.setting-method']()
    currentActive: 0
    onFocus: true
    settingMethodCheck:
        active: false
    settingMethodtitle: 'account-payment-method'
    setting_method: null
    addMethod: 0
    sources: null
    cardBrand: null
    callback: ()->
    loadCard: 
        active: false
    haveSource: false
    isMBF: false
    expYear: null
    buttons: 
      visa: 
        title: 'credit-card'
        action: ()->
          console.log 'Load VISA'
      changeCard: 
        title: 'change-card'
        action: ()->
          console.log 'change-card'
          # self.data.loadCard.active = false
          # self.data.addCard.active = true
          fimplus._settingMethod.initKey()
          fimplus._addCard.initPage(fimplus._settingMethod.callBackFunc)
  
  loadVisaKey: (event)->
    self = fimplus._settingMethod
    self.data.loadCard.active = true
    self.data.onFocus = true
    self.data.addMethod = 2
    self.data.settingMethodtitle = 'account-title-payment'
    self.render()

  initPage: (callback)->
    self = fimplus._settingMethod
    self.data.loadCard.active = false
    self.data.callback = ()->
      console.log 'setting method callback to setting'
    self.data.callback = callback if _.isFunction(callback)
    self.render()
    self.getData() 
    self.initKey()

  getData: ()->
    self = fimplus._settingMethod
    done = (error, result)->
      if result.status is 403
        #UtitService.closeHome()
        console.log "call login Screen"
        fimplus._login.initPage(self.callBackFunc, self.callBackFunc)
        #UtitService.openLogin()
      if result.sources[0] isnt null and result.sources[0] isnt undefined
        self.data.haveSource = true
        self.data.sources = result.sources[0]
        if result.sources[0].id is 'MBF'
          self.data.isMBF = true
        else
          self.data.cardBrand = result.sources[0].detail.brand.toLowerCase()
          self.data.expYear = result.sources[0].detail.expYear.toString().substr(2,3)
          month = result.sources[0].detail.expMonth
          if month < 10
            result.sources[0].detail.expMonth = '0' + month
        self.loadVisaKey()
        fimplus.KeyService.initKey(self.handleKeyLoadCard)
      else
        # open add card
        self.initKey()
    
    fimplus.ApiService.getPaymentMethod(null, window.fimplus.env, done)

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({
      settingMethodCheck: self.data.settingMethodCheck.active
      settingMethodtitle: self.data.settingMethodtitle
      setting_method: self.data.setting_method
      addMethod: self.data.addMethod
      loadCard: self.data.loadCard.active
      haveSource: self.data.haveSource
      expYear: self.data.expYear
      sources: self.data.sources
      currentActive: self.data.currentActive
      onFocus: self.data.onFocus
      buttons: self.data.buttons
      isMBF: self.data.isMBF
      cardBrand: self.data.cardBrand
    }))

  updateActive: (list, index, child)->
    self = @
    $(list).children(child).removeClass("active")
    nextActiveButton = $(list).children(child).get(index)
    $(nextActiveButton).addClass("active")

  toggleActiveMenu: (toggle)->
    listElement = '#setting-method .setting-menu'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = fimplus._settingMethod
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        # check to focus Active Key handle
        if self.data.sources isnt null and self.data.sources isnt undefined
          fimplus.KeyService.initKey(self.handleKeyLoadCard)
        else
          self.initKey()

      when key.RETURN,key.ENTER
        self.removePage()
    
  handleKey: (keyCode, key)->
    self = fimplus._settingMethod
    console.info 'Setting Method Key:' + keyCode
    # length = Object.keys(self.data.buttons).length
    listElement = '.setting-menu'
    switch keyCode
      when key.ENTER
        # fimplus.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        fimplus._addCard.initPage(self.callBackFunc)
        break;
      when key.RETURN
        self.removePage()
        fimplus._setting.initKey()
        break;
      when key.UP
        fimplus._backButton.setActive(true, self.handleBackbutton)
        self.toggleActiveMenu(false)

  handleKeyLoadCard: (keyCode, key)->
    self = fimplus._settingMethod
    console.info 'Setting Load Visa Card:' + keyCode
    length = $('.bt-payment-load').find('li').length
    listElement = '.bt-payment-load'
    actionKey = ()->
      self.data.currentActive = fimplus.KeyService.reCalc(self.data.currentActive, length)
      self.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        fimplus.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        break;
      when key.RETURN
        console.log 'Call back to setting menu'
        self.data.haveSource = false
        self.removePage()
        fimplus._setting.initKey()
        break;
      when key.UP
        self.data.currentActive--
        if self.data.currentActive < 0
          fimplus._backButton.setActive(true, self.handleBackbutton)
          self.toggleActiveMenu(false)
        else
        actionKey()
        break;
      when key.DOWN
        self.data.currentActive++
        console.log "down key add method"
        actionKey()
        break;
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)

  callBackFunc: ()->
    self = fimplus._settingMethod
    self.initPage()
  
  removePage: ()->
    self = @
    element = $(self.data.id)
    self.data.isMBF = false
    self.data.callback() if _.isFunction(self.data.callback)
    element.find('.setting-method').removeClass('fadeIn').addClass('fadeOut')
    element.html('')
    # setTimeout(()->
    #   $(self.data.id).html('')
    # , 500)
  