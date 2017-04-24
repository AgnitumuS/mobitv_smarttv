pateco.UserService =
  data:
    watchLater:
      items: []
  
  addDataWatchLater: (item, add = true)->
    self = pateco.UserService
    index = _.findIndex self.data.watchLater.items, {id: item.id}
    if add and index is -1
      self.data.watchLater.items.unshift item
    else if index isnt -1
      self.data.watchLater.items.splice(index, 1)
  
  getWatchLater: (callback)->
    self = pateco.UserService
    done = (error, result)->
      if error
        return callback()
      self.data.watchLater = result
      callback()
    return callback() unless self.isLogin()
    params =
      limit: 40
      page : 0
    pateco.ApiService.getWatchLater(params, done)
  
  getProfile : ()->
    try
      return JSON.parse localStorage.user_info
    catch e
      console.warn(e)
      return null
  saveProfile: (user = {})->
    localStorage.user_info = JSON.stringify(user)
  
  saveToken: (data)->
    _.map data, (item, key)->
      localStorage[key] = item.access_token
  
  getToken: ()->
    data = {}
    if localStorage.hd1_cas or localStorage.hd1_billing or localStorage.hd1_cm or localStorage.hd1_payment
      if localStorage.hd1_cas isnt 'null' and localStorage.hd1_billing isnt 'null' && localStorage.hd1_cm isnt 'null' && localStorage.hd1_payment isnt 'null'
        data =
          cas    : localStorage.hd1_cas
          billing: localStorage.hd1_billing
          cm     : localStorage.hd1_cm
          payment: localStorage.hd1_payment
    return data
  
  upDateLocalStorage: (nameLocalParent, objectKeyName, valueNew)->
    objectNew = JSON.parse(localStorage.getItem(nameLocalParent))
    objectNew[objectKeyName] = valueNew
    localStorage.setItem(nameLocalParent, JSON.stringify(objectNew))
  
  isLogin: ()->
    return true unless _.isEmpty(@getToken())
    return false
  
  saveSettingStorage: ()->
    if localStorage.userSettings is null or localStorage.userSettings is undefined
      userSetting =
        language          : 'vi'
        quality           : 'auto'
        movieTitleLanguage: 'vi'
        subtitleState     : 'on'
        pairingDeviceState: 'off'
        subtitleColor     : 'white'
        subtitleSize      : 'font-type-2'
        subtitleOpacity   : '0.0'
      localStorage.setItem('userSettings', JSON.stringify(userSetting))
  
  getUserSetting: ()->
    try
      return JSON.parse localStorage.userSettings
    catch e
      console.warn(e)
      return null
  
  getValueStorage: (nameStorage, objectKeyName)->
    try
      objectNew = JSON.parse(localStorage.getItem(nameStorage)) if localStorage.getItem(nameStorage)
    catch e
      console.error e
    if objectNew
      return objectNew[objectKeyName]
    return null

 
