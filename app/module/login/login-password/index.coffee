pateco._loginPassword =
  data:
    id           : '#login-password'
    title        : 'password'
    description  : 'enter-password'
    template     : Templates['module.login.login-password']()
    currentActive: 0
    buttons     : [
      cancelBtn =
        title : 'button-back'
        action: ()->
          pateco._loginPassword.removePage()
    ,
      continueBtn =
        title : 'button-confirm'
        action: ()->
          pateco._loginPassword.loginFinish()
      ]
    positionEntity:
      active : false


  loginFinish: ()->
    self = @
    self.data.password = $("#password").val()
    retry = ()->
      self.element.find('#password').val('')
      self.initKey()
    finish = ()->
      $('#login, #login-user-name, #login-password').hide()
      pateco._login.removePage()
    unless self.data.password
      pateco._error.initPage({
        title      : "login-phone-failed-login"
        onReturn   : retry
        description: "setting-input-password-for-request"
        buttons    : [
          title   : 'button-try-again'
          callback: retry
        ]
      });
      return
    $('.wrap-loading').show()
    params =
      mobile  : self.data.username
      password: self.data.password
      platform: pateco.config.platform
      services : ["hd1_cas", "hd1_cm", "hd1_payment", "hd1_billing"]

    doneLoginCas = (error, result)->
      if result.status
        $('.wrap-loading').hide()
        pateco._error.initPage({
          title      : "login-phone-failed-login"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      getTicket(result)
      return
    pateco.ApiService.loginWithPassword(params, doneLoginCas)

    getTicket = (result)->
      data = pateco.UtitService.formatTicket result.tickets
      pateco.ApiService.loginServices data, (error, result)->
        $('.wrap-loading').hide()
        if error
          console.log error
          return
        pateco.UserService.saveToken(result)
        pateco.ApiService.getUserProfile (error, user)->
          unless error
            pateco.UserService.saveProfile(user)
            if user.fullName
              userName = user.fullName
            else if user.email
              userName = user.email
            else
              userName = user.localAcc.mobile
            self.removePage()
            pateco._error.initPage({
              title      : "login-phone-success"
              onReturn   : finish
              timeOut    :
                callback  : finish
                time      : 3
              description: ['greeting', userName]
              descriptionUnder: 'have-fun'
              buttons    : []
            });
            return

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  initPage: (item, callback)->
    self = @
    self.data.username = item
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.render()
    self.initKey()

  onReturnPage: ()->
    self = pateco._loginPassword
    self.initKey()

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({login: self.data}))
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
    element = $('.login-pass-keyboard')
    input = $('#password')
    pateco._keyboard.render(element, input, self.onActiveEntity, 'text')

  onActiveEntity: (type = 'DOWN')->
    self = pateco._loginPassword
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        pateco._backButton.setActive(true, self.hanldeBackbutton)
        pateco._keyboard.setActiveKeyboard(0, 0, false)

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._loginPassword
    switch keyCode
      when key.DOWN
        pateco._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()
  
  handleKey: (keyCode, key)->
    self = pateco._loginPassword
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
        self.element.find('.bt-movie').find('li').removeClass('active')
        pateco._keyboard.onBackBoardButton()
        break
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
    self = pateco._loginPassword
    self.data.callback()
    self.element.html('')