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
    functions.config().sendgrid_api_key,
);

// method to delete user from firebase auth via uid,
// this method is called from the client side
// this should also delete all the data from firestore
exports.deleteUser = functions.https.onCall(async (data, context) => {
  cors(async () => {
    const uid = data.uid;
    await admin.auth().deleteUser(uid);
    const userRef = admin.firestore().collection("users").doc(uid);
    const userDoc = await userRef.get();

    if (userDoc.exists) {
      await userRef.delete();
      logger.info(`User ${uid} and data deleted successfully`);
      return {success: true, message: "User and data deleted successfully"};
    } else {
      logger.info(`User ${uid} not found`);
      return {success: false, message: "User not found"};
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
exports.sendEmail = functions.https.onCall(async (data, context) => {
  cors(async () => {
    try {
      const {to, subject, htmlContent} = data;

      // Optionally, you can add authentication/authorization logic here
      // if (context.auth) { ... }

      await sendEmail(to, subject, htmlContent);
      return {
        success: true,
        message: "Email sent successfully",
      };
    } catch (error) {
      console.error("Error sending email:", error);
      throw new functions.https.HttpsError(
          "internal",
          "Unable to send email",
      );
    }
  });
});

// TODO: FIX DEPLOYMENT OF THIS

exports.onUserCreateOrUpdate = functions.firestore
    .document("users/{userId}")
    .onCreate(async (snapshot, context) => {
      cors(async () => {
        const newValue = snapshot.data();
        const previousValue = context.data().previous.data();

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
      });
    });

