fimplus._registerPassword=
  data:
    id           : '#register-password'
    title        : 'password'
    description  : 'enter-password'
    template     : Templates['module.login.register-password']()
    currentActive: 0
    buttons     : [
      cancelBtn =
        title : 'button-cancel'
        action: ()->
          $('#register-otp, #register-password').html('')
          fimplus._registerUserName.removePage()
    ,
      continueBtn =
        title : 'button-continue'
        action: ()->
          fimplus._registerPassword.registerFinish()
      ]
    positionEntity:
      active : false


  registerFinish: ()->
    self = @
    self.password = $("#register-password-input").val()
    retry = ()->
      fimplus._login.removePage()
    finish = ()->
      $('#login, #register-user-name, #register-otp, #register-password').hide()
      fimplus._login.element.html('')
      fimplus._payment.initPage('buyPackage', self.onReturnHomepage)
      
    unless self.password
      fimplus._error.initPage({
        title      : "register-fail"
        onReturn   : retry
        description: "setting-input-password-for-request"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return
    if self.password.length < 6
      fimplus._error.initPage({
        title      : "register-fail"
        onReturn   : retry
        description: "login-phone-register-password-hint2"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return
    $('.wrap-loading').show()
    params =
      token : fimplus._registerOtp.data.token
      password : self.password
    fimplus.ApiService.registerPhone params, (error, result)->
      $('.wrap-loading').hide()
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
      try
        getTicket(result)
      catch
        fimplus._error.initPage({
          title      : "register-fail"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });

    getTicket = (result)->
      data = fimplus.UtitService.formatTicket result.tickets
      fimplus.ApiService.loginServices data, (error, result)->
        if result.status is 400
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
        fimplus.UserService.saveToken(result)
        fimplus.ApiService.getUserProfile (error, user)->
          unless error
            fimplus.UserService.saveProfile(user)
            self.removePage()
            fimplus._error.initPage({
              title      : "register-success"
              onReturn   : finish
              timeOut    :
                callback  : finish
                time      : 3
              description: ['greeting', user.localAcc.mobile]
              descriptionUnder: 'have-fun'
              buttons    : []
            });
            return
          fimplus._error.initPage({
            title      : "register-fail"
            onReturn   : retry
            description: user.responseJSON.message
            buttons    : [
              title   : 'button-try-again'
              callback: retry
            ]
          });

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  initPage: (callback)->
    self = @
    self.render()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.initKey()

  onReturnPage: ()->
    self = fimplus._registerPassword
    self.initKey()
  
  onReturnHomepage: ()->
    self = fimplus._page
    self.reRender()
    self.initKey()
  
  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({register: self.data}))
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
    element = $('.register-password-keyboard')
    input = $('#register-password-input')
    fimplus._keyboard.render(element, input, self.onActiveEntity, 'text')

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._registerPassword
    switch keyCode
      when key.DOWN
        fimplus._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  onActiveEntity: (type = 'DOWN')->
    self = fimplus._registerPassword
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
      self.element.find('#register-password-input').val('')
      self.initKey()
    unless self.username
      fimplus._error.initPage({
        title      : "register-fail"
        onReturn   : retry
        description: "button-try-again"
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
    self = fimplus._registerPassword
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
        self.element.find('.bt-movie').find('li').removeClass('active')
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
    self = fimplus._registerPassword
    self.data.callback()
    self.element.html('')
    