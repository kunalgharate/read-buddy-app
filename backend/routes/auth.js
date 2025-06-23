// backend/routes/auth.js
const { OAuth2Client } = require('google-auth-library');
const express = require('express');
const router = express.Router();

const client = new OAuth2Client(process.env.GOOGLE_CLIENT_ID);

router.post('/google', async (req, res) => {
  const { idToken } = req.body;

//   try {
//     const ticket = await client.verifyIdToken({
//       idToken,
//       audience: process.env.GOOGLE_CLIENT_ID,
//     });

//     const payload = ticket.getPayload();


    // res.status(200).json({
    //   id: payload.sub,
    //   email: payload.email,
    //   name: payload.name,
    //   picture: payload.picture,
    // return res.status(200).json({
    //   id: '123456789',
    //   email: 'testuser@example.com',
    //   name: 'Test User',
    //   picture: 'https://via.placeholder.com/150',
    
    // });
//   } catch (err) {
//     console.error('Google token verification failed:', err);
//     res.status(401).json({ message: 'Invalid Google ID token' });
//   }
 try {
    const ticket = await client.verifyIdToken({
      idToken,
      audience: process.env.GOOGLE_CLIENT_ID,
    });

    const payload = ticket.getPayload();
    res.status(200).json({
      id: payload.sub,
      email: payload.email,
      name: payload.name,
      picture: payload.picture,
    });
  } catch (err) {
    console.error(err);
    res.status(401).json({ message: 'Invalid Google ID token' });
  }


});

module.exports = router;
