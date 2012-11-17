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
//    return '<h3 id="spinner"><img src="/assets/ui-anim_basic_16x16.gif">Loading...</h3>'
    $("#spinner").show();
}

function flash(obj) {
    obj.stop().css("background-color", "#FFFF9C").animate({ backgroundColor:"#FFFFFF"}, 1500);
}

function load(path, id, force) {
    spinner();
    if (force || !$(id).hasClass("ui-tabs-hide")) {
        $.get(path, $("#loan_fundamentals").children("form").serialize(),
            function (data) {
                $(id).html(data)
                if (!force) {
//                    $("#tabs " + id + " input, #tabs " + id + " table").stop().css("background-color", "#FFFF9C")
//                        .animate({ backgroundColor:"#FFFFFF"}, 1500);
                    flash($("#tabs " + id + " input, #tabs " + id + " table"));
                }
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
//            alert("population dialog");
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
//                    alert(current_id+" != "+new_id)
                    if (current_id != new_id) {
                        $("#payment-form-container").dialog("close");
                    }
                    buttonize();
                    create_calendar();
                    flash($("#payment-form-container input"));
//                    $("#payment-form-container form input:first").focus()
                    $("#payment-form-container form input[type='text']:first").focus();
                    load("/loans/actual_payments", "#actual_payments_tab");
                });
            },
            "Done":function () {
                $(this).dialog("close");
            }
        },
        close:function () {
            $.get(window.location.href + '/payments/new', function (data) {
                $("#payment-form-container").html(data)
                create_calendar();
            });
//        },
//        open:function () {
//            $("#payment-form-container form input[type='text']:first").focus();
//            $("#payment-form-container form input:first").focus()
//            alert($("#payment-form-container div").attr("id"));
//            $("#payment-form-container input").keypress(function (e) {
//            $("#new-payment-form").keypress(function (e) {
//                if (e.keyCode == $.ui.keyCode.ENTER) {
//                    $(this).parent().find("button:eq(0)").trigger("click");
//                }
//            });
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
        load("/loans/actual_payments", "#actual_payments_tab");
        load("/loans/current_schedule", "#current_schedule_tab");
        load("/loans/ideal_schedule", "#ideal_schedule_tab");
        load("/loans/summary", "#summary_tab");
        buttonize();
        create_calendar();
        new_payment_form();
    });
    $('li a[href="#actual_payments_tab"]').click(function () {
        load("/loans/actual_payments", "#actual_payments_tab", true);
    });
    $('li a[href="#ideal_schedule_tab"]').click(function () {
        load("/loans/ideal_schedule", "#ideal_schedule_tab", true);
    });
    $('li a[href="#current_schedule_tab"]').click(function () {
        load("/loans/current_schedule", "#current_schedule_tab", true);
    });
    $('li a[href="#summary_tab"]').click(function () {
        load("/loans/summary", "#summary_tab", true);
    });
    $("#loan_fundamentals input").live("change", function (e) {
        $(".alert-save").addClass("ui-state-error");
        load("/loans/actual_payments", "#actual_payments_tab");
        load("/loans/current_schedule", "#current_schedule_tab");
        load("/loans/ideal_schedule", "#ideal_schedule_tab");
        load("/loans/summary", "#summary_tab");
    });
    $("#payment-form-container").live('keypress', function (e) {
        if (e.keyCode == $.ui.keyCode.ENTER) {
            $("#payment-form-container").parent().find("button:eq(0)").trigger("click");
        }
    });
});

