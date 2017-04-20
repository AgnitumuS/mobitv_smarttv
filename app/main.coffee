initApp = ()->
  logoScreenEl = $('.logo_slashscreen')
  logoScreenEl.show()
  console.info 'pateco.config', pateco.config
  setTimeout(()->
    logoScreenEl.addClass('animated fadeOut')
  , 1000)
  setTimeout(()->
    pateco._page.initPage()
  , 1500)

$(document).ready(()->
  console.info 'app ready'
  initApp()
)