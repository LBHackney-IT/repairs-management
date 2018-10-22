var filterCheckBoxes = [];
var workOrders = [];

function handleToggleTrade() {
  filterCheckBoxes = document.querySelectorAll('.trade-filter-checkbox:checked');
  workOrders = document.querySelectorAll('.hackney-work-order-rows.repairs-history');

  var showTheseTrades = [];

  for(var i = 0; i < filterCheckBoxes.length; i++) {
    showTheseTrades.push(filterCheckBoxes[i].id);
  }

  if (showTheseTrades.length == 0) {
    for(var i = 0; i < workOrders.length; i++) {
      workOrders[i].classList.remove('hidden');
    }
  } else {

    for(var i = 0; i < workOrders.length; i++) {
      workOrders[i].classList.add('hidden');
      if (showTheseTrades.indexOf(workOrders[i].getAttribute("data-trade")) >= 0) {
        workOrders[i].classList.remove('hidden');
      }
    }
  }
}

function handleClearAllFilters() {
  for(var i = 0; i < filterCheckBoxes.length; i++) {
    filterCheckBoxes[i].checked = false;
  }
  for(var i = 0; i < workOrders.length; i++) {
    workOrders[i].classList.remove('hidden');
  }
}

function collapsibleFilter(hierarchyOrTrade) {
  var collapsible = document.querySelector(hierarchyOrTrade + '-filter-collapsible');
  var content = document.querySelector(hierarchyOrTrade + '-hackney-checkbox');

  if (content.style.display === "none") {
    content.style.display = "block";
    collapsible.classList.remove('up-arrow');
    collapsible.classList.add('up-arrow');
  } else {
    content.style.display = "none";
    collapsible.classList.remove('up-arrow');
    collapsible.classList.add('down-arrow');
  }
}

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

function clickAndDisableLink(workOrderLink) {
  workOrderLink.onclick = function(event) {
    event.preventDefault();
  }
}
