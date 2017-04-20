pateco._registerOtp =
  data:
    id           : '#register-otp'
    title        : 'login-phone-otp'
    description  : 'login-phone-input-otp'
    template     : Templates['module.login.register-otp']()
    currentActive: 0
    lengthDefault: 0
    getOtp       : false
    buttons     : [
      backBtn =
        title : 'button-back'
        action: ()->
          pateco._registerOtp.backOtp()
      ,
      continueBtn =
        title : 'button-continue'
        action: ()->
          pateco._registerOtp.registerContinue()
      ]
    positionEntity:
      active : false


  backOtp: ()->
    self = @
    self.removePage()


  registerContinue: ()->
    self = @
    self.otp = $("#otp").val()
    retry = ()->
      self.element.find('#otp, #otp1, #otp2, #otp3, #otp4').val('')
      self.initKey()
    params =
      mobile : pateco._registerUserName.username
      code : self.otp
      platform : pateco.config.platform
    pateco.ApiService.registerCheckCode params, (error, result)->
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
      self.data.token = result.token
      pateco._registerPassword.initPage(self.onReturnPage)

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  setOtpActive : (boolean)->
    self = @
    button = self.element.find('.otp-code')
    if boolean
      button.addClass('active')
    else
      button.removeClass('active')

  initPage: (callback)->
    self = @
    self.render()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.initEventOtpOnchange()
    self.initKey()

  onReturnPage: ()->
    self = pateco._registerOtp
    element = $('.register-otp-keyboard')
    input = $('#otp')
    pateco._keyboard.render(element, input, self.onActiveEntity, 'number')
    self.initKey()

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({register: self.data}))
    @renderKeyboard()
    pateco._keyboard.setActiveKeyboard(0, 0)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick

  getOtp: ()->
    self = @
    retry = ()->
      self.element.find('#otp, #otp1, #otp2, #otp3, #otp4').val('')
      self.initKey()
    pateco._error.initPage({
      title      : "login-phone-otp"
      onReturn   : retry
      description: 'get-otp-again-message'
      buttons    : [
        title   : 'button-try-again'
        callback: retry
      ]
    });
    params =
      mobile  : pateco._registerUserName.username
      platform: pateco.config.platform
    pateco.ApiService.registerGetCode params, (error, result)->
      console.log 'get otp again'

  renderKeyboard: ()->
    self = @
    self.data.positionEntity.active = false
    element = $('.register-otp-keyboard')
    input = $('#otp')
    pateco._keyboard.render(element, input, self.onActiveEntity, 'number')

  initEventOtpOnchange: ()->
    self = @
    otp = $("#{self.data.id} #otp")
    onKeyOtpChange = ()->
      length = otp.val().length
      if length > 4
        otp.val(otp.val().substring(0,4))
      else if length > self.data.lengthDefault
        value = otp.val().substring(self.data.lengthDefault, length)
        self.data.lengthDefault = length
        $("#{self.data.id} #otp#{self.data.lengthDefault}").val(value)
      else if length is 0
        $("#{self.data.id} #otp1").val('')
        $("#{self.data.id} #otp2").val('')
        $("#{self.data.id} #otp3").val('')
        $("#{self.data.id} #otp4").val('')
        self.data.lengthDefault = length
      else
        $("#{self.data.id} #otp#{length+1}").val('')
        self.data.lengthDefault = length
    otp.off 'change'
    otp.on 'change', onKeyOtpChange

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._registerOtp
    switch keyCode
      when key.DOWN
        pateco._keyboard.onBackKeyboard()
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  onActiveEntity: (type = 'DOWN')->
    self = pateco._registerOtp
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
      when 'UP'
        pateco._backButton.setActive(true, self.hanldeBackbutton)
        pateco._keyboard.setActiveKeyboard(0, 0, false)

  handleKey: (keyCode, key)->
    self = pateco._registerOtp
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
        if self.data.getOtp
          self.getOtp()
        else
          self.data.buttons[self.data.currentActive].action()
        break;
      when key.DOWN
        self.setActiveButton(-1, 0)
        self.data.getOtp = true
        self.setOtpActive(self.data.getOtp)
        break;
      when key.UP
        if self.data.getOtp
          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.getOtp = false
          self.setOtpActive(self.data.getOtp)
        else
          self.data.positionEntity.active = false
          self.element.find('.bt-movie').find('li').removeClass('active')
          pateco._keyboard.onBackBoardButton()
        break;
      when key.LEFT
        if self.data.getOtp is false
          self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.buttons.length)
        break;
      when key.RIGHT
        if self.data.getOtp is false
          self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.buttons.length)
        break;
  
  initKey: ()->
    self = @
    self.data.lengthDefault = 0
    pateco.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = pateco._registerOtp
    self.data.callback()
    self.element.html('')
    