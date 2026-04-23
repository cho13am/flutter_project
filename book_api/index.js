const express = require('express')
const cors = require('cors')
const mysql = require('mysql2')
require('dotenv').config()
const app = express()

app.use(cors())
app.use(express.json())

const connection = mysql.createConnection(process.env.DATABASE_URL)

app.get('/', (req, res) => {
    res.send('Hello world!!')
})

app.get('/books', (req, res) => {
    connection.query(
        'SELECT * FROM books',
        function (err, results) {
            if(err) {
                res.status(500).send(err);
            } else {
                res.send(results);
            }
        }
    )
})

app.get('/books/:id', (req, res) => {
    const id = req.params.id;
    connection.query(
        'SELECT * FROM books WHERE id = ?', [id],
        function (err, results) {
            if(err) {
                res.status(500).send(err);
            } else {
                res.send(results[0]);
            }
        }
    )
})

app.post('/books', (req, res) => {
    connection.query(
        'INSERT INTO `books` (`title`, `author`, `category`, `status`, `image_url`) VALUES (?, ?, ?, ?, ?)',
        [req.body.title, req.body.author, req.body.category, req.body.status, req.body.image_url],
         function (err, results) {  
            if (err) {
                console.error('Error in POST /books:', err);
                res.status(500).send('Error adding book');
            } else {
                res.status(200).send(results);
            }
        }
    )
})

app.put('/books', (req, res) => {
    const sql = 'UPDATE `books` SET `title`=?, `author`=?, `category`=?, `status`=?, `image_url`=? WHERE id=?';
    
    const values = [req.body.title, req.body.author, req.body.category, req.body.status, req.body.image_url, req.body.id];

    connection.query(sql, values, function (err, results) {
        if(err) {
            console.error('SQL Error:', err);
            res.status(500).send(err);
        } else {
            res.send(results);
        }
    });
});

app.delete('/books', (req, res) => {
    connection.query(
        'DELETE FROM `books` WHERE id =?',
        [req.body.id],
        function (err, results) {
            if(err) {
                res.status(500).send(err);
            } else {
                res.send(results[0]);
            }
        }
    )
})

app.listen(process.env.PORT || 3000, () => {
    console.log('CORS-enabled web server listening on port 3000')
})

// export the app for vercel serverless functions
module.exports = app;