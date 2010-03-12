
Facebooked = {
  logout: function(url) {
    FB_RequireFeatures(["Connect"], function() {
      if(FB.Connect.get_loggedInUser()) {
        FB.Connect.logoutAndRedirect(url);
      } else {
        window.location = url;
      }
    });
  },

  showPermissionDialog: function(permissions) {
    FB_RequireFeatures(["Connect", "CanvasUtil"], function() {
      if(FB.Connect.get_loggedInUser()) {
        FB.Connect.showPermissionDialog(permissions, function(perms) {window.location.reload(true);});
      }
    });
  },

  init: function(api_key, xd_receiver_url, permissions) {
    FB_RequireFeatures(["Connect"], function() {
      if( permissions ) {
        FB.init(api_key, xd_receiver_url, {permsToRequestOnConnect: permissions});
      } else {
	FB.init(api_key, xd_receiver_url);
      }
    });
  }
}
