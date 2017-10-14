$(function() {
	var members = undefined;
	var fruits = undefined;
	var yield = undefined;
	var size = undefined;
	var submit = undefined;
	var displayMessages = undefined;
	var yield = undefined;

	
	var editEngagement = document.getElementById("edit-engagement");
	if (editEngagement) {
		set_variables();
		set_listeners();		
		check_seed();
	}
	
	function set_variables() {
		displayMessages = document.getElementById("messages");
		submit = document.getElementById("submit");
		size = document.getElementById("epicenter_size");
		members = document.getElementById("epicenter_depth_members");
		fruits = document.getElementById("epicenter_depth_fruits");
		yield = document.getElementById("epicenter_monthly_fruits_basis");
	}

	function set_listeners() {
		members.addEventListener('keyup', check_seed);
		fruits.addEventListener('keyup', check_seed);	
		$('select#epicenter_size').change(size_selection);
	}

	
	function size_selection() {
		var selected_size = size.options[size.selectedIndex].value;
		switch (selected_size)
		{
			case 'Tribe':
				members.value = 100;
				break;
			case 'Movement':
				members.value = 1000;
				break;
		}
	}


	function check_seed() {
		var messages = [];
		var seedIsOk = false;

		var membersValue = members.value;
		var fruitsValue = fruits.value;

		var requirements = {
			members: { min: 0, max: 0 },
			fruits: { min: 0, max: 0}
		}

		var selected_size = size.options[size.selectedIndex].value;
		

		switch (selected_size)
		{
			case 'Tribe':
				requirements = {
					members: { min: 100, max: 1000 },
					fruits: { min: 30000, max: 100000 }
				}
				break;

			case 'Movement':
				requirements = {
					members: { min: 1000, max: 10000 },
					fruits: { min: 30000, max: 150000 }
				}
				break;

		}

		if (membersValue < requirements.members.min) {
			messages.push(`Medlemmer skal minimum være ${requirements.members.min}`);
		}

		if (membersValue > requirements.members.max) {
			messages.push(`Medlemmer må højst være ${requirements.members.max}`);
		}

		if (fruitsValue < requirements.fruits.min) {
			messages.push(`Vanddråber skal være over ${requirements.fruits.min}`);
		} 

		if (fruitsValue > requirements.fruits.max) {
			messages.push(`Vanddråber må ikke være over ${requirements.fruits.max}`);
		}

		seedIsOk = (messages.length == 0);
		
		if (seedIsOk) {
			submit.disabled = false
			displayMessages.innerHTML = '';
		} else {
			submit.disabled = true
			displayMessages.innerHTML = messages.join(', ');
		}
		
	}

});