pateco._payment =
  data:
    id           : '#payment'
    template     : Templates['module.payment']()

  initPage: (type, callback)->
    self = @
    self.data.isRentMovie = false
    self.render()
    self.data.callback = ()-> console.log 'callback'
    self.data.callback = callback if _.isFunction(callback)
    if type is 'buyPackage'
      pateco._buyPackage.initPage(self.onReturnPage)
    if type is 'rentMovie'
      retry = ()->
        self.removePage()
      env = pateco.env
      self.data.pricePackage = pateco._detail.data.item.ppvPrice
      allowMethod = pateco._detail.data.item.notAllowChargeOnMethod
      if allowMethod is '[]' or !allowMethod
        allowMethod = null
      getSourceIdDone = (error, result) ->
        if result.status
          pateco._error.initPage({
            title      : "button-buy-package"
            onReturn   : retry
            description: result.responseJSON.message
            buttons    : [
              title   : 'try-again-button'
              callback: retry
            ]
          });
          return
        i = 0
        self.data.methods = result.methods
        self.data.paymentMethodSync = 0
        while i < result.sources.length
          if result.sources[i].methodType == 'CCSTRIPE'
            self.data.paymentMethodSync = 1
          i++
        if result.sources.length > 0
          i = 0
          while i < result.sources.length
            if result.sources[i].methodType is 'CCSTRIPE'
              self.data.sourceId = result.sources[i].id
            i++
        if self.data.paymentMethodSync is 1
          pateco._rentMovie.initPage(pateco._detail.data.item, self.data.sourceId, self.onReturnPage)
        else
          self.data.isRentMovie = true
          pateco._paymentMethod.initPage(self.data, self.onReturnPage)
      pateco.ApiService.getPaymentMethod(allowMethod, env, getSourceIdDone)
  onReturnPage: ()->
    self = pateco._payment
    self.removePage()

  showPage: (idPage)->
    listId = ['#redeem-code', '#rent-movie']
    i = 0
    while i < listId.length
      $(listId[i]).hide()
      i++
    $(idPage).show()


  render: ()->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template({payment: self.data}))

  removePage: ()->
    self = @
    pateco._redeemCode.data.code = null
    self.data.callback()
    self.element.html('')


    

    