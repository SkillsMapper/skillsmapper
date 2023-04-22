//const SKILLS_ENDPOINT = "http://localhost:8086/autocomplete";
const SKILLS_ENDPOINT = "/api/skills/autocomplete";

const suggestions = $("#suggestions");

$(document).ready(function() {
    suggestions.hide();
});

const DEBOUNCE_DELAY = 500; // Adjust this value based on the desired delay (in milliseconds)
let debounceTimeout;

$('#skill').on('input', function (event) {
    const searchInput = event.target;
    const prefix = searchInput.value;

    if (prefix.length === 0) {
        suggestions.empty();
        suggestions.hide();
        return;
    }

    // Clear the existing debounce timeout if it exists
    if (debounceTimeout) {
        clearTimeout(debounceTimeout);
    }

    // Set a new debounce timeout
    debounceTimeout = setTimeout(() => {
        const request = $.ajax({
            url: SKILLS_ENDPOINT,
            method: "GET",
            data: { prefix: prefix },
            dataType: "json"
        });

        // Set the callback function for when the request finishes
        request.done(function (response) {
            suggestions.empty();
            if (response.results.length === 0) {
                suggestions.hide();
                return;
            }
            response.results.forEach(function (result) {
                const a = $("<a class='collection-item'>").text(result);
                a.on("click", function () {
                    searchInput.value = result;
                    suggestions.empty();
                    suggestions.hide()
                });
                suggestions.append(a);
            });
            suggestions.show();
        });
    }, DEBOUNCE_DELAY);
});
