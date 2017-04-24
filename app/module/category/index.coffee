#category khi click xem tat ca item of ribbon
# vi du Truyền Hình Nổi Bật; TV Show ... o trang chu
pateco._category =
  elemment : '#category'
  data :
    category : {}
    indexItemActive:[]
    items : []
    pagination :
      limit : 20
      offset : 0
    callback : ()->

  initPage : (category, callback)->
    self=@
    self.data.category = category
    self.data.callback = callback if _.isFunction(callback)
    self.getData(()->
      self.render()
      self.initKey()
      self.setItemActive()
    )

  removePage : ()->
    self = pateco._category
    $(self.element).html('')
    self.data.callback() if _.isFunction(self.data.callback)


  onReturnCategoryPage:()->
    self = pateco._category
    self.element.show()
    self.initKey()

  setItemActive:()->

  initKey:()->
    self = @
    pateco.KeyService.initKey(self.handleKey)

  handleKey: (keyCode, key)->
    self = pateco._category
    console.info 'category Key:' + keyCode
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

  handleKeyUp : ()->
  handleKeyDown : ()->
  handleKeyLeft : ()->
  handleKeyRight : ()->
  render : ()->

  getData:(callback = null)->
    self = @
    params =
      id : self.data.category.id
    pateco.ApiService.getPage(params,(error, result)->
      return unless result
      self.data.items = result.items
      callback() if _.isFunction(callback)
    )

