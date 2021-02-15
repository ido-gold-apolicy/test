create database compliance;
use compliance;

CREATE TABLE `violation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint NOT NULL,
  `policy_name` varchar(255) NOT NULL,
  `requirement_id` bigint NOT NULL,
  `requirement_name` varchar(255) NOT NULL,
  `cluster_id` binary(16) NOT NULL,
  `cluster_name` varchar(255) NOT NULL,
  `type` int NOT NULL,
  `score` tinyint NOT NULL,
  `severity` varchar(10) NOT NULL,
  `pass` tinyint(4) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_violation_tenant_id` (`tenant_id`, `cluster_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE `control_violation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `violation_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  `description` varchar(1024) NULL,
  `type` int NOT NULL,
  `target` int NOT NULL,
  `pass` tinyint(4) NOT NULL,
  `score` tinyint NOT NULL,
  `severity` varchar(10) NOT NULL,
  `control_id` bigint NOT NULL,
  CONSTRAINT fk_control_violation_violation_id FOREIGN KEY (violation_id) REFERENCES violation(id),
  PRIMARY KEY (`id`)
);