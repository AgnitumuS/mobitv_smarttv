fimplus._addCard =
  data:
    id: '#add-card'
    template  : Templates['module.setting.setting-method.add-card']()
    backVisa: false
    cardFail: false
    currentFocus: 1
    currentActive: 0
    cardInfo: null
    onFocus: false
    settingMethodtitle: 'full-name'
    inputFocus: '#card_name'
    currentKeyType: 'text'
    resultCard: null
    successCard: false
    expMonthCard: null
    expYearCard: null
    cardInfo: {
      name: ''
      number: ''
      exp_month: ''
      exp_year: ''
      cvc: ''
    }
    callback: ()->
    success: ()->
    positionEntity:
      active : false
    buttons: 
      cancleCard:
        title: 'button-cancel'
        action: ()->
          self = fimplus._addCard
          if self.data.backVisa
            # back front visa
            self.data.cardInfo.cvc = $('#card_cvc').val()
            self.backFrontVisa()
          else
            # check case when back focusInput 
            switch self.data.inputFocus
              when "#card_name"
                fimplus._addCard.removePage()
                break;
              when "#card_number"
                self.data.inputFocus = "#card_name"
                self.focusInput(self.data.inputFocus,'text')
                self.data.settingMethodtitle = 'full-name'
                self.renderButton('cancleCard', 'button-cancel')
                self.reRenderTitle()
                break;
              when "#card_date"
                self.data.inputFocus = "#card_number"
                self.focusInput(self.data.inputFocus,'number')
                self.data.settingMethodtitle = 'mobile-card-number'
                self.renderButton('cancleCard', 'button-back')
                self.reRenderTitle()
                break;
            console.log 'cancel add card'
            self.removeFocus()
      sendCard:
        title: 'button-continue'
        action: ()->
          self = fimplus._addCard
          
          switch self.data.inputFocus
            when "#card_name"
              # keep input number
              self.data.inputFocus = "#card_number"
              # self.setHightLightInput(self.data.inputFocus)
              self.focusInput(self.data.inputFocus,'number')
              self.data.settingMethodtitle = 'mobile-card-number'
              self.removeFocus()
              self.renderButton('cancleCard', 'button-back')
              self.reRenderTitle()
              break;
            when "#card_number"
              if self.checkCardNumber()
                # keep input number
                self.data.inputFocus = "#card_date"
                # self.setHightLightInput(self.data.inputFocus)
                self.focusInput(self.data.inputFocus,'number')
                self.data.settingMethodtitle = 'expiration-date'
                self.removeFocus()
                self.renderButton('cancleCard', 'button-back')
                self.reRenderTitle()
              break;
            when "#card_date"
              if self.checkCardDate()
                self.data.backVisa = true
                self.data.currentActive = 0
                self.data.inputFocus = '#card_name'
                fimplus.KeyService.initKey(self.handleKeyCVC)
                self.data.settingMethodtitle = 'cvv-title'
                cvc = ''
                if self.data.cardInfo.cvc != undefined and self.data.cardInfo.cvc != null
                  cvc = self.data.cardInfo.cvc

                self.data.cardInfo =
                  name : $('#card_name').val(),
                  number : $('#card_number').val().toString().replace(/\s/g, ''),
                  exp_month : $('#card_date').val().toString().substr(0,2),
                  exp_year : $('#card_date').val().toString().substr(3,2),
                  cvc : cvc
                self.data.buttons['cancleCard'].title = 'button-back'
                self.reRenderTitle()
                self.render()
                self.data.inputFocus = "#card_cvc"
                $('#card_cvc').val(cvc)
                
                # self.setHightLightInput(self.data.inputFocus)
                self.focusInput(self.data.inputFocus,'number')
                self.removeFocus()
              break;
            when "#card_cvc"
              ### send update card ###
              if self.checkCardCVV()
                console.log 'send add card'
                fimplus._addCard.data.cardInfo.cvc = $('#card_cvc').val()
                fimplus._addCard.updateCard()
                $(".wrap-loading").show()
              break;
          self.data.onFocus = false
          
          
        buttonsFail:
          tryAgain:
            title: 'button-try-again'
            action: ()->
              fimplus._addCard.data.cardFail = false
              fimplus._addCard.data.backVisa = false
              # call add card action again
          cancleCardAfterFail:
            title: 'button-cancel'
            action: ()->
              fimplus._addCard.data.cardFail = false
              fimplus._addCard.removePage()
  
  initPage: (callback, success)->
    self = fimplus._addCard
    self.data.callback = ()->
      console.log 'detail callback show homepage'
    self.data.success = success if _.isFunction(success)
    self.data.callback = callback if _.isFunction(callback)
    self.data.onFocus = false
    self.render()
    self.initKey()

  renderButton: (nameButton, value)->
    self = @
    lang = fimplus.UserService.getValueStorage('userSettings', 'language')
    value = fimplus.LanguageService.convert(value, lang)
    html = '<a><span>'+value+'</span></a>'
    $(".add-card-menu li:first").html(html)
    

    
  backFrontVisa: ()->
    self = @
    # save data front
    self.data.backVisa = false
    self.data.cardFail = false
    self.data.settingMethodtitle = 'full-name'
    self.renderButton('cancleCard','button-cancel')
    self.removeFocus()
    self.render()
    self.initKey()
    # render data again
    # name : $('#card_name')
    # number : $('#card_number)
    # exp_month : $('#card_date')
    # exp_year : $('#card_date')
    self.removeFocus()
    name = self.data.cardInfo.name
    number = self.data.cardInfo.number
    tempstr = ''
    i = 0
    while i < number.length
      tempstr += number[i]
      if (tempstr.length + 1) % 5 is 0
        tempstr += ' '
      i++
    date = self.data.cardInfo.exp_month + '/' + self.data.cardInfo.exp_year
    $('#card_name').val(name)
    $('#card_number').val(tempstr)
    $('#card_date').val(date)
    self.data.inputFocus = "#card_name"
    self.focusInput(self.data.inputFocus, 'text')
  
  setHightLightInput: (inputFocus)->
    self = @
    element = $(self.data.id)
    element.find('input[type="text"]').removeClass('active')
    $(inputFocus).addClass('active')
  
  removeFocus: ()->
    $('.add-card-menu').find("li").removeClass("active")

  toggleActiveMenu: (toggle)->
    listElement = '#add-card .setting-bt'
    unless toggle
      $(listElement).find('li').removeClass('active')
    else
      $(listElement).find('li').first().addClass('active')

  handleBackbutton: (keyCode, key) ->
    self = fimplus._addCard
    switch keyCode
      when key.DOWN
        if self.data.successCard
          fimplus.KeyService.initKey(self.handleKeyScuccessCard)
        if self.data.backVisa and !self.data.successCard
          fimplus.KeyService.initKey(self.handleKeyCVC)
        if !self.data.backVisa and !self.data.successCard
          self.initKey()
