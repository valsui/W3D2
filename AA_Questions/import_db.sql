DROP TABLE IF EXISTS users;

CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  fname VARCHAR(255) NOT NULL,
  lname VARCHAR(255) NOT NULL
);

DROP TABLE IF EXISTS questions;

CREATE TABLE questions (
  id INTEGER PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  body VARCHAR(255) NOT NULL,
  author_id INTEGER NOT NULL,

  FOREIGN KEY (author_id) REFERENCES users(id)
);

DROP TABLE IF EXISTS question_follows;

CREATE TABLE question_follows (
  id INTEGER PRIMARY KEY,
  users_id INTEGER NOT NULL,
  questions_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);

DROP TABLE IF EXISTS replies;

CREATE TABLE replies (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  users_id INTEGER NOT NULL,
  body VARCHAR(255) NOT NULL,
  reply_id INTEGER,

  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id),
  FOREIGN KEY (reply_id) REFERENCES replies(id)
);

DROP TABLE IF EXISTS question_likes;

CREATE TABLE question_likes (
  id INTEGER PRIMARY KEY,
  questions_id INTEGER NOT NULL,
  users_id INTEGER NOT NULL,

  FOREIGN KEY (users_id) REFERENCES users(id),
  FOREIGN KEY (questions_id) REFERENCES questions(id)
);


INSERT INTO
  users(fname, lname)
VALUES
  ('Arthur', 'Aardvark'),
  ('First', 'Last'),
  ('Mary', 'Canary'),
  ('Lunch', 'Time');

INSERT INTO
  questions(title, body, author_id)
VALUES
  ('Yellow shirt', 'Where can I find yellow shirts?', (SELECT id FROM users WHERE fname = 'Arthur' AND lname = 'Aardvark')),
  ('Free lunch?', 'Can I be freed?', (SELECT id FROM users WHERE fname = 'Lunch' AND lname = 'Time')),
  ('Turtles', 'Where are the turtles?', (SELECT id FROM users WHERE fname = 'Arthur' AND lname = 'Aardvark')),
  ('Wtf?', 'Why am I here?', (SELECT id FROM users WHERE fname = 'First' AND lname = 'Last'));

INSERT INTO
  replies(questions_id, users_id, body, reply_id)
VALUES
  ((SELECT id FROM questions WHERE title = 'Wtf?'), (SELECT author_id FROM questions WHERE title = 'Wtf?'), 'You tell me, I dont know.', NULL),
  ((SELECT id FROM questions WHERE title = 'Free lunch?'), (SELECT author_id FROM questions WHERE title = 'Free lunch?'), 'Buy me lunch and we will talk.', NULL),
  ((SELECT id FROM questions WHERE title = 'Wtf?'), (SELECT author_id FROM questions WHERE title = 'Wtf?'), 'I love AA', 1);


INSERT INTO
  question_follows(users_id, questions_id)
VALUES
  (1, 2),
  (3, 1),
  (2, 1);

INSERT INTO
  question_likes(questions_id, users_id)
VALUES
  (1, 2),
  (3, 1),
  (1, 1),
  (2, 3),
  (3, 2);
