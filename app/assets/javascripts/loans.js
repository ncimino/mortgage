function auto_fill(id, value, force) {
    if ((force || $(id).val() == "") && !isNaN(value)) {
        $(id).val(value);
    }
}

function normalize_money(value) {
    var returnval = value.replace(/(?:[a-zA-Z]|\s|,|\$)+/ig, '')
    return returnval;
}

function fix_decimal(value, fix_to) {
    return (value == "") ? "" : (value * 1.0).toFixed(fix_to);
}

function spinner() {
    return '<h3><img src="/assets/ui-anim_basic_16x16.gif">Loading...</h3>'
}

function load(path, id,force) {
    if (force || !$(id).hasClass("ui-tabs-hide")) {
        $.get(path, $("#loan_fundamentals").children("form").serialize(),
            function (data) {
                $(id).html(data)
                if (! force) {
                $("#tabs " + id + " input, #tabs " + id + " table").stop().css("background-color", "#FFFF9C")
                    .animate({ backgroundColor:"#FFFFFF"}, 1500);
                }
                bind_rails_callbacks();
                buttonize();
            }).error(function(req,status,msg) {
                $(id).html("<h3 class='error'>An error occurred</h3><h4>"+msg+"</h4>");
            });
    }
}

function buttonize() {
    $("button:button").click(function () {
        if ( $(this).attr('formaction') ) window.location.href = $(this).attr('formaction');
    });
    $(".back-button").button({
        icons:{ primary:"ui-icon-arrowreturnthick-1-w" }
    });
    $(".save-button").button({
        icons:{ primary:"ui-icon-disk" }
    });
    $(".new-button").button({
        icons:{ primary:"ui-icon-plusthick" }
    });
    $(".edit-button").button({
        icons:{ primary:"ui-icon-pencil" }
    });
    $(".delete-button").button({
        icons:{ primary:"ui-icon-trash" }
    });
    $("#new-payment-button").click(function() {
        $( "#new-payment-form" ).dialog( "open" );
    });
}

function bind_rails_callbacks() {
    $(".delete-payment")
        .bind("ajax:success", function(event, data, status, xhr) {
            $("#loan_payments").html(data);
            bind_rails_callbacks();
            buttonize();
        });
}

function create_calendar() {
    $(function () {
        $("#loan_first_payment, #payment_date").datepicker({
            showOn:"both",
            buttonImage:"/assets/calendar.png",
            buttonImageOnly:true,
            changeMonth:true,
            changeYear:true,
            dateFormat:"yy-mm-dd"
        });
    });
}

function create_payment_form() {
    $( "#new-payment-form" ).dialog({
        autoOpen: false,
        height: 355,
        width: 385,
        modal: true,
        buttons: {
            "Add payment": function() {
                $.post(window.location.href + '/payments', $("#new_payment").serialize(),
                    function (data) {
                        $("#new-payment-form").html( data );
                        buttonize();
                        create_calendar();
                        load("/loans/payments_main","#loan_payments");
                    }).error(function(req,status,msg) {
                        $("#new-payment-form").html("<h3 class='error'>An error occurred</h3><h4>"+msg+"</h4>");
                    });
            },
            "Done": function() {
                $( this ).dialog( "close" );
            }
        },
        close: function() {
            $.get(window.location.href + '/payments/new', function (data) {
                $("#new-payment-form").html(data)
                create_calendar();
            });
        }
    });
}

$(document).ready(function () {
    $("#loan_asset_price").focus().change(function () {
        auto_fill("#loan_down_payment", fix_decimal($(this).val() * 0.2, 2));
        auto_fill("#loan_years", fix_decimal(($(this).val() < 150000) ? "5" : "30"), 0);
    });
    $("#loan_asset_price, #loan_planned_payment, #loan_escrow_payment, #loan_down_payment").change(function () {
        $(this).val(fix_decimal(normalize_money($(this).val()), 2));
    });
    $("#loan_interest_rate").change(function () {
        $(this).val(fix_decimal(normalize_money($(this).val()), 3));
    });
    $("#loan_years, #loan_payments_per_year").change(function () {
        $(this).val(fix_decimal(normalize_money($(this).val()), 0));
    });
    $(function () {
        $("#tabs").tabs();
    });
    $('li a[href="#loan_payments"]').click(function () {
        $("#loan_payments").prepend(spinner());
        load("/loans/payments_main","#loan_payments",true);
    });
    $('li a[href="#loan_schedule"]').click(function () {
        $("#loan_schedule").prepend(spinner());
        load("/loans/schedule","#loan_schedule",true);
    });
    $('li a[href="#loan_summary"]').click(function () {
        $("#loan_summary").prepend(spinner());
        load("/loans/summary","#loan_summary",true);
    });
    $("#loan_fundamentals input").live("change", function (event) {
        $(".alert-save").addClass("ui-state-error");
        load("/loans/payments_main","#loan_payments");
        load("/loans/schedule","#loan_schedule");
        load("/loans/summary","#loan_summary");
    });
    buttonize();
    create_calendar();
    create_payment_form();
});

