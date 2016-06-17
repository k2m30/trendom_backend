$(document).on('ready page:load', function () {
    $('#_email_template_id').change(function () {
        var value = $(this).find('option:selected').val();
        var current_url = $(this).attr('data-url');
        var new_url;

        if (current_url.includes('email_template_id')) {
            var re = /email_template_id=\d+/;
            new_url = current_url.replace(re, 'email_template_id=' + value);
        }
        else {
            new_url = current_url + '&email_template_id=' + value;
        }

        Turbolinks.visit(new_url);
    });

    $('.select-email').change(function () {
        var email = $(this).find('option:selected').val();
        var id = $(this).attr('id');
        console.log(email, id);
        $.ajax({
            method: 'PATCH',
            url: "/profiles/" + id + '/set_primary_email',
            data: {main_email: email}
        }).done(function() {
            //Turbolinks.reload();
        });


    });

    $(".profile").hover(function () {
       console.log('hover');
    });

    $("#_send_later").click(function () {
        console.log($(this).val());

        if ($(this).prop('checked')) {
            $("#send").val("Create campaign")
        }
        else {
            $("#send").val("Create campaign and send away now")
        }

    })
});
