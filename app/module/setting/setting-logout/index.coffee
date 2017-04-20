pateco._settingLogout =
  data:
    id: '#setting-logout'
    template  : Templates['module.setting.setting-logout']()
    currentActive: 0
    onFocus: true
    callback: ()->
    buttons: [
      cancle =
        title: 'button-cancel'
        action: ()->
          console.log 'Hủy logout'
          pateco._settingLogout.exitApp()
      logout =
        title: 'account-logout'
        action: ()->
          console.log 'Logout'
          pateco._settingLogout.logoutLocal()
    ]
  
  initPage: (callback)->
    self = @
    self.data.callback = ()->
      console.log 'callback from logout'
    self.data.callback = callback if _.isFunction(callback)
    self.render()
    self.initKey()

  toggleActiveMenu: (toggle)->
    listElement = '#btn-logout'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = pateco._settingLogout
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        # check to focus Active Key handle
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()
        pateco._setting.initKey()

  exitApp: ()->
    pateco._settingLogout.removePage()
    pateco._setting.initKey()

  # open screen success and go home
  finish: ()->
    pateco._setting.removePage()
    pateco._settingLogout.removePage()
    pateco._page.initPage()
    pateco._setting.data.currentActive = 0
  
  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({
      onFocus: self.data.onFocus, 
      currentActive: self.data.currentActive, 
      buttons: self.data.buttons
      }))
  

  handleKey: (keyCode, key)->
    self = pateco._settingLogout
    element = $(self.data.id)
    console.info 'Setting Logout:' + keyCode
    listElement = '#btn-logout'
    # load detail notify in right panel
    length = $(listElement).find("li").length
    actionKey = ()->
      self.data.currentActive = pateco.KeyService.reCalc(self.data.currentActive, length)
      pateco.UtitService.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        pateco.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        break;
      when key.RETURN
        console.log 'Call back to setting menu'
        self.removePage()
        # pateco._setting.initKey()
        break;
      when key.LEFT
        # focus on input Code
        # $("#codeInput").focus()
        self.data.currentActive--
        if self.data.currentActive < 0
          pateco._backButton.setActive(true, self.handleBackbutton)
          self.toggleActiveMenu(false)
        else
          actionKey()
        break;
      when key.RIGHT
        self.data.currentActive++
        actionKey()
        break;
      when key.UP
        if self.data.currentActive < 0
          pateco._backButton.setActive(true, self.handleBackbutton)
          self.toggleActiveMenu(false)
        else
          actionKey()
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)
    
  removePage: ()->
    self = @
    self.data.callback() if _.isFunction(self.data.callback)
    $('.error-wrapper').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 800)

  logoutLocal: ()->
    self = @
    # go to account page
    updateLogoutDone = (error, result) ->
      self = @
      if error
        # open screen fail and back previous screen
        pateco._error.initPage({
            description: 'Đăng xuất thất bại, vui lòng thử lại.'
            title      : 'Đăng xuất lỗi'
            buttons    : [
              title   : 'Thử lại'
              # callback: pateco._settingLogout.logoutLocal()
            ,
              title   : 'Hủy'
              # callback: pateco._setting.initPage()
            ]
        })
        return
      # successful
      # remove storage
      localStorage.setItem('user_info', 'null')
      localStorage.setItem('hd1_billing', 'null')
      localStorage.setItem('hd1_payment', 'null')
      localStorage.setItem('hd1_cas', 'null')
      localStorage.setItem('hd1_cm', 'null')
      localStorage.setItem('package', 'null')
      localStorage.setItem('packageInfo', 'null')
      localStorage.setItem('sourceId', 'null')

      pateco._error.initPage({
        description: 'logout-success'
        onReturn : pateco._settingLogout.finish
        title      : 'account-logout'
        buttons    : [
          title   : 'payment-button-back'
          callback: pateco._settingLogout.finish
        ]
      })
    pateco.ApiService.updateLogout(pateco.config.appInfo.deviceId, updateLogoutDone)
  
      
  