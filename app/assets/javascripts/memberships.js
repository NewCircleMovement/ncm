$(function() {
	var monthlyFee = undefined; 
	var depthMembers = undefined;
	var depthFruits = undefined;
	var monthlyDecay = undefined;
	var monthlyFee = undefined; 
	var createMembershipButton = undefined;
	var message = undefined;

	var notEnoughFruit = true;

	var editMemberships = document.getElementById("edit-memberships");
	
	if (editMemberships) {

		set_variables();
		set_listeners();
	}

	function set_variables() {
		monthlyFee = document.getElementById("membership_monthly_fee");	
		depthMembers = document.getElementById("depth_members");
		depthFruits = document.getElementById("depth_fruits");
		monthlyDecay = document.getElementById("monthly_decay");
		monthlyFee = document.getElementById("membership_monthly_fee");	
		createMembershipButton = document.getElementById("create-membership-button");
		backButton = document.getElementById("back-button")
		message = document.getElementById("message");
	}
	
	function set_listeners() {
		monthlyFee.addEventListener('keyup', check_membership);

	}

	function check_membership() {
		var maxSupply = depthMembers.value * monthlyFee.value
		var fruitPeak = maxSupply / monthlyDecay.value;

		notEnoughFruit = (fruitPeak < depthFruits.value) 
		
		createMembershipButton.disabled = notEnoughFruit;
		backButton.style.display = notEnoughFruit ? '' : 'none';

		var minSupply = (depthFruits.value * monthlyDecay.value) / depthMembers.value;

		if (notEnoughFruit) {
			message.innerHTML = `
				Bemærk: Med ${monthlyFee.value} vanddråber pr. måned kan du 
				med ${depthMembers.value} medlemmer maximalt nå
				${fruitPeak} (da ${monthlyDecay.value * 100}% forsvinder hver måned).
				Du skal nå dit minimum på ${depthFruits.value}.
				Sæt enten medlemsskabets månedlige tilførsel op til mindst ${minSupply} 
				eller juster minimum antal medlemmer/frugter.
			`;
		} else {
			message.innerHTML = '';
		}

	}

});