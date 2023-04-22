function showTabs() {
    document.getElementById('facts').classList.remove('hide-content');
    document.getElementById('profile').classList.remove('hide-content');
}

function hideTabs() {
    document.getElementById('facts').classList.add('hide-content');
    document.getElementById('profile').classList.add('hide-content');
}

$('#signInButtonNav').click(toggle);
$('#signInButtonSide').click(toggle);

$(document).ready(function() {
    // Initialize tabs
    $('.tabs').tabs();

    // Hide all tab content divs initially except for the first one
    $('.tab-content').hide();
    $('.tab-content:first').show();

    // Handle click event for tabs
    $('.tabs a').click(function(e) {
        e.preventDefault();

        // Get the target tab's ID
        var targetTabId = $(this).attr('href');

        // Hide all tab content divs
        $('.tab-content').hide();

        // Show the content div with the target tab's ID
        $(targetTabId).show();
    });
});


$(document).ready(function () {
    const elems = $('select');
    M.FormSelect.init(elems, {});
});

$(document).ready(function () {
    var elems = $('.sidenav');
    var instances = M.Sidenav.init(elems);
});

document.addEventListener('DOMContentLoaded', function() {
    var elems = document.querySelectorAll('.tooltipped');
    var instances = M.Tooltip.init(elems);
});