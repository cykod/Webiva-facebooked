
Facebooked = {
  logout: function(url) {
    FB.logout(function(response) {
      window.location = url;
    });
  }
}
