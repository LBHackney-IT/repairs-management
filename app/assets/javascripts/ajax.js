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

function handleAjaxRepairsHistoryFiveYears(endpoint, ajaxTab) {
  handleClickShowRepairsHistoryBtn();

  var ajaxTab = document.getElementById('repair-history-tab');

  var request = new XMLHttpRequest();
  var errorHandler = function() {
    ajaxTab.innerHTML = 'There was a problem with an API while fetching data.'
  };

  request.open('GET', endpoint, true);
  request.onreadystatechange = function() {
    if (request.readyState === 4) {
      if (request.status === 200) {
        ajaxTab.innerHTML = request.response;
        handleRepairHistoryYearsInfoText();
      } else {
        errorHandler();
      }
    }
  };

  request.onerror = errorHandler;
  request.send();
}

function handleClickShowRepairsHistoryBtn() {
  var loadBtn = document.getElementById('load-repair-history-btn');
  var loadingText = document.createElement('p');

  document.querySelector('.repair-history-years-info').classList.add('hidden')
  loadingText.innerHTML = 'Loading repairs history'

  loadBtn.parentNode.replaceChild(loadingText, loadBtn);
  loadingText.classList.add('ajax-loading', 'govuk-caption-m');
}

function handleRepairHistoryYearsInfoText() {
  var repairHistoryYearsInfo = document.querySelector('.repair-history-years-info')
  repairHistoryYearsInfo.classList.remove('hidden');

  if (document.querySelector('.hackney-work-order-table')) {
    repairHistoryYearsInfo.innerHTML = 'Repairs history is showing jobs raised in the last <strong>5 years</strong>.'
  } else {
    repairHistoryYearsInfo.innerHTML = 'There are no work orders within the last <strong>5 years</strong>.'
  }

  document.querySelector('.load-repairs-history').classList.add('hidden');
}
