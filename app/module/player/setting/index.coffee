fimplus._playerSetting =
  data:
    callback     : ()->
      console.log 'callback'
    currentActive:
      col: 0
      row: 0
    items        : {}
    setting      : []
  
  initPage: (items, callback)->
    self = @
    self.data.items = items
    self.data.callback = ()->
      console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    self.data.setting = []
    self.prepareSounds()
    self.prepareSubtitle()
    self.render()
    self.setActivePointer()
    self.initKey()
  
  
  initKey: ()->
    self = @
    fimplus.KeyService.initKey(self.handleKey)
  
  setConfigSetting: ()->
    self = fimplus._playerSetting
    currentActive = self.data.currentActive
    pointer = self.element.find('.player-edit-row')
    pointer.find('.icon').removeClass('ic-check')
    pointer.eq(currentActive.row).find('li').eq(currentActive.col).find('.icon').addClass('ic-check')
    
    checkActive = (data)->
      _.map(data.info, (item, index)->
        item.isActive = 0
        if index is currentActive.col
          item.isActive = 1
          data.type = item.type
      )
      return data
    self.data.items.subtitle = checkActive(self.data.items.subtitle)
  
  setActivePointer: (active = true)->
    self = fimplus._playerSetting
    
    currentActive = self.data.currentActive
    setting = self.data.setting
    return if _.isEmpty(setting)
    
    maxRow = setting.length
    currentActive.row = fimplus.KeyService.reCalc(currentActive.row, maxRow)
    maxCol = setting[currentActive.row].items.length
    currentActive.col = fimplus.KeyService.reCalc(currentActive.col, maxCol)
    self.data.currentActive = currentActive
    
    pointer = self.element.find('.player-edit-row')
    pointer.find('li').removeClass('active')
    if active
      pointer.eq(currentActive.row).find('li').eq(currentActive.col).addClass('active')
  
  
  prepareSounds: ()->
    self = @
    data = [
      title: 'en'
      type : 'EN'
    ,
      title: 'vi'
      type : 'VI'
    ,
      title: 'close'
      type : 'OFF'
    ]
    return if  _.isEmpty(self.data.items.sounds)
    self.data.setting.push
      title: 'play-option-audio'
      items: data
  
  prepareSubtitle: ()->
    self = @
    return if _.isEmpty(self.data.items.subtitle)
    self.data.setting.push
      title: 'account-subtitle-title'
      items: self.data.items.subtitle.info
  
  
  handleKey: (keyCode, key)->
    self = fimplus._playerSetting
    console.info 'Player Setting Key:' + keyCode
    
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.setConfigSetting()
        break;
      when key.LEFT
        self.data.currentActive.col--
        break;
      when key.RIGHT
        self.data.currentActive.col++
        break;
      when key.DOWN
        self.data.currentActive.row++
        break;
      when key.UP
        self.data.currentActive.row--
        break;
    
    self.setActivePointer()
  
  removePage: ()->
    self = fimplus._playerSetting
    self.element.html('')
    self.data.callback()
  
  render: ()->
    self = @
    source = Templates['module.player.setting']()
    template = Handlebars.compile(source);
    self.element = $('#player-wrapper #player-setting')
    self.element.html(template(self.data))
    
    