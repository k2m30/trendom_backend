$(document).on('ready page:load', function () {
    $('#select-template').change(function () {
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


});
