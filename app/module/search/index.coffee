pateco._search =
  data:
    id            : '#search'
    template      : Templates['module.search']()
    dataSearch    : null
    keySearch     : null
    ribbon        : []
    layout        : 'keyboard' # keyboard, suggest , result
    suggest       :
      currentActive: 0
      items        : []
      transition   : 0
    positionEntity:
      length : 0
      active : false
      col    : 0
      row    : 0
      current: 0
      maxCol : 4
  
  initPage: (callback)->
    self = pateco._search
    self.data.layout = 'keyboard'
    self.data.callback = ()->
      console.log 'detail callback show homepage'
    self.data.callback = callback if _.isFunction(callback)
    self.render()
    self.setNotifySearch(1, true)
    self.initEventSearchOnchange()
    self.renderKeyboard()
    self.renderSuggest()
    self.getSuggestData()
    pateco._backButton.enable()
    pateco._keyboard.setActiveKeyboard(0, 0)
  
  getSuggestData: ()->
    self = pateco._search
    done = (error, result)->
      if error
        return
      data = _.flatten(_.pluck result.sections, 'tiles')
      self.data.suggest.items = data
      self.renderSuggest()
    pateco.ApiService.getSuggestionSearch(done)
  
  renderSuggest: ()->
    self = pateco._search
    suggest = self.element.find('.search-suggest')
    self.data.suggest.currentActive = 0
    source = Templates['module.search.result-suggest']()
    template = Handlebars.compile(source);
    suggest.html(template(self.data.suggest))
  
  setSuggestActive: (active = true)->
    self = pateco._search
    length = self.data.suggest.items.length
    
    self.data.suggest.currentActive = pateco.KeyService.reCalc(self.data.suggest.currentActive, length)
    suggestEl = self.element.find('.search-suggest-content')
    suggestItem = suggestEl.find('li')
    oldIndex = suggestEl.find('.active').index()
    suggestItem.removeClass('active')
    #    $('.search-suggest-content li:eq(1)~')
    return unless active
    suggestItem.eq(self.data.suggest.currentActive).addClass('active').show()
    
    if length - self.data.suggest.currentActive > 2
      if  self.data.suggest.currentActive > oldIndex
        previewItem = suggestItem.eq(self.data.suggest.currentActive - 1)
        width = previewItem.outerWidth()
        self.data.suggest.transition += width
      else
        previewItem = suggestItem.eq(self.data.suggest.currentActive)
        width = previewItem.outerWidth()
        self.data.suggest.transition -= width
    
    self.data.suggest.transition = 0 if self.data.suggest.currentActive is 0
    dataTransition = "translateX(-#{self.data.suggest.transition}px)"
    
    suggestEl.css({
      transform          : dataTransition
      '-webkit-transform': dataTransition
      
    })
