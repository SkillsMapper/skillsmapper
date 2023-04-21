//const FACTS_ENDPOINT = "http://localhost:8080/facts";
const FACTS_ENDPOINT = "/api/facts";

async function fetchFacts()
{
    const token = await firebase.auth().currentUser.getIdToken();
    console.log("Fetching facts...");
    const response = await fetch(FACTS_ENDPOINT, {
        headers: {
            "Content-Type": "application/json",
            'Authorization': `Bearer ${token}`
        }
    });
    const data = await response.json();

    const factsCollection = $("#factsCollection");
    factsCollection.empty();
    factsCollection.hide();
    if (data._embedded && data._embedded.factList) {
        factsCollection.show();
        data._embedded.factList.forEach(fact => {
            $("#factsCollection").append(
                `<li class="collection-item">
                   <span class="title">${fact.skill}</span>
                    <span class="secondary-content delete">
                      <i class="material-icons delete-btn" data-id="${fact.id}" style="cursor: pointer;">delete</i>
                    </span>
                 </li>`
            );
        });
    } else {
        console.log("No _embedded or factList found in the response data.");
    }
}

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

$('#addFact').click(async function () {
    const skillField = $('#skill');
    const levelField = $('#level');
    const skill = skillField.val();
    const level = levelField.val();
    if (skill && level) {
        const result = await submitFact(skill, level);

        if (result) {
            M.toast({html: "Fact submitted successfully"}, 3000);
            console.info("Fact submitted successfully", result)
            levelField.prop('selectedIndex', 0);
            skillField.val('');
            await fetchFacts();
        } else {
            M.toast({html: "Failed to submit fact"}, 3000);
            console.error('Failed to submit fact');
        }
    } else {
        M.toast({html: "Please fill out all fields"}, 3000);
        console.info("Please fill out all fields!")
    }
});
$('#factsTab').click(function () {
    console.log('Facts tab clicked');
    fetchFacts().then(() => {
        console.log('Facts fetched');
    }).catch((error) => {
        console.error('Error fetching facts:', error);
    });
});