fimplus._registerUserName =
  data:
    id            : '#register-user-name'
    title         : 'register-title'
    description   : 'login-phone-input-phone'
    template      : Templates['module.login.register-user-name']()
    currentActive : 0
    buttons       : [
      cancelBtn =
        title : 'button-back'
        action: ()->
          fimplus._registerUserName.removePage()
    ,
      continueBtn =
        title : 'button-continue'
        action: ()->
          fimplus._registerUserName.registerContinue()
    ]
    positionEntity:
      active: false
  
  
  registerContinue: ()->
    self = @
    self.username = $("#register-username").val()
    retry = ()->
      self.element.find('#register-username').val('')
      self.initKey()
    if self.checkUsername()
      params =
        mobile  : self.username
        platform: fimplus.config.platform
      fimplus.ApiService.registerGetCode params, (error, result)->
        if result.status
          fimplus._error.initPage({
            title      : "register-fail"
            onReturn   : retry
            description: result.responseJSON.message
            buttons    : [
              title   : 'button-try-again'
              callback: retry
            ]
          });
          return
        fimplus._registerOtp.initPage(self.onReturnPage)
  
  setActiveButton: (current = 0, length = 0)->
    self = @
    button = $(self.data.id).find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current
  
  initPage: (callback)->
    self = @
    self.render()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.element = $('#register-user-name')
    self.initKey()

  onReturnPage: ()->
    self = fimplus._registerUserName
    element = $('.register-keyboard')
    input = $('#register-username')
    fimplus._keyboard.render(element, input, self.onActiveEntity, 'number')
    self.initKey()
  
  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({register: self.data}))
    @renderKeyboard()
    fimplus._keyboard.setActiveKeyboard(0, 0)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    $(self.data.id).find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick
  
  renderKeyboard: ()->
    self = @
    self.data.positionEntity.active = false
    element = $('.register-keyboard')
    input = $('#register-username')
    fimplus._keyboard.render(element, input, self.onActiveEntity, 'number')

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._registerUserName
    switch keyCode
      when key.DOWN
        fimplus._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  onActiveEntity: (type = 'DOWN')->
    self = fimplus._registerUserName
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        fimplus._backButton.setActive(true, self.hanldeBackbutton)
        fimplus._keyboard.setActiveKeyboard(0, 0, false)

  
  checkUsername: ()->
    self = @
    retry = ()->
      self.element.find('#register-username').val('')
      self.initKey()
    unless self.username
      fimplus._error.initPage({
        title      : "register-fail"
        onReturn   : retry
        description: "setting-input-phone-for-request"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return false
    patt = new RegExp("^0");
    res = patt.test(self.username);
    if !res
      fimplus._error.initPage({
        title      : "register-fail"
        onReturn   : retry
        description: "phone-format-fail"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return false
    patt = new RegExp("^[0-9]+$");
    res = patt.test(self.username);
    if !res
      fimplus._error.initPage({
        title      : "register-fail"
        onReturn   : retry
        description: "phone-format-fail"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return false
    if self.username.length < 10 or self.username.length > 11
      fimplus._error.initPage({
        title      : "register-fail"
        onReturn   : retry
        description: "phone-format-fail"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return false
    return true
  
  handleKey: (keyCode, key)->
    self = fimplus._registerUserName
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
      when key.UP
        self.data.positionEntity.active = false
        $(self.data.id).find('.bt-movie').find('li').removeClass('active')
        fimplus._keyboard.onBackBoardButton()
        break;
      when key.LEFT
        self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.buttons.length)
        break;
      when key.RIGHT
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.buttons.length)
        break;
  
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)
  
  removePage: ()->
    self = fimplus._registerUserName
    self.data.callback()
    self.element.html('')
