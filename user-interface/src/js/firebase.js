firebase.initializeApp(config);

// Watch for state change from sign in
function initApp() {
    hideTabs();
    firebase.auth().onAuthStateChanged(function (user) {
        if (user) {
            // User is signed in.
            const displayName = user.displayName;
            const photoURL = user.photoURL;
            $('#user-name').text(`${displayName}`).show();
            $('#user-photo').attr('src', `${photoURL}`).show();
            $('#signInButtonNav').text('Sign Out');
            $('#signInButtonSide').text('Sign Out');
            fetchProfile().then(fetchFacts().then(showTabs()));
        } else {
            // No user is signed in.
            hideTabs();
            $('#signInButtonNav').text('Sign In with Google');
            $('#signInButtonSide').text('Sign In with Google');
            $('#user-name').text('').show();
            $('#user-photo').attr('src', '').hide();
        }
    });
}



window.onload = function () {
    initApp();
}

function signIn() {
    var provider = new firebase.auth.GoogleAuthProvider();
    provider.addScope('https://www.googleapis.com/auth/userinfo.email');
    firebase.auth().signInWithPopup(provider).then(function (result) {
        console.log(`${result.user.displayName} logged in.`);
    }).catch((err) => {
        console.log(`Error during sign in: ${err.message}`)
    });
}

function signOut() {
    firebase.auth().signOut().then(function (result) {
        console.log(`User logged out.`);
    }).catch((err) => {
        console.log(`Error during sign out: ${err.message}`);
    });
}

// Toggle Sign in/out button
function toggle() {
    if (!firebase.auth().currentUser) {
        signIn();
    } else {
        signOut();
    }
}

