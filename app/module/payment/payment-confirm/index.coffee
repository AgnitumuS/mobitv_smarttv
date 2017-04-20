pateco._paymentConfirm =
  data:
    id           : '#payment-confirm'
    title        : 'button-buy-package'
    descriptionUnder: 'term-of-service'
    template     : Templates['module.payment.payment-confirm']()
    currentActive: 0
    redeemCodeActive: false
    buttons     : [
      cancelBtn =
        title : 'button-cancel'
        action: ()->
          pateco._paymentConfirm.removePage()
      registerBtn =
        title: 'button-accept'
        action: ()->
          pateco._paymentConfirm.buyPackage()
      ]


  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  selectCard: (index)->
    self = @
    index = index or self.data.currentActive
    console.log index

  initPage: (item = null, callback)->
    self = pateco._paymentConfirm
    self.data.item = item
    self.render()
    self.initKey()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = pateco._paymentConfirm
    self.initKey()

  getApiBuyPackage: (params)->
    self = pateco._paymentConfirm
    retry = ()->
      self.initKey()
    finish = ()->
      pateco._payment.removePage()
    buyPackageDone = (error, result)->
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
      pateco._error.initPage({
        title      : "button-buy-package"
        onReturn   : finish
        description: result.message
        buttons    : [
          title   : 'OK'
          callback: finish
        ]
      });
    pateco.ApiService.buyPackage(params, buyPackageDone)

  buyPackage: ()->
    self = @
    if pateco._listPackage.data.paymentMethodSync is 1
      params =
        redeemCode : pateco._redeemCode.data.code or ''
        packageId : self.data.item.newPackageId
        sourceId : pateco._listPackage.data.sourceId
      self.getApiBuyPackage(params)
    else
      env = pateco.env
      getSourceIdDone = (error, result)->
        if result.status is 400
          params =
            method : ''
            paymentSource : ''
            sourceId : ''
            isTelco : 1
            redeemCode : pateco._redeemCode.data.code or ''
            packageId : self.data.item.newPackageId
          self.getApiBuyPackage(params)
          return
        i = 0
        while i < result.sources.length
          if result.sources[i].methodType == 'CCSTRIPE'
            self.data.paymentMethodSync = 1
            self.data.sourceId = result.sources[i].id
          i++
        if self.data.paymentMethodSync is 1
          params =
            redeemCode : pateco._redeemCode.data.code or ''
            packageId : self.data.item.newPackageId
            sourceId : self.data.sourceId
          self.getApiBuyPackage(params)
        else
          params =
            method : ''
            paymentSource : ''
            sourceId : ''
            isTelco : 1
            redeemCode : pateco._redeemCode.data.code or ''
            packageId : self.data.item.newPackageId
          self.getApiBuyPackage(params)
      pateco.ApiService.getPaymentMethod('["MPAY"]', env, getSourceIdDone)

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({paymentConfirm: self.data}))
    self.setActiveButton(self.data.currentActive, self.data.buttons.length)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._paymentConfirm
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.buttons.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = pateco._paymentConfirm
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.data.buttons[self.data.currentActive].action()
        break;
      when key.RIGHT
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.buttons.length)
        break;
      when key.LEFT
        self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.buttons.length)
        break;
      when key.UP
        pateco._backButton.setActive(true, self.hanldeBackbutton)
        self.setActiveButton(0, 0)
        break;

  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = pateco._paymentConfirm
    self.data.callback()
    self.element.html('')