#        self.data.currentActive = 0
        fimplus._keyboard.onBackBoardButton()
#        self.data.currentActive = 0
#        self.toggleActiveMenu(true)
        # check to focus Active Key handle

      when key.RETURN,key.ENTER
        #        self.removePage()
        if self.data.backVisa
          # back front visa
          self.data.cardInfo.cvc = $('#card_cvc').val()
          self.backFrontVisa()
        else
          # check case when back focusInput
          switch self.data.inputFocus
            when "#card_name"
              fimplus._addCard.removePage()
              break;
            when "#card_number"
              self.data.inputFocus = "#card_name"
              self.focusInput(self.data.inputFocus,'text')
              self.data.settingMethodtitle = 'full-name'
              self.renderButton('cancleCard', 'button-cancel')
              self.reRenderTitle()
              break;
            when "#card_date"
              self.data.inputFocus = "#card_number"
              self.focusInput(self.data.inputFocus,'number')
              self.data.settingMethodtitle = 'mobile-card-number'
              self.renderButton('cancleCard', 'button-back')
              self.reRenderTitle()
              fimplus._keyboard.onBackBoardButton()
              break;
          console.log 'cancel add card'
          self.removeFocus()
          self.initKey()


  loadOnChange: ()->
    self = @    
    unless self.data.successCard
      unless self.data.backVisa 
        self.checkCardNumberOnChange()
        self.checkExpirationDate()
      else 
        self.checkCVV()

  render: ()->
    self = @
    source = self.data.template
    element = $(self.data.id)
    template = Handlebars.compile(source);
    # focus on current input
    
    element.html(template({
      backVisa: self.data.backVisa
      cardFail: self.data.cardFail
      successCard: self.data.successCard
      currentActive: self.data.currentActive
      onFocus: self.data.onFocus
      buttons: self.data.buttons
      settingMethodtitle: self.data.settingMethodtitle
      resultCard: self.data.resultCard
      expMonthCard: self.data.expMonthCard
      expYearCard: self.data.expYearCard
    }))
    self.loadOnChange()

    @focusInput(self.data.inputFocus, self.data.currentKeyType)
    
  focusInput: (inputFocus, type)->
    self = @
    self.setHightLightInput(inputFocus)
    self.renderKeyboard(inputFocus, type)
    fimplus._keyboard.setActiveKeyboard(0, 0)
    buttonClick = ()->
      index = $(@).index()
      self.data.buttons[index].action()
    $(self.data.id).find('.add-card-menu').find('li')
      .off 'click'
      .on 'click', buttonClick

  handleKey: (keyCode, key)->
    self = fimplus._addCard
    console.info 'Setting Method add card Key:' + keyCode
    # length = Object.keys(self.data.buttons).length
    length = $('.add-card-menu').find('li').length
    listElement = '.add-card-menu'
    positionEntity = self.data.positionEntity
    if keyCode isnt key.RETURN
      unless positionEntity.active
        fimplus._keyboard.handleKey(keyCode, key)
        return
    # blur all input, press UP to focus
    actionKey = ()->
      self.data.currentActive = fimplus.KeyService.reCalc(self.data.currentActive, length)
      self.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        fimplus.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        break;
      when key.RETURN
        self.removePage()
        break;
      when key.UP
        self.data.positionEntity.active = false
        $(self.data.id).find('.add-card-menu').find('li').removeClass('active')
        fimplus._keyboard.onBackBoardButton()
        break;
      when key.LEFT
        if self.data.onFocus
          self.data.currentActive--
        actionKey()
        break;
      when key.RIGHT
        if self.data.onFocus
          self.data.currentActive++
        actionKey()
        break;
      when key.DOWN
        self.data.positionEntity.active = true
        actionKey()
        break;
      
  handleKeyCVC: (keyCode, key)->
    self = fimplus._addCard
    console.info 'Setting Method add CVV card:' + keyCode
    # length = Object.keys(self.data.buttons).length
    length = $('.visa-bt ul').find('li').length
    listElement = '.visa-bt ul'
    # blur all input, press UP to focus
    positionEntity = self.data.positionEntity
    if keyCode isnt key.RETURN
      unless positionEntity.active
        fimplus._keyboard.handleKey(keyCode, key)
        return
    actionKey = ()->
      self.data.currentActive = fimplus.KeyService.reCalc(self.data.currentActive, length)
      self.updateActive(listElement, self.data.currentActive, 'li')
    switch keyCode
      when key.ENTER
        fimplus.UtitService.convertObjToArr(self.data.buttons)[self.data.currentActive].action()
        break;
      when key.RETURN
        # self.removePage()
        # back to front of card
        # self.data.settingMethodtitle = 'mobile-card-number'
        # self.data.backVisa = false
        # self.data.cardFail = false
        # self.render()
        # self.data.inputFocus = "#card_name"
        # self.focusInput(self.data.inputFocus, 'text')
        self.backFrontVisa()
        break;
      when key.LEFT
        if self.data.onFocus
          self.data.currentActive--
          self.data.currentFocus = 0
        actionKey()
        break;
      when key.RIGHT
        if self.data.onFocus
          self.data.currentActive++
          self.data.currentFocus = 0
        actionKey()
        break;
      when key.DOWN
        $("#card_cvc").blur()
        self.data.positionEntity.active = true
        actionKey()
        break;
      when key.UP
        self.data.positionEntity.active = false
        $(self.data.id).find('.add-card-menu').find('li').removeClass('active')
        fimplus._keyboard.onBackBoardButton()
        self.setHightLightInput("#card_cvc")
        break;

  handleKeyScuccessCard: (keyCode, key)->
    self = fimplus._addCard
    element = $(self.data.id)
    console.info 'added card success:' + keyCode
    self.data.successCard = false
    if keyCode in [key.ENTER, key.RETURN]
      if self.data.success()
