
FacebookAlbumSelector = {
  albums: new Array(),
  inited: false,
  block_id: 'facebook_albums',
  form_element_id: 'facebook_album_id',

  init: function(block_id, form_element_id) {
    if(this.inited) {  return; }
    this.inited = true;

    this.block_id = block_id;
    this.form_element_id = form_element_id;

    FB.api('/me/albums', function(response) {
      for( var i=0; i<response.data.length; i++ ) {
        var name = response.data[i].name;
        var id = response.data[i].id;
        if( ! name ) { name = "Photo Album " + (i+1); }
        if( response.data[i].privacy == "everyone" && response.data[i].count > 0 ) {
          FacebookAlbumSelector.albums.push({
            name: name,
            id: id,
            link: response.data[i].link,
            picture: null
          });
          FacebookAlbumSelector.get_photo( FacebookAlbumSelector.albums[i] );
        }
      }
 
      FacebookAlbumSelector.ready();
    });
  },

  get_photo: function(album) {
    FB.api('/' + album.id, {fields: 'picture'}, function(response) {
      album.picture = response.picture;
    });
  },

  is_ready: function() {
    for( var i=0; i<this.albums.length; i++ ) {
      if( this.albums[i].picture == null ) { return false; }
    }
    return true;
  },

  select: function(id) {
    $$('.fb_album').each(function(e) { e.className = 'fb_album' });
    $(this.block_id).className = '';

    if( $(this.form_element_id).value == id ) {
      $(this.form_element_id).value = '';
    } else {
      $(this.form_element_id).value = id;
      $('fb_album_' + id).className = 'fb_album fb_album_selected';
    }
  },

  ready: function() {
    if(this.inited == false) { return; }

    if(this.is_ready() == false ) {
      setTimeout('FacebookAlbumSelector.ready();', 100);
      return;
    }

    for( var i=0; i<this.albums.length; i++ ) {
      var onclick = 'FacebookAlbumSelector.select("' + this.albums[i].id + '");';

      $(this.block_id).insert( Builder.node('div', {className: 'fb_album', id: 'fb_album_' + this.albums[i].id},
                                            [
                                             Builder.node('a', {className: 'fb_album_photo', href: 'javascript:void(0);', onclick: onclick},
                                                          [Builder.node('img', {src: this.albums[i].picture, width: 80, alt: this.albums[i].name, title: this.albums[i].name})]),
                                             Builder.node('a', {className: 'fb_album_name', href: 'javascript:void(0);', onclick: onclick}, this.albums[i].name)
                                            ]
                                           ));
    }
  }
}
