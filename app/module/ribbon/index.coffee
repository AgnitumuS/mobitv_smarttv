fimplus._ribbon =
  data:
    id        : '#ribbon'
    sliderWrap: '.slider-wrap'
    template  : Templates['module.ribbon']()
  
  addViewMoreButton: (ribbon)->
#    console.log ribbon
    _.map ribbon, (item, i)->
      delete ribbon[i] if item is null
      item.currentActive = 0
      viewmore = _.extend {}, fimplus.config.viewmoreButton
      viewmore.categoryId = item.categoryId
      viewmore.categoryType = item.categoryType
      viewmore.pageId = item.pageId
      viewMoreRibbon = ''
      lang = JSON.parse(localStorage.userSettings).language
      if lang is 'vi'
        viewMoreRibbon = 'https://ast.fimplus.io/files/xem-them_1488968348945.png'
      else
        viewMoreRibbon = 'https://ast.fimplus.io/files/view-more_1492485660763.png'

      viewmore.posterLandscape = viewMoreRibbon
      if item.totalItems > 6 or item.items.length > 5
        item.items = item.items.slice(0, 6)
        item.items.push viewmore
    
    return ribbon
  
  render: (ribbon = {}, currentRibbonIndex = 0, activePointer = true)->
    self = @
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $('#ribbon')
    self.displayRibbon(false)
    self.element.html(template({ribbon: ribbon, activePointer: activePointer}))
    self.setRibbonPosition(currentRibbonIndex)
    
    setTimeout(()->
      fimplus._ribbon.displayRibbon()
      self.initActivePointer()
    , 500)
  
  onItemClick: (done)->
    done = done or ()-> console.log 'on item click'
    elementEnity = $('#ribbon').find('.entity-view')
    elementEnity.off 'click'
    elementEnity.on 'click', done
  
  displayRibbon: (active = true)->
    self = fimplus._ribbon
    self.element = $('#ribbon')
    if active
      self.element.show()
    else
      self.element.hide()
  
  initActivePointer: (current = 0)->
    self = fimplus._ribbon
    
    entityDetail = self.element.find('.entity-view').eq(current)
    width = entityDetail.outerWidth()
    height = entityDetail.outerHeight()
    pointer = self.element.find(".active-image")
    css =
      width : width
      height: height
    
    pointer.css(css)
  
  setRibbonPosition  : (current = 0)->
    self = @
    clearTimeout(self.data.timeouSetCurrenRibbon)
    self.data.timeouSetCurrenRibbon = setTimeout(()->
      items = self.element.find(self.data.sliderWrap)
      items.map (index)->
        value = index - current
        if value < -1 or value > 2
          display = 'none'
        else
          display = 'block'
        css =
          transform          : "translateY(#{value * 100}%)"
          '-webkit-transform': "translateY(#{value * 100}%)"
        
        items.eq(index).css(css)
    , 200)
  removeActivePointer: ()->
    $('.active-image').hide()
  
  setActivePointer: (ribbon, currentRibbonIndex = 0)->
    self = fimplus._ribbon
    activeRibbon = ribbon[currentRibbonIndex]
    
    current = activeRibbon.currentActive || 0
    deactivePointer = activeRibbon.items[current].deactive
    element = $("#{self.data.id} #{self.data.sliderWrap}").eq(currentRibbonIndex)
    activeIndex = 0
    max = 4
    length = activeRibbon.items.length
    if max > length
      max = length
    if current > length - max
      activeIndex = max + current - length
      current = length - max
    
    data = "translate(-#{current * 100 / length}%,0%)"
    element.find('.home-slider').css({
      
      "will-change"      : 'transform'
      "transform"        : data
      "-webkit-transform": data
      "-ms-transform"    : data
      "-moz-transform"   : data
      "-o-transform"     : data
    })
    #    $('.active-image').css({display: 'none'})
#    color = "#fff"
#    if deactivePointer
#      color = "#aba7a5"
#    self.element.find('.active-border').css({
#      'outline-color': color
#    })
    dataCsss = "translateX(#{activeIndex * (100)}%)"
    self.element.find('.active-image').css({
      display            : 'block'
      "transform"        : dataCsss
      "-webkit-transform": dataCsss
      "-ms-transform"    : dataCsss
      "-moz-transform"   : dataCsss
      "-o-transform"     : dataCsss
    })
    null