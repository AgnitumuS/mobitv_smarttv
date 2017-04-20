fimplus._paymentMethod =
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
          fimplus._paymentMethod.selectPaymentMethod()
      ]

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.payment-method-list').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  selectPaymentMethod: ()->
    self = fimplus._paymentMethod
    if self.data.currentActive is 0
      fimplus._setting.initPage()
      # fimplus._settingMethod.initPage()
      fimplus._addCard.initPage(self.onAddCardReturn, self.onAddCardSuccess)
    else
      if self.data.methods[self.data.currentActive].type is 'MPAY'
        fimplus._rentMovie.initPage(fimplus._detail.data.item, 'mpay', self.onReturnPage)
      else
        fimplus._mobileCard.initPage(self.data.pricePackage, self.onReturnPage)


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
    self = fimplus._paymentMethod
    self.initKey()
    fimplus._setting.removePage()

  retry: ()->
    self.initKey()
  
  onAddCardSuccess: ()->
    self = fimplus._paymentMethod
    sourceId = fimplus._addCard.getSourceId()
    redeemCode = fimplus._redeemCode.data.code
    if fimplus._payment.data.isRentMovie
      fimplus._rentMovie.initPage(fimplus._detail.data.item, sourceId, fimplus._payment.onReturnPage)
    else
      updatePaymentConfirmDone = (error, result) ->
        if result.status is 400
          fimplus._error.initPage({
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

        fimplus._paymentConfirm.initPage(result, fimplus._payment.onReturnPage)
      fimplus.ApiService.updatePaymentConfirm(self.data.packageId, sourceId, redeemCode, updatePaymentConfirmDone)

    
  onReturnPage: ()->
    self = fimplus._paymentMethod
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
    self = fimplus._paymentMethod
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.methods.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = fimplus._paymentMethod
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
          fimplus._backButton.setActive(true, self.hanldeBackbutton)
          self.setActiveButton(0, 0)
        else
          self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.methods.length)
        break;
  
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = fimplus._paymentMethod
    self.data.callback()
    self.element.html('')

    