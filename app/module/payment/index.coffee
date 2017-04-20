fimplus._payment =
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
      fimplus._buyPackage.initPage(self.onReturnPage)
    if type is 'rentMovie'
      retry = ()->
        self.removePage()
      env = fimplus.env
      self.data.pricePackage = fimplus._detail.data.item.ppvPrice
      allowMethod = fimplus._detail.data.item.notAllowChargeOnMethod
      if allowMethod is '[]' or !allowMethod
        allowMethod = null
      getSourceIdDone = (error, result) ->
        if result.status
          fimplus._error.initPage({
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
          fimplus._rentMovie.initPage(fimplus._detail.data.item, self.data.sourceId, self.onReturnPage)
        else
          self.data.isRentMovie = true
          fimplus._paymentMethod.initPage(self.data, self.onReturnPage)
      fimplus.ApiService.getPaymentMethod(allowMethod, env, getSourceIdDone)
  onReturnPage: ()->
    self = fimplus._payment
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
    fimplus._redeemCode.data.code = null
    self.data.callback()
    self.element.html('')


    

    