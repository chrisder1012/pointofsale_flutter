"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const stripe = require('stripe')("pk_live_51GdI0GAvPCmOyedyBmU45Q5c5JRJq9nuOD97xMJSfCOTBVxZgZed0ttp6V4uoDS5nOEWaFZcojJOjJmHCesXMbX000tvtRhLBU");
const cors = require('cors')({ origin: true });
admin.initializeApp(functions.config().firebase);


// Creates a Payment Method (Credit Card)
// Example: createPaymentMethod.post().form({})
exports.createTokenFromCard = functions
.runWith({
      timeoutSeconds: 10,
    }).https.onRequest((req, res) => {
    res.setHeader("Access-Control-Allow-Origin", "*");
    res.setHeader("Access-Control-Allow-Headers", "content-type");
    return cors(req, res, () => {
        stripe.tokens.create({
            card: {
                number: req.body.number,
                exp_month: req.body.exp_month,
                exp_year: req.body.exp_year,
                cvc: req.body.cvc,
            },
        }, function (err, customer) {
            if (customer) {
                res.status(200).send({"message" :"Success","status":true,"data":customer});
            }
            else {
                res.status(err.statusCode).send({"message" :err.message,"status":false});
                reportError(err);
            }
        });
    });
});


// To keep on top of errors, we should raise a verbose error report with Stackdriver rather
// than simply relying on console.error. This will calculate users affected + send you email
// alerts, if you've opted into receiving them.
// [START reporterror]
function reportError(err, context = {}) {
    console.log(err);
}
// [END reporterror]
////# sourceMappingURL=index.js.map
