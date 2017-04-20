fimplus._rentMovie =
  data:
    id           : '#rent-movie'
    title        : 'rental'
    template     : Templates['module.payment.rent-movie']()
    currentActive: 0
    buttons     : [
      buyItemBtn =
        title : 'button-accept'
        action: ()->
          self = fimplus._rentMovie
          self.buyItem()
    ,
      redeemCodeBtn =
        title : 'button-promo-code'
        action: ()->
          self = fimplus._rentMovie
          fimplus._redeemCode.initPage(self.onReInitpage)
    ,
      cancelBtn =
        title : 'button-cancel'
        action: ()->
          self = fimplus._rentMovie
          self.data.currentActive = 0
          fimplus._payment.removePage()
    ]

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.payment-method-list').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  initPage: (item, sourceId, callback)->
    self = @
    self.data.item = item
    self.data.item.priceDefault = fimplus._detail.data.item.ppvPrice
    self.data.sourceId = sourceId
    self.getSourceId()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.initKey()

  reInitpage: ()->
    self = @
    self.getSourceId()
    self.initKey()

  buyItem: ()->
    self = @
    retry = ()->
      self.initKey()
    finish = ()->
      fimplus._page.loadDataRibonOfUser({},()->)
      fimplus._payment.removePage()
    playMovie = ()->
      fimplus._payment.element.html('')
      fimplus._detail.playMovie(fimplus._detail.data.item)
    params =
      itemId : self.data.item.id
      sourceId : self.data.sourceId
      redeemCode : fimplus._redeemCode.data.code or null
      version : 1.0
    if fimplus._payment.data.isRentMovie && self.data.sourceId is ''
      params.isTelco = '1'
    buyItemDone = (error, result)->
      if result.status is 400
        fimplus._error.initPage({
          title      : "payment-fail"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      fimplus._error.initPage({
        title      : "payment-success"
        onReturn   : finish
        description: result.message
        buttons    : [
            title    : 'payment-button-later'
            callback : finish
          ,
            title   : 'payment-button-play'
            callback: playMovie
        ]
      });
    fimplus.ApiService.buyItem(params, buyItemDone)

  checkRedeemCode: ()->
    self = @
    self.data.code = fimplus._redeemCode.data.code or null
    if self.data.code
      self.data.buttons[1].title = self.data.code+' - '+fimplus.LanguageService.convert('change', fimplus.UserService.getValueStorage('userSettings', 'language'))
      if fimplus._redeemCode.data.percent is 1
        self.data.item.ppvPrice = fimplus._detail.data.item.ppvPrice * fimplus._redeemCode.data.discount
        if fimplus._payment.data.isRentMovie
          fimplus._detail.data.item.knownAs
      else
        self.data.item.ppvPrice = fimplus._detail.data.item.ppvPrice - fimplus._redeemCode.data.discount
    else
      self.data.buttons[1].title = 'button-promo-code'

  getSourceId: ()->
    self = fimplus._rentMovie
    env = fimplus.env
    getSourceIdDone = (error, result)->
      return if result.status is 400
      i = 0
      while i < result.sources.length
        if result.sources[i].methodType == 'CCSTRIPE'
          self.data.paymentMethodSync = 1
          self.data.sourceId = result.sources[i].id
        i++
      self.checkRedeemCode()
      self.confirmMessage()
    fimplus.ApiService.getPaymentMethod(null, env, getSourceIdDone)

  confirmMessage: ()->
    self = fimplus._rentMovie
    if self.data.sourceId is 'mpay' or self.data.sourceId is 'MBF'
      self.data.description = ['do-you-want-rent', self.data.item.knownAs, 'playable-48h', fimplus.UtitService.coverNumber(self.data.item.ppvPrice), 'd', 'mpay-method']
    else if fimplus._payment.data.isRentMovie and self.data.paymentMethodSync isnt 1
      self.data.description = ['do-you-want-rent', self.data.item.knownAs, 'playable-48h', fimplus.UtitService.coverNumber(self.data.item.ppvPrice), 'd']
    else
      self.data.description = ['do-you-want-rent',self.data.item.knownAs, 'playable-48h', fimplus.UtitService.coverNumber(self.data.item.ppvPrice), 'd', 'using-visa']
    self.render()
  onReturnPage: ()->
    self = fimplus._rentMovie
    self.initKey()

  onReInitpage: ()->
    self = fimplus._rentMovie
    self.reInitpage()

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({rentMovie: self.data}))
    self.setActiveButton(self.data.currentActive, self.data.buttons.length)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.payment-method-list').find('li')
      .off 'click'
      .on 'click', buttonClick


  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._rentMovie
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.buttons.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()


  handleKey: (keyCode, key)->
    self = fimplus._rentMovie
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.data.buttons[self.data.currentActive].action()
        break;
      when key.DOWN
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.buttons.length)
        break;
      when key.UP
        if self.data.currentActive is 0
          fimplus._backButton.setActive(true, self.hanldeBackbutton)
          self.setActiveButton(0, 0)
        else
          self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.buttons.length)
        break;

  initKey: ()->
    self = @
    self.data.item.ppvPrice = self.data.item.priceDefault
    fimplus.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = fimplus._rentMovie
    self.data.currentActive = 0
    self.data.callback()
    self.element.html('')

    