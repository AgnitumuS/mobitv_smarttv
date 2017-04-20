pateco.SubtitleService =
  getContentSubFromServer : (subtitles, callback) ->
    self = @
    language =
      VI : 'Tiếng Việt'
      EN : 'Tiếng Anh'

    sub =
      function : {}
      info : []

    _.map subtitles, (data)->
      sub.info.push(
        type : data.sub
        title : language[data.sub]
        isActive : data.isdefault
      )
      sub.type = data.sub if data.isdefault is 1
      sub.function[data.sub] = (cb)->
        options =
          url : data.source
          success : (text)-> cb null, self.convert(text)
          error : (error) -> cb null, []
        $.ajax(options)

    async.parallel sub.function, (error, result)->
      _.extend sub, result
      delete sub.function
      sub.info.push(
        isActive : 0
        title : 'Tắt'
        type : 'OFF')
      callback sub

  getCurrent : (sub, currentTime) ->
    return _.find(sub, (val, key) ->
      if (val.startTime <= currentTime) and (val.endTime >= currentTime)
        return key
    )
# end getCurrent
  timeMs : (val) ->
    regex = /(\d+):(\d{2}):(\d{2}).(\d{3})/
    parts = regex.exec(val)
    return 0  if parts is null
    i = 1
    while i < 5
      parts[i] = parseInt(parts[i], 10)
      parts[i] = 0  if isNaN(parts[i])
      i++

    # hours + minutes + seconds + ms
    time = parts[1] * 3600000 + parts[2] * 60000 + parts[3] * 1000 + parts[4]
    return time
# end timeMs

  search : (subs, time) ->
    sub = subs[subs.type]
    return false unless _.isArray sub
    left = 0
    right = sub.length - 1
    mid = 0
    a = 0
    while left < right
      a++
      mid = (left + right ) / 2
      mid = Math.ceil(mid)
      if time >= sub[0].startTime and time <= sub[0].endTime
        return sub[0]

      if time >= sub[mid].startTime and time <= sub[mid].endTime
        return sub[mid]

      if time > sub[mid].endTime
        left = mid
      else
        right = mid - 1
    return false
# end search

  convert : (data, useMs = true)->
    data = data.replace(/\r/g, "")
    regex = /(\d{2}:\d{2}:\d{2}.\d{3}) --> (\d{2}:\d{2}:\d{2}.\d{3})/g
    data = data.split(regex)
    data.shift()
    items = []
    i = 0

    while i < data.length
      try
        items.push
          id : data[i].trim()
          startTime : @timeMs(data[i].trim())
          endTime : @timeMs(data[i + 1].trim())
          text : data[i + 2].trim().replace("\n", "<br>")
      catch e
        console.log data[i], i
      i += 3

    return items
   
