//const PROFILES_ENDPOINT = "http://localhost:8080/profiles/me";
const PROFILES_ENDPOINT = "/api/profiles/me"

async function fetchProfile() {
    const currentUser = firebase.auth().currentUser;
    if (!currentUser) {
        console.log("User is not authenticated");
        return;
    }

    const token = await currentUser.getIdToken();

    const response = await fetch(PROFILES_ENDPOINT, {
        headers: {
            "Content-Type": "application/json",
            'Authorization': `Bearer ${token}`
        }
    });

    console.log("Response status:", response.status);

    if (response.ok) {
        const profile = await response.json();
        console.log("Profile data:", profile);
        document.getElementById('profile-photo').src = profile.PhotoURL;
        document.getElementById('profile-name').innerText = profile.Name;
        populateSkillChips('interested-skills', profile.Interested);
        populateSkillChips('learning-skills', profile.Learning);
        populateSkillChips('using-skills', profile.Using);
        populateSkillChips('used-skills', profile.Used);
    } else {
        console.error('Error fetching profile:', response.status, response.statusText);
    }
}

function populateSkillChips(containerId, skills) {
    if (!skills) return;

    const container = document.getElementById(containerId);
    container.innerHTML = ''; // Clear the container before populating

    skills.forEach(skill => {
        const chip = document.createElement('div');
        chip.className = 'chip';
        chip.innerText = skill;
        container.appendChild(chip);
    });
}


$('#profileTab').click(function () {
    console.log('Profile tab clicked');
    fetchProfile().then(() => {
        console.log('Profile fetched');
    }).catch((error) => {
        console.error('Error fetching profile:', error);
    });
});

