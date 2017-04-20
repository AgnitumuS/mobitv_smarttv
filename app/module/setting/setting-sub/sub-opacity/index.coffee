pateco._settingSubOpacity =
  data:
    id: '#sub-opacity'
    template  : Templates['module.setting.setting-sub.sub-opacity']()
    currentActive: 0
    onFocus: true
    subtitleColor: 'white'
    subtitleSize: 'font-type-2'
    subtitleOpacity: '0.0'
    buttons: [
      _0 =
        title: '0%'
        value: '0.0'
        action: ()->
          pateco._settingSubOpacity.updateValueOpacity('0.0')
      _25 =
        title: '25%'
        value: '0.25'
        action: ()->
          pateco._settingSubOpacity.updateValueOpacity('0.25')
      _50 =
        title: '50%'
        value: '0.5'
        action: ()->
          pateco._settingSubOpacity.updateValueOpacity('0.5')
      _75 =
        title: '75%'
        value: '0.75'
        action: ()->
          pateco._settingSubOpacity.updateValueOpacity('0.75')
      _100 =
        title: '100%'
        value: '100'
        action: ()->
          pateco._settingSubOpacity.updateValueOpacity('100')
    ]
  
  initPage: ()->
    self = @
    # check Storage
    if localStorage.userSettings isnt null and localStorage.userSettings isnt undefined
        self.data.subtitleColor = JSON.parse(localStorage.userSettings).subtitleColor
        self.data.subtitleSize = JSON.parse(localStorage.userSettings).subtitleSize
        self.data.subtitleOpacity = JSON.parse(localStorage.userSettings).subtitleOpacity    
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
      subtitleColor: self.data.subtitleColor
      subtitleSize: self.data.subtitleSize
      subtitleOpacity: self.data.subtitleOpacity
    }))

  toggleActiveMenu: (toggle)->
    listElement = '.btn-sub-opacity'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = pateco._settingSubOpacity
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        # check to focus Active Key handle
        self.initKey()
      when key.RETURN,key.ENTER
        self.data.haveSource = false
        self.data.currentActive = 0
        self.removePage()
        pateco._settingSub.initPage()
  
  handleKey: (keyCode, key)->
    self = pateco._settingSubOpacity
    console.info 'Setting Sub Opacity:' + keyCode
    listElement = '.btn-sub-opacity'
    length = $('.btn-sub-opacity').find('li').length
    # load detail notify in right panel
    actionKey = ()->
      self.data.currentActive = pateco.KeyService.reCalc(self.data.currentActive, length)
      pateco.UtitService.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        pateco.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        break;
      when key.RETURN
        console.log 'Call back to setting menu'
        self.data.haveSource = false
        self.removePage()
        pateco._settingSub.initPage()
        break;
      when key.UP
        self.data.currentActive--
        actionKey()
        break;
      when key.DOWN
        self.data.currentActive++
        if self.data.currentActive < 0
          pateco._backButton.setActive(true, self.handleBackbutton)
          self.toggleActiveMenu(false)
        else
          actionKey()
        break;
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)
  
  removePage: ()->
    self = @
    $(self.data.id).find('.sub-opacity').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  
  # update color when press enter key
  updateValueOpacity: (opacity)->
    self = @
    self.data.subtitleOpacity = opacity
    pateco.UserService.upDateLocalStorage('userSettings','subtitleOpacity', opacity)
    pateco._settingSubOpacity.initPage()