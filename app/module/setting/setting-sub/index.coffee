pateco._settingSub =
  data:
    id: '#setting-sub'
    template  : Templates['module.setting.setting-sub']()
    currentActive: 0
    onFocus: true
    subtitleColor: 'white'
    subtitleSize: 'font-type-2'
    subtitleOpacity: '0.75'
    buttons: [
      textColor =
        title: 'account-subtitle-color'
        valueRight: 'color'
        action: ()->
          pateco._settingSubColor.initPage()
          return
      textSize =
        title: 'account-subtitle-size'
        valueRight: 'size'
        action: ()->
          console.log 'textSize'
          pateco._settingSubSize.initPage()
          return
      textOpacity =
        title: 'account-subtitle-opacity'
        valueRight: 'opacity'
        action: ()->
          console.log 'textOpacity'
          pateco._settingSubOpacity.initPage()
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
    listElement = '.btn-sub'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = pateco._settingSub
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        # check to focus Active Key handle
        self.initKey()
      when key.RETURN,key.ENTER
        self.data.currentActive = 0
        self.removePage()
        pateco._setting.initKey()

  
  handleKey: (keyCode, key)->
    self = pateco._settingSub
    console.info 'Setting Sub:' + keyCode
    listElement = '.btn-sub'
    length = $('.btn-sub').find('li').length
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
        pateco._setting.initPage()
        break;
      when key.UP
        self.data.currentActive--
        if self.data.currentActive < 0
          pateco._backButton.setActive(true, self.handleBackbutton)
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
    pateco.KeyService.initKey(self.handleKey)
  
  removePage: ()->
    self = @
    $(self.data.id).find('.setting-sub').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  