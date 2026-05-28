const DEFAULT_APP_URL = "https://h2mvocab.vercel.app";
const MENU_ID = "open-h2m-vocabulary";

const getAppUrl = async () => {
  const data = await chrome.storage.sync.get(["appUrl"]);
  return data.appUrl || DEFAULT_APP_URL;
};

chrome.runtime.onInstalled.addListener(() => {
  chrome.contextMenus.create({
    id: MENU_ID,
    title: "Open H2M Vocabulary Builder",
    contexts: ["action"]
  });
});

chrome.contextMenus.onClicked.addListener(async (info) => {
  if (info.menuItemId !== MENU_ID) return;
  const url = await getAppUrl();
  chrome.tabs.create({ url });
});
