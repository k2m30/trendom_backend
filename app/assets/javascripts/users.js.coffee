$(document).on 'ready page:load', ->
  $('#reveal').click ->
    $('#reveal').fadeOut()
    $('.progress-window').fadeIn()
    $.ajax
      url: $('#reveal').attr('data')
      success: (progress) ->
        $('.progress-window').fadeOut()
        return
      error: (err) ->
        console.log(err)
        return

    interval = setInterval((->
      $.ajax
        url: '/home/progress'
        success: (progress) ->
          if parseFloat(progress) != 0.0
            $('.progress-bar').css('width', progress + '%').text progress + '%'
          if parseFloat(progress) >= 100.0
            clearInterval interval
            window.location.reload(true)
          return
        error: (err) ->
          console.log(err)
          clearInterval interval
          return
      return
    ), 200)