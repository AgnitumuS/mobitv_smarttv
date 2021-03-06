pateco._settingCode =
  data:
    id            : '#setting-code'
    template      : Templates['module.setting.setting-code']()
    currentActive : 0
    onFocus       : false
    code          : null
    notifications : null
    currentNotify : null
    inputFocus    : '#codeInput'
    listCode      : null
    listButton    : null
    isList        : false
    positionEntity:
      active: true

  
  initPage: ()->
    self = @
    self.render()
    self.getListCode()
    self.initKey()

  render: ()->
    self = @
    self.data.onFocus = false
    self.data.currentActive = 0
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template)
    unless self.data.isList
      self.renderKeyboard(self.data.inputFocus, 'text')
      pateco._keyboard.setActiveKeyboard(0, 0)

  renderCodeList: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    console.log self.data.listCode
    console.log self.data.isList
    $(self.data.id).html(template({
      onFocus: self.data.onFocus
      listCode: self.data.listCode
      isList: self.data.isList
      currentActive: self.data.currentActive
    }))

  checkEmpty: ()->
    element = $("#codeInput")

    exitApp = ()->
      pateco._settingCode.initPage()

    unless element.val()
      pateco._error.initPage({
        onReturn   : exitApp
        description: 'code-empty'
        title      : 'use-code-discount-error'
        buttons    : [
          title   : 'button-try-again'
          callback: exitApp
        ]
      })
      return true
    return false

