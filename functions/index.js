const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();
const users = db.collection('users');

const charset = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
const choose = arr => arr[Math.floor(Math.random() * arr.length)];
const gen = () => [...Array(5)].map(_ => choose(charset)).join('');
exports.newUser = functions.auth.user().onCreate(async u => {
    let code = gen();
    let tries = 0;

    while (!(await users.where('code', '==', code).get()).empty && tries < 10) {
        code = gen();
        tries++;
    }

    await users.doc(u.uid).set({
        code,
        name: u.displayName,
        photo: u.photoURL,
        friends: []
    });
});

async function find(code) {
    let query = await users.where('code', '==', code).get();
    return query.empty ? null : query.docs[0];
}

async function notify(uref, notification) {
    const tokens = (await uref.collection('tokens').get()).docs.map(d => d.id);
    return Promise.all(tokens.map(token =>
        admin.messaging().send({notification, token})));
}

exports.heart = functions.https.onCall(async (data, ctx) => {
    const self = (await users.doc(ctx.auth.uid).get()).data();

    const to = await find(data.code);
    if (!to) return 404;

    const friends = await to.ref.collection('friends')
          .where('code', '==', self.code)
          .get();

    if (friends.empty) return 400;

    await notify(to.ref, {
        title: `${self.name} sent you a heart!`,
        body: 'Send one back?',
    });

    return 200;
});

exports.sendFriendRequest = functions.https.onCall(async (data, ctx) => {
    const self = (await users.doc(ctx.auth.uid).get()).data();

    const to = await find(data.code);
    if (!to) return 404;

    // TODO: No-op if already pending
    await to.ref.collection('requests').doc().set({
        name: self.name,
        code: self.code
    });

    await notify(to.ref, {
        title: `${self.name} sent you a friend request!`,
        body: 'Accept it?'
    });

    return 200;
});

exports.acceptFriendRequest = functions.https.onCall(async (data, ctx) => {
    const self = (await users.doc(ctx.auth.uid).get());

    const from = await find(data.code);
    if (!from) return 404;

    const reqs = (await self.ref.collection('requests')
                  .where('code', '==', data.code)
                  .get()).docs;

    await Promise.all(reqs.map(r => r.ref.delete()));

    await self.ref.collection('friends').doc().set({
        name: from.data().name,
        code: data.code
    });

    await from.ref.collection('friends').doc().set({
        name: self.data().name,
        code: self.data().code
    });

    await notify(from.ref, {
        title: `${self.data().name} accepted your friend request!`,
        body: 'Send them a heart?',
    });

    return 200;
});
