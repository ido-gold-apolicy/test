create database schedule;
use schedule;

DROP TABLE IF EXISTS `schedule_task`;
CREATE TABLE `schedule_task` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` int NOT NULL,
  `name` varchar(45) NOT NULL,
  `cron_expression` varchar(200) NOT NULL,
  `enabled` tinyint NOT NULL,
  `next_run` datetime DEFAULT NULL,
  `tenant_id` bigint NOT NULL,
  PRIMARY KEY (`id`,`tenant_id`),
  KEY `idx_schedule_task_next_run` (`next_run`)
);

DROP TABLE IF EXISTS `schedule_task_parameter`;
CREATE TABLE `schedule_task_parameter` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `value` varchar(200) DEFAULT NULL,
  `schedule_task_id` bigint NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `id_UNIQUE` (`id`),
  KEY `idx_schedule_task_parameter_schedule_task_id` (`schedule_task_id`)
);

DROP TABLE IF EXISTS `task`;
CREATE TABLE `task` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `schedule_task_id` bigint NOT NULL,
  `name` varchar(45) NOT NULL,
  `type` int NOT NULL,
  `start_date` datetime NOT NULL,
  `end_date` datetime DEFAULT NULL,
  `status` int NOT NULL,
  `progress` int NOT NULL DEFAULT '0',
  `tenant_id` bigint NOT NULL,
  PRIMARY KEY (`id`,`tenant_id`),
  UNIQUE KEY `id_UNIQUE` (`id`)
);

DROP TABLE IF EXISTS `task_log`;
CREATE TABLE `task_log` (
  `id` int NOT NULL AUTO_INCREMENT,
  `task_id` bigint NOT NULL,
  `details` varchar(500) NOT NULL,
  `type` int NOT NULL,
  PRIMARY KEY (`id`),
  KEY `idx_task_log_task_id` (`task_id`)
);

DROP TABLE IF EXISTS `task_type`;
CREATE TABLE `task_type` (
  `id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(45) NOT NULL,
  `topic_name` varchar(45) NOT NULL,
  PRIMARY KEY (`id`)
);

#########################
#    INIT TASK TYPES    #
#########################

INSERT INTO task_type (`id`, `name`, `topic_name`) VALUES (1, 'WorkloadScan', 'task-workload');
INSERT INTO task_type (`id`, `name`, `topic_name`) VALUES (2, 'AccessScan', 'task-access');
INSERT INTO task_type (`id`, `name`, `topic_name`) VALUES (3, 'IDPScan', 'task-idp');
INSERT INTO task_type (`id`, `name`, `topic_name`) VALUES (4, 'ChangeCollectorLogLevel', 'task-collector-log-level');