#        element.find('.add-card').removeClass('fadeIn').addClass('fadeOut')
        element.html('')
        fimplus._setting.removePage()
        self.data.success()
        return

      self.removePage()
    # self.removePage()
    # fimplus._settingMethod.initPage()


  updateActive: (list, index, child)->
    self = @
    $(list).children(child).removeClass("active")
    nextActiveButton = $(list).children(child).get(index)
    $(nextActiveButton).addClass("active")

  ### format card number and date card###
  checkCardNumberOnChange: ()->
    self = @
    element = $("#add-card #card_number")
    cardIcon = $("#ic-type")
    onKeyNumberChange = ()->
      length = element.val().length
      # varible to check American Express
      isAm = false
      # check type card
      type = self.detectCardType(element.val())
      cardIcon.removeClass().addClass(type)
      self.data.brandCard = type
      if length >= self.data.lengthInputNumber
#
        unless isAm       
          if (length + 1) % 5 is 0
              element.val element.val() + ' '  
          if length > 19
            element.val(element.val().substring(0,19))
        else
          if length in [4,11] 
              element.val element.val() + ' '  
          # self.data.inputFocus = "#card_date"
          # to support click "continue" --> next back card
          # if self.checkCardNumber()
          #   self.data.settingMethodtitle = 'expiration-date'
          #   self.reRenderTitle()
          #   self.renderButton('cancleCard', 'button-back')
          #   self.setHightLightInput(self.data.inputFocus)
          #   self.focusInput(self.data.inputFocus, 'number')

      self.data.lengthInputNumber = element.val().length
    element.off 'change'
    element.on 'change', onKeyNumberChange

  detectCardType: (number) ->
    strCleared = number.replace(/\s/g, '')
    re =
      visa: /^4[0-9]{0,}$/
      mastercard: /^5[1-5][0-9]{5,}|222[1-9][0-9]{3,}|22[3-9][0-9]{4,}|2[3-6][0-9]{5,}|27[01][0-9]{4,}|2720[0-9]{3,}$/
      americanexpress: /^3[47][0-9]{0,}$/
      dinersclub: /^3(?:0[0-59]{1}|[689])[0-9]{0,}/
      discover: /^(6011|65|64[4-9]|62212[6-9]|6221[3-9]|622[2-8]|6229[01]|62292[0-5])[0-9]{0,}$/
      jcb: /^(?:2131|1800|35)[0-9]{0,}$/
    for key of re
      if re[key].test(strCleared)
        return key
    return

  # format expiration date
  checkExpirationDate: ()->
    self = @
    inputDate = $("#add-card #card_date")
    onKeyDateChange = ()->
      length = inputDate.val().length
      if length >= self.data.lengthInputDate
        if inputDate.val().length is 2
          if inputDate.val() > 12 or inputDate.val() <= 0
            inputDate.val() inputDate.val(null)
          inputDate.val inputDate.val() + '/'
        if inputDate.val().length is 5
          year = inputDate.val().substr(3,4)
          currentDate = new Date()
          currentYear = currentDate.getFullYear()
          currentYearFormat = currentYear.toString().substr(2,3);
          if year < currentYearFormat
            inputDate.val inputDate.val().substr(0,3)
        if inputDate.val().length > 5
          inputDate.val(inputDate.val().substring(0,4))
      self.data.lengthInputDate = inputDate.val().length
    inputDate.off 'change'
    inputDate.on 'change', onKeyDateChange

  checkCVV: ()->
    self = @
    inputCVV = $("#add-card #card_cvc")
    lengthDefault = inputCVV.val().length
    onKeyCVVChange = ()->
      if inputCVV.val().length > 4
        inputCVV.val(inputCVV.val().substring(0,4))
      
    inputCVV.off 'change'
    inputCVV.on 'change', onKeyCVVChange     
  
  focusCardNumber: ()->
    self = fimplus._addCard
    self.initKey()
    self.focusInput("#card_number", 'number')
    self.removeFocus()
  
  focusCardDate: ()->
    self = fimplus._addCard
    self.initKey()
    self.focusInput("#card_date", 'number')
    self.removeFocus()

  focusCardCVV: ()->
    self = fimplus._addCard
    self.initKey()
    self.focusInput("#card_cvc", 'number')
    self.removeFocus()
    

  checkCardNumber: ()->
    cardNum = $("#card_number")
    str = ''
    self = fimplus._addCard
    patt = new RegExp("^[0-9 ]+$");
    res = patt.test(cardNum.val());
    str = cardNum.val().replace(/\s/g, '')
    if  str.length < 12 or str.length > 19 or !res
      fimplus._error.initPage({
        title      : 'visa-error-invalid_number'
        onReturn   : self.focusCardNumber
        description: 'visa-error-invalid_number'
        buttons    : [
          title   : 're-enter'
          callback: self.focusCardNumber
        ]
      });
      return false
    return true

  # check format expiration date
  checkCardDate: ()->
    cardDate = $("#card_date")
    str = ''
    self = fimplus._addCard
    patt = new RegExp("^[0-9\/]+$");
    res = patt.test(cardDate.val());
    year = cardDate.val().substr(3,4)
    month = cardDate.val().substr(0,2)
    if !res
      fimplus._error.initPage({
        title      : 'visa-error-invalid_expiry_date'
        onReturn   : self.focusCardDate
        description: 'visa-error-invalid_expiry_date'
        buttons    : [
          title   : 're-enter'
          callback: self.focusCardDate
        ]
      });
      return false
    # wrong month
    if month <= 0 or month > 12
      fimplus._error.initPage({
        title      : 'visa-error-invalid_expiry_month'
        onReturn   : self.focusCardDate
        description: 'visa-error-invalid_expiry_month'
        buttons    : [
          title   : 're-enter'
          callback: self.focusCardDate
        ]
      });
      return false
    currentDate = new Date()
    currentYear = currentDate.getFullYear()
    currentYearFormat = currentYear.toString().substr(2,3);

    # wrong year
    if year < currentYearFormat
      fimplus._error.initPage({
        title      : 'visa-error-invalid_expiry_year'
        onReturn   : self.focusCardDate
        description: 'visa-error-invalid_expiry_year'
        buttons    : [
          title   : 're-enter'
          callback: self.focusCardDate
        ]
      });
      return false
    return true

  checkCardCVV: ()->
    cardCVV = $("#card_cvc")
    self = fimplus._addCard
    patt = new RegExp("^[0-9]+$");
    res = patt.test(cardCVV.val());
    length = cardCVV.val().length
    if (length != 3 and length != 4) or !res
      fimplus._error.initPage({
        title      : 'visa-error-invalid_cvc'
        onReturn   : self.focusCardCVV
        description: 'visa-error-invalid_cvc'
        buttons    : [
          title   : 're-enter'
          callback: self.focusCardCVV
        ]
      });
      return false
    return true


  initKey: ()->
    fimplus.KeyService.initKey(fimplus._addCard.handleKey)
  
  setActiveButton    : (current, length)->
    self = @
    self.data.onFocus = true
    button = $(self.data.id).find('.add-card-menu').find('li')
    current = fimplus.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current

  onActiveEntity: (type = 'DOWN')->
    self = fimplus._addCard
    switch type
      when 'DOWN'
        if !self.data.positionEntity.active
