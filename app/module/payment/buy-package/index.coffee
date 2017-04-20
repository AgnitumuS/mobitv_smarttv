fimplus._buyPackage =
  data:
    id           : '#buy-package'
    title        : 'button-welcome-register'
    description  : 'requice-package'
    descriptionUnder: ''
    updatePre    : false
    template     : Templates['module.payment.buy-package']()
    currentActive: 0
    buttons     : [
      cancelBtn =
        title : 'button-cancel'
        action: ()->
          fimplus._payment.removePage()
      registerBtn =
        title: 'button-welcome-register'
        action: ()->
          $(fimplus._buyPackage.data.id).find('.overlayBuyPackage').show()
          fimplus._listPackage.initPage(fimplus._buyPackage.onReturnPage)
      ]


  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  getCurrentPackage: ()->
    self = @
    if localStorage.user_info
      done = (error, result)->
        if result.id
          self.data.updatePre = true
          self.data.title = 'update-pre-title'
          self.data.description = 'update-pre'
          self.data.descriptionUnder = 'confirm-update-pre'
          self.data.buttons[1].title = 'update-pre-btn'
        else
          self.data.updatePre = false
          self.data.title = 'button-welcome-register'
          self.data.description = 'requice-package'
          self.data.descriptionUnder = ''
          self.data.buttons[1].title = 'button-welcome-register'
        self.render()
        self.initKey()
        self.setActiveButton(self.data.currentActive, self.data.buttons.length)
      fimplus.ApiService.updateProfileLeft(done)

  initPage: (callback)->
    self = @
    self.getCurrentPackage()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = fimplus._buyPackage
    self.initKey()
  
  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({payment: self.data}))
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._buyPackage
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.buttons.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = fimplus._buyPackage
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
    self.element.find('.overlayBuyPackage').hide()
    fimplus.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = fimplus._buyPackage
    self.data.callback()
    self.element.html('')

    