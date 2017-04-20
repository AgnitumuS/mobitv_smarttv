pateco._cardSeri =
  data:
    id           : '#card-seri'
    title        : 'series-number'
    template     : Templates['module.payment.select-card.card-seri']()
    currentActive: 0
    buttons     : [
      registerBtn =
        title: 'button-continue'
        action: ()->
          pateco._cardSeri.addCode()
      ]
    positionEntity:
      active : false

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  addCode : ()->
    self = @
    self.element.find(".wrap-loading").show()
    self.data.cardSeri = $("#input-card-seri").val()
    retry = ()->
      self.initKey()
    finish = ()->
      pateco._selectCard.removePage()
    env = pateco.env
    unless self.data.cardSeri
      pateco._error.initPage({
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
        pateco._error.initPage({
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
        pateco._error.initPage({
          title      : "phone-card"
          onReturn   : retry
          description: 'player-error'
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      pateco._error.initPage({
        title      : "phone-card"
        onReturn   : finish
        description: result.message
        buttons    : [
          title   : 'OK'
          callback: finish
        ]
      });
    pateco.ApiService.updatePaymentMobileCard(self.data.cardSeri, pateco._cardNumber.data.cardNumber, pateco._selectCard.data.telcoCode, env, updatePaymentMobileCardDone)

  initPage: (callback)->
    self = @
    self.render()
    self.initKey()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = pateco._cardSeri
    self.initKey()


  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({mobileCard: self.data}))
    
    @renderKeyboard()
    pateco._keyboard.setActiveKeyboard(0, 0)
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
    pateco._keyboard.render(element, input, self.onActiveEntity, 'number')

  onActiveEntity: (type = 'DOWN')->
    self = pateco._cardSeri
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        pateco._backButton.setActive(true, self.hanldeBackbutton)


  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._cardSeri
    switch keyCode
      when key.DOWN
        pateco._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = pateco._cardSeri
    positionEntity = self.data.positionEntity
    if keyCode isnt key.RETURN
      unless positionEntity.active
        pateco._keyboard.handleKey(keyCode, key)
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
        pateco._keyboard.onBackBoardButton()
  
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = pateco._cardSeri
    self.data.callback()
    self.element.html('')

    