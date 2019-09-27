var express = require("express");
var router = express.Router();

/* GET greeting */
router.get("/sayhello", function(req, res) {
  res.send("Hello there!");
});

module.exports = router;