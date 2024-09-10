const express = require('express')
const app = express()
const cors = require('cors')

require('dotenv').config()

const mongoose = require('mongoose')

mongoose.connect(process.env.MONGOOSE_URI);
const userSchema = new mongoose.Schema({
  username: {
    type: String,
    require: [true, 'username must be provided'],
    unique: true
  },
});
const exerciseSchema = new mongoose.Schema({
	userId: String,
	username: String,
	description: { type: String, required: true },
	duration: { type: Number, required: true },
	date: String,
});

let User = mongoose.model("ExerciseUsers", userSchema);
let Exercise = mongoose.model('Exercise', exerciseSchema);

app.use(cors())
app.use(express.static('public'))
app.use(express.urlencoded({ extended: true }))

app.get('/', (req, res) => {
  res.sendFile(__dirname + '/views/index.html')
});

app.get('/api/users', function (_req, res) {
		User.find({}, function (err, users) {
		if (err) {
			console.error(err);
			res.json({
				message: 'Getting all users failed!',
			});
		}
		if (users.length === 0) {
			res.json({ message: 'There are no users in the database!' });
		}
		res.json(users);
	});
});

app.post('/api/users', function (req, res) {
	const inputUsername = req.body.username;
	let newUser = new User({ username: inputUsername });

	newUser.save((err, user) => {
		if (err) {
			console.error(err);
			res.json({ message: 'User creation failed!' });
		}
		res.json({ username: user.username, _id: user._id });
	});
});

app.post('/api/users/:_id/exercises', function (req, res) {
	var userId = req.params._id;
	var description = req.body.description;
	var duration = req.body.duration;
	var date = req.body.date;

	if (!date) {
		date = new Date().toISOString().substring(0, 10);
	}

	User.findById(userId, (err, userInDb) => {
		if (err) {
			console.error(err);
			res.json({ message: 'There are no users with that ID in the database!' });
		}

		let newExercise = new Exercise({
			userId: userInDb._id,
			username: userInDb.username,
			description: description,
			duration: parseInt(duration),
			date: date,
		});

		newExercise.save((err, exercise) => {
			if (err) {
				console.error(err);
				res.json({ message: 'Exercise creation failed!' });
			}

			res.json({
				username: userInDb.username,
				description: exercise.description,
				duration: exercise.duration,
				date: new Date(exercise.date).toDateString(),
				_id: userInDb._id,
			});
		});
	});
});


app.get('/api/users/:_id/logs', async function (req, res) {
	const userId = req.params._id;
	const from = req.query.from || new Date(0).toISOString().substring(0, 10);
	const to =
		req.query.to || new Date(Date.now()).toISOString().substring(0, 10);
	const limit = Number(req.query.limit) || 0;

	let user = await User.findById(userId).exec();

		let exercises = await Exercise.find({
		userId: userId,
		date: { $gte: from, $lte: to },
	})
		.select('description duration date')
		.limit(limit)
		.exec();

	let parsedDatesLog = exercises.map((exercise) => {
		return {
			description: exercise.description,
			duration: exercise.duration,
			date: new Date(exercise.date).toDateString(),
		};
	});

	res.json({
		_id: user._id,
		username: user.username,
		count: parsedDatesLog.length,
		log: parsedDatesLog,
	});
});


const listener = app.listen(process.env.PORT || 3000, () => {
  console.log('Your app is listening on port ' + listener.address().port)
})
