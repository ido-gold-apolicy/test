
CREATE DATABASE `access`;
USE `access`;

CREATE TABLE `scan` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint NOT NULL,
  `cluster_id` binary(16) NOT NULL,
  `cluster_name` varchar(255) NOT NULL,
  `start_date` datetime DEFAULT NULL,
  `end_date` datetime DEFAULT NULL,
  `messages_count` int DEFAULT '0',
  INDEX `idx_scan` (`tenant_id`, `cluster_id`, `end_date`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `risk` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `identifier` bigint NOT NULL,
  `scan_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(1024) NOT NULL,
  `type` int NOT NULL,
  `Weight` float NOT NULL,
  `Score` int NOT NULL,
  CONSTRAINT `fk_risk_scan_id` FOREIGN KEY (`scan_id`) REFERENCES `scan` (`id`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `policy` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `risk_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  `kind` int NOT NULL,
  CONSTRAINT `fk_policy_risk_id` FOREIGN KEY (`risk_id`) REFERENCES `risk` (`id`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `role` (
  `id` varchar(32) NOT NULL,
  `namespace` varchar(255) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `aggregation_rules` varchar(1024) DEFAULT NULL,
  `labels` varchar(4000) DEFAULT NULL,
  `scan_id` bigint DEFAULT NULL,
  `has_risky_access` tinyint NOT NULL DEFAULT '0',
  `subjects_count` int DEFAULT '0',
  `cluster_name` varchar(255) DEFAULT NULL,
  INDEX `idx_role_scan_id` (`scan_id`, `has_risky_access`),
  CONSTRAINT `fk_role_scan_id` FOREIGN KEY (`scan_id`) REFERENCES `scan` (`id`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `role_risk` (
  `role_id` varchar(32) NOT NULL,
  `risk_identifier` bigint NOT NULL,
  PRIMARY KEY (`role_id`,`risk_identifier`),
  CONSTRAINT `fk_role_risk_role_id` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`)
);

CREATE TABLE `rule` (
  `id` varchar(32) NOT NULL,
  `verbs` varchar(255) DEFAULT NULL,
  `resources` varchar(1024) DEFAULT NULL,
  `resource_names` varchar(1024) DEFAULT NULL,
  `non_resource_urls` varchar(1024) DEFAULT NULL,
  `api_groups` varchar(1024) DEFAULT NULL,
  `risk_id` bigint DEFAULT NULL,
  PRIMARY KEY (`id`)
);

CREATE TABLE `role_rule` (
  `role_id` varchar(32) NOT NULL,
  `rule_id` varchar(32) NOT NULL,
  PRIMARY KEY (`role_id`,`rule_id`),
  KEY `rule_id` (`rule_id`),
  CONSTRAINT `role_rule_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `role_rule_ibfk_2` FOREIGN KEY (`rule_id`) REFERENCES `rule` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE
);

CREATE TABLE `role_binding` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `scan_id` bigint NOT NULL,
  `namespace` varchar(255) DEFAULT NULL,
  `kind` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `subject_kind` varchar(255) DEFAULT NULL,
  `subject_name` varchar(255) DEFAULT NULL COLLATE utf8_bin,
  `subject_namespace` varchar(255) DEFAULT NULL,
  `role_id` varchar(32) DEFAULT NULL,
  `has_risky_access` tinyint NOT NULL,
  `risk_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_role_binding_role` (`role_id`),
  CONSTRAINT `fk_role_binding_scan_id` FOREIGN KEY (`scan_id`) REFERENCES `scan` (`id`),
  CONSTRAINT `role_binding_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `role` (`id`),
  INDEX `idx_role_binding` (`scan_id`, `subject_name`, `subject_namespace`, `subject_kind`)
);

CREATE TABLE `service_account` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint NOT NULL,
  `scan_id` bigint NOT NULL,
  `namespace` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL,
  `labels` varchar(4000) DEFAULT NULL,
  UNIQUE INDEX `idx_service_account` (`scan_id`, `name`, `namespace`),
  CONSTRAINT `fk_service_account_scan_id` FOREIGN KEY (`scan_id`) REFERENCES `scan` (`id`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `subject` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint NOT NULL,
  `scan_id` bigint NULL,
  `namespace` varchar(255) DEFAULT NULL,
  `name` varchar(255) DEFAULT NULL COLLATE utf8_bin,
  `kind` varchar(50) DEFAULT NULL,
  `members` varchar(20) DEFAULT NULL,
  `labels` varchar(4000) DEFAULT NULL,
  `original_kind` varchar(255) DEFAULT NULL,
  `original_namespace` varchar(255) DEFAULT NULL,
  `has_risky_access` tinyint NOT NULL,
  INDEX `idx_subject_tenant_id` (`tenant_id`, `has_risky_access`),
  CONSTRAINT `fk_subject_scan_id` FOREIGN KEY (`scan_id`) REFERENCES `scan` (`id`),
  PRIMARY KEY (`id`)
);

CREATE TABLE `subject_cluster_access` (
  `subject_id` bigint NOT NULL,
  `cluster_id` binary(16) NOT NULL,
  `cluster_name` varchar(255) NOT NULL,
  `has_risky_access` tinyint NOT NULL,
  PRIMARY KEY (`subject_id`, `cluster_name`),
  CONSTRAINT `fk_subject_cluster_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`),
  INDEX `idx_subject_cluster_access` (`has_risky_access`)
);

CREATE TABLE `subject_risk` (
  `subject_id` bigint NOT NULL,
  `risk_identifier` bigint NOT NULL,
  PRIMARY KEY (`subject_id`, `risk_identifier`),
  CONSTRAINT `fk_subject_risk_subject_id` FOREIGN KEY (`subject_id`) REFERENCES `subject` (`id`)
);

CREATE TABLE `group_member` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `scan_id` bigint NOT NULL,
  `group_name` varchar(255) NOT NULL,
  `group_identifier` varchar(255) NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `user_identifier` varchar(255) NOT NULL,
  `group_path` varchar(1024) NULL,
  `namespace` varchar(255) NULL,
  `provider` varchar(45) NULL,
  CONSTRAINT `fk_group_member_scan_id` FOREIGN KEY (`scan_id`) REFERENCES `scan` (`id`),
  INDEX `idx_group_member` (`scan_id`, `group_identifier`),
  PRIMARY KEY (`id`)
);

#######################################################################
# VIEWS
#######################################################################

# LATEST_SCANS
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `latest_scans` AS
    SELECT 
        MAX(`scan`.`tenant_id`) AS `tenant_id`,
        MAX(`scan`.`id`) AS `scan_id`,
        MAX(`scan`.`cluster_id`) AS `cluster_id`,
        MAX(`scan`.`cluster_name`) AS `cluster_name`
    FROM
        `scan`
    WHERE
        (`scan`.`end_date` IS NOT NULL)
    GROUP BY `scan`.`cluster_id`
    HAVING (0 <> MAX(`scan`.`end_date`));
    
### PERMISSION ###
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `permission` AS
SELECT 
	`rb`.`scan_id` AS `scan_id`,
	IF (((`rb`.`namespace` IS NULL) OR (`rb`.`namespace` = '')), 'All', `rb`.`namespace`) AS `rb_namespace`,
	`rb`.`name` AS `rb_name`,
	`rb`.`kind` AS `rb_kind`,
	`rb`.`subject_kind` AS `subject_kind`,
	`rb`.`subject_name` AS `subject_name`,
	`rb`.`subject_namespace` AS `subject_namespace`,
	`role`.`id` AS `role_id`,
	`role`.`name` AS `role_name`,
	IF (((`role`.`namespace` IS NULL) OR (`role`.`namespace` = '')), 'All', `role`.`namespace`) AS `role_namespace`,
	`role`.`kind` AS `role_kind`,
	`rule`.`id` AS `rule_id`,
	`rule`.`verbs` AS `verbs`,
	`rule`.`resources` AS `resources`,
	`rule`.`resource_names` AS `resource_names`,
	`rule`.`non_resource_urls` AS `non_resource_urls`,
	`rule`.`api_groups` AS `api_groups`,
	`risk`.`id` AS `risk_id`,
	`scan`.`cluster_name` AS `cluster_name`
FROM
	(((((`scan`
        JOIN `role_binding` `rb`)
        JOIN `role`)
        JOIN `role_rule` `rr`)
        JOIN `rule`)
        JOIN `risk`)
WHERE
	((`rb`.`scan_id` = `scan`.`id`)
		AND (`rb`.`role_id` = `role`.`id`)
		AND (`role`.`id` = `rr`.`role_id`)
		AND (`rr`.`rule_id` = `rule`.`id`)
		AND (`risk`.`id` = `rule`.`risk_id`));
        
### PERMISSION_FINE_GRAINED ###
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `permission_fine_grained` AS
	SELECT 
		`p`.`rb_namespace` AS `rb_namespace`,
		`p`.`rb_name` AS `rb_name`,
		`p`.`rb_kind` AS `rb_kind`,
		'User' AS `subject_kind`,
		`gm`.`user_identifier` AS `subject_name`,
		`p`.`subject_namespace` AS `subject_namespace`,
		`p`.`scan_id` AS `scan_id`,
		`p`.`role_id` AS `role_id`,
		`p`.`role_name` AS `role_name`,
		`p`.`role_namespace` AS `role_namespace`,
		`p`.`role_kind` AS `role_kind`,
		`p`.`verbs` AS `verbs`,
		`p`.`resources` AS `resources`,
		`p`.`resource_names` AS `resource_names`,
		`p`.`non_resource_urls` AS `non_resource_urls`,
		`p`.`api_groups` AS `api_groups`,
		`p`.`risk_id` AS `risk_id`,
		`p`.`cluster_name` AS `cluster_name`,
		`gm`.`group_name` AS `group_name`,
		`gm`.`group_identifier` AS `group_identifier`,
		`gm`.`user_name` AS `user_name`,
		`gm`.`group_path` AS `group_path`,
		`gm`.`provider` AS `provider`
	FROM
		(`permission` `p`
		JOIN `group_member` `gm` ON (((`gm`.`group_identifier` = `p`.`subject_name`)
			AND (`p`.`scan_id` = `gm`.`scan_id`))))
	WHERE
		(`p`.`subject_kind` = 'Group') 
	UNION ALL SELECT 
		`p`.`rb_namespace` AS `rb_namespace`,
		`p`.`rb_name` AS `rb_name`,
		`p`.`rb_kind` AS `rb_kind`,
		`p`.`subject_kind` AS `subject_kind`,
		`gm`.`user_identifier` AS `subject_name`,
		`p`.`subject_namespace` AS `subject_namespace`,
		`p`.`scan_id` AS `scan_id`,
		`p`.`role_id` AS `role_id`,
		`p`.`role_name` AS `role_name`,
		`p`.`role_namespace` AS `role_namespace`,
		`p`.`role_kind` AS `role_kind`,
		`p`.`verbs` AS `verbs`,
		`p`.`resources` AS `resources`,
		`p`.`resource_names` AS `resource_names`,
		`p`.`non_resource_urls` AS `non_resource_urls`,
		`p`.`api_groups` AS `api_groups`,
		`p`.`risk_id` AS `risk_id`,
		`p`.`cluster_name` AS `cluster_name`,
		`gm`.`group_name` AS `group_name`,
		`gm`.`group_identifier` AS `group_identifier`,
		`gm`.`user_name` AS `user_name`,
		`gm`.`group_path` AS `group_path`,
		`gm`.`provider` AS `provider`
	FROM
		(`permission` `p`
		JOIN `group_member` `gm` ON (((`gm`.`user_identifier` = `p`.`subject_name`)
			AND (`gm`.`namespace` = `p`.`subject_namespace`)
			AND (`p`.`scan_id` = `gm`.`scan_id`))))
	WHERE
		(`p`.`subject_kind` = 'ServiceAccount') 
	UNION ALL SELECT 
		`p`.`rb_namespace` AS `rb_namespace`,
		`p`.`rb_name` AS `rb_name`,
		`p`.`rb_kind` AS `rb_kind`,
		`p`.`subject_kind` AS `subject_kind`,
		`p`.`subject_name` AS `subject_name`,
		`p`.`subject_namespace` AS `subject_namespace`,
		`p`.`scan_id` AS `scan_id`,
		`p`.`role_id` AS `role_id`,
		`p`.`role_name` AS `role_name`,
		`p`.`role_namespace` AS `role_namespace`,
		`p`.`role_kind` AS `role_kind`,
		`p`.`verbs` AS `verbs`,
		`p`.`resources` AS `resources`,
		`p`.`resource_names` AS `resource_names`,
		`p`.`non_resource_urls` AS `non_resource_urls`,
		`p`.`api_groups` AS `api_groups`,
		`p`.`risk_id` AS `risk_id`,
		`p`.`cluster_name` AS `cluster_name`,
		NULL AS `NULL`,
		NULL AS `NULL`,
		NULL AS `NULL`,
		NULL AS `NULL`,
		NULL AS `NULL`
	FROM
		`permission` `p`
	WHERE
		(`p`.`subject_kind` IN ('User' , 'ServiceAccount', 'Group'));

### SUBJECT_ROLE ###
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `subject_role` AS
    SELECT 
        `rb`.`id` AS `id`,
        `rb`.`scan_id` AS `scan_id`,
        `scan`.`cluster_name` AS `cluster_name`,
        `rb`.`subject_kind` AS `subject_kind`,
        `rb`.`subject_name` AS `subject_name`,
        `rb`.`subject_namespace` AS `subject_namespace`,
        `role`.`id` AS `role_id`,
        `role`.`name` AS `role_name`,
        IF(((`role`.`namespace` IS NULL)
                OR (`role`.`namespace` = '')),
            'All',
            `role`.`namespace`) AS `role_namespace`,
        `role`.`kind` AS `role_kind`,
        `rb`.`risk_id` AS `risk_id`
    FROM
        ((`scan`
        JOIN `role_binding` `rb`)
        JOIN `role`)
    WHERE
        ((`rb`.`scan_id` = `scan`.`id`)
            AND (`rb`.`role_id` = `role`.`id`));
			
### SUBJECT_ROLE_FINE_GRAINED ###
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`%` 
    SQL SECURITY DEFINER
VIEW `subject_role_fine_grained` AS
    SELECT 
        `sr`.`id` AS `id`,
        `sr`.`scan_id` AS `scan_id`,
        `sr`.`cluster_name` AS `cluster_name`,
        `sr`.`subject_kind` AS `subject_kind`,
        `sr`.`subject_name` AS `subject_name`,
        `sr`.`subject_namespace` AS `subject_namespace`,
        `sr`.`role_id` AS `role_id`,
        `sr`.`role_name` AS `role_name`,
        `sr`.`role_namespace` AS `role_namespace`,
        `sr`.`role_kind` AS `role_kind`,
        `sr`.`risk_id` AS `risk_id`,
        `gm`.`group_name` AS `group_name`,
        `gm`.`group_identifier` AS `group_identifier`,
        `gm`.`user_name` AS `user_name`,
        `gm`.`group_path` AS `group_path`,
        `gm`.`provider` AS `provider`
    FROM
        (`subject_role` `sr`
        JOIN `group_member` `gm` ON (((`gm`.`group_identifier` = `sr`.`subject_name`)
            AND (`sr`.`scan_id` = `gm`.`scan_id`))))
    WHERE
        (`sr`.`subject_kind` = 'Group') 
    UNION ALL SELECT 
        `sr`.`id` AS `id`,
        `sr`.`scan_id` AS `scan_id`,
        `sr`.`cluster_name` AS `cluster_name`,
        `sr`.`subject_kind` AS `subject_kind`,
        `sr`.`subject_name` AS `subject_name`,
        `sr`.`subject_namespace` AS `subject_namespace`,
        `sr`.`role_id` AS `role_id`,
        `sr`.`role_name` AS `role_name`,
        `sr`.`role_namespace` AS `role_namespace`,
        `sr`.`role_kind` AS `role_kind`,
        `sr`.`risk_id` AS `risk_id`,
        `gm`.`group_name` AS `group_name`,
        `gm`.`group_identifier` AS `group_identifier`,
        `gm`.`user_name` AS `user_name`,
        `gm`.`group_path` AS `group_path`,
        `gm`.`provider` AS `provider`
    FROM
        (`subject_role` `sr`
        JOIN `group_member` `gm` ON (((`gm`.`user_identifier` = `sr`.`subject_name`)
            AND (`gm`.`namespace` = `sr`.`subject_namespace`)
            AND (`sr`.`scan_id` = `gm`.`scan_id`))))
    WHERE
        (`sr`.`subject_kind` = 'ServiceAccount') 
    UNION ALL SELECT 
        `sr`.`id` AS `id`,
        `sr`.`scan_id` AS `scan_id`,
        `sr`.`cluster_name` AS `cluster_name`,
        `sr`.`subject_kind` AS `subject_kind`,
        `sr`.`subject_name` AS `subject_name`,
        `sr`.`subject_namespace` AS `subject_namespace`,
        `sr`.`role_id` AS `role_id`,
        `sr`.`role_name` AS `role_name`,
        `sr`.`role_namespace` AS `role_namespace`,
        `sr`.`role_kind` AS `role_kind`,
        `sr`.`risk_id` AS `risk_id`,
        NULL AS `NULL`,
        NULL AS `NULL`,
        NULL AS `NULL`,
        NULL AS `NULL`,
        NULL AS `NULL`
    FROM
        `subject_role` `sr`
    WHERE
        (`sr`.`subject_kind` IN ('User' , 'ServiceAccount', 'Group'));           
