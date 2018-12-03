function showAddNoteForm() {
  document.querySelector('.hackney-add-note__form').classList.remove('hidden');
  document.querySelector('.hackney-add-note__text').classList.add('hidden');
}

function isValidNote(event) {
  event.preventDefault();

  var formText = event.target.elements.note_text.value;

  if (formText.replace(/\s/g, "") == "") {
    if (!document.querySelector('.govuk-error-message')) {
      addErrorSummary(event);
    }

    return false;

  } else {

    var destinationId = 'notes-tab';
    postAjaxForm(event, destinationId);
  }
}

function addErrorSummary(event) {
  var notesForm = document.getElementById("notes-form");
  var invalidText = document.createElement("div");
  var notesTextField = event.target.elements.note_text;

  invalidText.classList.add('govuk-error-message');
  invalidText.innerHTML = 'Notes field cannot be empty';

  notesForm.insertBefore(invalidText, notesForm.firstChild);
  notesTextField.classList.add('hackney-note__invalid-border');

  document.querySelector('.govuk-button.publish-notes-button').removeAttribute("data-disable-with");
}
