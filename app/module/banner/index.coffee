Handlebars.registerPartial('homeBar', Templates['module.banner.home-main']());
Handlebars.registerPartial('detailButton', Templates['module.banner.detail-button']());

pateco._banner =
  data:
    banner       : {}
    id           : '#banner'
    sliderWrap   : '.slider-wrap'
    template     : Templates['module.banner']()
    currentBanner: {}
  
  reRender: (banner = {})->
    self = pateco._banner
    return if !banner or banner.id is self.data.banner
    self.data.banner = banner
    source = Templates['module.banner.home-main']()
    template = Handlebars.compile(source)
    self.element = $(self.data.id)
    self.element.find('.home-main').html(template(banner))
    currentTitleLangguage = pateco.UserService.getValueStorage('userSettings', 'movieTitleLanguage')
    if currentTitleLangguage is 'en' then banner.knownAs = banner.title
    doAnimation = ()->
      
      if pateco.config.state is 'detail'
        if banner.descriptionShort.length > 162
          self.activeLabelViewMore()
      #      typeAnimation = "500ms opacity cubic-bezier(.5, 0, .1, 1) 0s"
      parent = self.element.find('.img-wrapper')
      parent.find('img').not(":last-child").remove()
      oldBanner = self.element.find('.img-wrapper').find('img').eq(0)
      nextBanner = $("<img/>", {
        src  : if(banner and banner.image3x)then banner.image3x.bannerAppletv else banner.bannerAppletv
        style: "display:none"
      })
      newImg = new Image;
      onLoadSuccess = ()->
        nextBanner.appendTo(parent)
        nextBanner.fadeIn(1000)
        oldBanner.fadeOut(1000, ()->
          oldBanner.remove()
        )
      
      newImg.onerror = onLoadSuccess;
      newImg.onload = onLoadSuccess
      newImg.src = banner.image3x.bannerAppletv
    
    clearTimeout(self.data.timeRerender)
    self.data.timeRerender = setTimeout(doAnimation, 1000)
  
  
  render: (banner = {})->
    self = @
    self.data.banner = banner
    currentTitleLangguage = pateco.UserService.getValueStorage('userSettings', 'movieTitleLanguage')
    if currentTitleLangguage is 'en' then banner.knownAs = banner.title
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id);
    self.element.html(template(banner))
  
  
  activeLabelViewMore: (active)->
    self = pateco._banner
    viewmore = self.element.find('.description .description-viewmore')
    viewmore.hide()
    if pateco.config.state is 'detail'
      return viewmore.show()
    if active is true
      return viewmore.show()
  
  
  setEventClickButton: (callback)->
    self = @
    onClick = ()->
      callback($(@).index())
    button = $(self.data.id).find('.detail-buttons').find('li')
    button.off('click').on('click', onClick)
  
  setActiveButton: (current = 0, length = 0)->
    self = @
    button = $(self.data.id).find('.detail-buttons').find('li')
    current = pateco.KeyService.reCalc(current, length)
    button.removeClass('active').eq(current).addClass('active')
    return current
  
  removeButton: ()->
    self = @
    self.element.find('.timeRecents').show()
    self.element.find('.detail-buttons').html('')
  
  renderButton: (data = {})->
    self = @
    self.element.find('.timeRecents').hide()
    source = Templates['module.banner.detail-button']()
    template = Handlebars.compile(source);
    self.element.find('.detail-buttons').html(template(data))
    self.element.find('.detail-buttons ul.bt-movie-detail').hide().slideDown()
  
  
  getCurrentBanner: (ribbon = {}, currentRibbonIndex)->
    self = @
    model = ribbon[currentRibbonIndex] || {}
    return if _.isEmpty(model)
    index = model.currentActive || 0
    currentBanner = model.items[index] if model.items
    return if _.isEmpty(currentBanner)
    if currentBanner and currentBanner.id isnt self.data.currentBanner.id
      self.data.currentBanner = currentBanner
    return self.data.currentBanner
  