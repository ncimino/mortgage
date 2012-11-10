
function auto_fill(id, value, force) {
    if ( (force || $(id).val() == "") && !isNaN(value) ) {
        $(id).val(value);
    }
}

function normalize_money (value) {
    var returnval = value.replace(/(?:[a-zA-Z]|\s|,|\$)+/ig,'')
    return returnval;
}

function fix_decimal (value, fix_to) {
    return (value == "") ? "" : (value * 1.0).toFixed(fix_to);
}

$(document).ready(function(){
    $("#loan_asset_price").focus().change(function() {
        $(this).val(fix_decimal(normalize_money($(this).val()),2));
        auto_fill("#loan_down_payment", fix_decimal($(this).val() * 0.2,2));
        auto_fill("#loan_years", ($(this).val() < 150000) ? "5" : "30");
    });
    $("#loan_planned_payment").change(function() {
        $(this).val(fix_decimal(normalize_money($(this).val()),2));
    });
    $("#loan_escrow_payment").change(function() {
        $(this).val(fix_decimal(normalize_money($(this).val()),2));
    });
    $("#loan_down_payment").change(function() {
        $(this).val(fix_decimal(normalize_money($(this).val()),2));
    });
    $("#loan_interest_rate").change(function() {
        $(this).val(fix_decimal(normalize_money($(this).val()),3));
    });
    $("#loan_years").change(function() {
        $(this).val(fix_decimal(normalize_money($(this).val()),0));
    });
    $("#loan_payments_per_year").change(function() {
        $(this).val(fix_decimal(normalize_money($(this).val()),0));
    });
//    $("#reload").click(function() {
//        set_domain_defaults($("#website_domain").val().toLowerCase(), true);
//        set_name_defaults($("#website_name").val().toLowerCase(), true);
//    });
//    $(".clearfield").click(function() {
//        $(this).prev("input.text").val('');
//        $(this).prev("div").children("input.text").val('');
//    });
    $(function() {
        $( "#tabs" ).tabs();
    });
    $(function() {
        $( "#loan_first_payment" ).datepicker({
            showOn: "button",
            buttonImage: "/assets/calendar.png",
            buttonImageOnly: true,
            changeMonth: true,
            changeYear: true,
            dateFormat: "yy-mm-dd"
        });
    });
    $("button:button").click( function() {
        window.location.href = $(this).attr('formaction');
    });
    $(".back-button").button({
        icons: { primary: "ui-icon-arrowreturnthick-1-w" }
    });
    $(".save-button").button({
        icons: { primary: "ui-icon-disk" }
    });
    $(".new-loan-button").button({
        icons: { primary: "ui-icon-plusthick" }
    });
    $(".edit-loan-button").button({
        icons: { primary: "ui-icon-pencil" }
    });
    $(".delete-loan-button").button({
        icons: { primary: "ui-icon-trash" }
    });
    $("input").live("change",function(event){
        $(".alert-save").addClass("ui-state-error");

    $.get('/loans/summary', $(this).parents("form:first").serialize(),
        function(data) {
            $("#loan_summary").html(data)
            $("#tabs input").stop().css("background-color", "#FFFF9C")
                .animate({ backgroundColor: "#FFFFFF"}, 1500);
        });

});
});

