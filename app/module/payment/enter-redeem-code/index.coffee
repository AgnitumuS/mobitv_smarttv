fimplus._enterRedeemCode =
  data:
    id           : '#enter-redeem-code'
    title        : 'enter-code'
    template     : Templates['module.payment.enter-redeem-code']()
    currentActive: 0
    buttons     : [
      registerBtn =
        title: 'Hoàn tất'
        action: ()->
          fimplus._enterRedeemCode.addCode()
      ]
    positionEntity:
      active : false

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = $(self.data.id).find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  addCode: ()->
    self = @
    self.data.code = self.element.find('#input-redeem-code').val().toLowerCase()
    retry = ()->
      self.initKey()
    finish = ()->
      self.removePage()
    unless self.data.code
      fimplus._error.initPage({
        title      : "code-discount"
        onReturn   : retry
        description: 'code-empty'
        buttons    : [
          title   : 'OK'
          callback: retry
        ]
      });
      return
    getVerifyCodeDone = (error, result) ->
      if result.status is 400
        fimplus._error.initPage({
          title      : "code-discount"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      if result.isAutoApply != 1
        getbCodeActiveDone = (error, result) ->
          if result.status is 400
            fimplus._error.initPage({
              title      : "code-discount"
              onReturn   : retry
              description: result.responseJSON.message
              buttons    : [
                title   : 'button-try-again'
                callback: retry
              ]
            });
            return
          fimplus._error.initPage({
            title      : "code-discount"
            onReturn   : finish
            description: result.message
            buttons    : [
              title   : 'OK'
              callback: finish
            ]
          });
        fimplus.ApiService.getbCodeActive(self.data.code, getbCodeActiveDone)
      else
        fimplus._error.initPage({
          title      : "code-discount"
          onReturn   : retry
          description: 'code-not-accept'
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
    fimplus.ApiService.getVerifyCode(self.data.code, getVerifyCodeDone)

  initPage: (callback)->
    self = @
    self.render()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.initKey()

  onReturnPage: ()->
    self = fimplus._enterRedeemCode
    self.initKey()


  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({payment: self.data}))
    fimplus._payment.showPage(self.element)
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
    element = $('.enter-redeem-code-keyboard')
    input = $('#input-redeem-code')
    fimplus._keyboard.render(element, input, self.onActiveEntity, 'text')

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._enterRedeemCode
    switch keyCode
      when key.DOWN
        fimplus._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  onActiveEntity: (type = 'DOWN')->
    self = fimplus._enterRedeemCode
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        fimplus._backButton.setActive(true, self.hanldeBackbutton)
        fimplus._keyboard.setActiveKeyboard(0, 0, false)

  handleKey: (keyCode, key)->
    self = fimplus._enterRedeemCode
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
    self = fimplus._enterRedeemCode
    self.data.callback()
    self.element.html('')

    