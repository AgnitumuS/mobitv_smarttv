fimplus._settingTitleLang =
  data:
    id: '#setting-title-lang'
    template  : Templates['module.setting.setting-title-lang']()
    currentActive: 0
    onFocus: true
    activeTitleLanguage: 'vi'
    buttons: [
      vietnamese =
        title: 'account-language-vi'
        type: 'vi'
        action: ()->
          console.log 'Chuyển sang tiếng Việt'
          fimplus._settingTitleLang.data.activeTitleLanguage = 'vi'
          fimplus._settingTitleLang.render()
          fimplus.UserService.upDateLocalStorage('userSettings','movieTitleLanguage','vi')
      english =
        title: 'account-language-en'
        type: 'en'
        action: ()->
          console.log 'Chuyển sang tiếng Anh'
          fimplus._settingTitleLang.data.activeTitleLanguage = 'en'
          fimplus._settingTitleLang.render()
          fimplus.UserService.upDateLocalStorage('userSettings','movieTitleLanguage','en')
    ]
  
  initPage: ()->
    self = @
    # check Storage
    if localStorage.userSettings isnt null and localStorage.userSettings isnt undefined
        self.data.activeTitleLanguage = JSON.parse(localStorage.userSettings).language
        switch self.data.activeTitleLanguage
          when 'vi'
            self.data.currentActive = 0
            break;
          when 'en'
            self.data.currentActive = 1
            break;
    self.render()
    self.initKey()
  

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({
      onFocus: self.data.onFocus, 
      currentActive: self.data.currentActive, 
      buttons: self.data.buttons, 
      activeTitleLanguage: self.data.activeTitleLanguage
    }))

  toggleActiveMenu: (toggle)->
    listElement = '.btn-title-lang'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = fimplus._settingTitleLang
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        # check to focus Active Key handle
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()
        fimplus._setting.initKey()
  
  handleKey: (keyCode, key)->
    self = fimplus._settingTitleLang
    console.info 'Setting Title Lang:' + keyCode
    listElement = '.btn-title-lang'
    length = $('.btn-title-lang').find('li').length
    # load detail notify in right panel
    actionKey = ()->
      self.data.currentActive = fimplus.KeyService.reCalc(self.data.currentActive, length)
      fimplus.UtitService.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        fimplus.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        break;
      when key.RETURN
        console.log 'Call back to setting menu'
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
    $(self.data.id).find('#setting-title-lang').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  