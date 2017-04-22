pateco._main =
  element : $('#main-app')
  data :
    menu : []
  initPage : ()->
    self = @
    source = Templates['module.main']()
    template = Handlebars.compile(source)
    self.element.html(template)
    pateco._home.initPage()
    self.getDataMenu(()->
      self.renderMenuHeader()
    )

  renderMenuHeader:()->
    self = @
    source = Templates['module.main.menu']()
    template = Handlebars.compile(source)
    $('#menu').html(template({menu:self.data.menu}))


  getDataMenu : (callback = null)->
    self = @
    pateco.ApiService.getMenu('menu',(error, result)->
      unless result
        callback() if _.isFunction(callback)
        return
      self.data.menu = result.menu
      console.log 'self.data.menu',self.data.menu
      callback() if _.isFunction(callback)
    )

  removePage : ()->

