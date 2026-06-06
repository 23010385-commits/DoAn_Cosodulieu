const express = require("express");
const cors = require("cors");

const app = express();

app.use(cors());
app.use(express.json());

app.get("/", (req, res) => {
    res.send("Book API Running");
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
app.use(express.json());

const bookRoutes = require("./routes/bookRoutes");

app.use("/api/books", bookRoutes);

app.listen(3000, () => {
    console.log("Server running on port 3000");
});