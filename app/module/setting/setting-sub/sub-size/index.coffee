pateco._settingSubSize =
  data:
    id: '#sub-color'
    template  : Templates['module.setting.setting-sub.sub-size']()
    currentActive: 0
    onFocus: true
    subtitleColor: 'white'
    subtitleSize: 'font-type-2'
    subtitleOpacity: '0.75'
    buttons: [
      small =
        title: 'account-subtitle-size-font-type-1'
        value: 'font-type-1'
        action: ()->
          pateco._settingSubSize.updateValueSize('font-type-1')
      normal =
        title: 'account-subtitle-size-font-type-2'
        value: 'font-type-2'
        action: ()->
          pateco._settingSubSize.updateValueSize('font-type-2')
      big =
        title: 'account-subtitle-size-font-type-3'
        value: 'font-type-3'
        action: ()->
          pateco._settingSubSize.updateValueSize('font-type-3')
      huge =
        title: 'account-subtitle-size-font-type-4'
        value: 'font-type-4'
        action: ()->
          pateco._settingSubSize.updateValueSize('font-type-4')
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
    listElement = '.btn-sub-size'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = pateco._settingSubSize
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
    self = pateco._settingSubSize
    console.info 'Setting Sub Size:' + keyCode
    listElement = '.btn-sub-size'
    length = $('.btn-sub-size').find('li').length
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
    $(self.data.id).find('.sub-size').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  
  # update color when press enter key
  updateValueSize: (size)->
    self = @
    self.data.subtitleSize = size
    pateco.UserService.upDateLocalStorage('userSettings','subtitleSize', size)
    pateco._settingSubSize.initPage()