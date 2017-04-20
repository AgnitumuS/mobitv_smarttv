pateco._redeemCode =
  data:
    id           : '#redeem-code'
    title        : 'code-discount'
    description  : 'code-description'
    template     : Templates['module.payment.redeem-code']()
    currentActive: 0
    buttons     : [
      registerBtn =
        action: ()->
          pateco._redeemCode.getCode()
      ]

  setActiveButton    : (current = 0, length = 0)->
    self = @
    button = self.element.find('.redeem-code-list').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  getCode: ()->
    self = @
    if self.data.currentActive is 0
      pateco._enterRedeemCode.initPage(self.onReturnPage)
    else
      self.data.code = self.data.listCode[self.data.currentActive-1].code
      i = 0
      while i < self.data.listCode.length
        if self.data.code != null and typeof(self.data.code) != 'undefined'
          if self.data.listCode[i].code.toLowerCase() == self.data.code.toLowerCase()
            self.data.applyCodeLength = self.data.listCode[i].applyPackageLength
            if self.data.listCode[i].isDiscount == 1
              if self.data.listCode[i].isPercentage == 1
                self.data.discount = (100 - self.data.listCode[i].value * 1) / 100
                self.data.percent = 1
              else
                self.data.discount = self.data.listCode[i].value * 1
                self.data.percent = 0
            if self.data.listCode[i].isApply
              self.data.applyCode = 1
        i++
      self.removePage()


  initPage: (callback)->
    self = @
    self.getData()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)

  onReturnPage: ()->
    self = pateco._redeemCode
    self.getData()


  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({payment: self.data}))
    pateco._payment.showPage(self.element)
    self.setActiveButton(self.data.currentActive, self.data.listCode.length+1)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    self.element.find('.redeem-code-list').find('li')
      .off 'click'
      .on 'click', buttonClick

  getData: ()->
    self = @
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
      self.render()
      self.initKey()
      if result.length > 0
        self.isGiftcode = 1
      else
        self.isGiftcode = 0
    pateco.ApiService.getListCode(getListCodeDone)

  hanldeBackbutton: (keyCode, key) ->
    console.log 'backb'
    self = pateco._redeemCode
    switch keyCode
      when key.DOWN
        self.setActiveButton(self.data.currentActive, self.data.listCode.length+1)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()

  handleKey: (keyCode, key)->
    self = pateco._redeemCode
    switch keyCode
      when key.RETURN
        self.removePage()
        break;
      when key.ENTER
        self.data.buttons[0].action()
        break;
      when key.DOWN
        self.data.currentActive = self.setActiveButton(++self.data.currentActive, self.data.listCode.length+1)
        break;
      when key.UP
        if self.data.currentActive is 0
          pateco._backButton.setActive(true, self.hanldeBackbutton)
          self.setActiveButton(0, 0)
        else
          self.data.currentActive = self.setActiveButton(--self.data.currentActive, self.data.listCode.length+1)
        break;
  
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)

  removePage: ()->
    self = pateco._redeemCode
    $('#rent-movie').show()
    self.data.callback()
    self.element.html('')

    