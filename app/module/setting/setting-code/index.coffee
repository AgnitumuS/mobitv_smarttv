fimplus._settingCode =
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
      fimplus._keyboard.setActiveKeyboard(0, 0)

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
      fimplus._settingCode.initPage()

    unless element.val()
      fimplus._error.initPage({
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
    self = fimplus._settingCode
    retry = ()->
      self.initKey()
    getListCodeDone = (error, result) ->
      if result.status
        fimplus._error.initPage({
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
        fimplus.KeyService.initKey(self.handleKeyCodeList)
        self.renderCodeList()
      else
        self.data.isList = false
    fimplus.ApiService.getListCode(getListCodeDone)

  getData: ()->
    self = fimplus._settingCode
    self.data.code = $("#codeInput").val()
    email = fimplus.UserService.getProfile().email
    phone = fimplus.UserService.getProfile().localAcc.mobile
    params =
      code: self.data.code
      email: email
      phone: phone
      env: fimplus.env

    retry = ()->
      self.initKey()
      fimplus._error.destroyPage()
    
    exitApp = ()->
      fimplus._settingCode.initPage()

    tryInput = ()->
      self = fimplus._settingCode
      self.render()
      self.initKey()

    backSetting = ()->
      fimplus._setting.initPage()
    
    addCodeDone = (error, result)->
     if error
       if result.responseJSON.error is 400
         fimplus._error.initPage({
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
         fimplus._error.initPage({
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
       fimplus._error.initPage({
         onReturn   : exitApp
         description: result.message
         title      : 'code-discount-success'
         buttons    : [
           title   : 'button-confirm'
           callback: exitApp
         ]
       })
       console.log result

    fimplus.ApiService.getCodeVal(params, addCodeDone)

  toggleActiveMenu: (toggle)->
    self = fimplus._settingCode
    if self.data.isList
      listElement = '.code-list'
    else
      listElement = '#button-code'

    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  hanldeBackbutton: (keyCode, key) ->
    self = fimplus._settingCode
    console.log 'back button in coupons'
    switch keyCode
      when key.DOWN
        if self.data.isList
          self.data.currentActive = 0
          self.toggleActiveMenu(true)
          fimplus.KeyService.initKey(self.handleKeyCodeList)
        else
          fimplus._keyboard.onBackBoardButton()
          self.initKey()
      when key.RETURN,key.ENTER
        self.data.haveSource = false
        #self.removePage()

        if self.data.isList
          self.removePage()
          fimplus._setting.initKey()
          self.data.isList = true
        else
          if self.data.listCode.length == 0
            fimplus._setting.initKey()
          else
            self.initPage()


  handleKey: (keyCode, key)->
    self = fimplus._settingCode
    element = $(self.data.id)
    console.info 'Setting Code:' + keyCode
    positionEntity = self.data.positionEntity
    if keyCode isnt key.RETURN
      unless positionEntity.active
        fimplus._keyboard.handleKey(keyCode, key)
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
          fimplus._setting.initPage()
        else
          self.initPage()
        break;
      when key.UP
      # focus on input Code
      # $("#codeInput").focus()
        self.data.positionEntity.active = false
        element.find('#button-code').find('li').removeClass('active')
        self.data.onFocus = false
        fimplus._keyboard.onBackBoardButton()
        break;
      when key.DOWN
        self.data.onFocus = true
        $("#codeInput").blur()
        break;

  handleKeyCodeList: (keyCode, key)->
    self = fimplus._settingCode
    console.info 'Setting List Code:' + keyCode
    listElement = '.code-list'
    length = $('.code-list').find('li').length
    # load detail notify in right panel
    actionKey = ()->
      self.data.currentActive = fimplus.KeyService.reCalc(self.data.currentActive, length)
      fimplus.UtitService.updateActive(listElement, self.data.currentActive, 'li')
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
        fimplus._setting.initPage()
        break;
      when key.UP
        self.data.currentActive--
        self.data.onFocus = false
        if self.data.currentActive < 0
          fimplus._backButton.setActive(true, self.hanldeBackbutton)
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
    fimplus.KeyService.initKey(self.handleKey)
  
  renderKeyboard: (inputId, type)->
    self = @
    self.data.positionEntity.active = false
    element = $('.register-code-keyboard')
    input = $(inputId)
    fimplus._keyboard.render(element, input, self.onActiveEntity, type)

  onActiveEntity: (type = 'DOWN')->
    self = fimplus._settingCode
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
#          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
          self.data.onFocus = true
          $(self.data.id).find('#button-code').find('li').addClass('active')
      when 'UP'
        fimplus._backButton.setActive(true, self.hanldeBackbutton)
        fimplus._keyboard.setActiveKeyboard(0, 0, false)
  
#  onActiveEntity: ()->
#    self = fimplus._settingCode
#    if !self.data.positionEntity.active
## length = $(self.data.id).find('.add-card-menu').find('li').length
## self.setActiveButton(self.data.currentActive, length)
#      self.data.positionEntity.active = true
#      self.data.onFocus = true
#      $(self.data.id).find('#button-code').find('li').addClass('active')
#      return
#    fimplus._keyboard.onBackBoardButton()
  
  removePage: ()->
    self = @
    $(self.data.id).find('.setting-code').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  