
function auto_fill(id, value, force) {
    if ( (force || $(id).val() == "") && !isNaN(value) ) {
        $(id).val(value);
    }
}

function normalize_money (value) {
    var returnval = value.replace(/(?:[a-zA-Z]|\s|,|\$)+/ig,'')
    return returnval
}

$(document).ready(function(){
    $("#loan_asset_price").focus().change(function() {
        var down_payment = normalize_money($(this).val()) * 0.2
        var asset_price = $(this).val() * 1.0
        if (asset_price < 150000) { year = 5 } else { year = "30" }
        auto_fill("#loan_down_payment", down_payment.toFixed(2));
        if ($(this).val() != "") { auto_fill("#loan_asset_price", asset_price.toFixed(2), true); }
        auto_fill("#loan_years", year);
    });
    $("#loan_interest_rate").change(function() {
        var ir = $(this).val() * 1.0
        auto_fill("#loan_interest_rate", ir.toFixed(3), true);
    });
//    $("#reload").click(function() {
//        set_domain_defaults($("#website_domain").val().toLowerCase(), true);
//        set_name_defaults($("#website_name").val().toLowerCase(), true);
//    });
//    $(".clearfield").click(function() {
//        $(this).prev("input.text").val('');
//        $(this).prev("div").children("input.text").val('');
//    });
});