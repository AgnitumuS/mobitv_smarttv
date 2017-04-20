pateco._settingNotification =
  data:
    id: '#setting-notification'
    template  : Templates['module.setting.setting-notification']()
    currentActive: 0
    translateY : 0
    icActive: false
    onFocus: true
    notifications: null
    currentNotify: null
  
  initPage: ()->
    self = @
    self.data.currentActive = 0
    self.render()
    self.getData() 
    self.initKey()
    
  getData: ()->
    self = pateco._settingNotification
    done = (error, result)->
      self.data.notifications = result
      # load notification content when init
      if self.data.notifications.count > 0
        self.data.currentNotify = self.data.notifications.rows[self.data.currentActive]
        if self.data.notifications.count > 9
          self.data.icActive = true
        else
          self.data.icActive = false
      self.renderNotify()
      console.log self.data.notifications
    
    pateco.ApiService.getNotification(done)

  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template)

  renderNotify: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    $(self.data.id).html(template({
      notifications: self.data.notifications, 
      currentNotify : self.data.currentNotify, 
      currentActive: self.data.currentActive, 
      onFocus: self.data.onFocus
      icActive: self.data.icActive
     }))

  toggleActiveMenu: (toggle)->
    listElement = '.bt-notificartion'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  loadChangeRight: ()->
    self = @
    if self.data.notifications isnt null and self.data.notifications isnt undefined
      if self.data.notifications.count > 0
        self.data.currentNotify = self.data.notifications.rows[self.data.currentActive]
        self.renderNotify()

  handleBackbutton: (keyCode, key) ->
    self = pateco._settingNotification
    switch keyCode
      when key.DOWN
        self.data.currentActive = 0
        self.toggleActiveMenu(true)
        # check to focus Active Key handle
        self.initKey()

      when key.RETURN,key.ENTER
        self.removePage()
        pateco._setting.initKey()

  handleKey: (keyCode, key)->
    self = pateco._settingNotification
    console.info 'Setting Notification:' + keyCode
    length = $('.bt-notificartion').find('li').length
    listElement = '.bt-notificartion'
    # load detail notify in right panel

    actionKey = ()->
      self.data.currentActive = pateco.KeyService.reCalc(self.data.currentActive, length)
      pateco.UtitService.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.RETURN
        console.log 'Call back to setting menu'
        self.data.haveSource = false
        self.removePage()
        pateco._setting.initPage()
        break;
      when key.UP
        self.data.currentActive--
        if self.data.currentActive < 0
          self.data.currentActive = 0
          pateco._backButton.setActive(true, self.handleBackbutton)
          self.toggleActiveMenu(false)
        else
          actionKey()
          self.loadChangeRight()
        if self.data.currentActive >= 9
          self.data.translateY += 8
          $(listElement).css 'transform': 'translateY(' + self.data.translateY + '%)'
          if self.data.currentActive < (length + 1)
            self.data.icActive = true
            $(self.data.id).find('.icon-down').show()
        break;
      when key.ENTER
        if self.data.notifications.count is 0
          self.removePage()
          pateco._setting.initPage()
        break;
      when key.DOWN
        if self.data.currentActive < length
          self.data.currentActive++
          console.log "down key notify"
          actionKey()
          self.loadChangeRight()
          if self.data.currentActive >= 9
            self.data.translateY -= 8
            $(listElement).css 'transform': 'translateY(' + self.data.translateY + '%)'

            if self.data.currentActive is (length - 1)
              self.data.icActive = false
              self.data.currentActive = length - 1
              $(self.data.id).find('.icon-down').hide()
        break;
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)

  
  removePage: ()->
    self = @
    $(self.data.id).find('.setting-notificartion').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      $(self.data.id).html('')
    , 500)
  