#      previewItem.css({opacity: 0})
  
  renderKeyboard: ()->
    self = pateco._search
    board = self.element.find('.search-keyboard')
    input = self.element.find('#inputSearch')
    pateco._keyboard.render(board, input, self.onActiveEntity, 'text')
  
  setNotifySearch: (type = 1, active = true)->
    types = [
      "search-empty"
      "searc-text"
    ]
    self = pateco._search
    notify = self.element.find('.search-notify')
    lang = pateco.UserService.getValueStorage('userSettings', 'language')
    types[type] = pateco.LanguageService.convert(types[type], lang)
    notify.html(types[type])
    
    if active
      notify.show()
    else
      notify.hide()
  
  onActiveEntity: (key = 'DOWN')->
    self = pateco._search
    if key is 'DOWN'
      if $('#result-search').find('.entity-detail').length <= 0
        pateco._keyboard.onBackBoardButton()
        return
      self.slideKeyBoard('hide')
      positionEntity = self.data.positionEntity
      if positionEntity.length > 0
        self.data.layout = 'result'
        self.initActivePointer()
        self.setActivePointer(positionEntity.col, positionEntity.row)
        return
    if key is 'UP'
      if self.data.suggest.items.length is 0
        pateco._keyboard.onBackKeyboard()
        return
      self.slideKeyBoard('hide')
      self.data.layout = 'suggest'
      self.setSuggestActive()
  
  
  initActivePointer: (current = 0)->
    self = pateco._search
    entityDetail = self.element.find('.entity-detail').eq(current)
    width = entityDetail.outerWidth()
    height = entityDetail.outerHeight()
    pointer = self.element.find('.active-pointer')
    css =
      width : width
      height: height
    
    pointer.css(css)
  
  setActivePointer: (col = 0, row = 0, active = true)->
    self = @
    pointer = $("#{self.data.id} .active-pointer")
    resultSearch = $('#result-search')
    currentResultSearch = 0
    maxRow = 1
    if row > maxRow
      itemHeight = resultSearch.find('.entity-detail').outerHeight()
      currentResultSearch = itemHeight * (row - maxRow)
      row = maxRow
    
    resultSearch.css({
      transform: "translateY(-#{currentResultSearch}px)"
    })
    css =
      display  : if active then 'block' else 'none'
      transform: "translate(#{col * 100}%,#{row * 100}%)"
    pointer.css(css)
  
  
  renderListEntity: (data = {})->
    self = pateco._search
    return unless data.results
    self.data.ribbon = data.results
    source = Templates['module.search.result-search']()
    template = Handlebars.compile(source);
    self.data.positionEntity.length = data.results.length
    $('#result-search').html(template(data))
  
  onSearchValue: (value)->
    self = pateco._search
    unless value
      self.setNotifySearch(1, true)
      return
    
    doneSearch = (error, result)->
      if error
        pateco._error.initPage({
          onReturn   : ()->
            console.log 'exit'
          description: ['connect-error', '#1000']
          title      : 'notification'
          buttons    : [
            title   : 'button-try-again'
            callback: ()->
          ,
            title   : 'exit'
            callback: ()->
          ]
        })
        return
      self.data.dataSearch = result
      if result and result.results and result.results.length <= 0
        self.setNotifySearch(0, true)
      else
        self.setNotifySearch(0, false)
      self.renderListEntity(result)
      if value.length < 2
        if $('#result-search').find('.entity-detail').length <= 0
          self.setNotifySearch(1, true)
        return
    pateco.ApiService.search(value, doneSearch)
  
  initEventSearchOnchange: ()->
    self = @
    search = $("#{self.data.id} #inputSearch")
    onKeySearchChange = ()->
      unless search.val()
        $('#result-search').html('')
        $('.search-result').find('.search-notify').show()
        return
      if search.val() and search.val().length >= 50
        search.val( search.val().substr(0,50) )
      setTimeout(()->
        self.onSearchValue(search.val())
        self.data.keySearch = search.val()
      , 1)
    search.off 'change'
    search.on 'change', onKeySearchChange
  
  
  removePage: ()->
    self = @
    self.element.html('')
    pateco._page.addClassIntoIcBack(false)
    self.data.callback()
  
  render: ()->
    self = pateco._search
    source = self.data.template
    template = Handlebars.compile(source);
    self.element = $(self.data.id)
    self.element.html(template)
    self.initKey()
  
  slideKeyBoard: (type = 'show')->
    self = pateco._search
    searchBoard = self.element.find('.search-keyboard')
    #    suggestBoard = sellf.element.find('')
    setTimeout(()->
      if type is 'show'
        searchBoard.slideDown()
      else
        searchBoard.slideUp()
    , 100)
  
  hanldeBackbutton: (keyCode, key)->
    self = pateco._search
    switch keyCode
      when key.DOWN
        self.setSuggestActive(true)
        self.initKey()
      when key.RETURN,key.ENTER
        self.removePage()
  
  
  handleSuggestKey: (keyCode, key)->
    self = pateco._search
    console.info 'Search Suggest Key:' + keyCode
    switch keyCode
      when key.UP
        pateco._backButton.setActive(true, self.hanldeBackbutton)
        self.setSuggestActive(false)
        return;
      when key.DOWN
        self.data.layout = 'keyboard'
        self.slideKeyBoard()
        self.setSuggestActive(false)
        pateco._keyboard.onBackKeyboard()
        return;
      when key.LEFT
        if self.data.suggest.currentActive > 0
          self.data.suggest.currentActive--
        break;
      when key.RIGHT
        if self.data.suggest.currentActive < self.data.suggest.items.length - 1
          self.data.suggest.currentActive++
        break;
      when key.ENTER
        input = self.element.find('#inputSearch')
        value = self.data.suggest.items[self.data.suggest.currentActive].subtitle
        input.val(value)
        self.onSearchValue(value)
        break;
    
    self.setSuggestActive()
  
  handleKey: (keyCode, key)->
    self = pateco._search
    
    positionEntity = self.data.positionEntity
    if keyCode isnt key.RETURN
      if self.data.layout is 'keyboard'
        pateco._keyboard.handleKey(keyCode, key)
        return
      if self.data.layout is 'suggest'
        self.handleSuggestKey(keyCode, key)
        return
    console.info 'Search Key:' + keyCode
    switch keyCode
      when key.LEFT
        if positionEntity.current > 0
          positionEntity.current--
        break;
      
      when key.RIGHT
        if positionEntity.current < positionEntity.length - 1
          positionEntity.current++
        break;
      
      when key.DOWN
        positionEntity.current += positionEntity.maxCol
        if positionEntity.current > positionEntity.length - 1
          positionEntity.current = positionEntity.length - 1
        self.slideKeyBoard('hide')
        break;
      when key.ENTER
        self.openDetail()
        return;
      when key.UP
        if positionEntity.row is 0
          self.data.layout = 'keyboard'
          self.setActivePointer(positionEntity.col, positionEntity.row, false)
          pateco._keyboard.onBackBoardButton()
          self.slideKeyBoard('show')
          return;
        positionEntity.current -= positionEntity.maxCol
        positionEntity.current = 0 if positionEntity.current < 0
        break;
      when key.RETURN
        self.removePage()
    if keyCode in [key.LEFT, key.RIGHT, key.UP, key.DOWN]
      positionEntity.row = Math.floor(positionEntity.current / positionEntity.maxCol)
      positionEntity.col = positionEntity.current - positionEntity.row * positionEntity.maxCol
      self.data.positionEntity = positionEntity
      self.setActivePointer(positionEntity.col, positionEntity.row)
  
  initKey: ()->
    self = @
    pateco.KeyService.initKey(self.handleKey)
  
  setCurrentBanner: (inFirst = false)->
    self = @
    #    if inFirst
    currentBanner = pateco._banner.getCurrentBanner(self.data.ribbon, 0)
    currentBanner.model4K = pateco.config.appInfo.model4K if currentBanner
    console.log 'search setCurrentBanner', currentBanner
    if inFirst
      pateco._banner.render(currentBanner)
    else
      pateco._banner.reRender(currentBanner)
  
  onReturnPage: ()->
    self = pateco._search
    self.element.show()
    self.initKey()
  
  openDetail: ()->
    self = pateco._search
    self.element.hide()
    currentItem = self.data.ribbon[self.data.positionEntity.current]
    currentItem.model4K = pateco.config.appInfo.model4K if currentItem
#    console.log 'search openDetail=', currentItem
    pateco._banner.reRender(currentItem)
    pateco._detail.initPage(currentItem, self.onReturnPage)