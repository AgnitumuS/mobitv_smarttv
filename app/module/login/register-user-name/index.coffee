pateco._registerUserName =
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
          pateco._registerUserName.removePage()
    ,
      continueBtn =
        title : 'button-continue'
        action: ()->
          pateco._registerUserName.registerContinue()
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
        platform: pateco.config.platform
      pateco.ApiService.registerGetCode params, (error, result)->
        if result.status
          pateco._error.initPage({
            title      : "register-fail"
            onReturn   : retry
            description: result.responseJSON.message
            buttons    : [
              title   : 'button-try-again'
              callback: retry
            ]
          });
          return
        pateco._registerOtp.initPage(self.onReturnPage)
  
  setActiveButton: (current = 0, length = 0)->
    self = @
    button = $(self.data.id).find('.bt-movie').find('li')
    current = pateco.KeyService.reCalc(current, length)
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
    self = pateco._registerUserName
    element = $('.register-keyboard')
    input = $('#register-username')
    pateco._keyboard.render(element, input, self.onActiveEntity, 'number')
    self.initKey()
  
  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({register: self.data}))
    @renderKeyboard()
    pateco._keyboard.setActiveKeyboard(0, 0)
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
    pateco._keyboard.render(element, input, self.onActiveEntity, 'number')

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._registerUserName
    switch keyCode
      when key.DOWN
        pateco._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  onActiveEntity: (type = 'DOWN')->
    self = pateco._registerUserName
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        pateco._backButton.setActive(true, self.hanldeBackbutton)
        pateco._keyboard.setActiveKeyboard(0, 0, false)

  
  checkUsername: ()->
    self = @
    retry = ()->
      self.element.find('#register-username').val('')
      self.initKey()
    unless self.username
      pateco._error.initPage({
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
      pateco._error.initPage({
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
      pateco._error.initPage({
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
      pateco._error.initPage({
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
    self = pateco._registerUserName
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
      when key.UP
        self.data.positionEntity.active = false
        $(self.data.id).find('.bt-movie').find('li').removeClass('active')
        pateco._keyboard.onBackBoardButton()
        break;
      when key.LEFT
        self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.buttons.length)
        break;
      when key.RIGHT
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.buttons.length)
        break;
  
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)
  
  removePage: ()->
    self = pateco._registerUserName
    self.data.callback()
    self.element.html('')