#          self.setActiveButton(self.data.currentActive, self.data.buttons.length)
          self.data.positionEntity.active = true
          self.data.onFocus = true
          $(self.data.id).find('.add-card-menu').find('li').first().addClass('active')
      when 'UP'
        fimplus._backButton.setActive(true, self.handleBackbutton)
        fimplus._keyboard.setActiveKeyboard(0, 0, false)

#  onActiveEntity: ()->
#    self = fimplus._addCard
#    if !self.data.positionEntity.active
#      length = $(self.data.id).find('.add-card-menu').find('li').length
#      self.setActiveButton(self.data.currentActive, length)
#      self.data.positionEntity.active = true
#      return
#    fimplus._keyboard.onBackBoardButton()

  reRenderTitle: ()->
    self = @
    lang = fimplus.UserService.getValueStorage('userSettings', 'language')
    value = fimplus.LanguageService.convert(self.data.settingMethodtitle, lang)
    $("#add-card-title").text(value)
    # template = Handlebars.compile(source)
    # $("#add-card-title").html(template({settingMethodtitle: self.data.settingMethodtitle}))

  renderKeyboard: (inputId, type)->
    self = @
    self.data.positionEntity.active = false
    element = $('.register-otp-keyboard')
    input = $(inputId)
    fimplus._keyboard.render(element, input, self.onActiveEntity, type)

  updateCard: () ->
    self = @
    tryAgain = ()->
      fimplus.KeyService.initKey(self.handleKeyCVC)
      self.data.inputFocus = "#card_cvc"
      self.focusInput(self.data.inputFocus, 'number')
      self.setHightLightInput(self.data.inputFocus)
      self.removeFocus()
    exitApp = ()->
      # fimplus._error.destroyPage()
      fimplus._addCard.removePage()
      # fimplus._page.initPage()

    Stripe.setPublishableKey fimplus.config.paymentInfo.stripe_key
    stripeResponseHandler = (status, response) ->
      console.log response
      if response.error
        $(".wrap-loading").hide()
        # ErrorService.log(response.error)
        self.data.cardFail = true
        # notice fail key

        fimplus._error.initPage({
          title      : "add-credit-card-fail"
          description: 'visa-error-card_declined'
          buttons    : [
            title   : 'button-try-again'
            callback: tryAgain
          ,
            title   : 'button-cancel'
            callback: exitApp
          ]
        });

        # if !$scope.$$phase then $scope.$apply()
        try
          # $scope.Failmessage = $rootScope.text("visa-error-#{response.error.code}")
        catch e
        ### show error here ###
      else
        token = response.id
        updateCreditcardDone = (error, result) ->
          $(".wrap-loading").hide()
          if error
            console.log 'Add card fail'
            fimplus._error.initPage({
              title      : "add-credit-card-fail"
              description: 'visa-error-card_declined'
              buttons    : [
                title   : 'button-try-again'
                callback: tryAgain
              ,
                title   : 'button-cancel'
                callback: exitApp
              ]
            });
          else
            self.data.cardFail = false
            self.data.successCard = true
            self.data.backVisa = false
            self.data.settingMethodtitle = 'connect-visa-success'
            console.log 'Add card success'
            console.log result
            self.data.resultCard = response
            self.data.sourceId = result.sourceId
            self.data.expMonthCard = self.data.resultCard.card.exp_month
            if self.data.expMonthCard > 0 and self.data.expMonthCard < 10
              self.data.expMonthCard = '0' + self.data.expMonthCard
            self.data.expYearCard = self.data.resultCard.card.exp_year.toString().substr(2,3)
            self.render()
            $("#ic-type").addClass(self.data.brandCard);
            fimplus.KeyService.initKey(self.handleKeyScuccessCard)

          # if onlySync
          #   console.log 'onlySync'
          # else
          #   if buyPackage is 'true'
          #     console.log 'buyPackage'
          #     $rootScope.steppackage = 2
          #     $rootScope.paymentMethodSync = 1
          #     $state.go 'paymentBuyPackage', {location : 'replace'}
          #   else
          #     $state.go 'paymentRentMovie', {id : $rootScope.detail.id}, {location : 'replace'}
          # return
        fimplus.ApiService.updateCreditcard(token, updateCreditcardDone)
      return
    Stripe.card.createToken(self.data.cardInfo, stripeResponseHandler)
  
  getSourceId: ()->
    self = fimplus._addCard
    if self.data.sourceId
      return self.data.sourceId

  removePage: ()->
    self = @
    element = $(self.data.id)
    self.data.backVisa = false
    self.data.cardFail = false
    self.data.successCard = false
    self.data.inputFocus = "#card_name"
    self.data.settingMethodtitle = 'full-name'
    
    element.find('.add-card').removeClass('fadeIn').addClass('fadeOut')
    setTimeout(()->
      element.html('')
    , 500)
    self.data.callback() if _.isFunction(self.data.callback)
  
# $("#card_date").on('keyUp', function(){
#   fimplus._addCard.updateDate()
# })
