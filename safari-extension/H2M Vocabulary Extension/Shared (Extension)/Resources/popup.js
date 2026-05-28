const DEFAULT_APP_URL = "https://h2mvocab.vercel.app";

const openAppBtn = document.getElementById("openAppBtn");
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
openFavoritesBtn.addEventListener("click", () => openInNewTab("?view=favorites"));
openRecencyBtn.addEventListener("click", () => openInNewTab("?view=recency"));
saveUrlBtn.addEventListener("click", saveUrl);

init();
