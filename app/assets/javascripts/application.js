// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require_tree .
//= require jquery3
//= require popper
//= require bootstrap

$(document).ready(function() {
	$("#gen-button").click(function(event){
        event.preventDefault();

        $("#error").fadeOut(function(){
            $("#short-url").fadeOut(400, function(){
                if ($("#long-url")[0].checkValidity() === false) {
                    $("#long-url").addClass('was-validated');
                } else {
                    original = $("#original").val();
                    $.ajax({
                        url: '/short_urls',
                        contentType: 'application/json',
                        data: JSON.stringify({ "original": original }),
                        dataType: 'json',
                        method: 'POST',
                        processData: false
                    }).done(function(data){
                        $("#short-url a:first").prop("href", data.short);
                        $("#short-url a:first").text(data.short);
                        $("#short-url").fadeIn();
                    }).fail(function(error){
                        $(Object.values(error.responseJSON)).each(function(i,elem){
                            $("#error").empty();
                            $("#error").append("<li>"+elem+"</li>")
                            $("#error").fadeIn();
                        });
                    });
                }
            });
        });
	});

    $("#modal-trigger").click(function(event){
        event.preventDefault();
        $.ajax({
            url: '/short_urls/top?max=100',
            contentType: 'application/json',
            dataType: 'json',
            method: 'GET',
            processData: false
        }).done(function(data){
            generateTopTable(data);
            $('#top100-modal').modal('show');
        }).fail(function(error){
            alert("There was a problem!");
        });
    });
});

function generateTopTable(data) {
    $("#top100-table").empty();
    $(data).each(function(index, element){
        url = element;
        row = '<tr><th scope="row">'+url.visit_count+'</th><td>'+url.title+'</td><td><a target="_blank" href="'+url.short+'">'+url.short+'</a></td></tr>';
        $("#top100-table").append(row);
    });
}
