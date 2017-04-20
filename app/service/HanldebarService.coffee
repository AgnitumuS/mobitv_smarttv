Handlebars.registerHelper('placeholder', (str) ->
#  image = str || "images/imgholder.png"
  return str
)

Handlebars.registerHelper('limit', (str) ->
  limit = 162
  return str unless str
  if (str.length > limit)
    return str.substring(0, limit) + '...';
  return str
)

# switch case 
Handlebars.registerHelper 'switch', (value, options) ->
  @_switch_value_ = value
  html = options.fn(this)
  # Process the body of the switch block
  delete @_switch_value_
  html

Handlebars.registerHelper 'case', (value, options) ->
  if value == @_switch_value_
    return options.fn(this)
  return

Handlebars.registerHelper 'ifCond', (v1, v2, options)->
  if v1 == v2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifCondPlusOne', (v1, v2, options)->
  if v1 == (v2 + 1)
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifMore', (v1, v2, options)->
  if v1 > v2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifMoreEqual', (v1, v2, options)->
  if v1 >= v2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifLess', (v1, v2, options)->
  if v1 < v2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifLessEqual', (v1, v2, options)->
  if v1 <= v2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifNotEqual', (v1, v2, options)->
  if v1 != v2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifBetween', (value, param1, param2, options)->
  if value > param1 and value < param2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'ifBetweenEqual', (value, param1, param2, options)->
  if value >= param1 and value <= param2
    return options.fn(this)
  return options.inverse(this)

Handlebars.registerHelper 'language', (str)->
  if localStorage.userSettings
    lang = pateco.UserService.getValueStorage('userSettings', 'language')
    return pateco.LanguageService.convert(str, lang)
  else
    return pateco.LanguageService.convert(str)

Handlebars.registerHelper 'coverNumber', (int)->
  return pateco.UtitService.coverNumber(int)

Handlebars.registerHelper 'inc', (value, options)->
  return parseInt(value) + 1

Handlebars.registerHelper 'coverTime', (seconds)->
  hh = Math.floor(seconds / 3600)
  mm = Math.floor(seconds / 60) % 60
  ss = Math.floor(seconds) % 60
  return ((if hh then ((if hh < 10 then "0" else "")) + hh + ":" else "")) + ((if (mm < 10) then "0" else "")) + mm + ":" + ((if (ss < 10) then "0" else "")) + ss

Handlebars.registerHelper 'coverTimeMinute', (seconds)->
  mm = Math.ceil(seconds / 60)
  return mm

Handlebars.registerHelper 'timeEpisode', (runtime)->
  d = Number(runtime * 60) #runtime is minutes
  h = Math.floor(d / 3600)
  m = Math.floor(d % 3600 / 60)
  s = Math.floor(d % 3600 % 60)
  res = ''
  if h > 0 then res += h + 'h'
  if m < 10 then m = '0' + m
  res += m + 'min'
  #  if s<10 then s+='0'+s
  #  res+=s
  return res

Handlebars.registerHelper('forLoop', (n, block)->
  accum = ''
  i = 0
  while(i < n )
    accum += block.fn(i)
    i++
  return accum
)
