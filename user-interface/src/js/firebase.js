firebase.initializeApp(config);

// Watch for state change from sign in
function initApp() {
  firebase.auth().onAuthStateChanged(function(user) {
    if (user) {
      // User is signed in.
      $('#signInButtonNav').text('Sign Out');
      $('#signInButtonSide').text('Sign Out');
      $('#loggedin').show();
    } else {
      // No user is signed in.
      $('#signInButtonNav').text('Sign In with Google');
      $('#signInButtonSide').text('Sign In with Google');
      $('#username').text(``);
      $('#loggedin').hide();
    }
  });
}

window.onload = function() {
  initApp();
}

function signIn() {
  var provider = new firebase.auth.GoogleAuthProvider();
  provider.addScope('https://www.googleapis.com/auth/userinfo.email');
  firebase.auth().signInWithPopup(provider).then(function(result) {
    // Returns the signed in user along with the provider's credential
    var user = result.user;
    var displayName = user.displayName;
    var photoURL = user.photoURL;
    console.log(`${displayName} logged in.`);
    console.log(`photo: ${photoURL}`);
    $('#user-name').text(`${displayName}`);
    $('#user-photo').attr('src', `${photoURL}`);
  }).catch((err) => {
    console.log(`Error during sign in: ${err.message}`)
    window.alert(`Sign in failed. Retry or check your browser logs.`);
  });
}


function signOut() {
  firebase.auth().signOut().then(function(result) {
  }).catch((err) => {
    console.log(`Error during sign out: ${err.message}`);
    window.alert(`Sign out failed. Retry or check your browser logs.`);
  })
}

// Toggle Sign in/out button
function toggle() {
  if (!firebase.auth().currentUser) {
    signIn();
  } else {
    signOut();
  }
}

async function addFact(skill, level) {
  if (firebase.auth().currentUser) {
    // Retrieve JWT to identify the user to the Identity Platform service.
    // Returns the current token if it has not expired. Otherwise, this will
    // refresh the token and return a new one.
    try {
      const token = await firebase.auth().currentUser.getIdToken();
      const response = await fetch('/facts', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${token}`
        },
        body: `{ "skill": "${skill}", "level": "${level}" }` // send application data (vote)
      });
      if (response.ok) {
        const text = await response.text();
        window.alert(text);
        window.location.reload();
      } else {
        window.alert('Something went wrong... Please try again!');
      }
    } catch (err) {
      console.log(`Error when voting: ${err}`);
      window.alert('Something went wrong... Please try again!');
    }
  } else {
    window.alert('User not signed in.');
  }
}
