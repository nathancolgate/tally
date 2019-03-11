var Choices = {
  complete_add: function(request) {
    TallyFlash.clear();
    if(request.status == 200) {
      var ch = $('choices');
      new Effect.Highlight(ch.childNodes[ch.childNodes.length-1]);
      Field.clear('choice_body');
      TallyFlash.set_notice('Choice added successfully.');
    } else {
      TallyFlash.set_error(request.responseText);
    }
  },

  complete_destroy: function(request, choice_id) {
    if(request.status == 200) {
      TallyFlash.set_notice('Choice deleted.');
      new Effect.Fade('choice_' + choice_id);
    }
  }
};

var Reply = {
  create_complete: function(request) {},
  
  rapid_create_complete: function(request) {
    if (request.status == 200) {
      new Effect.Highlight($('rf_left'));
      new Ajax.Updater('rf_right','/polls/rapid_get');
    }
  }
};

var Tags = {
  complete_tag: function(request) {
    TallyFlash.clear();
    if (request.status == 200) {
      var tags = $('tags');
      new Effect.Highlight(tags.childNodes[tags.childNodes.length - 1]);
      Field.clear('tag_tag');
      TallyFlash.set_notice('Tag added successfully.');
    } else {
      TallyFlash.set_error(request.responseText);
    }
  },
  
  complete_untag: function(request, tag_id) {
    if (request.status == 200) {
      TallyFlash.set_notice('Tag deleted.');
      new Effect.Fade('tag_' + tag_id);
    }
  }
}

var Auth = {
  login_complete: function(request) {
    TallyFlash.clear();
    if(request.status == 200) {
      window.location.reload();
    } else {
      TallyFlash.set_error(request.responseText);
    }
  },

  logoff_complete: function(request) {
    if(request.status == 200) {
      window.location.reload();
    }
  }
}

var TallyFlash = {
  set: function(msg, cls) {
    var fl = $('flash');
    fl.innerHTML = msg;
    fl.className = cls;
    new Effect.Highlight(fl);
  },
  set_error: function(msg) {
    TallyFlash.set(msg, 'error');
  },
  set_notice: function(msg) {
    TallyFlash.set(msg, 'notice');
  },
  clear: function() {
    var fl = $('flash');
    fl.innerHTML = '';
    fl.className = '';
  }
}