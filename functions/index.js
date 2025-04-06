const {onRequest} = require("firebase-functions/v2/https");
const axios = require("axios");
require("dotenv").config();

exports.geminiChat = onRequest(async (req, res) => {
  const prompt = req.body.prompt;

  if (!prompt) {
    return res.status(400).json({error: "Missing prompt"});
  }

  try {
    console.log("Gemini API Key:", process.env.GEMINI_API_KEY);
    const response = await axios.post(`https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${process.env.GEMINI_API_KEY}`, {contents: [{parts: [{text: prompt}]}]});

    let text = "No response received.";
    const candidates = response.data.candidates;
    if (
      candidates &&
      candidates.length > 0 &&
      candidates[0].content &&
      candidates[0].content.parts &&
      candidates[0].content.parts.length > 0 &&
      candidates[0].content.parts[0].text
    ) {
      text = candidates[0].content.parts[0].text;
    }

    res.status(200).json({response: text});
  } catch (err) {
    console.error("Gemini API Error:", err.message);
    res.status(500).json({error: "Failed to connect to Gemini API"});
  }
});
