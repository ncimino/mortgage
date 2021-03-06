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

function flash(obj) {
    obj.stop().css("background-color", "#FFFF9C").animate({ backgroundColor:"#FFFFFF"}, 1500);
}

function save_session() {
        $.get("/loans/save_session", $("#loan_fundamentals").children("form").serialize());
}

function load(path, id, force) {
    $("#spinner").show();
    $(id).html("");
    if (force || !$(id).hasClass("ui-tabs-hide")) {
        $.get(path, $("#loan_fundamentals").children("form").serialize(),
            function (data) {
                $(id).html(data)
                if (!force) { flash($("#tabs " + id + " input, #tabs " + id + " table")); }
                bind_rails_callbacks();
                buttonize();
            }).error(function (req, status, msg) {
                $(id).html("<h3 class='error'>An error occurred</h3><h4>" + msg + "</h4>");
            }).complete(function () {
                $("#spinner").hide();
            });
    }
}

function buttonize() {
    $("button:button").click(function () {
        if ($(this).attr('formaction')) window.location.href = $(this).attr('formaction');
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
    $(".button").button();
}

function bind_rails_callbacks() {
    $(".delete-payment")
        .bind("ajax:success", function (event, data, status, xhr) {
            $("#actual_payments_tab").html(data);
            bind_rails_callbacks();
            buttonize();
        });
    $(".edit-payment")
        .bind("ajax:success", function (event, data, status, xhr) {
            $("#payment-form-container").html(data);
            buttonize();
            create_calendar();
            new_payment_form();
            $("#payment-form-container").dialog("open");
        });
    $(".new-payment")
        .bind("ajax:success", function (event, data, status, xhr) {
            $("#payment-form-container").html(data);
            buttonize();
            create_calendar();
            new_payment_form();
            $("#payment-form-container").dialog("open");

        });
}

function create_calendar() {
    $(function () {
        $(".date-picker").datepicker({
            showOn:"both",
            buttonImage:"/assets/calendar.png",
            buttonImageOnly:true,
            changeMonth:true,
            changeYear:true,
            dateFormat:"yy-mm-dd"
        });
    });
}

function new_payment_form() {
    $("#payment-form-container").dialog({
        autoOpen:false,
        height:355,
        width:385,
        modal:true,
        title:$("#payment-form-container").children("div").attr("title"),
        buttons:{
            "Submit":function () {
                $.ajax({
                    type:$("#payment-form-container form").attr("data-method"),
                    url:$("#payment-form-container form").attr("action"),
                    data:$("#payment-form-container form").serialize()
                }).done(function (data) {
                    current_id = $("#payment-form-container form").attr("id");
                    $("#payment-form-container").html(data);
                    new_id = $("#payment-form-container form").attr("id")
                    if (current_id != new_id) {
                        $("#payment-form-container").dialog("close");
                    }
                    buttonize();
                    create_calendar();
                    flash($("#payment-form-container input"));
                    $("#payment-form-container form input[type='text']:first").focus();
                    if ( $("#new_loan").length == 0 ) { load("/payments/actual", "#actual_payments_tab"); }
                    if ( $("#new_loan").length != 0 ) { load("/session_payments/actual", "#actual_payments_tab"); }
                    load("/schedule/actual", "#current_schedule_tab");
                });
            },
            "Done":function () {
                $(this).dialog("close");
            }
        }
    });
}

$(document).ready(function () {
    $(".focus").focus();
    $("#loan_asset_price").change(function () {
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
        if ( $("#new_loan").length == 0 ) { load("/payments/actual", "#actual_payments_tab"); }
        if ( $("#new_loan").length != 0 ) { load("/session_payments/actual", "#actual_payments_tab"); }
        load("/schedule/actual", "#current_schedule_tab");
        load("/schedule/ideal", "#ideal_schedule_tab");
        load("/loans/summary", "#summary_tab");
        buttonize();
        create_calendar();
        new_payment_form();
    });
    $('li a[href="#actual_payments_tab"]').click(function () {
        if ( $("#new_loan").length == 0 ) { load("/payments/actual", "#actual_payments_tab", true); }
        if ( $("#new_loan").length != 0 ) { load("/session_payments/actual", "#actual_payments_tab", true); }
    });
    $('li a[href="#ideal_schedule_tab"]').click(function () {
        load("/schedule/ideal", "#ideal_schedule_tab", true);
    });
    $('li a[href="#current_schedule_tab"]').click(function () {
        load("/schedule/actual", "#current_schedule_tab", true);
    });
    $('li a[href="#summary_tab"]').click(function () {
        load("/loans/summary", "#summary_tab", true);
    });
    $("#loan_fundamentals input").bind("change", function (e) {
        $(".alert-save").addClass("ui-state-error");
        if ( $("#new_loan").length == 0 ) { load("/payments/actual", "#actual_payments_tab"); }
        if ( $("#new_loan").length != 0 ) { load("/session_payments/actual", "#actual_payments_tab"); }
        load("/schedule/actual", "#current_schedule_tab");
        load("/schedule/ideal", "#ideal_schedule_tab");
        load("/loans/summary", "#summary_tab");
    });
    $("#new_loan input").bind("change", function (e) {
        save_session();
    });
    $("#payment-form-container").bind('keypress', function (e) {
        if (e.keyCode == $.ui.keyCode.ENTER) {
            $("#payment-form-container").parent().find("button:eq(0)").trigger("click");
        }
    });
});

