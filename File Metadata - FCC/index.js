var express = require('express');
var cors = require('cors');
require('dotenv').config()

var app = express();
var multer = require('multer');
var upload = multer({ dest: 'uploads/' });

app.use(cors());
app.use('/public', express.static(process.cwd() + '/public'));

app.get('/', function (req, res) {
  res.sendFile(process.cwd() + '/views/index.html');
});

app.post('/api/fileanalyse', upload.single('upfile'), function (req, res) {
try {
  res.json({"name" : req.file.originalname, "type" : req.file.mimetype, "size" : req.file.size })
  console.log(req.file.originalname, req.file.mimetype,req.file.size)
} catch (err){res.json({message : "Error loading file"})}
});


const port = process.env.PORT || 3000;
app.listen(port, function () {
  console.log('Your app is listening on port ' + port)
});
