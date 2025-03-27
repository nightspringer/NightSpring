import { post } from '@rails/request.js';
import swal from 'sweetalert';

import I18n from 'retrospring/i18n';
import { showErrorNotification } from 'utilities/notifications';

export function updateDeleteButton(increment = true): void {
  const deleteButton: HTMLElement = document.querySelector('[id^=ib-delete-all]');
  const inboxCount: number = parseInt(deleteButton.getAttribute('data-ib-count'));
  let targetInboxCount = 0;

  if (increment) {
    targetInboxCount = inboxCount + 1;
  }
  else {
    targetInboxCount = inboxCount - 1;
  }

  deleteButton.setAttribute('data-ib-count', targetInboxCount.toString());

  if (targetInboxCount > 0) {
    deleteButton.removeAttribute('disabled');
  } else {
    deleteButton.setAttribute('disabled', 'disabled');
  }
}

export function deleteAllQuestionsHandler(event: Event): void {
  const button = event.target as Element;
  const count = button.getAttribute('data-ib-count');

  swal({
    title: I18n.translate('frontend.inbox.confirm_all.title', { count: count }),
    text: I18n.translate('frontend.inbox.confirm_all.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('voc.delete'),
    cancelButtonText: I18n.translate('voc.cancel'),
    closeOnConfirm: true
  }, (returnValue) => {
    if (returnValue === false) {
      return;
    }

    post('/ajax/delete_all_inbox')
      .then(async response => {
        const data = await response.json;

        if (!data.success) return false;

        updateDeleteButton(false);
        document.querySelector('#entries').innerHTML = 'Nothing to see here!';
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
      });
  });
}

export function deleteAllAuthorQuestionsHandler(event: Event): void {
  const button = event.target as Element;
  const count = button.getAttribute('data-ib-count');
  const urlSearchParams = new URLSearchParams(window.location.search);

  swal({
    title: I18n.translate('frontend.inbox.confirm_all.title', { count: count }),
    text: I18n.translate('frontend.inbox.confirm_all.text'),
    type: "warning",
    showCancelButton: true,
    confirmButtonColor: "#DD6B55",
    confirmButtonText: I18n.translate('voc.delete'),
    cancelButtonText: I18n.translate('voc.cancel'),
    closeOnConfirm: true
  }, (returnValue) => {
    if (returnValue === null) return false;

    post(`/ajax/delete_all_inbox/${urlSearchParams.get('author')}`)
      .then(async response => {
        const data = await response.json;

        if (!data.success) return false;

        updateDeleteButton(false);
        document.querySelector('#entries').innerHTML = 'Nothing to see here!';
      })
      .catch(err => {
        console.log(err);
        showErrorNotification(I18n.translate('frontend.error.message'));
      });
  });
}
