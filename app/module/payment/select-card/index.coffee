fimplus._selectCard =
  data:
    id           : '#select-card'
    title        : 'select-card'
    template     : Templates['module.payment.select-card']()
    currentActive: 0
    redeemCodeActive: false
    buttons     : [
      registerBtn =
        action: ()->
          fimplus._selectCard.selectCard()
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
    self.data.telcoCode = self.data.listTelco[index].code
    fimplus._cardNumber.initPage(self.onReturnPage)

  initPage: (callback)->
    self = @
    self.getData()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = fimplus._selectCard
    self.initKey()


  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({mobileCard: self.data}))
    self.setActiveButton(self.data.currentActive, self.data.listTelco.length)
    buttonClick = ()->
      index = $(@.parentElement.parentElement).index()
      self.selectCard(index)
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick

  getData: ()->
    self = @
    env = fimplus.env
    retry = ()->
      self.initKey()
    getPaymentMobileCardDone = (error, result) ->
      if result.status
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
      self.data.listTelco = result
      self.render()
      self.initKey()
      console.log result
    fimplus.ApiService.getPaymentMobileCard(env, getPaymentMobileCardDone)

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._selectCard
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.listTelco.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = fimplus._selectCard
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.data.buttons[0].action()
        break;
      when key.RIGHT
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.listTelco.length)
        break;
      when key.LEFT
        self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.listTelco.length)
        break;
      when key.UP
        fimplus._backButton.setActive(true, self.hanldeBackbutton)
        self.setActiveButton(0, 0)
        break;

  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = fimplus._selectCard
    self.data.callback()
    self.element.html('')

#    fimplus._mobileCard.initPage(fimplus._listPackage.data.pricePackage)