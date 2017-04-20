fimplus._cardNumber =
  data:
    id           : '#card-number'
    title        : 'mobile-card-number'
    template     : Templates['module.payment.select-card.card-number']()
    currentActive: 0
    buttons     : [
      registerBtn =
        title: 'button-continue'
        action: ()->
          fimplus._cardNumber.addCode()
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
    self.data.cardNumber = $("#input-card-number").val()
    retry = ()->
      self.initKey()
    unless self.data.cardNumber
      fimplus._error.initPage({
        title      : "mobile-card-number"
        onReturn   : retry
        description: "enter-mobile-card"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return
    fimplus._cardSeri.initPage(self.onReturnPage)

  initPage: (callback)->
    self = @
    self.render()
    self.initKey()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = fimplus._cardNumber
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
    element = $('.card-number-keyboard')
    input = $('#input-card-number')
    fimplus._keyboard.render(element, input, self.onActiveEntity, 'number')

  onActiveEntity: (type = 'DOWN')->
    self = fimplus._cardNumber
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        fimplus._backButton.setActive(true, self.hanldeBackbutton)

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._cardNumber
    switch keyCode
      when key.DOWN
        fimplus._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = fimplus._cardNumber
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
    self = fimplus._cardNumber
    self.data.callback()
    self.element.html('')

    