'use strict';

import * as C from 'crypto';

export const connectImpl = ({ apiBaseUrl }) => () => new Promise(resolve => {
  console.info(`API ${apiBaseUrl} will not be really used. This is a mock.`);
  console.info();
  resolve({
    nextId: 3,
    tokens: {},
    users: {
      adri: { password: '1234' },
      other: { password: '4321' }
    },
    posts: {
      1: {
        reactions: {},
        comments: {}
      },
      2: {
        reactions: {},
        comments: {}
      }
    }
  });
});

export const disconnectImpl = connection => () => new Promise(resolve => {
  console.info();
  console.info('Final mock state:');
  console.info(JSON.stringify(connection, undefined, 2));
  resolve();
});

export const loginImpl = ({ username, password }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.users[username])
    return reject(`User ${username} not found`);

  if (connection.users[username].password !== password)
    return reject(`Wrong password for user ${username}`);

  C.randomBytes(48, (err, buffer) => {
    if (err)
      return reject(err);

    const token = buffer.toString('hex');
    if (connection.tokens[token])
      return reject(`Auth token collision`);

    connection.tokens[token] = username;
    resolve(token);
  });
});

export const randomPostImpl = ({ username, token }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.tokens[token] || connection.tokens[token] !== username)
    return reject(`Wrong auth token`);

  const postIds = Object.keys(connection.posts);
  if (!postIds)
    return reject(`No posts`);

  const postId = postIds[Math.floor(Math.random() * postIds.length)];
  resolve(postId);
});

export const reactToPostImpl = reaction => showReaction => ({ username, token, postId }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.tokens[token] || connection.tokens[token] !== username)
    return reject(`Wrong auth token`);

  if (!connection.posts[postId])
    return reject(`Post ${postId} not found`);

  connection.posts[postId].reactions[username] = showReaction(reaction);
  resolve();
});

export const commentPostImpl = comment => ({ username, token, postId }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.tokens[token] || connection.tokens[token] !== username)
    return reject(`Wrong auth token`);

  if (!connection.posts[postId])
    return reject(`Post ${postId} not found`);

  const commentId = connection.nextId++;
  connection.posts[postId].comments[commentId] = { username, comment, replyToId: null, reactions: {} };
  resolve(commentId);
});

export const replyToCommentImpl = comment => ({ username, token, postId, commentId }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.tokens[token] || connection.tokens[token] !== username)
    return reject(`Wrong auth token`);

  if (!connection.posts[postId])
    return reject(`Post ${postId} not found`);

  if (!connection.posts[postId].comments[commentId])
    return reject(`Comment ${commentId} not found`);

  const replyId = connection.nextId++;
  connection.posts[postId].comments[replyId] = { username, comment, replyToId: commentId, reactions: {} };
  resolve(replyId);
});

export const reactToCommentImpl = reaction => showReaction => ({ username, token, postId, commentId }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.tokens[token] || connection.tokens[token] !== username)
    return reject(`Wrong auth token`);

  if (!connection.posts[postId])
    return reject(`Post ${postId} not found`);

  if (!connection.posts[postId].comments[commentId])
    return reject(`Comment ${commentId} not found`);

  connection.posts[postId].comments[commentId].reactions[username] = showReaction(reaction);
  resolve();
});

export const editCommentImpl = comment => ({ username, token, postId, commentId }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.tokens[token] || connection.tokens[token] !== username)
    return reject(`Wrong auth token`);

  if (!connection.posts[postId])
    return reject(`Post ${postId} not found`);

  if (!connection.posts[postId].comments[commentId])
    return reject(`Comment ${commentId} not found`);

  if (connection.posts[postId].comments[commentId].username !== username)
    return reject(`The comment ${commentId} is not from the user ${username}`);

  connection.posts[postId].comments[commentId].comment = comment;
  resolve();
});

export const removeCommentImpl = ({ username, token, postId, commentId }) => connection => () => new Promise((resolve, reject) => {
  if (!connection.tokens[token] || connection.tokens[token] !== username)
    return reject(`Wrong auth token`);

  if (!connection.posts[postId])
    return reject(`Post ${postId} not found`);

  if (!connection.posts[postId].comments[commentId])
    return reject(`Comment ${commentId} not found`);

  if (connection.posts[postId].comments[commentId].username !== username)
    return reject(`The comment ${commentId} is not from the user ${username}`);

  const comments = connection.posts[postId].comments;
  const remove = commentId => {
    delete comments[commentId];
    for (const otherCommentId in comments)
      if (comments[otherCommentId].replyToId === commentId)
        remove(otherCommentId);
  };

  remove(commentId);
  resolve();
});
