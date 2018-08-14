
$(document).ready(function() {
    // prepopulates calendar form with user's time zone
    var time_zone = Intl.DateTimeFormat().resolvedOptions().timeZone
    $("#time_zone select").val(time_zone);

})