
FacebookAlbumSelector = {
  albums: new Array(),
  inited: false,
  block_id: 'facebook_albums',
  form_name: 'facebook_media_',

  init: function(block_id, form_name) {
    if(this.inited) {  return; }
    this.inited = true;

    this.block_id = block_id;
    this.form_name = form_name;

    FB.api('/me/albums', function(response) {
      for( var i=0; i<response.data.length; i++ ) {
        var name = response.data[i].name;
        var id = response.data[i].id;
        if( ! name ) { name = "Photo Album " + (i+1); }
        if( response.data[i].privacy == "everyone" && response.data[i].count > 0 ) {
          FacebookAlbumSelector.albums.push({
            id: id,
            name: name,
            type: 'album',
            picture: null,
            link: response.data[i].link,
            count: response.data[i].count,
            author_id: response.data[i].from.id,
            author_name: response.data[i].from.name
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

  album: function(id) {
    for(var i=0; i<this.albums.length; i++) {
      if( this.albums[i].id == id ) {
        return this.albums[i];
      }
    }
    return null;
  },

  select: function(id) {
    $$('.fb_album').each(function(e) { e.className = 'fb_album' });
    $(this.block_id).className = '';

    var album = this.album(id);
    if(album == null) { return; }

    if( $(this.form_name + '_id').value == id ) {
      $(this.form_name + '_id').value = '';
    } else {
      $(this.form_name + '_id').value = id;
      $(this.form_name + '_name').value = album.name;
      $(this.form_name + '_link').value = album.link;
      $(this.form_name + '_count').value = album.count;
      $(this.form_name + '_type').value = album.type;
      $(this.form_name + '_picture').value = album.picture;
      $(this.form_name + '_author_name').value = album.author_name;
      $(this.form_name + '_author_id').value = album.author_id;
      $('fb_album_' + id).className = 'fb_album fb_album_selected';
    }
  },

  ready: function(id) {
    if(this.inited == false) { return; }

    if(this.is_ready() == false ) {
      setTimeout('FacebookAlbumSelector.ready();', 100);
      return;
    }

    for( var i=0; i<this.albums.length; i++ ) {
      var onclick = 'FacebookAlbumSelector.select("' + this.albums[i].id + '");';

      var className = this.albums[i].id == id ? 'fb_album fb_album_selected' : 'fb_album';
      $(this.block_id).insert( Builder.node('div', {className: className, id: 'fb_album_' + this.albums[i].id},
                                            [
                                             Builder.node('a', {className: 'fb_album_photo', href: 'javascript:void(0);', onclick: onclick},
                                                          [Builder.node('img', {src: this.albums[i].picture, width: 90, alt: this.albums[i].name, title: this.albums[i].name})]),
                                             Builder.node('a', {className: 'fb_album_name', href: 'javascript:void(0);', onclick: onclick}, this.albums[i].name)
                                            ]
                                           ));
    }
  }
}
