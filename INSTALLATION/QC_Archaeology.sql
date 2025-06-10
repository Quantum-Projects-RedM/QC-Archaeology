CREATE TABLE `QC_Archaeology` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`citizenid` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
	`arcid` VARCHAR(255) NOT NULL COLLATE 'utf8mb4_general_ci',
	`time_found` DATETIME NOT NULL,
	PRIMARY KEY (`id`) USING BTREE,
	UNIQUE INDEX `unique_discovery` (`citizenid`, `arcid`) USING BTREE
)
COLLATE='utf8mb4_general_ci'
ENGINE=InnoDB
AUTO_INCREMENT=11
;
