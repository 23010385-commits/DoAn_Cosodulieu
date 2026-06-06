const db = require("../config/db");
exports.getAllBooks = async (req, res) => {
    try {

        const [rows] = await db.query(`
            SELECT
                b.book_id,
                b.title,
                b.published_year,
                p.name AS publisher
            FROM books b
            LEFT JOIN publishers p
                ON b.publisher_id = p.publisher_id
        `);

        return res.status(200).json(rows);

    } catch (err) {

        console.error(err);

        return res.status(500).json({
            message: "Internal Server Error",
            error: err.message
        });
    }
};
exports.getBookById = async (req, res) => {

    try {

        const [rows] = await db.query(`
            SELECT
                b.book_id,
                b.title,
                b.published_year,
                p.name AS publisher
            FROM books b
            LEFT JOIN publishers p
                ON b.publisher_id = p.publisher_id
            WHERE b.book_id = ?
        `, [req.params.id]);

        if (rows.length === 0) {
            return res.status(404).json({
                message: "Book not found"
            });
        }

        res.json(rows[0]);

    } catch (err) {
        res.status(500).json({
            error: err.message
        });
    }
};
