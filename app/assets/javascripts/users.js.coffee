jQuery ->
  $('#reveal').click ->
    $('#reveal').fadeOut()
    $('.progress-window').fadeIn()
    $.ajax
      url: $('#reveal').attr('data')
      success: (progress) ->
        $('.progress-window').fadeOut()
        $('#download').fadeIn()
        return
      error: (err) ->
        console.log(err)
        return

    interval = setInterval((->
      $.ajax
        url: '/users/progress'
        success: (progress) ->
          if progress != 0
            $('.progress-bar').css('width', progress + '%').text progress + '%'
#          $('.progress-status').text progress
          if parseFloat(progress) >= 100
            clearInterval interval
            window.location.reload(true)
          return
        error: (err) ->
          console.log(err)
          clearInterval interval
          return
      return
    ), 200)