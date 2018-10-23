function clickAndDisableLink(workOrderLink) {
  workOrderLink.onclick = function(event) {
    event.preventDefault();
  }
}
