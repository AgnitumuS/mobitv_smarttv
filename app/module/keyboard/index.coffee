Handlebars.registerHelper 'checkColSpan', (value)->
  switch value
    when '#+-','abc'
      col = 2
    else
      col = 1
  return col

Handlebars.registerHelper 'filterKeyboard', (value)->
  lang = fimplus.UserService.getValueStorage('userSettings', 'language')
  switch value
    when 'shift'
      value = "<i class='icon ic-shift'></i>"
    when 'space'
      value = "<i class='icon ic-space'></i>"
    when 'delete'
      value = fimplus.LanguageService.convert('key-delete', lang)
    when 'deleteAll'
      value = fimplus.LanguageService.convert('key-delete-all', lang)
  
  return value

fimplus._keyboard =
  data:
    template      : Templates['module.keyboard']()
    currentBoard  : 'text'
    layout        : 'board' # board, button
    positionButton: 0
    input         : null
    boardType     : 'lowercase' #'uppercase'
    callback      : ()->
    
    positionKey   :
      col: 0
      row: 0
    buttons       : ['space', 'delete', 'deleteAll']
    buttonsNoSpace: ['delete', 'deleteAll']
    text          : [
      ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm']
      ['n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']
      ['1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '#+-', 'shift']
    ],
    special       : [
      ['-', '/', ':', ';', '(', ')', '$', '&', '@', '"', '*', '+', '=']
      ['[', ']', '{', '}', '#', '%', '^', ',', '?', '!', '\'', '.', '_']
      ['\\', '|', '~', '<', '>', '€', '£', '¥', '•', 'abc', 'shift']
    ],
    number        : [
      ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
    ]
  
  
  render: (element, input = null, callback, type = 'text')->
    self = @
    self.data.input = input
    self.data.element = element
    self.data.callback = ()->
    self.data.positionKey =
      col: 0
      row: 0
    if _.isFunction(callback)
      self.data.callback = callback
    self.reRender(type)
  
  reRender: (type)->
    self = @
    self.data.currentBoard = type
    source = self.data.template
    if type isnt 'number'
      board =
        key   : self.data[type]
        button: self.data.buttons
    else
      board =
        key   : self.data[type]
        button: self.data.buttonsNoSpace
    template = Handlebars.compile(source);
    self.data.element.html(template(board))
    self.initEventClick()
  
  onEnter: (event, value)->
    self = fimplus._keyboard
    currentValue = self.data.input.val()
    keyboardEl = $('.keyboard')
    if value is undefined
      element = $(@)
      value = element.data('value')
    switch value
      when 'space'
        currentValue += ' '
        break;
      when 'delete'
        if currentValue.length
          currentValue = currentValue.substring(0, currentValue.length - 1)
        break;
      when 'deleteAll'
        currentValue = ''
        break;
      when 'shift'
        keyboardEl.removeClass(self.data.boardType)
        if self.data.boardType is 'lowercase'
          self.data.boardType = 'uppercase'
        else
          self.data.boardType = 'lowercase'
        keyboardEl.addClass(self.data.boardType)
        break;
      when '#+-'
        self.reRender('special')
        break;
      when 'abc'
        self.reRender('text')
        break;
      else
        if self.data.boardType is 'uppercase'
          value = value.toUpperCase()
        currentValue += value
    
    self.data.input.val(currentValue)
    self.data.input.trigger 'change'
  
  
  initEventClick: ()->
    self = @
    keyboard = self.data.element.find('.keyboard')
    buttonKey = self.data.element.find('.delete-key')
    keyboard.find('td span').off 'click'
      .on 'click', self.onEnter
    
    buttonKey.find('li').off 'click'
      .on 'click', self.onEnter
  
  setActiveKeyboard: (col = 0, row = 0, allowActive = true)->
    self = @
    keyboard = self.data.element.find('.keyboard')
    keyboard.find('td').removeClass('active')
    if allowActive
      keyboard
        .find('tr').eq(row)
        .find('td').eq(col).addClass('active')
      self.data.layout = 'board'
  
  setActiveKeyBoardButton: (current = 0, allowActive = true)->
    self = @
    keyboard = self.data.element.find('.delete-key')
    keyboard.find('li').removeClass('active')
    if allowActive
      keyboard.find('li').eq(current).addClass('active')
  
  handleKeyButton: (keyCode, key)->
    self = fimplus._keyboard
    console.log('Keyboard Button :', keyCode)
    if self.data.currentBoard is 'number'
      button = self.data.buttonsNoSpace
    else
      button = self.data.buttons
    
    if keyCode in key.NUMBER
      value = keyCode - 48
      self.onEnter(null, value)
    
    switch  keyCode
      when key.DELETE
        self.onEnter(null, 'delete')
        break
      when key.LEFT
        self.data.positionButton--
        break;
      when key.RIGHT
        self.data.positionButton++
        break;
      when key.UP
        self.data.layout = 'board'
        self.setActiveKeyBoardButton(0, false)
        self.setActiveKeyboard(self.data.positionKey.col, self.data.positionKey.row)
        return;
      when key.DOWN
        self.setActiveKeyBoardButton(0, false)
        self.data.callback()
        return;
      when key.ENTER
        value = button[self.data.positionButton]
        self.onEnter(null, value)
        return;
    self.data.positionButton = fimplus.KeyService.reCalc(self.data.positionButton, button.length)
    self.setActiveKeyBoardButton(self.data.positionButton)
  
  onBackKeyboard: ()->
    self = fimplus._keyboard
    self.data.layout = 'keyboard'
    self.setActiveKeyboard(self.data.positionKey.col, self.data.positionKey.row, true)
  
  onBackBoardButton: ()->
    self = fimplus._keyboard
    self.data.layout = 'button'
    self.setActiveKeyBoardButton(self.data.positionButton)
    self.setActiveKeyboard(0, 0, false)
  
  handleKey: (keyCode, key)->
    console.log('Keyboard :', keyCode)
    self = fimplus._keyboard
    positionKey = self.data.positionKey
    board = self.data[self.data.currentBoard]
    if self.data.layout is 'button'
      self.handleKeyButton(keyCode, key)
      return
    if keyCode in key.NUMBER
      value = keyCode - 48
      self.onEnter(null, value)
    
    switch  keyCode
      when key.DELETE
        self.onEnter(null, 'delete')
        break;
      when key.LEFT
        positionKey.col--
        break;
      when key.RIGHT
        positionKey.col++
        break;
      when key.UP
        if positionKey.row is 0
          self.setActiveKeyboard(0, 0, false)
          self.data.callback('UP')
          return;
        positionKey.row--
        break;
      
      when key.DOWN
        if positionKey.row < board.length - 1
          positionKey.row++
          break;
        self.onBackBoardButton()
        return;
      when key.ENTER
        value = board[positionKey.row][positionKey.col]
        self.onEnter(null, value)
    
    positionKey.row = fimplus.KeyService.reCalc(positionKey.row, board.length)
    positionKey.col = fimplus.KeyService.reCalc(positionKey.col, board[positionKey.row].length)
    self.data.positionKey = positionKey
    self.setActiveKeyboard(positionKey.col, positionKey.row)
    
    
    