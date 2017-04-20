pateco._listPackage =
  data:
    id           : '#list-package'
    title        : 'register-package-title'
    template     : Templates['module.payment.buy-package.list-package']()
    currentActive: 0
    redeemCodeActive: false
    buttonPackage: 'button-welcome-register'
    buttons     : [
        title : 'code-discount'
        action: ()->
          $(pateco._listPackage.data.id).hide()
          pateco._redeemCode.initPage(pateco._listPackage.onReturnPage)
      ]



  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  setRedeemCodeActive : (boolean)->
    self = @
    button = self.element.find('.redeem-code ')
    if boolean
      button.addClass('active')
    else
      button.removeClass('active')

  buyPackageBtn : (index)->
    self = @
    index = index or self.data.currentActive
    packageId = self.data.item[index].id
    self.data.pricePackage = self.data.item[index].realPrice
    self.data.packageId = packageId
    retry = ()->
      self.initKey()
    if self.data.paymentMethodSync == 1
      retry = ()->
        self.initKey()
      sourceId = self.data.sourceId
      redeemCode = pateco._redeemCode.data.code
      updatePaymentConfirmDone = (error, result) ->
        if result.status is 400
          pateco._error.initPage({
            title      : "button-buy-package"
            onReturn   : retry
            description: result.responseJSON.message
            buttons    : [
              title   : 'button-try-again'
              callback: retry
            ]
          });
          return
        localStorage.packageId = result.newPackageId
        localStorage.packageInfo = JSON.stringify(result)
        pateco._paymentConfirm.initPage(result, pateco._payment.onReturnPage)
      pateco.ApiService.updatePaymentConfirm(packageId, sourceId, redeemCode, updatePaymentConfirmDone)
    else
      localStorage.packageId = packageId
      pateco._paymentMethod.initPage(self.data, self.onReturnPage)

  checkRedeemCode: ()->
    self = @
    self.data.code = pateco._redeemCode.data.code or null
    if self.data.code
      self.data.buttons[0].title = self.data.code+' - '+pateco.LanguageService.convert('change', pateco.UserService.getValueStorage('userSettings', 'language'))
      i = 0
      while i < self.data.item.length
        if pateco._redeemCode.data.percent is 1
          self.data.item[i].price.default = self.data.item[i].price.default * pateco._redeemCode.data.discount
        else
          self.data.item[i].price.default = self.data.item[i].price.default - pateco._redeemCode.data.discount
        i++
    else
      self.data.buttons[0].title = 'code-discount'


  initPage: (callback)->
    self = @
    self.getData()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = pateco._listPackage
    self.getData()
  
  render: ()->
    self = @
    source = self.data.template
    if pateco._buyPackage.data.updatePre
      self.data.updatePre = pateco._buyPackage.data.updatePre
      self.data.title = 'update-pre-title'
      self.data.buttonPackage = pateco.LanguageService.convert('update-pre-btn', pateco.UserService.getValueStorage('userSettings', 'language'))
    else
      self.data.buttonPackage = pateco.LanguageService.convert('button-welcome-register', pateco.UserService.getValueStorage('userSettings', 'language'))
    self.checkRedeemCode()
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({payment: self.data}))
    self.element.hide().slideDown()
    self.setActiveButton(self.data.currentActive, self.data.item.length)
    buttonClick = ()->
      self.data.buttons[0].action()
    self.element.find('.redeem-code')
      .off 'click'
      .on 'click', buttonClick
    packageClick = ()->
      index = $(@.parentElement.parentElement).index()
      self.buyPackageBtn(index)
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', packageClick



  getData: ()->
    self = @
    retry = ()->
      self.initKey()
    env = pateco.env
    self.data.paymentMethodSync = 0
    movieId = pateco._detail.data.item.id or null
    getSourceIdDone = (error, result) ->
      if result.status
        pateco._error.initPage({
          title      : "button-buy-package"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      i = 0
      self.data.methods = result.methods
      while i < result.sources.length
        if result.sources[i].methodType == 'CCSTRIPE'
          self.data.paymentMethodSync = 1
        i++
      if result.sources.length > 0
        self.data.url = "packagedisplay?method=ccstripe&platform=#{pateco.config.platform}&env=#{env}&version=1.0"
        i = 0
        while i < result.sources.length
          if result.sources[i].methodType is 'CCSTRIPE'
            self.data.sourceId = result.sources[i].id
          i++
      else
        self.data.url = "packagedisplay?method=&paymentSource=&platform=#{pateco.config.platform}&env=#{env}&version=1.0"
      getPackageDisplayDone = (error, result) ->
        if error
          pateco._error.initPage({
            title      : "button-buy-package"
            onReturn   : retry
            description: result.responseJSON.message
            buttons    : [
              title   : 'button-try-again'
              callback: retry
            ]
          });
          return
        self.data.item = result
        i = 0
        while i < self.data.item.length
          self.data.item[i].priceDefault = self.data.item[i].price.default
          i++
        self.render()
        self.initKey()
      pateco.ApiService.getPackageDisplay(movieId, self.data.url, getPackageDisplayDone)
    pateco.ApiService.getPaymentMethod('["MPAY"]', env, getSourceIdDone)

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._listPackage
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.item.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = pateco._listPackage
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        if self.data.redeemCodeActive is false
          self.buyPackageBtn()
        else
          self.data.buttons[0].action()
        break;
      when key.DOWN
        self.setActiveButton(-1, 0)
        self.data.redeemCodeActive = true
        self.setRedeemCodeActive(self.data.redeemCodeActive)
        break;
      when key.UP
        if self.data.redeemCodeActive is false
          pateco._backButton.setActive(true, self.hanldeBackbutton)
          self.setActiveButton(0, 0)
        else
          self.setActiveButton(self.data.currentActive, self.data.item.length)
          self.data.redeemCodeActive = false
          self.setRedeemCodeActive(self.data.redeemCodeActive)
        break;
      when key.LEFT
        if self.data.redeemCodeActive is false
          self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.item.length)
        break;
      when key.RIGHT
        if self.data.redeemCodeActive is false
          self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.item.length)
        break;
  
  initKey: ()->
    self = @
    self.data.redeemCodeActive = false
    pateco.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = pateco._listPackage
    self.data.callback()
    self.element.html('')

    