# renderNotify: ()->
#   self = @
#   source = self.data.template
#   template = Handlebars.compile(source);
#   $(self.data.id).html(template({notifications: self.data.notifications, currentNotify : self.data.currentNotify, currentActive: self.data.currentActive, onFocus: self.data.onFocus
#    }))


  getListCode: ()->
    self = pateco._settingCode
    retry = ()->
      self.initKey()
    getListCodeDone = (error, result) ->
      if result.status
        pateco._error.initPage({
          title      : "code-discount"
          onReturn   : retry
          description: result.responseJSON.message
          buttons    : [
            title   : 'button-try-again'
            callback: retry
          ]
        });
        return
      self.data.listCode = result
      addNew =
        code: 'enter-new-code'
        value: ''
      if result.length > 0
        self.data.isList = true
        pateco.KeyService.initKey(self.handleKeyCodeList)
        self.renderCodeList()
      else
        self.data.isList = false
    pateco.ApiService.getListCode(getListCodeDone)

  getData: ()->
    self = pateco._settingCode
    self.data.code = $("#codeInput").val()
    email = pateco.UserService.getProfile().email
    phone = pateco.UserService.getProfile().localAcc.mobile
    params =
      code: self.data.code
      email: email
      phone: phone
      env: pateco.env

    retry = ()->
      self.initKey()
      pateco._error.destroyPage()
    
    exitApp = ()->
      pateco._settingCode.initPage()

    tryInput = ()->
      self = pateco._settingCode
      self.render()
      self.initKey()

    backSetting = ()->
      pateco._setting.initPage()
    
    addCodeDone = (error, result)->
     if error
       if result.responseJSON.error is 400
         pateco._error.initPage({
           onReturn   : tryInput
           description: result.responseJSON.message
           title      : 'use-code-discount-error'
           buttons    : [
             title   : 'button-try-again'
             callback: tryInput
           ]
         })
         return console.log(error)
     else
       if result.status is 400
         pateco._error.initPage({
           onReturn   : tryInput
           description: result.responseJSON.message
           title      : 'use-code-discount-error'
           buttons    : [
             title   : 'button-try-again'
             callback: tryInput
           ]
         })
         return
       # successful
       pateco._error.initPage({
         onReturn   : exitApp
         description: result.message
         title      : 'code-discount-success'
         buttons    : [
           title   : 'button-confirm'
           callback: exitApp
         ]
       })
       console.log result

    pateco.ApiService.getCodeVal(params, addCodeDone)

  toggleActiveMenu: (toggle)->
    self = pateco._settingCode
    if self.data.isList
      listElement = '.code-list'
    else
      listElement = '#button-code'

    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  hanldeBackbutton: (keyCode, key) ->
    self = pateco._settingCode
    console.log 'back button in coupons'
    switch keyCode
      when key.DOWN
        if self.data.isList
          self.data.currentActive = 0
          self.toggleActiveMenu(true)
          pateco.KeyService.initKey(self.handleKeyCodeList)
        else
          pateco._keyboard.onBackBoardButton()
          self.initKey()
      when key.RETURN,key.ENTER
        self.data.haveSource = false
        #self.removePage()

        if self.data.isList
          self.removePage()
          pateco._setting.initKey()
          self.data.isList = true
        else
          if self.data.listCode.length == 0
            pateco._setting.initKey()
          else
            self.initPage()


  handleKey: (keyCode, key)->
    self = pateco._settingCode
    element = $(self.data.id)
    console.info 'Setting Code:' + keyCode
    positionEntity = self.data.positionEntity
    if keyCode isnt key.RETURN
      unless positionEntity.active
        pateco._keyboard.handleKey(keyCode, key)
        return
    # load detail notify in right panel
    switch keyCode
      when key.ENTER
        unless self.checkEmpty()
          self.getData()
        break;
      when key.RETURN
        self.data.haveSource = false
        #self.removePage()
        if self.data.listCode.length == 0
          pateco._setting.initPage()
        else
          self.initPage()
        break;
      when key.UP
      # focus on input Code
      # $("#codeInput").focus()
        self.data.positionEntity.active = false
        element.find('#button-code').find('li').removeClass('active')
        self.data.onFocus = false
        pateco._keyboard.onBackBoardButton()
        break;
      when key.DOWN
        self.data.onFocus = true
        $("#codeInput").blur()
        break;

  handleKeyCodeList: (keyCode, key)->
    self = pateco._settingCode
    console.info 'Setting List Code:' + keyCode
    listElement = '.code-list'
    length = $('.code-list').find('li').length
    # load detail notify in right panel
    actionKey = ()->
      self.data.currentActive = pateco.KeyService.reCalc(self.data.currentActive, length)
      pateco.UtitService.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        if self.data.currentActive is 0
          self.data.isList = false
          self.render()
          self.initKey()
        break;
      when key.RETURN
        self.data.haveSource = false
        self.removePage()
        pateco._setting.initPage()
        break;
      when key.UP
        self.data.currentActive--
        self.data.onFocus = false
        if self.data.currentActive < 0
          pateco._backButton.setActive(true, self.hanldeBackbutton)
          self.toggleActiveMenu(false)
        else
          actionKey()
        break;
      when key.DOWN
        self.data.currentActive++
        self.data.onFocus = true
        actionKey()
        break;

  initKey  : ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)
  
  renderKeyboard: (inputId, type)->
    self = @
    self.data.positionEntity.active = false
    element = $('.register-code-keyboard')
    input = $(inputId)
    pateco._keyboard.render(element, input, self.onActiveEntity, type)

  onActiveEntity: (type = 'DOWN')->
    self = pateco._settingCode
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
#          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
          self.data.onFocus = true
          $(self.data.id).find('#button-code').find('li').addClass('active')
      when 'UP'
        pateco._backButton.setActive(true, self.hanldeBackbutton)
        pateco._keyboard.setActiveKeyboard(0, 0, false)
  
#  onActiveEntity: ()->
#    self = pateco._settingCode
#    if !self.data.positionEntity.active
## length = $(self.data.id).find('.add-card-menu').find('li').length
## self.setActiveButton(self.data.currentActive, length)
#      self.data.positionEntity.active = true
#      self.data.onFocus = true
#      $(self.data.id).find('#button-code').find('li').addClass('active')
#      return
#    pateco._keyboard.onBackBoardButton()
  
  removePage: ()->
    self = @
    $(self.data.id).find('.setting-code').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  