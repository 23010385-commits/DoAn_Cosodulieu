const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
    res.send("Book API Running");
});

app.listen(3000, () => {
    console.log("Server running on port 3000");
});

const db = require("./config/db");

app.get("/books", (req, res) => {

    const sql = "SELECT * FROM books";

    db.query(sql, (err, result) => {

        if (err) {
            return res.status(500).json(err);
        }

        res.json(result);
    });

});