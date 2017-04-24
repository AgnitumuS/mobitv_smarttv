pateco._home =
  element : '#home'
  data :
    ribbon : []
    indexRibbonActive : 0 #index of ribbon is Current [1...ribbon.length()]
    timeouSetCurrenRibbon:0
    layoutActive : 'ribbon' # 'menu_header'  ribbon   menu_left
    callback : ()->

  initPage:()->
    self=pateco._home
    self.getData(()->
      self.render()
      self.initKey()
      self.setRibbonPosition(self.data.indexRibbonActive)
      self.setActiveItemOfRibbon(self.data.indexRibbonActive,self.getIndexItemActiveOfRibbon() )
    )

  removePage:()->
    console.log 'remove page & call callback pre page'
    self=pateco._home
    $(self.element).html('')


  getData:(callback = null)->
    addItemCategoryViewmore = (result)->
      i=0
      while result.ribbon and i < result.ribbon.length
        if result.ribbon[i] and result.ribbon[i].total > 20
          itemViewmore =
            isCategoryViewmore : true
            imgLandscape : pateco.server+'images/category-viewmore.png'
            categoryId : result.ribbon[i].id
          result.ribbon[i].items.push(itemViewmore)
        i++
      self.data.ribbon = result.ribbon

    self = pateco._home
    pateco.ApiService.getHome((error, result)->
      return unless result
      addItemCategoryViewmore(result)
      i=result.banner.length
      while result.banner and i > 0
        self.data.ribbon.unshift(result.banner[i-1]) if result.banner[i-1]
        i--
#      if result.banner
#        self.data.ribbon.unshift(result.banner[1]) if result.banner[1]
#        self.data.ribbon.unshift(result.banner[0]) if result.banner[0]
      i=0
      while i < self.data.ribbon.length
        self.data.ribbon[i].indexItemActive = 0
        i++
      console.log 'self.data.ribbon',self.data.ribbon
      callback() if _.isFunction(callback)
    )


  setActiveItemOfRibbon : (indexRibbon=0, indexItemOfRibbon = 0)->
    self = pateco._home
    $('#home').find('.wrapper-ribbon').find('.ribbon-item').removeClass('active')
    elementRibbonActive = $('#home').find('.wrapper-ribbon').eq(indexRibbon)
    eleItemActive = elementRibbonActive.find('.ribbon-item').eq(indexItemOfRibbon)
    eleItemActive.addClass('active')
    clienWidth = eleItemActive[0].clientWidth
    number = Math.floor(indexItemOfRibbon/4)
    lengthToScoll = number*(clienWidth*4)
    elementRibbonActive.find('.wrap-ribbon-items').animate({'scrollLeft':"#{lengthToScoll}px"}, 100)



  setRibbonPosition : (current = 0)->
    self = pateco._home
    clearTimeout(self.data.timeouSetCurrenRibbon)
    self.data.timeouSetCurrenRibbon = setTimeout(()->
      items = $('#home').find('.wrapper-ribbon')
      items.map (index)->
        css =
          'transform'          : "translateY(#{-current * 100}%)"
          '-webkit-transform'  : "translateY(#{-current * 100}%)"
          '-webkit-transition-duration': '0.3s'
          'transition-duration': '0.3s'
        items.eq(index).css(css)
    , 100)

  getIndexItemActiveOfRibbon : ()->
    self = @
    if self.data.ribbon and self.data.ribbon[self.data.indexRibbonActive]
      return self.data.ribbon[self.data.indexRibbonActive].indexItemActive
    return 0


  handleKeyLeft : ()->
    self=@
    if self.data.layoutActive is 'menu_header'
      if pateco._main.data.indexItemMenuActive > 0
        pateco._main.data.indexItemMenuActive--
        pateco._main.setItemMenuActive(pateco._main.data.indexItemMenuActive)
      return
    if self.data.layoutActive is 'ribbon'
      indexItemActive = self.getIndexItemActiveOfRibbon()
      if indexItemActive > 0
        self.data.ribbon[self.data.indexRibbonActive].indexItemActive--
        self.setActiveItemOfRibbon(self.data.indexRibbonActive,self.getIndexItemActiveOfRibbon() )
      return

  handleKeyRight : ()->
    self=@
    if self.data.layoutActive is 'menu_header'
      if pateco._main.data.indexItemMenuActive < pateco._main.data.menu.length-1
        pateco._main.data.indexItemMenuActive++
        pateco._main.setItemMenuActive(pateco._main.data.indexItemMenuActive)
      return
    if self.data.layoutActive is 'ribbon'
      indexItemActive = self.getIndexItemActiveOfRibbon()
      if indexItemActive < self.data.ribbon[self.data.indexRibbonActive].items.length-1
        self.data.ribbon[self.data.indexRibbonActive].indexItemActive++
        self.setActiveItemOfRibbon(self.data.indexRibbonActive, self.getIndexItemActiveOfRibbon() )
      return

  handleKeyUp : ()->
    self = @
    if self.data.layoutActive is 'ribbon' and self.data.indexRibbonActive is 0
      self.data.layoutActive = 'menu_header'
      pateco._main.setItemMenuActive(pateco._main.data.indexItemMenuActive)
      return
    if self.data.layoutActive is 'ribbon'
      if self.data.indexRibbonActive > 0
        self.data.indexRibbonActive--
        self.setRibbonPosition(self.data.indexRibbonActive)
        self.setActiveItemOfRibbon(self.data.indexRibbonActive,self.getIndexItemActiveOfRibbon() )
      return

  handleKeyDown : ()->
    self=@
    if self.data.layoutActive is 'menu_header'
      self.data.layoutActive = 'ribbon'
      pateco._main.removeClassMenuActive()
      self.data.indexRibbonActive = 0
      self.setRibbonPosition(self.data.indexRibbonActive)
      self.setActiveItemOfRibbon(self.data.indexRibbonActive,self.data.ribbon[self.data.indexRibbonActive].indexItemActive )
      return
    if self.data.layoutActive is 'ribbon'
      if self.data.indexRibbonActive < (self.data.ribbon.length - 1)
        self.data.indexRibbonActive++
        self.setRibbonPosition(self.data.indexRibbonActive)
        self.setActiveItemOfRibbon(self.data.indexRibbonActive,self.getIndexItemActiveOfRibbon() )
      return

  handleKeyEnter : ()->
    self=@
    if self.data.layoutActive is 'menu_header'
      itemMenu = pateco._main.data.menu[pateco._main.data.indexItemMenuActive]
      console.log 'enter menu',itemMenu
      pateco._page.initPage(itemMenu, self.onReturnHomePage)
      return
    if self.data.layoutActive is 'ribbon'
      itemDetail = self.data.ribbon[self.data.indexRibbonActive].items[self.getIndexItemActiveOfRibbon() ]
      self.removePage()
      if itemDetail and itemDetail.isCategoryViewmore is true
        console.log 'open category viewmore:',itemDetail
        pateco._category.initPage(itemDetail, self.onReturnHomePage)
        return
      console.log 'enter detail:',itemDetail
      pateco._detail.initPage(itemDetail, self.onReturnHomePage) if itemDetail
      return



  handleKey: (keyCode, key)->
    self = pateco._home
    console.info 'Home Key:' + keyCode
    switch keyCode
      when key.RIGHT
        self.handleKeyRight()
        break;
      when key.LEFT
        self.handleKeyLeft()
        break;
      when key.DOWN
        self.handleKeyDown()
        break;
      when key.UP
        self.handleKeyUp()
        break;
      when key.ENTER
        self.handleKeyEnter()
        break;
      when key.RETURN
        break;


  initKey:()->
    self = pateco._home
    pateco.KeyService.initKey(self.handleKey)

  onReturnHomePage:()->
    self = pateco._home
    console.log 'next page & set callback return function'
    self.render()
    self.initKey()
    self.setRibbonPosition(self.data.indexRibbonActive)
    self.setActiveItemOfRibbon(self.data.indexRibbonActive,self.getIndexItemActiveOfRibbon() )

  render:()->
    self = pateco._home
    source = Templates['module.home']()
    template = Handlebars.compile(source)
    $(self.element).html(template({ribbon: self.data.ribbon }))
