function showAddNoteForm() {
  document.querySelector('.hackney-add-note__form').classList.remove('hidden');
  document.querySelector('.hackney-add-note__text').classList.add('hidden');
}

function isValidNote(event) {
  event.preventDefault();

  var formText = event.target.elements.note_text.value;

  if (formText.replace(/\s/g, "") == "") {
    addNoteErrorSummary(event, 'Notes field cannot be empty');
    // Api needs to change from 50 to 2000
  } else if (formText.length > 2000) {
    addNoteErrorSummary(event, "Notes field cannot exceed 2000 characters");
  } else {
    postAjaxForm(event, 'notes-tab');
  }
}

function addNoteErrorSummary(event, errorMessage) {
  var invalidText = document.querySelector('#notes-form .govuk-error-message');

  if (!invalidText) {
    var notesForm = document.getElementById("notes-form");
    var notesTextField = event.target.elements.note_text;

    invalidText = document.createElement("div");
    invalidText.classList.add('govuk-error-message');
    notesForm.insertBefore(invalidText, notesForm.firstChild);
    notesTextField.classList.add('hackney-note__invalid-border');
  }

  invalidText.innerHTML = errorMessage;

  document.querySelector('.govuk-button.publish-notes-button').removeAttribute("data-disable-with");
}
