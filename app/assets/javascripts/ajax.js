function handleAjaxResponse(endpoint, ajaxTab) {
  var request = new XMLHttpRequest();
  var errorHandler = function() {
    ajaxTab.innerHTML = 'There was a problem with an API while fetching data.'
  };

  request.open('GET', endpoint, true);
  request.onreadystatechange = function() {
    if (request.readyState === 4) {
      if (request.status === 200) {
        ajaxTab.innerHTML = request.response;
      } else {
        errorHandler();
      }
    }
  };

  request.onerror = errorHandler;
  request.send();
}

function ajaxRepairsHistoryFiveYears(endpoint) {
  var loadBtn = document.getElementById('load-repair-history-btn');
  loadBtn.classList.add('ajax-loading')

  var tab = document.getElementById('repair-history-tab');
  handleAjaxResponse(endpoint, tab);

  loadBtn.parentNode.removeChild(loadBtn);
}
