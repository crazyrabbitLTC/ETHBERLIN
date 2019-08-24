var express = require("express");
var app = express();
const wordList = require("./data/WordDao_SignedWordList.json");

//const wordObj = JSON.parse(wordList);
console.log("Hello: ", wordList["hello"].signature);
console.log("Word List Parsed.");

app.get("/:word", function(req, res) {
  res.setHeader("Access-Control-Allow-Origin", "http://localhost:3001");
  res.send(wordList[req.params.word].signature);
});
app.post("/", (req, res) => {
  return res.send(`Received a POST HTTP method: ${JSON.parse(req)}`);
});

app.listen(3000, () => {
  console.log("Server running on port 3000");
});
