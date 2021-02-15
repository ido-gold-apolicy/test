create database gitprovider;
use gitprovider;

DROP TABLE IF EXISTS `git_integration`;
CREATE TABLE `git_integration` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint,
  `name` varchar(300) NOT NULL,
  `type` int NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_tenant_id` (`tenant_id`)
);

DROP TABLE IF EXISTS `git_provider`;
CREATE TABLE `git_provider` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint,
  `type` int NOT NULL,
  `status` int NOT NULL,
  `installation_id` bigint,
  `git_integration_id` bigint,
  `creation_timestamp` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP(),
  `organization` varchar(300) NOT NULL,
  `target_type` varchar(50) NOT NULL,
  `raw_installation_json` longtext,
  PRIMARY KEY (`id`),
  UNIQUE KEY `installation_id_UNIQUE` (`installation_id`),
  INDEX `idx_tenant_id` (`tenant_id`)
);

DROP TABLE IF EXISTS `git_repository`;
CREATE TABLE `git_repository` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `git_provider_id` bigint NOT NULL,
  `name` varchar(300) NOT NULL,
  `full_name` varchar(300) NOT NULL,
  `metadata` varchar(300) NOT NULL,
  PRIMARY KEY (`id`),
  FOREIGN KEY (git_provider_id)
      REFERENCES git_provider(id)
      ON DELETE CASCADE,
  INDEX `idx_git_provider_id` (`git_provider_id`)
);

DROP TABLE IF EXISTS `raw_event`;
CREATE TABLE `raw_event` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `raw_event` longtext NOT NULL,
  PRIMARY KEY (`id`)
);
