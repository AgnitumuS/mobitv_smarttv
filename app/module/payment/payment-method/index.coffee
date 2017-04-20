pateco._paymentMethod =
  data:
    id           : '#payment-method'
    title        : 'account-payment-method'
    description  : 'please-select-method'
    template     : Templates['module.payment.payment-method']()
    currentActive: 0
    packageId    : ''
    buttons     : [
      registerBtn =
        action: ()->
          pateco._paymentMethod.selectPaymentMethod()
      ]

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.payment-method-list').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  selectPaymentMethod: ()->
    self = pateco._paymentMethod
    if self.data.currentActive is 0
      pateco._setting.initPage()
      # pateco._settingMethod.initPage()
      pateco._addCard.initPage(self.onAddCardReturn, self.onAddCardSuccess)
    else
      if self.data.methods[self.data.currentActive].type is 'MPAY'
        pateco._rentMovie.initPage(pateco._detail.data.item, 'mpay', self.onReturnPage)
      else
        pateco._mobileCard.initPage(self.data.pricePackage, self.onReturnPage)


  initPage: (item = null, callback)->
    self = @
    if item
      self.data.methods = item.methods
      self.data.pricePackage = item.pricePackage
      self.data.packageId = item.packageId
    self.render()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.initKey()

  onAddCardReturn: ()->
    self = pateco._paymentMethod
    self.initKey()
    pateco._setting.removePage()

  retry: ()->
    self.initKey()
  
  onAddCardSuccess: ()->
    self = pateco._paymentMethod
    sourceId = pateco._addCard.getSourceId()
    redeemCode = pateco._redeemCode.data.code
    if pateco._payment.data.isRentMovie
      pateco._rentMovie.initPage(pateco._detail.data.item, sourceId, pateco._payment.onReturnPage)
    else
      updatePaymentConfirmDone = (error, result) ->
        if result.status is 400
          pateco._error.initPage({
            title      : "button-buy-package"
            onReturn   : self.retry
            description: result.responseJSON.message
            buttons    : [
              title   : 'button-try-again'
              callback: self.retry
            ]
          });
          return
        localStorage.packageId = result.newPackageId
        localStorage.packageInfo = JSON.stringify(result)

        pateco._paymentConfirm.initPage(result, pateco._payment.onReturnPage)
      pateco.ApiService.updatePaymentConfirm(self.data.packageId, sourceId, redeemCode, updatePaymentConfirmDone)

    
  onReturnPage: ()->
    self = pateco._paymentMethod
    self.initKey()

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({payment: self.data}))
    self.setActiveButton(self.data.currentActive, self.data.methods.length)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.payment-method-list').find('li')
      .off 'click'
      .on 'click', buttonClick

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._paymentMethod
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.methods.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = pateco._paymentMethod
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.data.buttons[0].action()
        break;
      when key.DOWN
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.methods.length)
        break;
      when key.UP
        if self.data.currentActive is 0
          pateco._backButton.setActive(true, self.hanldeBackbutton)
          self.setActiveButton(0, 0)
        else
          self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.methods.length)
        break;
  
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = pateco._paymentMethod
    self.data.callback()
    self.element.html('')

    