
Facebooked = {
  logged_in: false,

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

  isConnected: function() {
    if( ! Facebooked.logged_in ) {
      window.location.reload();
    }
  },

  isNotConnected: function() {
    if( Facebooked.logged_in ) {
      window.location.reload();
    }
  },

  init: function(api_key, xd_receiver_url, permissions, logged_in) {
    Facebooked.logged_in = logged_in;

    if( permissions ) {
      FB.init(api_key, xd_receiver_url, {ifUserConnected: Facebooked.isConnected,
		                         ifUserNotConnected: Facebooked.isNotConnected,
		                         permsToRequestOnConnect: permissions});
    } else {
      FB.init(api_key, xd_receiver_url, {ifUserConnected: Facebooked.isConnected,
		                         ifUserNotConnected: Facebooked.isNotConnected});
    }
  },

  setup: function(facebook_script_src, api_key, xd_receiver_url, permissions, logged_in) {
    var head = document.getElementsByTagName("head")[0],
        script = document.createElement("script"),
        done = false;

    script.src = facebook_script_src;

    script.onload = script.onreadystatechange = function(){
      if( !done && (!this.readyState || this.readyState == "loaded" || this.readyState == "complete") ) {
	done = true
	Facebooked.init(api_key, xd_receiver_url, permissions, logged_in);
      }
    }

    head.appendChild(script);
  }
}
