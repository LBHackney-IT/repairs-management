function applyBuildingFilter(tab_id, content_id) {
  var tabs = document.getElementsByClassName('tabelement');

  var tab_contents = document.getElementsByClassName('tabcontent');
  for(i = 0; i < tabs.length; i++) {
    var el = tab_contents[i];
    el.style.display = 'none';
    el.className = 'tabcontent';
  }
  document.getElementById(content_id).style.display = 'block';
};
