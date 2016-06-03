$(document).on('ready page:load', function () {
    $('#template').change(function () {
        var select = $('#template');
        var value = select.find('option:selected').val();

        var current_url = select.attr('data-url');
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
