fimplus._mobileCard =
  data:
    id           : '#mobile-card'
    title        : 'account-balance'
    template     : Templates['module.payment.mobile-card']()
    currentActive: 0
    redeemCodeActive: false
    buttons     : [
      cancelBtn =
        title : 'Hủy'
        action: ()->
          fimplus._mobileCard.removePage()
      registerBtn =
        title: 'Đồng ý'
        action: ()->
          fimplus._selectCard.initPage(fimplus._mobileCard.onReturnPage)
      ]


  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  selectCard: (index)->
    self = @
    index = index or self.data.currentActive
    console.log index

  initPage: (item = null, callback)->
    self = @
    self.data.item = item
    self.checkRedeemCode()
    self.getData()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = fimplus._mobileCard
    self.initKey()

  checkRedeemCode: ()->
    self = @
    self.data.code = fimplus._redeemCode.data.code or null
    if self.data.code
      if fimplus._redeemCode.data.percent is 1
        self.data.item = self.data.item * fimplus._redeemCode.data.discount
      else
        self.data.item = self.data.item - fimplus._redeemCode.data.discount

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({mobileCard: self.data}))
    self.setActiveButton(self.data.currentActive, self.data.buttons.length)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick

  getData: ()->
    self = @
    env = fimplus.env
    retry = ()->
      self.initKey()
    getWalletDone = (error, result)->
      if result.status is 400
        fimplus._error.initPage({
          title      : "select-card"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      self.data.userWallet = result
      self.data.price = self.data.item - result.balance
#      if buyPackage is true
      if result.balance >= self.data.item
        if fimplus._payment.data.isRentMovie
          itemResult =
            id : fimplus._detail.data.item.id
            ppvPrice : fimplus._detail.data.item.ppvPrice
            knownAs : fimplus._detail.data.item.knownAs
          fimplus._rentMovie.initPage(itemResult, '', fimplus._payment.onReturnPage)
        else
          params =
            packageId : localStorage.packageId
            redeemCode : fimplus._redeemCode.data.code or null
            sourceId  : ""
            isTelco   : "1"
          updateWalletSubscriptionDone = (error, result) ->
            if result.status is 400
              fimplus._error.initPage({
                title      : "select-card"
                onReturn   : retry
                description: result.responseJSON.message
                buttons    : [
                  title   : 'button-try-again'
                  callback: retry
                ]
              });
              return
            else
              fimplus._paymentConfirm.initPage(result, fimplus._payment.onReturnPage)
          fimplus.ApiService.updateWalletSubscription(params, updateWalletSubscriptionDone)
      else
        self.render()
        self.initKey()
    fimplus.ApiService.getWallet(env, getWalletDone)

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._mobileCard
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.buttons.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = fimplus._mobileCard
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
        fimplus._backButton.setActive(true, self.hanldeBackbutton)
        self.setActiveButton(0, 0)
        break;

  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = fimplus._mobileCard
    self.data.callback()
    self.element.html('')