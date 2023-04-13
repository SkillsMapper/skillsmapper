$('#signInButtonNav').click(toggle);
$('#signInButtonSide').click(toggle);

$('#addFact').click(function () {
    const skill = $('#skill').val();
    const level = $('#level').val();
    const output =
        `<li class="collection-item">
                <div>${skill}
                  <a href="#!" class="secondary-content delete">
                    <i class="material-icons">close</i>
                  </a>
                </div>
              </li>`;

    $('.facts').append(output);
    addFact(skill, level);
});

$('.facts').on('click', '.delete', function (e) {
    $(this).parent().parent().remove();
    M.Toast('Fact removed');
    e.preventDefault();
});

$(document).ready(function () {
    const elems = $('select');
    M.FormSelect.init(elems, {});
});

$(document).ready(function () {
    const elems = $('.autocomplete');
    M.Autocomplete.init(elems, {});
});

$(document).ready(function () {
    var elems = $('.sidenav');
    var instances = M.Sidenav.init(elems);
});

$('#skill').on('input', function (event) {
    // Get the search input element
    var searchInput = event.target;

    // Get the search prefix
    var prefix = searchInput.value;

    // Set up the HTTP request
    var request = $.ajax({
        url: "/skills/autocomplete",
        method: "GET",
        data: {prefix: prefix},
        dataType: "json"
    });

    // Set the callback function for when the request finishes
    request.done(function (response) {
        // Get the suggestions list element
        var suggestions = $(".suggestions");

        // Clear the list
        suggestions.empty();

        // Add the suggestions to the list
        response.results.forEach(function (result) {
            var li = $("<li>").text(result);
            li.on("click", function () {
                searchInput.value = result;
                suggestions.empty();
            });
            suggestions.append(li);
        });
    });
});