pateco._main =
  element : $('#main-app')
  data :
    menu : []
    indexItemMenuActive : 0
  initPage : ()->
    self = @
    source = Templates['module.main']()
    template = Handlebars.compile(source)
    self.element.html(template)
    pateco._home.initPage()
    self.getDataMenu(()->
      self.renderMenuHeader()
    )

  removeClassMenuActive : ()->
    $('#menu').find('ul.menu li').removeClass('active')


  setItemMenuActive : (indexItemMenuActive = 0)->
    return if indexItemMenuActive > pateco._main.data.menu.length-1
    items = $('#menu').find('ul.menu li')
    items.removeClass('active')
    items.eq(indexItemMenuActive).addClass('active')
    clientWidth = items.eq(indexItemMenuActive)[0].clientWidth
#    console.log 'clientWidth',clientWidth
    if indexItemMenuActive > 5
      lengthToScroll = clientWidth*indexItemMenuActive
      $('#menu').find("ul.menu").animate({"scrollLeft": lengthToScroll+"px"}, 100)
    else if indexItemMenuActive <= 5
      $('#menu').find("ul.menu").animate({"scrollLeft": "0px"}, 100)


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

