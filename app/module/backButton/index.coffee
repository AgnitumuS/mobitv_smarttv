fimplus._backButton =
  data:
    active: false
  
  enable: (active = true)->
    self = fimplus._backButton
    self.data.enable = active
    backButton = $('#home .back-button')
    backButton.hide()
    if active
      backButton.show()
  
  checkActive: ()->
    self = fimplus._backButton
    return self._backButton.data.active = active
  
  setActive: (active = true, callback)->
    self = fimplus._backButton
    self.data.callback = callback || ()-> console.log 'callback Backbutton'
    self.data.active = active
    backButton = $('#home .back-button')
    backButton.removeClass('active')
    if active
      self.initKey()
      backButton.addClass('active')
  
  handleKey: (keyCode, key)->
    self = fimplus._backButton
    console.info 'Back Button Key:' + keyCode
    if keyCode in [key.DOWN, key.ENTER, key.RETURN]
      self.data.callback(keyCode, key)
      self.setActive(false)
  
  initKey: ()->
    self = fimplus._backButton
    self.data.active = true
    fimplus.KeyService.initKey(self.handleKey, '', false)
    
  