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
//= require govuk-frontend/all
//= require ajax
//= require repair-history-filter
//= require building-type-filter
//= require disable-link-after-click
//= require_tree .

// This disables govuk tab behaviour. On a mobile device the tab content now remain in separate tabs, rather than
// being on one long page.
window.GOVUKFrontend.Tabs.prototype.setupResponsiveChecks = function () {
  this.mql = window.matchMedia('(min-width: 0em)');
  this.mql.addListener(this.checkMode.bind(this));
  this.checkMode();
};
