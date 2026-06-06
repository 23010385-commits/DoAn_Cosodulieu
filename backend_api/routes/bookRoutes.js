const express = require("express");
const router = express.Router();

const {
    getAllBooks,
    getBookById
} = require("../controllers/bookControllers.js");

router.get("/", getAllBooks);
router.get("/:id", getBookById);

module.exports = router;