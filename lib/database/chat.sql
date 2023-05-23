CREATE TABLE chats
(
    id        INTEGER PRIMARY KEY,
    text      TEXT,
    receiver  VARCHAR(36) NOT NULL,
    sender    VARCHAR(36) NOT NULL,
    type      INT,
    timestamp INTEGER,
    filepath  VARCHAR(255) NOT NULL,
    extend    VARCHAR(255),
    status    INT,
    INDEX `sender_index` (`sender`),
    INDEX `receiver_index` (`receiver`)
);