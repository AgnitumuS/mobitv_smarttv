Handlebars.registerPartial('userInfo', Templates['module.setting.user-info']());
pateco._setting =
  data:
    id: '#setting'
    template  : Templates['module.setting']()
    currentActive: 0
    onFocus: true
    user_profile: null
    subtitleState: true
    packageInfo: null
    userPackage: false
    userDetail: false
    callback: ()->
    buttons: 
      paymentMethod:
        title: 'account-payment-method'
        valueRight: 'off'
        action: ()->
          pateco._settingMethod.initPage(pateco._setting.callbackFunc)
      notice:
        title: 'notification'
        valueRight: 'off'
        action: ()->
          pateco._settingNotification.initPage()
      coupon:
        title: 'code-discount'
        valueRight: 'off'
        action: ()->
          pateco._settingCode.initPage()
      language:
        title: 'account-language-title'
        valueRight: 'lang'
        action: ()->
          pateco._settingLang.initPage()
      fimname:
        title: 'account-movie-name'
        valueRight: 'titlelang'
        action: ()->
          pateco._settingTitleLang.initPage()
      subtitle:
        title: 'account-subtitle-title'
        valueRight: 'sub'
        action: ()->
          pateco._setting.toggleSubtitle()
      subtitleSetting:
        title: 'account-custom-subtitle'
        valueRight: 'off'
        action: ()->
          pateco._settingSub.initPage()
      logout:
        title: 'account-logout'
        valueRight: 'logout'
        action: ()->
          pateco._settingLogout.initPage(pateco._setting.callbackFunc)
  
  initPage: (callback)->
    self = pateco._setting
    pateco._backButton.enable()
    if pateco.UserService.isLogin()
      self.data.callback = callback if _.isFunction(callback)
      self.getData()
      self.getDataPackage()
      self.render()
      self.initKey() 
    else
      pateco._login.initPage(pateco._setting.callbackFuncLogin)
  
  render: ()->
    self = @
    # check exist data config in localStorage and load it when render
    if localStorage.userSettings isnt null and localStorage.userSettings isnt undefined
      self.data.language = JSON.parse(localStorage.userSettings).language
      self.data.movieTitleLanguage = JSON.parse(localStorage.userSettings).movieTitleLanguage
      self.data.subtitleState = JSON.parse(localStorage.userSettings).subtitleState
    source = self.data.template
    template = Handlebars.compile(source);

    $(self.data.id).html(template({
      buttons: self.data.buttons, 
      currentActive: self.data.currentActive, 
      language: self.data.language
      quality: self.data.quality
      movieTitleLanguage: self.data.movieTitleLanguage
      subtitleState: self.data.subtitleState
      }))
   

  getData: ()->
    self = @
    getPaymentMethodDone = (error, result) ->
      if error isnt null and error isnt undefined 
        if error.error == 1002
          if error
            console.log error
      else if result isnt undefined and result isnt null
        if result.error is 1005
          pateco._login.initPage(pateco._setting.callbackFuncLogin)
          return

        self.data.user_profile = result
        self.data.userDetail = true
        self.renderRightInfo()

    pateco.ApiService.getUserProfile(getPaymentMethodDone)


  getDataPackage: ()->
    self = @
    updateProfileLeftDone = (error, resultPackage) ->
      if error
        if error and error.message 
          self.data.packageInfo = error.message
        return
      if resultPackage.message
        self.data.packageInfo = resultPackage.message
        self.data.userPackage = true
        self.renderRightInfo()
    pateco.ApiService.updateProfileLeft(updateProfileLeftDone)
    

  callbackFuncLogin: ()->
    self = pateco._setting
    self.removePage()
    pateco._page.initKey()
    
  callbackFunc: ()->
    self = pateco._setting
    # self.removePage()
    pateco._setting.initKey()
    
  renderRightInfo: ()->
    self = @
    source = Templates['module.setting.user-info']()
    template = Handlebars.compile(source);
    element = $(self.data.id);
    data = 
      user: self.data.user_profile
      packageInfo : self.data.packageInfo

    element.find('#setting-account').html(template(data))
  
  # renderRightInfoPackage: ()->
  #   self = @
  #   source = Templates['module.setting.user-info']()
  #   template = Handlebars.compile(source);
  #   element = $(self.data.id);
  #   data = 
  #     packageInfo : self.data.packageInfo
  #   element.find('#packageInfo').html(template(data))

  updateActive: (list, index, child)->
    self = @
    $(list).children(child).removeClass("active")
    nextActiveButton = $(list).children(child).get(index)
    $(nextActiveButton).addClass("active")

  toggleActiveMenu: (toggle)->
    self = pateco._setting
    listElement = '.setting-menu'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

#  activeIconBack: (active = true)->
#    self = pateco._page
#    backButton = self.element.find('.back-button')
#    backButton.hide()
#    if active then backButton.show()

  addClassIntoIcBack: (active = true, callback)->
    self = pateco._page
    backButton = self.element.find('.back-button')
    backButton.removeClass('active')
    if active
      backButton.addClass('active')

  removePage: ()->
    self = @
    self.data.callback() if _.isFunction(self.data.callback)
    $(self.data.id).find('.setting-page').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 1000)

  handleBackbutton: (keyCode, key) ->
    self = pateco._setting
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()
        self.data.currentActive = 0
  
  handleKey: (keyCode, key)->
    self = pateco._setting
    console.info 'Setting Key:' + keyCode
    length = Object.keys(self.data.buttons).length
    listElement = '.setting-menu'
    actionKey = ()->
      self.data.currentActive = pateco.KeyService.reCalc(self.data.currentActive, length)
      self.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        pateco.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        break;
      when key.RETURN
        self.removePage()
        break;
      when key.DOWN
        self.data.currentActive++
        actionKey()
        break;
      when key.UP
        self.data.currentActive--
        if self.data.currentActive < 0
          #self.addClassIntoIcBack()
          pateco._backButton.setActive(true, self.handleBackbutton)
          self.toggleActiveMenu(false)
        else
          actionKey()
        break;

  toggleSubtitle: ()->
    self = @
    self.data.subtitleState = !self.data.subtitleState
    if self.data.subtitleState 
      addStorage = 'on'
    else 
      addStorage = 'off'
    # translate
    currentLang = pateco.UserService.getValueStorage('userSettings', 'language')
    if addStorage is 'on'
      str ='account-pairing-device-on'
    else 
      str = 'account-pairing-device-off'
    valueLangTitle = pateco.LanguageService.convert(str, currentLang)
    $(".setting-menu").find('li.active a .value span').text(valueLangTitle)
    pateco.UserService.upDateLocalStorage('userSettings','subtitleState', addStorage)
    
    
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)