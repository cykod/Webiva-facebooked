
FacebookAlbumSelector = {
  albums: new Array(),
  inited: false,
  block_id: 'facebook_albums',
  login_id: 'facebook_login',
  heading_id: 'facebook_heading',
  form_name: 'facebook_media_',

  init: function(form_name) {
    if(this.inited) {  return; }
    this.inited = true;

    this.form_name = form_name;

    $(this.block_id).hide();

    $(this.heading_id).innerHTML = 'Fetching Facebook photo albums ...';

    this.fetch();
  },

  fetch: function() {
    new Ajax.Request('/website/facebooked/api/albums', {onComplete: function(transport) {
      var response = transport.responseText.evalJSON();

      if( ! response  ) {
        $(FacebookAlbumSelector.heading_id).hide();
        $(FacebookAlbumSelector.login_id).show();
        return;
      }

      for( var i=0; i<response.length; i++ ) {
        var name = response[i].name;
        var id = response[i].id;
        if( ! name ) { name = "Photo Album " + (i+1); }

        FacebookAlbumSelector.albums.push({
          id: id,
          name: name,
          type: 'album',
          link: response[i].link,
          count: response[i].count,
          author_id: response[i].author_id,
          author_name: response[i].author_name,
          picture: response[i].picture,
          thumbnail: response[i].thumbnail,
          width: response[i].width,
          height: response[i].height
        });
      }
 
      FacebookAlbumSelector.ready();
    }});
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
    $$('.fb_album_image').each(function(e) { e.className = 'fb_album_image' });
    $$('.fb_album_name').each(function(e) { e.className = 'fb_album_name' });
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
      $(this.form_name + '_width').value = album.width;
      $(this.form_name + '_height').value = album.height;
      $(this.form_name + '_author_name').value = album.author_name;
      $(this.form_name + '_author_id').value = album.author_id;
      $('fb_album_image_' + id).className = 'fb_album_image fb_album_image_selected';
      $('fb_album_name_' + id).className = 'fb_album_name fb_album_name_selected';
    }
  },

  ready: function(id) {
    if(this.inited == false) { return; }

    var imageRow = Builder.node('tr', {className: 'fb_album_images'});
    var nameRow = Builder.node('tr', {className: 'fb_album_names'});

    for( var i=0; i<this.albums.length; i++ ) {
      var onclick = 'FacebookAlbumSelector.select("' + this.albums[i].id + '");';

      var className = this.albums[i].id == id ? 'fb_album_image fb_album_image_selected' : 'fb_album_image';
      imageRow.insert(Builder.node('td', {className: className, id: 'fb_album_image_' + this.albums[i].id},
                                   Builder.node('a', {className: 'fb_album_photo', href: 'javascript:void(0);', onclick: onclick},
                                                Builder.node('img', {src: this.albums[i].thumbnail, width: 90, alt: this.albums[i].name, title: this.albums[i].name}))));

      className = this.albums[i].id == id ? 'fb_album_name fb_album_name_selected' : 'fb_album_name';
      nameRow.insert(Builder.node('td', {className: className, id: 'fb_album_name_' + this.albums[i].id},
                                  Builder.node('a', {className: 'fb_album_name', href: 'javascript:void(0);', onclick: onclick}, this.albums[i].name)));
    }

    $(this.heading_id).innerHTML = 'Share your Facebook photo albums';
    if(this.albums.length == 0) {
      $(this.block_id).insert(Builder.node('p', {style: "text-align:center;"}, "You have no Public Photo Albums, make an Album public to post it."));
    } else {
      $(this.block_id).insert(Builder.node('table', {}, [imageRow, nameRow]));
    }
    $(this.block_id).show();
  }
}
