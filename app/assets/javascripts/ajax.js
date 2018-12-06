function handleAjaxResponse(endpoint, ajaxTab) {
  var errorHandler = function() {
    ajaxTab.innerHTML = 'There was a problem with an API while fetching data.'
  };

  var successHandler = function(request) {
    ajaxTab.innerHTML = request.response;
  };

  sendAjaxRequest('GET', endpoint, null, null, successHandler, errorHandler)
}

function handleAjaxRepairsHistoryFiveYears(endpoint) {
  showLoadingMessage();

  var ajaxTab = document.getElementById('repair-history-tab');

  var errorHandler = function() {
    ajaxTab.innerHTML = 'There was a problem with an API while fetching data.'
  };

  var successHandler = function(request) {
    ajaxTab.innerHTML = request.response;
    handleRepairHistoryYearsInfoText();
  };

  sendAjaxRequest('GET', endpoint, null, null, successHandler, errorHandler)
}

function sendAjaxRequest(method, endpoint, formData, csrfToken, successHandler, errorHandler) {
  var request = new XMLHttpRequest();
  request.open(method, endpoint, true);

  if (method === 'POST') {
    request.setRequestHeader('X-CSRF-Token', csrfToken);
  }

  request.onreadystatechange = function() {
    if (request.readyState === 4) {
      if (request.status === 200) {
        successHandler(request);
      } else {
        errorHandler();
      }
    }
  };

  request.onerror = errorHandler;
  request.send(formData);
}

function postAjaxForm(event, destinationId) {
  event.preventDefault();

  var destination = document.getElementById(destinationId);

  var form = event.target;

  var csrfToken = form.elements.namedItem('authenticity_token').value;

  var FD = new FormData(form);

  destination.innerHTML = '<p class="ajax-loading govuk-caption-m">Publishing note</p>';

  sendAjaxRequest('POST', form.action, FD, csrfToken,
    function (request) { destination.innerHTML = request.response; },
    function () { destination.innerHTML = "There was a problem submitting your form"; }
  );
}

function showLoadingMessage() {
  var loadRepairsDiv = document.querySelectorAll('.load-repairs-history');
  var loadingText = document.querySelectorAll('.loading-repairs-history-text');
  var repairHistoryYearsInfo = document.querySelectorAll('.repair-history-years-info');

  for(var i = 0; i < loadRepairsDiv.length; i++) {
    repairHistoryYearsInfo[i].classList.add('hidden');
    loadingText[i].classList.remove('hidden');
    loadRepairsDiv[i].parentNode.replaceChild(loadingText[i], loadRepairsDiv[i]);
  }
}

function handleRepairHistoryYearsInfoText() {
  var repairHistoryYearsInfo = document.querySelectorAll('.repair-history-years-info');
  var loadRepairsDiv = document.querySelectorAll('.load-repairs-history');

  for(var i = 0; i < repairHistoryYearsInfo.length; i++) {
    repairHistoryYearsInfo[i].classList.remove('hidden');
    if (document.querySelector('.hackney-work-order-rows')) {
      repairHistoryYearsInfo[i].innerHTML = 'Repairs history is showing jobs raised in the <strong>last 5 years</strong>.'
    } else {
      repairHistoryYearsInfo[i].innerHTML = 'There are no work orders within the <strong>last 5 years</strong>.'
    }
  }

  for(var i = 0; i < loadRepairsDiv.length; i++) {
    loadRepairsDiv[i].parentNode.removeChild(loadRepairsDiv[i]);
  }
}
