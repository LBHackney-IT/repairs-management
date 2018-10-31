function loadAjaxResponse(response, ajaxTab) {

  ajaxTab.innerHTML = response;
};

function handleAjaxResponseApiError(ajaxTab) {
  document.getElementById(ajaxTab).innerHTML = 'There was a problem with an API while fetching data.'
};

function handleAjaxResponse(endpoint, ajaxTab) {
  var xhttpAjaxResponse = new XMLHttpRequest();
  xhttpAjaxResponse.open('GET', endpoint, true);
  xhttpAjaxResponse.onreadystatechange = function() {
    if (xhttpAjaxResponse.readyState == 4) {
      if (xhttpAjaxResponse.status == 200) {
        loadAjaxResponse(xhttpAjaxResponse.response, ajaxTab);
      } else {
        handleAjaxResponseApiError(ajaxTab);
      }
    }
  }
  xhttpAjaxResponse.onerror = handleAjaxResponseApiError;
  xhttpAjaxResponse.send();
}
