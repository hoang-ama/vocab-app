const DEFAULT_APP_URL = "https://h2mvocab.vercel.app";

const openAppBtn = document.getElementById("openAppBtn");
const togglePanelBtn = document.getElementById("togglePanelBtn");
const openTranslatorBtn = document.getElementById("openTranslatorBtn");
const toggleTranslatorPanelBtn = document.getElementById("toggleTranslatorPanelBtn");
const openFavoritesBtn = document.getElementById("openFavoritesBtn");
const openRecencyBtn = document.getElementById("openRecencyBtn");
const saveUrlBtn = document.getElementById("saveUrlBtn");
const customUrlInput = document.getElementById("customUrlInput");
const statusText = document.getElementById("statusText");

const getSavedUrl = async () => {
  const data = await chrome.storage.sync.get(["appUrl"]);
  return data.appUrl || DEFAULT_APP_URL;
};

const openInNewTab = async (suffix = "") => {
  const baseUrl = await getSavedUrl();
  const url = `${baseUrl}${suffix}`;
  await chrome.tabs.create({ url });
};

const toggleInPagePanel = async (suffix = "") => {
  const [activeTab] = await chrome.tabs.query({ active: true, currentWindow: true });
  if (!activeTab || !activeTab.id) {
    setStatus("No active tab available.", true);
    return;
  }

  const baseUrl = await getSavedUrl();
  const appUrl = `${baseUrl}${suffix}`;

  chrome.tabs.sendMessage(
    activeTab.id,
    {
      type: "H2M_TOGGLE_PANEL",
      appUrl
    },
    () => {
      if (chrome.runtime.lastError) {
        setStatus("Cannot inject panel on this page.", true);
        return;
      }
      setStatus("Panel toggled.");
    }
  );
};

const setStatus = (text, isError = false) => {
  statusText.textContent = text;
  statusText.style.color = isError ? "#dc2626" : "#059669";
};

const saveUrl = async () => {
  const raw = customUrlInput.value.trim();
  if (!raw) {
    await chrome.storage.sync.remove(["appUrl"]);
    setStatus("Reset to default URL.");
    return;
  }

  try {
    const normalized = new URL(raw).toString().replace(/\/$/, "");
    await chrome.storage.sync.set({ appUrl: normalized });
    setStatus("Saved custom URL.");
  } catch (error) {
    setStatus("Invalid URL format.", true);
  }
};

const init = async () => {
  const appUrl = await getSavedUrl();
  customUrlInput.value = appUrl;
};

openAppBtn.addEventListener("click", () => openInNewTab());
togglePanelBtn.addEventListener("click", toggleInPagePanel);
openTranslatorBtn.addEventListener("click", () => openInNewTab("?tool=translator"));
toggleTranslatorPanelBtn.addEventListener("click", () => toggleInPagePanel("?tool=translator"));
openFavoritesBtn.addEventListener("click", () => openInNewTab("?view=favorites"));
openRecencyBtn.addEventListener("click", () => openInNewTab("?view=recency"));
saveUrlBtn.addEventListener("click", saveUrl);

init();
