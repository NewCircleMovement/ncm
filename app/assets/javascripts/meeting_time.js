$(function() {
	var meetingTime = document.getElementById('meeting-time');

	var meetingTimeChoice = document.getElementById('meeting-time-choice');
	var meetingTimeForm = document.getElementById('meeting-time-form');
	var meetingTimeYes = document.getElementById('meeting-time-yes');


	meetingTimeYes.onclick = function () {
		meetingTimeChoice.style.display = 'none';
		meetingTimeForm.style.display = '';
	}

	// if (meetingTime) {
	// 	console.log('active');
	// 	set_variables();
	// 	// meetingTimeChoice.onclick() = function () {
	// 	// 	test();
	// 	// }
	// }


	// function set_variables() {

	// }

	function test() {
		console.log('TEST');
	}

});