//const FACTS_ENDPOINT = "http://localhost:8080/facts";
const FACTS_ENDPOINT = "/api/facts";

async function fetchFacts() {
    const token = await firebase.auth().currentUser.getIdToken();
    const response = await fetch(FACTS_ENDPOINT, {
        headers: {
            "Content-Type": "application/json",
            'Authorization': `Bearer ${token}`
        }
    });
    const data = await response.json();

    const facts = $("#facts");
    facts.empty();

    if (data._embedded && data._embedded.factList) {
        facts.show();
        data._embedded.factList.forEach(fact => {
            $("#facts").append(
                `<li class="collection-item">
                   <span class="title">${fact.skill}</span>
                    <span class="secondary-content delete">
                      <i class="material-icons delete-btn" data-id="${fact.id}" style="cursor: pointer;">delete</i>
                    </span>
                 </li>`
            );
        });
    } else {
        facts.hide();
        console.log("No _embedded or factList found in the response data.");
    }
}

// Submit a new fact
async function submitFact(skill, level) {
    const token = await firebase.auth().currentUser.getIdToken();
    const response = await fetch(FACTS_ENDPOINT, {
        method: "POST",
        body: JSON.stringify({skill, level}),
        headers: {
            "Content-Type": "application/json",
            'Authorization': `Bearer ${token}`
        }
    });
    return await response.json();
}

// Delete a fact
async function deleteFact(id) {
    const token = await firebase.auth().currentUser.getIdToken();
    const response = await fetch(FACTS_ENDPOINT + "/" + id, {
        method: "DELETE",
        headers: {
            "Content-Type": "application/json",
            'Authorization': `Bearer ${token}`
        }
    });
    return response.status === 204;
}

$(document).on('click', '.delete-btn', function () {
    const factId = $(this).data('id');
    deleteFact(factId).then(r => fetchFacts());
});

$('#addFact').click(function () {
    const skill = $('#skill').val();
    const level = $('#level').val();
    submitFact(skill, level).then(r => fetchFacts());
});

$("#factForm").submit(async (event) => {
    event.preventDefault();
    const skill = $("#skill").val();
    const level = $("#level").val();
    if (skill && level) {
        const newFact = await submitFact(skill, level);
        if (newFact) {
            Materialize.toast("Fact submitted successfully!", 3000);
            $("#skill").val("");
            $("#level").val("");
        } else {
            Materialize.toast("Failed to submit fact!", 3000);
        }
    } else {
        Materialize.toast("Please fill out all fields!", 3000);
    }
});
