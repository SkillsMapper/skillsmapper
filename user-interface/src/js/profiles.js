const PROFILES_ENDPOINT = "/api/profiles/me"
async function fetchProfile() {
    const response = await fetch(PROFILES_ENDPOINT, {
        headers: {
            'Authorization': `Bearer ${localStorage.getItem('idToken')}`
        }
    });

    if (response.ok) {
        const profile = await response.json();
        document.getElementById('profile-photo').src = profile.photoURL;
        document.getElementById('profile-name').innerText = profile.name;
        document.getElementById('profile-email').innerText = profile.email;
    } else {
        console.error('Error fetching profile:', response.status, response.statusText);
    }
}

document.addEventListener('DOMContentLoaded', function() {
    firebase.auth().onAuthStateChanged(async (user) => {
        if (user) {
            const idToken = await user.getIdToken();
            localStorage.setItem('idToken', idToken);

            fetchProfile();
        } else {
            localStorage.removeItem('idToken');
        }
    });
});
