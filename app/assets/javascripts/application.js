// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require govuk-frontend/all
//= require_tree .

(function() {
  copyWorkOrderNotesContentToClipboard();
})();

function copyWorkOrderNotesContentToClipboard() {
  var notes = document.getElementsByClassName('hackney-note-info__content');
  for (i = 0; i < notes.length; i++) {
    notes[i].addEventListener('dblclick', function(element) {
      var tempTextArea = document.createElement('textarea');
      tempTextArea.value = element.target.textContent;
      document.body.appendChild(tempTextArea);
      tempTextArea.focus();
      tempTextArea.select();
      document.execCommand('copy');
      tempTextArea.remove();
    });
  }
}
