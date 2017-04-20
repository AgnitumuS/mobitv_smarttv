fimplus._error =
  data       :
    active     : false
    id         : '#error-page'
    template   : Templates['module.error']()
    currentData: {}
    defaultData:
      current    : 0
      title      : 'Thông báo'
      description: 'Error'
      buttons    : [
        title   : 'Ok'
        callback: ()->
      ]
  destroyPage: (enableCallReturn = true)->
    self = fimplus._error
    self.element.find('.error-wrapper').fadeOut()
    self.element.html('')
    self.data.active = false
    if _.isFunction(self.data.currentData.onReturn) and enableCallReturn
      self.data.currentData.onReturn()
  
  initPage: (data)->
    self = fimplus._error
    return if self.data.active
    data = data || self.data.defaultData
    data.current = data.current || 0
    self.data.currentData = data
    self.render(data)
    self.initKey()
    self.setActiveButton(self.data.currentData.current, self.data.currentData.buttons.length)
  
  render: (data)->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    buttonClick = ()->
      index = $(@).index()
      self.destroyPage(false)
      unless _.isFunction(data.buttons[index].callback)
        return
      data.buttons[index].callback()
    
    self.element.html(template(data))
    self.element.find('.bt-movie').find('li')
      .off 'click'
      .on 'click', buttonClick
    if self.data.currentData.timeOut && _.isFunction(self.data.currentData.timeOut.callback)
      setTimeout ()->
        self.destroyPage(false)
        self.data.currentData.timeOut.callback()
      , self.data.currentData.timeOut.time * 1000

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = fimplus._error
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentData.current, self.data.currentData.buttons.length)
        self.initKey()
      when key.RETURN,key.ENTER
        self.destroyPage()
  
  handleKey: (keyCode, key)->
    self = fimplus._error
    length = self.data.currentData.buttons.length
    console.info 'Error Key:' + keyCode
    switch keyCode
      when key.LEFT
        self.data.currentData.current = self.setActiveButton(--self.data.currentData.current, length)
        break;
      when key.RIGHT
        self.data.currentData.current = self.setActiveButton(++self.data.currentData.current, length)
        break;
      when key.ENTER
        self.element
          .find('.bt-movie')
          .find('li')
          .eq(self.data.currentData.current)
          .trigger 'click'

      when key.RETURN
        self.destroyPage()
        break;
      when key.UP
        fimplus._backButton.setActive(true, self.hanldeBackbutton)
        self.setActiveButton(0, 0)
  
  setActiveButton: (current = 0, length = 0)->
    self = @
    button = self.element.find('.bt-movie').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current
  
  initKey: ()->
    self = fimplus._error
    self.data.active = true
    fimplus.KeyService.initKey(self.handleKey, '', false)
    
  