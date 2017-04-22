pateco._home =
  element : $('#home')
  data :
    banner : []
    ribbon : []
    activeRibbonIndex : 0
    callback : ()->

  initPage:()->
    self=@
    self.getData(()->
      self.render()
      self.initKey()
    )

  removePage:()->
   console.log 'remove page & call callback pre page'

  show:()->
    self = @
    self.element.show()

  hide:()->
    self = @
    self.element.hide()

  getData:(callback = null)->
    self = @
    pateco.ApiService.getHome((error, result)->
      return unless result
      self.data.ribbon = result.ribbon
      self.data.banner = result.banner
      console.log 'self.data.banner',self.data.banner
      console.log 'self.data.ribbon',self.data.ribbon
      callback() if _.isFunction(callback)
    )

  handleKey: (keyCode, key)->
    self = @
    console.info 'Home Key:' + keyCode
    switch keyCode
      when key.LEFT
        break;
      when key.RIGHT
        break;
      when key.DOWN
        break;
      when key.ENTER
        break;
      when key.UP
        clearTimeout(self.data.timeouSetCurrenRibbon)
        self.data.timeouSetCurrenRibbon = setTimeout(()->
          items = self.element.find('.wrapper-banner')
          items.map (index)->
            value = index - current
            css =
              transform          : "translateY(#{value * 100}%)"
              '-webkit-transform': "translateY(#{value * 100}%)"
            items.eq(index).css(css)
        , 200)
        break;
      when key.RETURN
        break;


  initKey:()->
  callbackReturnPage:()->
    console.log 'next page & set callback return function'

  render:()->
    self = @
    source = Templates['module.home']()
    template = Handlebars.compile(source)
    $('#home').html(template({banner : self.data.banner, ribbon: self.data.ribbon }))
