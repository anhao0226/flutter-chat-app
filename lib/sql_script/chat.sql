CREATE TABLE chats
(
    id        INTEGER PRIMARY KEY,
    text      TEXT,
    receiver  VARCHAR(36),
    sender    VARCHAR(36),
    type      INT,
    timestamp INTEGER,
    filepath  VARCHAR(255),
    extend    VARCHAR(255),
    status    INT,
    INDEX `sender_index` (`sender`),
    INDEX `receiver_index` (`receiver`)
);