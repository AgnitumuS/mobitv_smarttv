fimplus._welcome =
  initPage: ()->
    source = Templates['module.welcome']()
    template = Handlebars.compile(source);
    triggerTimeout = null
    callbackAlready = false
    data =
      title          : 'intro-welcome'
      text           : 'intro-welcome-1'
      welcomeText    : 'title-welcome'
      welcomeTextLine: 'title-welcome-1'
      galaxy         : 'galaxy-family'
      background     : 'https://ast.fimplus.io/files/splashtv_1492575091272.jpg'
    
    turnOfWelcome = ()->
      $('#welcome').removeClass('fadeIn').addClass('fadeOut')
      setTimeout(()->
        $('#welcome').hide()
      , 2000)
      fimplus._page.initPage()
      fimplus.UtitService.setFlashScreenWelcome()

    triggerOffScreen = ()->
      $('.current-progress').css
        width: '100%'
      setTimeout(turnOfWelcome, 5000)
    
    doneLoadImage = ()->
      if callbackAlready
        return
      callbackAlready = true
      clearTimeout(triggerTimeout)
      $('#main-app').html(template(data))
      $('#welcome').addClass('fadeIn')
      setTimeout(triggerOffScreen, 100)
      null
    triggerTimeout = setTimeout(()->
      doneLoadImage()
    , 2000)
    
    fimplus.UtitService.loadImage(data.background, doneLoadImage)
    