CREATE TABLE `TB_HEARTBEAT` (
    `uuid` char(36) NOT NULL,
    `acceptTime` datetime(6) DEFAULT NULL,
    `batteryLevel` int(11) DEFAULT NULL,
    `createTime` datetime(6) DEFAULT NULL,
    `displayColor` varchar(255) DEFAULT NULL,
    `lat` decimal(8,6) DEFAULT NULL,
    `lng` decimal(9,6) DEFAULT NULL,
    `sourceIP` varchar(255) DEFAULT NULL,
    `sourceUUID` varchar(255) DEFAULT NULL,
    PRIMARY KEY (`uuid`)
);
