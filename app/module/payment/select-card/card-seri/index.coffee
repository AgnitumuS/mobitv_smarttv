fimplus._cardSeri =
  data:
    id           : '#card-seri'
    title        : 'series-number'
    template     : Templates['module.payment.select-card.card-seri']()
    currentActive: 0
    buttons     : [
      registerBtn =
        title: 'button-continue'
        action: ()->
          fimplus._cardSeri.addCode()
      ]
    positionEntity:
      active : false

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  addCode : ()->
    self = @
    self.element.find(".wrap-loading").show()
    self.data.cardSeri = $("#input-card-seri").val()
    retry = ()->
      self.initKey()
    finish = ()->
      fimplus._selectCard.removePage()
    env = fimplus.env
    unless self.data.cardSeri
      fimplus._error.initPage({
        title      : "series-number"
        onReturn   : retry
        description: "type-card-series-number"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return
    updatePaymentMobileCardDone = (error, result) ->
      self.element.find(".wrap-loading").hide()
      if result.status is 400
        console.log error
        fimplus._error.initPage({
          title      : "phone-card"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      if error
        console.log error
        fimplus._error.initPage({
          title      : "phone-card"
          onReturn   : retry
          description: 'player-error'
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      fimplus._error.initPage({
        title      : "phone-card"
        onReturn   : finish
        description: result.message
        buttons    : [
          title   : 'OK'
          callback: finish
        ]
      });
    fimplus.ApiService.updatePaymentMobileCard(self.data.cardSeri, fimplus._cardNumber.data.cardNumber, fimplus._selectCard.data.telcoCode, env, updatePaymentMobileCardDone)

  initPage: (callback)->
    self = @
    self.render()
    self.initKey()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = fimplus._cardSeri
    self.initKey()


  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({mobileCard: self.data}))
    
    @renderKeyboard()
    fimplus._keyboard.setActiveKeyboard(0, 0)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick

  renderKeyboard: ()->
    self = @
    self.data.positionEntity.active = false
    element = $('.card-seri-keyboard')
    input = $('#input-card-seri')
    fimplus._keyboard.render(element, input, self.onActiveEntity, 'number')

  onActiveEntity: (type = 'DOWN')->
    self = fimplus._cardSeri
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        fimplus._backButton.setActive(true, self.hanldeBackbutton)


  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._cardSeri
    switch keyCode
      when key.DOWN
        fimplus._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = fimplus._cardSeri
    positionEntity = self.data.positionEntity
    if keyCode isnt key.RETURN
      unless positionEntity.active
        fimplus._keyboard.handleKey(keyCode, key)
        return
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.data.buttons[self.data.currentActive].action()
        break;
      when  key.UP
        self.data.positionEntity.active = false
        self.element.find('.bt-movie').find('li').removeClass('active')
        fimplus._keyboard.onBackBoardButton()
  
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = fimplus._cardSeri
    self.data.callback()
    self.element.html('')

    