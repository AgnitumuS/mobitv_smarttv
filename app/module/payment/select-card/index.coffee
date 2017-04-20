pateco._selectCard =
  data:
    id           : '#select-card'
    title        : 'select-card'
    template     : Templates['module.payment.select-card']()
    currentActive: 0
    redeemCodeActive: false
    buttons     : [
      registerBtn =
        action: ()->
          pateco._selectCard.selectCard()
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
    self.data.telcoCode = self.data.listTelco[index].code
    pateco._cardNumber.initPage(self.onReturnPage)

  initPage: (callback)->
    self = @
    self.getData()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = pateco._selectCard
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
    env = pateco.env
    retry = ()->
      self.initKey()
    getPaymentMobileCardDone = (error, result) ->
      if result.status
        pateco._error.initPage({
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
    pateco.ApiService.getPaymentMobileCard(env, getPaymentMobileCardDone)

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._selectCard
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.listTelco.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = pateco._selectCard
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
        pateco._backButton.setActive(true, self.hanldeBackbutton)
        self.setActiveButton(0, 0)
        break;

  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = pateco._selectCard
    self.data.callback()
    self.element.html('')

#    pateco._mobileCard.initPage(pateco._listPackage.data.pricePackage)