fimplus._login =
  data:
    id           : '#login'
    template     : Templates['module.login']()
    currentActive: 0
    title        : 'title-register-login'
    description  : 'title-register-login-description'
    callback     : ()->
    buttons      : [
      loginBtn =
        title : 'button-welcome-login'
        action: ()->
          self = fimplus._login
          fimplus._loginUserName.initPage(self.onReturnPage)
    ,
      registerBtn =
        title : 'button-welcome-register'
        action: ()->
          self = fimplus._login
          fimplus._registerUserName.initPage(self.onReturnPage)
    ]
  
  setActiveButton: (current = 0, length = 0)->
    self = @
    button = $(self.data.id).find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current
  
  initPage: (callback)->
    self = @
    self.data.previousPage = 'detail'
    self.render()
    self.initKey()
    self.data.callback = ()->
    self.data.callback = callback if _.isFunction(callback)
    self.setActiveButton(self.data.currentActive, self.data.buttons.length)
    fimplus._backButton.enable()

# list butttons with login screen
  onReturnPage: ()->
    self = fimplus._login
    self.initKey()
  
  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $('#login')
    self.element.html(template({login: self.data}))
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.bt-movie li')
      .off 'click'
      .on 'click', buttonClick
  
  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._login
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.buttons.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()
  
  handleKey: (keyCode, key)->
    self = fimplus._login
    console.info 'Login Key:' + keyCode
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.data.buttons[self.data.currentActive].action()
        break;
      when key.LEFT
        self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.buttons.length)
        break;
      when key.RIGHT
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.buttons.length)
        break;
      when key.UP
        fimplus._backButton.setActive(true, self.hanldeBackbutton)
        self.setActiveButton(0, 0)
  
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)
  
  removePage: ()->
    doneGetWacthLater = ()->
      try
        if fimplus.UserService.data.watchLater.items.length is 0
          fimplus._page.initPage()
          return
        fimplus._page.loadDataRibonOfUser({}, ()->
          fimplus._login.data.callback() if _.isFunction(fimplus._login.data.callback)
          fimplus._login.element.html('')
        )
      catch
    fimplus.UserService.getWatchLater(doneGetWacthLater)
    

    

    