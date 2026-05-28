module.exports = (req, res) => {
  const supabaseUrl =
    process.env.VOCAB_SUPABASE_URL ||
    process.env.SUPABASE_URL ||
    "";
  const supabaseAnonKey =
    process.env.VOCAB_SUPABASE_ANON_KEY ||
    process.env.SUPABASE_ANON_KEY ||
    "";
  const geminiApiKey =
    process.env.VOCAB_GEMINI_API_KEY ||
    process.env.GEMINI_API_KEY ||
    "";

  res.setHeader("Content-Type", "application/javascript; charset=utf-8");
  res.setHeader("Cache-Control", "no-store, max-age=0");
  res.status(200).send(
    `window.VOCAB_SUPABASE_URL = ${JSON.stringify(supabaseUrl)};
window.VOCAB_SUPABASE_ANON_KEY = ${JSON.stringify(supabaseAnonKey)};
window.VOCAB_GEMINI_API_KEY = ${JSON.stringify(geminiApiKey)};`
  );
};
