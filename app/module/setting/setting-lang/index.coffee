fimplus._settingLang =
  data:
    id: '#setting-lang'
    template  : Templates['module.setting.setting-lang']()
    currentActive: 0
    onFocus: true
    activeLanguage: 'vi'
    buttons: [
      vietnamese =
        title: 'account-language-vi'
        type: 'vi'
        action: ()->
          fimplus._settingLang.data.activeLanguage = 'vi'
          fimplus._settingLang.render()
          fimplus.UserService.upDateLocalStorage('userSettings','language','vi')
      english =
        title: 'account-language-en'
        type: 'en'
        action: ()->
          fimplus._settingLang.data.activeLanguage = 'en'
          fimplus._settingLang.render()
          fimplus.UserService.upDateLocalStorage('userSettings','language','en')
    ]
  
  initPage: ()->
    self = @
    # check Storage
    if localStorage.userSettings isnt null and localStorage.userSettings isnt undefined
        self.data.activeLanguage = JSON.parse(localStorage.userSettings).language
        switch self.data.activeLanguage
          when 'vi'
            self.data.currentActive = 0
            break;
          when 'en'
            self.data.currentActive = 1
            break;
    self.render()
    self.initKey()

  toggleActiveMenu: (toggle)->
    listElement = '#setting-lang .setting-menu'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = fimplus._settingLang
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        # check to focus Active Key handle
        self.initKey()
      when key.RETURN,key.ENTER
        self.data.haveSource = false
        self.removePage()
        fimplus._setting.initKey()

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({onFocus: self.data.onFocus, currentActive: self.data.currentActive, buttons: self.data.buttons, activeLanguage: self.data.activeLanguage}))

  
  handleKey: (keyCode, key)->
    self = fimplus._settingLang
    console.info 'Setting Lang:' + keyCode
    listElement = '.btn-lang'
    length = $('.btn-lang').find('li').length
    # load detail notify in right panel
    actionKey = ()->
      self.data.currentActive = fimplus.KeyService.reCalc(self.data.currentActive, length)
      fimplus.UtitService.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        fimplus.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        self.render()
        break;
      when key.RETURN
        self.data.haveSource = false
        self.removePage()
        fimplus._setting.initPage()
        break;
      when key.UP
        self.data.currentActive--
        if self.data.currentActive < 0
          fimplus._backButton.setActive(true, self.handleBackbutton)
          self.toggleActiveMenu(false)
        else
          actionKey()
        break;
      when key.DOWN
        self.data.currentActive++
        actionKey()
        break;
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)

  
  removePage: ()->
    self = @
    $(self.data.id).find('.setting-lang').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  