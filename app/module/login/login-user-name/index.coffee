pateco._loginUserName =
  data:
    id            : '#login-user-name'
    title         : 'login-title'
    currentActive : 0
    description   : 'login-phone-input'
    template      : Templates['module.login.login-user-name']()
    buttons       : [
      cancelBtn =
        title : 'button-back'
        action: ()->
          pateco._loginUserName.removePage()
    ,
      continueBtn =
        title : 'button-continue'
        action: ()->
          pateco._loginUserName.loginContinue()
    ]
    positionEntity:
      active: false
  
  
  loginContinue: ()->
    self = @
    self.data.username = $("#username").val()
    if self.checkUsername() is true
      pateco._loginPassword.initPage(self.data.username, self.onReturnPage)
  
  setActiveButton: (current = 0, length = 0)->
    self = @
    button = $(self.data.id).find('.bt-movie').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current
  
  handleBackbutton: (keyCode, key) ->
    self = pateco._loginUserName
    switch keyCode
      when key.DOWN
        pateco._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()
  
  
  initPage: (callback)->
    self = @
    self.render()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.element = $('#login-user-name')
    self.initKey()
  
  onReturnPage: ()->
    self = pateco._loginUserName
    element = $('.login-keyboard')
    input = $('#username')
    pateco._keyboard.render(element, input, self.onActiveEntity, 'text')
    self.initKey()
  
  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({login: self.data}))
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
    element = $('.login-keyboard')
    input = $('#username')
    pateco._keyboard.render(element, input, self.onActiveEntity, 'text')
  
  onActiveEntity: (type = 'DOWN')->
    self = pateco._loginUserName
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        pateco._backButton.setActive(true, self.handleBackbutton)
        pateco._keyboard.setActiveKeyboard(0, 0, false)
  
  checkUsername: ()->
    self = @
    retry = ()->
      self.element.find('#username').val('')
      self.initKey()
    checkPhone = ()->
      phone = self.data.username
      resPhone = /^0/.test(phone)
      if phone and resPhone is false
        pateco._error.initPage({
          title      : "login-phone-failed-login"
          onReturn   : retry
          description: "phone-format-fail"
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return false
      if phone and phone.length < 10 or phone.length > 12
        pateco._error.initPage({
          title      : "login-phone-failed-login"
          onReturn   : retry
          description: "phone-format-fail"
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return false
      return true
    
    checkEmail = ()->
      email = self.data.username
      resEmail = /^[a-zA-Z0-9]+(\.[_a-zA-Z0-9]+)*@[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)*(\.[a-zA-Z]{2,15})$/.test(email)
      if email and resEmail is false
        pateco._error.initPage({
          title      : "login-phone-failed-login"
          onReturn   : retry
          description: "email-format-fail"
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        })
        return false
      return true
    
    unless self.data.username
      pateco._error.initPage({
        title      : "login-phone-failed-login"
        onReturn   : retry
        description: "setting-input-phone-email-for-request"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return false
    res = /^[0-9]+$/.test(self.data.username)
    if res
      console.info 'is Phone'
      if checkPhone() is false
        return false
      return true
    console.info 'is Email'
    if checkEmail() is false
      return false
    return true
  
  
  
  handleKey: (keyCode, key)->
    self = pateco._loginUserName
    console.info 'Login Key:' + keyCode
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
    self = pateco._loginUserName
    pateco.KeyService.initKey(self.handleKey)
  
  removePage: ()->
    self = pateco._loginUserName
    self.data.callback()
    self.element.html('')

    