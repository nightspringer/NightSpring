import { get, post } from '@rails/request.js';
import I18n from "retrospring/i18n";
import { showNotification } from "utilities/notifications";

export function enableHandler (event: Event): void {
  event.preventDefault();

  try {
    installServiceWorker()
      .then(subscribe)
      .then(async subscription => {
        return Notification.requestPermission().then(permission => {
          if (permission != "granted") {
            return;
          }

          post('/ajax/web_push', {
            body: {
              subscription
            },
            contentType: 'application/json'
          }).then(async response => {
            const data = await response.json;

            if (data.success) {
              new Notification(I18n.translate("frontend.push_notifications.subscribe.success.title"), {
                body: I18n.translate("frontend.push_notifications.subscribe.success.body")
              });
            } else {
              new Notification(I18n.translate("frontend.push_notifications.fail.title"), {
                body: I18n.translate("frontend.push_notifications.fail.body")
              });
            }
          });
        });
      });
    } catch (error) {
      console.error("Failed to set up push notifications", error);
      showNotification(I18n.translate("frontend.push_notifications.setup_fail"));
    }
}

async function installServiceWorker(): Promise<ServiceWorkerRegistration> {
  return navigator.serviceWorker.register("/service_worker.js", { scope: "/" });
}

async function getServerKey(): Promise<Buffer> {
  const response = await get("/ajax/webpush/key");
  const data = await response.json;
  return Buffer.from(data.key, 'base64');
}

async function subscribe(registration: ServiceWorkerRegistration): Promise<PushSubscription> {
  const key = await getServerKey();
  return await registration.pushManager.subscribe({
    userVisibleOnly: true,
    applicationServerKey: key
  });
}
