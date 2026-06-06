const APP_URL = "https://h2mvocab.vercel.app";

const openAppBtn = document.getElementById("openAppBtn");
const toggleVocabPanelBtn = document.getElementById("toggleVocabPanelBtn");

const openInNewTab = async () => {
  await chrome.tabs.create({ url: APP_URL });
};

const toggleInPagePanel = async () => {
  const [activeTab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (!activeTab || !activeTab.id) return;

  chrome.tabs.sendMessage(
    activeTab.id,
    {
      type: "H2M_TOGGLE_PANEL",
      appUrl: `${APP_URL}?tool=translator`
    },
    () => {
      if (chrome.runtime.lastError) {
        console.warn("Cannot inject panel on this page.", chrome.runtime.lastError);
      }
    }
  );
};

openAppBtn.addEventListener("click", openInNewTab);
toggleVocabPanelBtn.addEventListener("click", toggleInPagePanel);
