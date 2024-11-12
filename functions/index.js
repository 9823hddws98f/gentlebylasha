// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const logger = functions.logger;
const sgMail = require("@sendgrid/mail");
const cors = require("cors")({origin: true});

admin.initializeApp();
sgMail.setApiKey(
    "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",
);


// method to delete user from firebase auth via uid,
// this method is called from the client side
// this should also delete all the data from firestore
exports.deleteUser = functions.https.onRequest(async (request, response) => {
  cors(request, response, async () => {
    const uid = request.body.data.uid;
    await admin.auth().deleteUser(uid);
    const userRef = admin.firestore().collection("users").doc(uid);
    const userDoc = await userRef.get();
    if (userDoc.exists) {
      await userRef.delete();
      logger.info(`User ${uid} and data deleted successfully`);
      response.send("User and data deleted successfully");
    } else {
      logger.info(`User ${uid} not found`);
      response.send("User not found");
    }
  });
});


// Helper function to send an email
const sendEmail = async (to, subject, htmlContent) => {
  const msg = {
    to: to,
    from: "noreply@headfolk.com",
    subject: subject,
    html: htmlContent,
  };
  await sgMail.send(msg);
};

// Callable function to send an email
exports.sendEmail = functions.https.onRequest(async (request, response) => {
  cors(request, response, async () => {
    try {
      const {to, subject, htmlContent} = request.body.data;

      // Optionally, you can add authentication/authorization logic here

      await sendEmail(to, subject, htmlContent);
      response.send({
        success: true,
        message: "Email sent successfully",
      });
    } catch (error) {
      console.error("Error sending email:", error);
      response.send(new functions.https.HttpsError(
          "internal",
          "Unable to send email",
      ));
    }
  });
});

exports.onUserCreateOrUpdate = functions.firestore
    .document("users/{userId}")
    .onWrite(async (change, context) => {
      const newValue = change.after.exists ? change.after.data() : null;
      const previousValue = change.before.exists ? change.before.data() : null;

      // Check if the user is newly created
      if (!previousValue && newValue) {
        const userEmail = newValue.email;
        const firstName = newValue.firstName || "";
        const lastName = newValue.lastName || "";
        const fullName = `${firstName} ${lastName}`.trim() || "User";

        // Prepare a simple welcome email
        const subject = "Welcome to Gentle!";
        const htmlContent = `
          <h1>Welcome, ${fullName}!</h1>
          <p>Thank you for joining us. We're excited to have you on board!</p>
          <p>If you have any questions, feel free to reach out.</p>
        `;

        // Send the welcome email
        try {
          await sendEmail(userEmail, subject, htmlContent);
          logger.info(`Welcome email sent to ${userEmail}`);
        } catch (error) {
          logger.error(`Error sending welcome email: ${error}`);
        }
      }

      return null;
    });
