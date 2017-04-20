initApp = ()->
  logoScreenEl = $('.logo_slashscreen')
  logoScreenEl.show()
  console.info ' fimplus.config', fimplus.config
  setTimeout(()->
    logoScreenEl.addClass('animated fadeOut')
  , 2500)
  
  setTimeout(()->
    if fimplus.UtitService.getFlashScreenWelcome() is true
      fimplus._page.initPage()
    else
      fimplus._welcome.initPage()
  , 3000)

$(document).ready(()->
  console.log 'app ready'
  
  async.parallel([
      fimplus.UserService.getWatchLater
    ],
    initApp)
)