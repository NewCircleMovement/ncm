var stripe;
var checkoutSessionId;

function subscribeToMembership(membership_id) {
  const body = { membership_id: membership_id }
  createCheckoutSession('create_subscription', body);
}

function updateCreditCard() {
  const body = {}
  createCheckoutSession('update_card', body);
}
 

function getApiUrl(action) {
  switch (action) {
    case 'create_subscription': return "/api/v1/stripe/new_subscription_session";
    case 'update_card': return "/api/v1/stripe/update_card_session";
  }
}

var createCheckoutSession = function(action, body) {
  const url = getApiUrl(action)
  fetch(url, {
    method: "POST",
    headers: {
      "Content-Type": "application/json"
    },
    body: JSON.stringify(body)
  })
  .then(function(result) {
    return result.json();
  })
  .then(function(data) {
    checkoutSessionId = data.checkoutSessionId;
    switch (action) {
      case 'create_subscription':
        beginStripePayment(checkoutSessionId);
        break;
      case 'update_card':
        beginCardUpdate(checkoutSessionId);
        break;
    }
    
  });
};

function beginStripePayment(checkoutSessionId) {
  stripe
    .redirectToCheckout({
      sessionId: checkoutSessionId
    })
    .then(function(result) {
      console.log("error", result);
      alert(result.error.message);
    })
    .catch(function(err) {
      console.log(err);
    });
}


function beginCardUpdate(checkoutSessionId) {
  stripe.redirectToCheckout({
    sessionId: checkoutSessionId
  }).then(function (result) {
    console.log("error", result);
    alert(result.error.message);
  });
}

//------------------------------------------------------------------------------------

var setupElements = function(endSession) {
  fetch("/api/v1/stripe/public_key", {
    method: "GET",
    headers: {
      "Content-Type": "application/json"
    }
  })
  .then(function(result) {
    return result.json();
  })
  .then(function(data) {
    stripe = Stripe(data.publicKey);
    if (endSession) {
      checkout = stripe.retr
    }
  });
};

setupElements(false);


