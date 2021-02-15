create database policy;
use policy;

DROP TABLE IF EXISTS `policy`;
CREATE TABLE `policy` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(1024) NULL,
  `type` int NOT NULL DEFAULT 0,
  `kind` int NOT NULL,
  `version` varchar(15),  
  `apl_version` varchar(15),
  `requirements_count` int,
  `controls_count` int,
  `link` varchar(255) NULL,
  `authors` varchar(255) NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `requirement`;
DROP TABLE IF EXISTS `requirement_folder`;
CREATE TABLE `requirement_folder` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `description` varchar(1024) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE `requirement` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `version` varchar(255) NOT NULL,
  `requirement_folder_id` bigint NOT NULL,
  `type` int NOT NULL, 
  `description` varchar(1024) NOT NULL,
  CONSTRAINT fk_requirement_folder_id FOREIGN KEY (requirement_folder_id) REFERENCES requirement_folder(id),
  PRIMARY KEY (`id`),
  INDEX `idx_requirement_folder_id` (`requirement_folder_id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `policy_requirement_folder`;
CREATE TABLE `policy_requirement_folder` (
  `policy_id` bigint NOT NULL,
  `requirement_folder_id` bigint NOT NULL,
  PRIMARY KEY (`policy_id`, `requirement_folder_id`)
);

DROP TABLE IF EXISTS `requirement_risk`;
CREATE TABLE `requirement_risk` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `requirement_id` bigint NOT NULL,
  `risk_id` bigint DEFAULT NULL,
  UNIQUE INDEX `idx_requirement_risk_requirement_id_risk_id` (`requirement_id`, `risk_id`),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `risk`;
CREATE TABLE `risk` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `technical_name` varchar(255) NULL,
  `description` varchar(255) NOT NULL,
  `rego` varchar(2100) NULL DEFAULT '```bash \n\ndefault risky = false\n\n# RunAsUser container Level attribute\nrisky {\n    some i\n    input.spec.template.spec.container[i].securityContext.runAsUser = 0\n}\n\n\n\n```',
  `type` int NOT NULL, 
  `target_system` tinyint NOT NULL DEFAULT 0, 
  `weight` float NOT NULL,
  `score` int NOT NULL,
  `action` varchar(255) NULL, 
  `remediation_id` bigint NULL,
  `authors` varchar(255) NOT NULL DEFAULT '@Apolicy',
  `version` varchar(15) NOT NULL DEFAULT '1.0.0',
  `url` varchar(2048) NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_risk_type` (`type`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `remediation_step_input`;
DROP TABLE IF EXISTS `remediation_step`;
DROP TABLE IF EXISTS `remediation`;

CREATE TABLE `remediation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `type` smallint(6) NOT NULL,
  `object_name` varchar(255) NOT NULL,
  `change_impact` varchar(500) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;


CREATE TABLE `remediation_step` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `remediation_id` bigint NOT NULL,
  `title` varchar(128) NOT NULL,
  `step_number` smallint(6) NOT NULL,
  `playbook` varchar(2048) NOT NULL,
  `playbook_yaml_template` varchar(1000) NULL,
  `playbook_static` varchar(1000) NULL,
  CONSTRAINT fk_remediation_step_remediation_id FOREIGN KEY (remediation_id) REFERENCES remediation(id),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

CREATE TABLE `remediation_step_input` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `remediation_step_id` bigint NOT NULL,
  `description` varchar(128) NOT NULL,
  `field` varchar(128) NOT NULL,
  `value` varchar(128) NOT NULL,
  `is_user_input` tinyint(4) NOT NULL,  
  `type` smallint(6) NOT NULL,
  CONSTRAINT fk_remediation_step_input_remediation_step_id FOREIGN KEY (remediation_step_id) REFERENCES remediation_step(id),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `recommendation`;
CREATE TABLE `recommendation` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(128) NOT NULL,
  `type` smallint NOT NULL,
  `description` varchar(1000) DEFAULT NULL,
  `filter` varchar(1000) DEFAULT NULL,
  `severity` smallint NOT NULL,
  `change_impact` varchar(500) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `recommendation_risk`;
CREATE TABLE `recommendation_risk` (
  `recommendation_id` bigint NOT NULL,
  `risk_id` bigint NOT NULL,
  PRIMARY KEY (`recommendation_id`,`risk_id`)
);

DROP TABLE IF EXISTS `application`;
CREATE TABLE `application` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `tenant_id` bigint NOT NULL,
  `name` varchar(255) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `application_scope`;
CREATE TABLE `application_scope` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `application_id` bigint NOT NULL,
  `scope` varchar(2000) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `policy_application`;
CREATE TABLE `policy_application` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `policy_id` bigint NOT NULL,
  `application_id` bigint NOT NULL,
  `tenant_id` bigint NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `requirement_risk_status`;
CREATE TABLE `requirement_risk_status` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `requirement_risk_id` bigint NOT NULL,
  `tenant_id` bigint NOT NULL,
  `status` bool NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_requirement_risk_status_requirement_risk_id_tenant_id_status` (`requirement_risk_id`, `tenant_id`, `status`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

#######################
#    	 VIEWS    	  #
#######################

CREATE OR REPLACE VIEW `risk_policy` AS
SELECT DISTINCT p.id, p.name, p.description, p.type, p.kind, reqr.risk_id
FROM policy.policy p
INNER JOIN policy.policy_requirement_folder prf on p.id = prf.policy_id
INNER JOIN policy.requirement_folder rf on prf.requirement_folder_id = rf.id
INNER JOIN policy.requirement req on req.requirement_folder_id = rf.id
INNER JOIN policy.requirement_risk reqr on reqr.requirement_id = req.id;

#######################
#    INIT POLICIES    #
#######################

INSERT INTO policy (`id`, `name`, `description`, `kind`, `version`, `apl_version`, `requirements_count`, `controls_count`, `link`, `authors`) 
VALUES (1, 'CIS Kubernetes', 'A benchmark developed by the Center of Internet Security (CIS) to address security configurations for Kubernetes. The benchmark covers various topics including control plane, policies, access and general configuration', 1,  '1.5.1', '1.0.0', 22, 39, 'www.cissecurity.org', '@Apolicy');

#################################
#    INIT REQUIREMENT FOLDER    #
#################################

INSERT INTO requirement_folder (`id`, `name`, `description`) VALUES (1, '5.1 - RBAC', 'Policies for Role Based Access Control and Service Accounts');
INSERT INTO policy_requirement_folder(`policy_id`, `requirement_folder_id`) VALUES (1, 1);

INSERT INTO requirement_folder (`id`, `name`, `description`) VALUES (2, '5.2 - PSP', 'Policies for securing Pods');
INSERT INTO policy_requirement_folder(`policy_id`, `requirement_folder_id`) VALUES (1, 2);

INSERT INTO requirement_folder (`id`, `name`, `description`) VALUES (3, '5.4 - Secrets', 'Secrets management');
INSERT INTO policy_requirement_folder(`policy_id`, `requirement_folder_id`) VALUES (1, 3);

INSERT INTO requirement_folder (`id`, `name`, `description`) VALUES (4, '5.7 - General', 'General security policies');
INSERT INTO policy_requirement_folder(`policy_id`, `requirement_folder_id`) VALUES (1, 4);

#########################
#    INIT REQUIREMENT   #
#########################

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (1, 1, '5.1.1 - Cluster-admin', 'The RBAC role cluster-admin provides wide-ranging powers over the environment and should be used only where and when needed.', 2, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (1, 1, 2023);

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (2, 1, '5.1.2 - Access to secrets', 'The Kubernetes API stores secrets, which may be service account tokens for the Kubernetes API or credentials used by workloads in the cluster. Access to these secrets should be restricted to the smallest possible group of users to reduce the risk of privilege escalation.', 2, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (2, 2, 2003);
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (3, 2, 2005);
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (4, 2, 2003); -- need to replace when a new control is created
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (5, 2, 2005); -- need to replace when a new control is created

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (3, 1, '5.1.3 - Wildcard use in Roles', 'Kubernetes Roles and ClusterRoles provide access to resources based on sets of objects and actions that can be taken on those objects. It is possible to set either of these to be the wildcard ""*"" which matches all items. Use of wildcards is not optimal from a security perspective as it may allow for inadvertent access to be granted when new resources are added to the Kubernetes API either as CRDs or in later versions of the product.', 2, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (6, 3, 2009);
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (7, 3, 2010);
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (8, 3, 2011);
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (9, 3, 2012);
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (10, 3, 2011); -- need to replace when a new control is created
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (11, 3, 2012); -- need to replace when a new control is created

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (4, 1, '5.1.4 - Create pods', 'The ability to create pods in a namespace can provide a number of opportunities for privilege escalation, such as assigning privileged service accounts to these pods or mounting hostPaths with access to sensitive data (unless Pod Security Policies are implemented to restrict this access). As such, access to create new pods should be restricted to the smallest possible group of users.', 2, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (12, 4, 2007);
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (13, 4, 2007); -- need to replace when a new control is created

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (5, 1, '5.1.5 - (Res) default ServiceAccounts', 'The default service account should not be used to ensure that rights granted to applications can be more easily audited and reviewed.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (14, 5, 12);

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (6, 1, '5.1.5 - (ID) default ServiceAccounts', 'The default service account should not be used to ensure that rights granted to applications can be more easily audited and reviewed.', 2, '1.0.0');
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (15, 6, 12); -- need to replace when a new control is created

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (7, 1, '5.1.6 - SA Tokens', 'Service accounts tokens should not be mounted in pods except where the workload running in the pod explicitly needs to communicate with the API server.', 2, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (16, 7, 42); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (8, 2, '5.2.1 - privileged containers', 'Do not generally permit containers to be run with the securityContext.privileged flag set to true.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (17, 8, 16); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (9, 2, '5.2.2 - Host PID', 'Do not generally permit containers to be run with the hostPID flag set to true.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (19, 9, 3); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (10, 2, '5.2.3 - Host IPC', 'Do not generally permit containers to be run with the hostIPC flag set to true.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (20, 10, 5); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (11, 2, '5.2.4 - Host Network', 'Do not generally permit containers to be run with the hostNetwork flag set to true.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (21, 11, 1); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (12, 2, '5.2.5 - allowPrivilegeEscalation', 'Do not generally permit containers to be run with the allowPrivilegeEscalation flag set to true.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (22, 12, 18); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (13, 2, '5.2.6 - Root containers', 'Do not generally permit containers to be run as the root user.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (24, 13, 9);
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (25, 13, 21);
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (26, 13, 22);
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (27, 13, 26); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (14, 2, '5.2.7 - NET_RAW', 'Do not generally permit containers with the potentially dangerous NET_RAW capability.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (29, 14, 30); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (15, 2, '5.2.8 - Added capabilities', 'Do not generally permit containers with capabilities assigned beyond the default set.', 1, '1.0.0');
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (31, 15, ?); -- need to add once we will have that risk 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (16, 2, '5.2.9 - No capabilities', 'Do not generally permit containers with capabilities', 1, '1.0.0');

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (17, 3, '5.4.1 - Secrets Env Vars', 'Kubernetes supports mounting secrets as data volumes or as environment variables. Minimize the use of environment variable secrets.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (33, 17, 43); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (18, 3, '5.4.2 - ext secret storage', 'Consider the use of an external secrets storage and management system, instead of using Kubernetes Secrets directly, if you have more complex secret management needs. Ensure the solution requires authentication to access secrets, has auditing of access to and use of secrets, and encrypts secrets. Some solutions also make it easier to rotate secrets.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (34, 18, 44);

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (19, 4, '5.7.1 - Namespacing', 'Use namespaces to isolate your Kubernetes objects.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (35, 19, 39); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (20, 4, '5.7.2 - seccomp', 'Enable docker/default seccomp profile in your pod definitions.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (36, 20, 45); 

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (21, 4, '5.7.3 - Security Context', 'Apply Security Context to Your Pods and Containers', 1, '1.0.0');
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (37, 21, ?); -- need to add once we will have that risk
-- INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (38, 21, ?); -- need to add once we will have that risk

INSERT INTO requirement(`id`, `requirement_folder_id`, `name`, `description`, `type`, `version`) VALUES (22, 4, '5.7.4 - Default namespace', 'Kubernetes provides a default namespace, where objects are placed if no namespace is specified for them. Placing objects in this namespace makes application of RBAC and other controls more difficult.', 1, '1.0.0');
INSERT INTO requirement_risk(`id`, `requirement_id`, `risk_id`) VALUES (39, 22, 39); 

####################
#    INIT RISKS    #
####################

INSERT INTO risk (id, type, name, weight, score, description, action) VALUES (1000, 0, 'None Node', 1, 0, 'None', '');
INSERT INTO risk (id, type, name, weight, score, description, action) VALUES (1001, 1, 'None Access', 1, 0, 'None', '');
INSERT INTO risk (id, type, name, weight, score, description, action) VALUES (1002, 3, 'None Container', 1, 0, 'None', '');
INSERT INTO risk (id, type, name, weight, score, description, action) VALUES (1003, 4, 'None Permissions', 1, 0, 'None', '');

-- Workload Attributes risk
INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(1, 1, 'Workload sharing HostNetworks', 'HostNetwork', 1, 10, 'Sharing the host network exposes the Pod\'s network to anyone with access to the Pod. In addition,  it allows the Pod to communicate with processes bound to the host\'s loopback', 'Replace to: False', 1, '```bash \npackage apolicy \n \ndefault risky = false \n \n# HostNetworks POD Level attribute \nrisky {\n	input.spec.template.spec.hostNetwork == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(3, 1, 'Workload sharing HostPID', 'HostPID', 1, 6, 'Sharing the host\'s PID reduces isolation and exposes host data to the running Pod,  for example,  environment variables', 'Replace to: False', 2, '```bash \npackage apolicy \n \ndefault risky = false \n \n# HostPID POD Level attribute \nrisky {\n	input.spec.template.spec.hostPID == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(5, 1, 'Workload sharing HostIPC' ,'HostIPC', 1, 6, 'Sharing the host\'s IPC reduces isolation and allows the Pod to communicate with host processes eventually letting them perform tasks as if they were running on the host', 'Replace to: False', 3, '```bash \npackage apolicy \n \ndefault risky = false \n \n# HostIPC POD Level attribute \nrisky {\n	input.spec.template.spec.hostIPC == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(7, 1, 'Workload container default RunAsUser root', 'SecurityContext.RunAsUser Pod', 0.5, 2, 'In case a container in the Pod did not define runAsUser this will set the user to root', 'Replace to: > 10000', 4, '```bash \npackage apolicy \n \ndefault risky = false \n \n# RunAsUser POD Level attribute \nrisky  {\n	input.spec.template.spec.securityContext.runAsUser < 10001\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(9, 1, 'Container permitting root', 'SecurityContext.runAsNonRoot Container', 1, 3, 'The configuration enforces containers to run with ANY uid other than root. It is best practice to set this to make sure that even the image won\'t override the configuration and run as root', 'Replace to: True', 5, '```bash \npackage apolicy \n \ndefault risky = false \n \n# RunAsNonRoot POD Level attribute \nrisky {\n	input.spec.template.spec.securityContext.runAsNonRoot == false\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(10, 1, 'Workload container default RunAsGroup root', 'SecurityContext.RunAsGroup Pod', 0.5, 6, 'In case a container in the Pod did not define runAsGroup this will set the group to root', 'Replace to: <> 0', 6, '```bash \npackage apolicy \n \ndefault risky = false \n \n# RunAsGroup POD Level attribute \nrisky {\n	input.spec.template.spec.securityContext.runAsGroup == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(11, 1, 'Workload without ServiceAccount', 'ServiceAccountName', 1, 9, 'Pods must run with unique users using least privileges. This ensures accountability for actions,  easier troubleshooting and makes sure the Pod will not perform unauthorized actions', 'Set a named Service Account', 7, '```bash \npackage apolicy \n \ndefault risky = false \n \n# ServiceAccountName POD Level attribute \nrisky {\n	input.spec.template.spec.serviceAccountName == ""\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(12, 1, 'Workload using "default" ServiceAccount', 'ServiceAccountName Defaulted', 0.5, 5, 'Pods must run with unique users using least privileges. This ensures accountability for actions,  easier troubleshooting and makes sure the Pod will not perform unauthorized actions', 'Set a named Service Account', 7, '```bash \npackage apolicy \n \ndefault risky = false \n \n# ServiceAccountName POD Level attribute \nrisky {\n	input.spec.template.spec.serviceAccountName == "default"\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(13, 1, 'Container permanent image', 'ImagePullPolicy Never', 1, 10, 'Images that are not updated from the image repositories may result in tampered images', 'Replace to: Always or IfNotPresent', 8, '```bash \npackage apolicy \n \ndefault risky = false \n \n# ImagePullPolicy Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].imagePullPolicy == "Never"\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(14, 1, 'Container using latest image', 'Image Ends With Latest', 1, 7, 'Images running with \"latest\" or blank tag can break down the integrity of the system as update without a specific image', 'Replace to: specific version', 9, '```bash \npackage apolicy \n \ndefault risky = false \n \n# image Container Level attribute \nrisky {\n    some i; endswith(":latest", input.spec.template.spec.containers[i].image)\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(16, 1, 'Container running as privileged', 'SecurityContext.privileged', 1, 10, 'Privileged containers are almost unrestricted and should not be used', 'Replace to: False', 10, '```bash \npackage apolicy \n \ndefault risky = false \n \n# SecurityContext.Privileged Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].securityContext.privileged == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(18, 1, 'Container allowing privileged sub processes', 'SecurityContext.AllowPrivilegeEscalation', 1, 10, 'A sub-process can gain more privileges than the parent process.', 'Replace to: False', 11, '```bash \npackage apolicy \n \ndefault risky = false \n \n# SecurityContext.AllowPrivilegeEscalation Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].securityContext.allowPrivilegeEscalation == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(20, 1, 'Container with writable root file system', 'SecurityContext.ReadOnlyRootFileSystem', 1, 10, 'A container with writable root filesystem is more exposed to attacks as it allows tampering with executables', 'Replace to: True', 12, '```bash \npackage apolicy \n \ndefault risky = false \n \n# SecurityContext.ReadOnlyRootFilesystem Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].securityContext.readOnlyRootFilesystem == false\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(21, 1, 'Container running as root', 'SecurityContext.runAsUser Container', 1, 10, 'Running containers as root can result in pod escape', 'Replace to: > 10000', 13, '```bash \npackage apolicy \n \ndefault risky = false \n \n# SecurityContext.RunAsUser Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].securityContext.runAsUser == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(22, 1, 'Container uid is host range', 'SecurityContext.runAsUser Container', 0.5, 2, 'It is recommended to run with uid>10000 to avoid conflicts with host user tables', 'Replace to: > 10000', 13, '```bash \npackage apolicy \n \ndefault risky = false \n \n# SecurityContext.RunAsUser Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].securityContext.runAsUser < 10001\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(23, 1, 'Container with root group access', 'SecurityContext.runAsGroup Container', 0.5, 6, 'Running with root group context allows access to all files owned by root group', 'Replace to: <> 0', 14, '```bash \npackage apolicy \n \ndefault risky = false \n \n# SecurityContext.RunAsGroup Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].securityContext.runAsGroup == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(24, 1, 'Workload missing CPU limit', 'Resources.limits.cpu', 1, 7, 'No limits configuration could cause process starvation', 'Set value', 15, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Resources.Limits.CPU Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].resources.limits.cpu == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(25, 1, 'Workload missing memory limit', 'Resources.limits.memory', 1, 7, 'No limits configuration could cause process starvation', 'Set value', 16, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Resources.Limits.Memory Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].resources.limits.memory == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(26, 1, 'Container with SYS_Admin capability', 'Capabilities [SYS_ADMIN]', 1, 10, 'Assigns SYS_Admin capability that is equivalent to root access', 'Remove value', 17, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Capabilities.SYS_ADMIN Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].capabilities.SYS_ADMIN == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(28, 1, 'Container with NET_Admin capability', 'Capabilities [NET_ADMIN]', 1, 9, 'Assigns NET_Admin capability that allows binding to any address for transparent proxying any host address,  managing interfaces,  sniffing all host traffic and more.', 'Remove value', 18, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Capabilities.NET_ADMIN Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].capabilities.NET_ADMIN == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(30, 1, 'Container with NET_RAW capability', 'Capabilities [NET_RAW]', 1, 8, 'Assigns NET_Admin capability that allows binding to any address for transparent proxying any host address', 'Remove value', 19, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Capabilities.NET_RAW Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].capabilities.NET_RAW == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(32, 1, 'Container image update if not present only', 'ImagePullPolicy IfNotPresent', 0.5, 2, 'Setting the pull policy to Always is recommended ensuring the container runs with the most up to date image', 'Replace to: Always', 8, '```bash \npackage apolicy \n \ndefault risky = false \n \n# ImagePullPolicy Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].imagePullPolicy == "IfNotPresent"\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(33, 1, 'Container exposing HostPort', 'Ports.HostPort', 1, 7, 'Host port usage may create constraints as to where the Pod can run', 'Remove value', 20, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Ports.HostPort Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].ports.hostPort > 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(34, 1, 'Workload missing CPU request', 'Resources.requests.cpu', 0.5, 3, 'No resource request hurts the scheduler resource assignment for workloads', '', 21, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Resources.Requests.CPU Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].resources.requests.cpu == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(35, 1, 'Workload missing memory request', 'Resources.requests.memory', 0.5, 3, 'No resource request hurts the scheduler resource assignment for workloads', '', 22, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Resources.Requests.Memory Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].resources.requests.memory == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(36, 1, 'Workload container default permits root', 'SecurityContext.runAsNonRoot Pod', 1, 4, 'In case a container in the Pod did not define runAsNonRoot this will allow it define root as the user', '', 23, '```bash \npackage apolicy \n \ndefault risky = false \n \n# SecurityContext.RunAsNonRoot POD Level attribute \nrisky {\n	input.spec.template.spec.securityContext.runAsNonRoot == false\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(38, 1, 'Container using image without digest', 'Image Not Contains @', 0.5, 5, 'Image digest is immutable and guarantees all instances will run the same code always', '', 9, '```bash \npackage apolicy \n \ndefault risky = false \n \n# image Container Level attribute \nrisky {\n    some i; not contains("@", input.spec.template.spec.containers[i].image)\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(39, 1, 'Workload defined in "default" namespace', 'Namespace', 1, 6, 'Pods should be namespaced to promote isolation', '', 24, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Namespace POD Level attribute \nrisky {\n	input.spec.template.spec.namespace == "default"\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(40, 1, 'Container without liveness probe', 'LivenessProbe', 0.5, 3, 'Containers should have liveness probe to expose their app status and maintain system integrity', '', 25, '```bash \npackage apolicy \n \ndefault risky = false \n \n# LivenessProbe.PeriodSeconds Container Level attribute \nrisky {\n	some i; input.spec.template.spec.containers[i].livenessProbe.periodSeconds == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(41, 1, 'Container without readiness probe', 'ReadinessProbe', 0.5, 3, 'Containers should have readiness probe to expose their ability to service request and maintain system integrity', '', 26, '```bash \npackage apolicy \n \ndefault risky = false \n \n# ReadinessProbe.PeriodSeconds Container Level attribute \nrisky {\n	some i; input.spec.template.spec.containers[i].readinessProbe.periodSeconds == 0\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(42, 1, 'Workload mounting ServiceAccount Token', 'AutomountServiceAccountToken', 1, 7, 'Pods access to the API server should be minimized. When service account is not needed,  auto mount of secrets can be avoided', '', 27, '```bash \npackage apolicy \n \ndefault risky = false \n \n# AutomountServiceAccountToken POD Level attribute \nrisky {\n	input.spec.template.spec.automountServiceAccountToken == true\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(43, 1, 'Env variable exposing secret', 'Env Variable - SecretRef', 0.5, 3, 'Containers should avoid using secrets in environment variables as applications might print their content', '', 28, '```bash \npackage apolicy \n \ndefault risky = false \n \n# EnvFrom.SecretRef Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].envFrom.secretRef != null\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(44, 1, 'Env variable exposing key from a secret', 'Env Variable - SecretKeyRef', 0.5, 3, 'Containers should avoid using secrets in environment variables as applications might print their content', '', 29, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Env.SecretKeyRef Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].env.secretKeyRef != null\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(45, 1, 'Workload with docker.sock access', 'Volume HostPath contains /var/run/docker.sock', 1, 10, 'Pods mounting docker.sock can leak information about other container and result in container breakout', '', 30, '```bash \npackage apolicy \n \ndefault risky = false \n \n# Volume.HostPath POD Level attribute \nrisky {\n	contains("/var/run/docker.sock", input.spec.template.spec.volume.hostPath)\n}\n ```');

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id, rego) VALUES
(46, 1, 'Workload with writable volumes', 'Volume Mount Not Readyonly', 1, 6, 'Pods should mostly use read only volumes to make sure the workload is imutable', '', 31, '```bash \npackage apolicy \n \ndefault risky = false \n \n# VolumeMount.ReadOnly Container Level attribute \nrisky {\n    some i; input.spec.template.spec.containers[i].volumeMount.readOnly == false\n}\n ```');

-- Access Permissions risk
INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2003, 2, 'Access to secrets', 'Access to secrets', 1, 9, 'Has access to \"secrets\" resource', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2004, 2, 'Ingress management access', 'Ingress management access', 1, 9, 'Has create/update/delete access to Ingress/egress resource', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2005, 2, 'Listing secrets', 'Listing secrets', 1, 1, 'Has list access to secrets', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2007, 2, 'Create pod access', 'Create pod access', 1, 9, 'Subjects able to create Pods', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2008, 2, 'Service management access', 'Service management access', 1, 9, 'Has create/update/delete access to services resource', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2009, 2, 'Over permissive api group', 'Over permissive api group', 1, 9, 'Verb not in (read/get/list) and Role Rule with API Group = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2010, 2, 'Over permissive cluster api group', 'Over permissive cluster api group', 1, 9, 'Verb not in (read/get/list) and Cluster Role Rule with API Group = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2011, 2, 'Over permissive resource', 'Over permissive resource', 1, 5, 'Verb not in (read/get/list) and Role Rule with Resources = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2012, 2, 'Over permissive cluster resource', 'Over permissive cluster resource', 1, 5, 'Verb not in (read/get/list) and Cluster Role Rule with Resources = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2013, 2, 'Over permissive read access to api group', 'Over permissive read access to api group', 1, 5, 'Verb in (read/get/list) and Role Rule with API Group = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2014, 2, 'Over permissive read access to cluster api group', 'Over permissive read access to cluster api group', 1, 5, 'Verb in (read/get/list) and Cluster Role Rule with API Group = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2015, 2, 'Over permissive read access to resource', 'Over permissive read access to resource', 1, 1, 'Verb in (read/get/list) and Role Rule with Resources = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2016, 2, 'Over permissive read access to cluster resource', 'Over permissive read access to cluster resource', 1, 1, 'Verb in (read/get/list) and Cluster Role Rule with Resources = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2017, 2, 'Over permissive resource name', 'Over permissive resource name', 1, 1, 'Verb not in (read/get/list) and Role Rule with Resource Name = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2018, 2, 'Over permissive cluster resource name', 'Over permissive cluster resource name', 1, 1, 'Verb not in (read/get/list) and Cluster Role Rule with Resource Name = *', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2019, 2, 'Access without authentication', 'Access without authentication', 1, 1, '(Get/List/Watch) Access granted to system:unauthenticated', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2020, 2, 'Modify access without authentication', 'Modify access without authentication', 1, 9, '(Not Get/List/Watch) Access granted to system:unauthenticated', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2021, 2, 'Over exposed access', 'Over exposed access', 1, 1, '(Get/List/Watch) Access granted to system:authenticated', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2022, 2, 'Over exposed modify access', 'Over exposed modify access', 1, 9, '(Not Get/List/Watch) Access granted to system:authenticated', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2023, 2, 'Members of cluster-admin', 'Members of cluster-admin', 1, 9, 'cluster-admin role membership', '', NULL);

INSERT INTO risk (id, type, name, technical_name, weight, score, description, action, remediation_id) VALUES
(2024, 2, 'Service Account out of namespace access', 'Service Account out of namespace access', 1, 5, 'Service account access in a namespace it is not defined in', '', NULL);


#######################
# INIT RECOMMENDATION #
#######################

# Workloads recommendations
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (2,'Containers running as privileged',1,'CIS 1.5.1 (5.2.1) - Privileged containers are almost unrestricted and should not be used','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"16\", \"17\"]}]',1,'The container will not be able to run privileged mode and any privileged program will fail running.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (3,'Pods able to spawn privileged processes',1,'CIS 1.5.1 (5.2.5) - A sub-process can gain more privileges than the parent process.','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"18\", \"19\"]}]',1,'The container will not be able to spawn new processes with privileged mode. All new process will have privileged set to false.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (4,'Containers with writable root FS',1,'Best Practice - A container with writable root filesystem is more exposed to attacks as it allows tampering with executables','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"20\"]}]',2,'The container will not be able to modify the root file system of the container.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (5,'Pods sharing the host\'s process IDs',1,'CIS 1.5.1 (5.2.2) - Sharing the host\'s PID reduces isolation and exposes host data to the running Pod, for example, environment variables','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"3\"]}]',2,'The workload will lose visibility to processes running on the host.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (6,'Pods in the default namespace',1,'CIS 1.5.1 (5.7.4) - Pods should be namespaced to promote isolation','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"39\"]}]',3,'The workload will relocate to another namespace. All relevant objects must be relocated together with the workload.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (7,'Containers mounting docker.sock',1,'Best Practice - Pods mounting docker.sock can leak information about other container and result in container breakout','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"45\"]}]',1,'The containers will lose access to docker.sock and will not be able to control the docker daemon');

INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (8,'Missing resource requests',1,'Best Practice - Missing resource request hurts the scheduler resource assignment for workloads','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"34\", \"35\"]}]',3,'The container minimum requirements will be set to the requested values. If the request values are not available the workload will not be scheduled.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (10,'Missing resourcs limits',1,'Best Practice - Missing resouce limits could cause starvation','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"24\", \"25\"]}]',2,'The container resources will not surpass the set limits.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (12,'Containers with NET_ADMIN capability',1,'Best Practice - Assigns NET_Admin capability that allows binding to any address for transparent proxying any host address, managing interfaces, sniffing all host traffic and more.','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"28\", \"29\"]}]',1,'The container will lose its NET_ADMIN capability which allow manipuating the network interface');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (13,'Containers with NET_RAW capability',1,'Best Practice - Assigns NET_Admin capability that allows binding to any address for transparent proxying any host address','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"30\", \"31\"]}]',1,'The container will lose its NET_RAW capability which allows binding to any network interface');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (15,'Containers running as root',1,'CIS 1.5.1 (5.2.6) - Running containers as root can result in pod escape','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"26\", \"27\", \"21\", \"22\", \"9\"]}]',1,'The container will lose its root access in the container. If the container requires such access it will not function as expected.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (18,'Explicitly defined default service accounts',1,'CIS 1.5.1 (5.1.5) - Pods must run with unique users using least privileges. This ensures accountability for actions, easier troubleshooting and makes sure the Pod will not perform unauthorized actions','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"11\"]}]',2,'The service account is running the workload activities in the API server. The user replaced must be with the minimum required permissions to be able to perform all those activities. Insufficient permissions will cause the workload to fail.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (19,'Defaulted service account name',1,'CIS 1.5.1 (5.1.5) - Pods must run with unique users using least privileges. This ensures accountability for actions, easier troubleshooting and makes sure the Pod will not perform unauthorized actions','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"12\"]}]',1,'The service account is running the workload activities in the API server. The user replaced must be with the minimum required permissions to be able to perform all those activities. Insufficient permissions will cause the workload to fail.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (20,'Pods sharing host network interface',1,'CIS 1.5.1 (5.2.4) - Sharing the host network exposes the Pod\'s network to anyone with access to the Pod. In addition, it allows the Pod to communicate with processes bound to the host\'s loopback','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"1\"]}]',1,'Network activity performed through the host network interface (not Services and Ingresses) will fail once disabling this.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (21,'Host Port usage',1,'Best Practice - Host port usage may create constraints as to where the Pod can run','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"33\"]}]',2,'The container exposed host port will be removed and any services exposed through the port will not be exposed.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (22,'Pods sharing host IPC',1,'CIS 1.5.1 (5.2.3) - Sharing the host\'s IPC reduces isolation and allows the Pod to communicate with host processes eventually letting them perform tasks as if they were running on the host','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"5\"]}]',2,'The workload will not be able to communicate with processes running on the host.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (23,'Pod default security context misconfig',1,'CIS 1.5.1 (5.2.6) - In case a container in the Pod did not define runAsUser this will set the user to root','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"7\", \"8\", \"36\"]}]',3,'Containers in the workload without a defined user will inherit the defined user here as the user running the container.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (25,'Pod default group misconfig',1,'Best Practice - In case a container in the Pod did not define runAsGroup this will set the group to root','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"10\"]}]',3,'Containers in the workload without a defined running group will inherit the defined group here as the group for the file system permissions.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (26,'Containers that NEVER pull images',1,'Best Practice - Images that are not updated from the image repositories may result in tampered images','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"13\", \"32\"]}]',1,'The container will try and pull the image every time it will be scheduled. If it will not be able to the workload will fail to schedule.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (28,'Unversioned images using latest',1,'Best Practice - Images running with \"latest\" or blank tag can break down the integrity of the system as update without a specific image','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"14\"]}]',2,'The container will always try and get the specific image tag defined. Updates to the image will not be reflected until the tag update.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (31,'Containers without liveness probe',1,'Best Practice - Containers should have liveness probe to expose their app status and maintain system integrity','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"40\"]}]',2,'Defining a liveness probe assists in verifing the container is working correctly. If the defined liveness probe fails, the container will restart according to its restart policy.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (32,'Containers without startup probe',1,'Best Practice - Containers should have readiness probe to expose their ability to service request and maintain system integrity','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"41\"]}]',3,'Defining a readiness probe assists in verifing the container started correctly. If the defined readiness probe fails, the repllica will not be available. If all replicas fails, the workload will not be available.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (33,'Pods with API server access',1,'CIS 1.5.1 (5.1.6) - Pods access to the API server should be minimized. When service account is not needed, auto mount of secrets can be avoided','[{\"field\": \"attributes.risk.id\", \"operator\": 7, \"values\" : [\"42\"]}]',2,'The service account running the workload will not get his token automatically mounted to the workload. This will result in the service account inability to authenticate. This is recommended for workloads that DO NOT need to communicate with the API Server or for those that have other means of authenticating.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (34,'Secrets exposed in env variables',1,'CIS 1.5.1 (5.4.1) - Containers should avoid using secrets in environment variables as applications might print their content','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"43\", \"44\"]}]',3,'The environment variable or a value of an environment variable will not be available unless loaded from a different source.');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (36,'Use volumes in ReadOnly mode',1,'Best Practice - Pods should mostly use read only volumes to make sure the workload is imutable','[{\"field\": \"containers.attributes.risk.id\", \"operator\": 7, \"values\" : [\"46\"]}]',2,'The containers access to the volume will have read only access.');

# Subjects recommendations
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (37, 'Subject with access to secrets', 2, 'Any access other than list to Secret', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2003"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (38, 'Listing secrets', 2, 'List access to secrets', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2005"]}]', 3, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (39, 'Subjects able to create Pods', 2, 'Subjects with Create Pod access', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2007"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (40, 'Ingress management access', 2, 'Has create/update/delete access to Ingress/egress resource', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2004"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (41, 'Service management access', 2, 'Create/Update/Delete services', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2008"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (42, 'Modify Access without authentication', 2, 'Access granted to system:unauthenticated', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2020"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (43, 'Over exposed modify access', 2, 'Access granted to system:authenticated', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2022"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (44, 'Members of cluster-admin', 2, 'cluster-admin role membership', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2023"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (45, 'Service Account out of namespace access', 2, 'Service account access in a namespace it is not defined in', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2024"]}]', 2, '');

# Roles recommendations
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (46, 'Grants access to secrets', 3, 'Any access other than list to Secret', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2003"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (47, 'Listing secrets', 3, 'List access to secrets', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2005"]}]', 3, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (48, 'Create Pods access', 3, 'Enables Create Pod access', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2007"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (49, 'Ingress management access', 3, 'Has create/update/delete access to Ingress/egress resource', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2004"]}]', 1, '');
INSERT INTO recommendation (id, name, type, description, filter, severity, change_impact) VALUES (50, 'Service management access', 3, 'Create/Update/Delete services', '[{"field": "r.risk_identifier", "operator": 7, "values" : ["2008"]}]', 1, '');

##################################
#    INIT RECOMMENDATION RISK    #
##################################
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (2,16);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (3,18);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (4,20);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (5,3);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (6,39);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (7,45);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (8,34);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (8,35);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (10,24);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (10,25);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (12,28);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (13,30);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (15,9);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (15,21);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (15,26);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (25,23);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (18,11);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (19,12);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (20,1);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (21,33);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (22,5);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (23,7);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (23,36);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (25,10);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (26,13);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (26,32);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (28,14);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (31,40);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (32,41);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (33,42);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (34,43);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (34,44);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (36,46);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (37,2003);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (38,2005);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (39,2007);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (40,2004);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (41,2008);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (42,2020);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (43,2022);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (44,2023);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (45,2024);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (46,2003);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (47,2005);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (48,2007);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (49,2004);
INSERT INTO recommendation_risk (recommendation_id, risk_id) VALUES (50,2008);

##########################
#    INIT REMEDIATION    #
##########################

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (1, 1, 'HostNetwork', 'Network activity performed through the host network interface (not Services and Ingresses) will fail once disabling this.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (2, 1, 'HostPID', 'The workload will lose visibility to processes running on the host.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (3, 1, 'HostIPC', 'The workload will not be able to communicate with processes running on the host.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (4, 1, 'SecurityContext.runAsUser', 'Containers in the workload without a defined user will inherit the defined user here as the user running the container.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (5, 2, 'SecurityContext.runAsNonRoot', 'Containers in thw workload without an explicit RunAsNonRoot will be denied of running as root.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (6, 1, 'SecurityContext.runAsGroup', 'Containers in the workload without a defined running group will inherit the defined group here as the group for the file system permissions.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (7, 1, 'ServiceAccountName', 'The service account is running the workload activities in the API server. The user replaced must be with the minimum required permissions to be able to perform all those activities. Insufficient permissions will cause the workload to fail.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (8, 2, 'ImagePullPolicy', 'The container will try and pull the image every time it will be scheduled. If it will not be able to the workload will fail to schedule.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (9, 2, 'Image', 'The container will always try and get the specific image tag defined. Updates to the image will not be reflected until the tag update.');

INSERT INTO remediation (id, type, object_name, change_impact)
VALUES (10, 2, 'SecurityContext.privileged', 'The container will not be able to run privileged mode and any privileged program will fail running.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (11, 2, 'SecurityContext.allowPrivilegeEscalation', 'The container will not be able to spawn new processes with privileged mode. All new process will have privileged set to false.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (12, 2, 'SecurityContext.readOnlyRootFileSystem', 'The container will not be able to modify the root file system of the container.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (13, 2, 'SecurityContext.runAsUser', 'The container will run the image with the defined user.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (14, 2, 'SecurityContext.runAsGroup', 'The container user will be assigned to the group which in turn will set its group access privileges in the file system.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (15, 2, 'Resources.limits.cpu', 'The container CPU will not surpass the set limit.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (16, 2, 'Resources.limits.memory', 'The container memory will not surpass the set limit.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (17, 2, 'Capabilities.[SYS_ADMIN]', 'The container will lose its SYS_ADMIN capability which is equal to root');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (18, 2, 'Capabilities.[NET_ADMIN]', 'The container will lose its NET_ADMIN capability which allow manipuating the network interface');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (19, 2, 'Capabilities.[NET_RAW]', 'The container will lose its NET_RAW capability which allows binding to any network interface');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (20, 2, 'HostPort', 'The container exposed host port will be removed and any services exposed through the port will not be exposed.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (21, 2, 'Resources.requests.cpu', 'The container minimum CPU will be set to the requested value. If the request value is not available the workload will not be scheduled');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (22, 2, 'Resources.requests.memory', 'The container minimum memory will be set to the requested value. If the request value is not available the workload will not be scheduled');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (23, 1, 'SecurityContext.runAsNonRoot', 'The container will not be able to run as root. If root is set in the image the container will not be able to start.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (24, 1, 'Namespace', 'The workload will relocate to another namespace. All relevant objects must be relocated together with the workload.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (25, 2, 'LivenessProbe', 'Defining a liveness probe assists in verifing the container is working correctly. If the defined liveness probe fails, the container will restart according to its restart policy.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (26, 2, 'ReadinessProbe', 'Defining a readiness probe assists in verifing the container started correctly. If the defined readiness probe fails, the repllica will not be available. If all replicas fails, the workload will not be available.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (27, 1, 'AutomountServiceAccountToken', 'The service account running the workload will not get his token automatically mounted to the workload. This will result in the service account inability to authenticate. This is recommended for workloads that DO NOT need to communicate with the API Server or for those that have other means of authenticating.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (28, 2, 'Env.secretRef', 'The environment variable will not be available unless loaded from a different source.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (29, 2, 'Env.secretKeyRef', 'The environment variable value will not be available unless loaded from a different source.');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (30, 1, 'Volumes.hostPath', 'The containers will lose access to docker.sock and will not be able to control the docker daemon');

INSERT INTO remediation (id, type, object_name, change_impact) 
VALUES (31, 2, 'VolumeMounts.readOnly', 'The containers access to the volume will have read only access.');

###############################
#    INIT REMEDIATION STEPS   #
###############################

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static) 
VALUES (1, 1, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n'
,'* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        hostNetwork: false\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.HostNetwork.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (2, 2, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n'
,'* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        hostPID: false\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.HostPID.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (3, 3, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n'
,'* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        hostIPC: false\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.HostIPC.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (4, 4, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n'
,'* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        securityContext:\n          runAsUser: userId\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.runAsUser.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (5, 5, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
,'* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          securityContext:\n            runAsNonRoot: true\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.runAsNonRoot.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (6, 6, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n'
,'* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        securityContext:\n          runAsGroup: groupId\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.runAsGroup.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template,  playbook_static)  
VALUES (8, 8, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          imagePullPolicy: Always\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.ImagePullPolicy.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (9, 9, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          image: Image\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.Image.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (10, 10, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          securityContext:\n            privileged: false\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.privileged.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (11, 11, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          securityContext:\n            allowPrivilegeEscalation: false\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.allowPrivilegeEscalation.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (12, 12, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          securityContext:\n            readOnlyRootFileSystem: true\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.readOnlyRootFileSystem.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (13, 13, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          securityContext:\n            runAsUser: userId\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.runAsUser.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (14, 14, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          securityContext:\n            runAsGroup: groupId\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.runAsGroup.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (15, 15, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          resources:\n            limits:\n              cpu: limits.cpu\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.Resources.limits.cpu.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (16, 16, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          resources:\n            limits:\n              cpu: limits.memory\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.Resources.limits.memory.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (20, 20, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.HostPort.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (21, 21, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          resources:\n            requests:\n              cpu: requests.cpu\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.Resources.requests.cpu.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (22, 22, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        containers:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        containers:\n        - name: {{.ContainerName}}\n          resources:\n            requests:\n              cpu: requests.memory\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.Resources.requests.memory.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (23, 23, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        securityContext:\n          runAsNonRoot: true\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.SecurityContext.runAsNonRoot.yaml})\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (24, 24, 'Identify objects required to move', 1, '* The workload is in the default Namespace which is not recommended.<br />In order to be able to move it to a designated Namespace, you should first identify all Namespaced objects that would be transfered with it. For example, secrets, service account, services etc.<br />Make sure the other objects are not being used in any other workloads.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (25, 24, 'Create a Namespace', 2, '* Run the following command to create a Namespace. add any labels or metadata you need:\n&nbsp;\n```bash\nkubectl create ns <namesapce name>\n```\n', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (26, 24, 'Move workloads and relevant objects', 3, '* Move all pre-requisit objects to the new Namespace.<br />Add a Namespace attribute to the workload manifest.<br />Apply the updated configuration to move the workload.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (27, 25, 'Identify the liveness probe check', 1, '* Identify the command needed to run in the check.<br />The check should identify situations where the container cannot perform its tasks.<br />Make sure the check is simple enough so the check itself will not get stuck.<br />The check should be able to run regardless of the state of the container.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (28, 25, 'Add liveness probe to the workload', 2, '* Add the liveness probe for your workload.<br />Define the intervals of the check.<br />If the check is not successful it will restart the container.<br />Restart the workload.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (29, 26, 'Identify the readiness probe check', 1, '* Identify the command needed to run in the check.<br />The check should identify situations where the container cannot serve requests.<br />This will allow the container to hold requests from being served if it is not ready.<br />Make sure the check is simple enough so the check itself will not get stuck.<br />The check should be able to run regardless of the state of the container.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (30, 26, 'Add readiness probe to the workload', 2, '* Add the readiness probe for your workload.<br />Define the intervals of the check.<br />If the check is not successful it will stop requests from coming to the container but will not restart it.<br />Restart the workload.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (31, 27, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        automountServiceAccountToken: false\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.AutomountServiceAccountToken.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (32, 28, 'Remove secrets from environment variables', 1, '* Loading secrets into the environment variables makes them accessible to anyone that has access to the workload. Access will be granted even to users that do not have access to the secret object.<br />The best practice is to load the secret into a file accessible to the service account.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (33, 29, 'Remove secrets from environment variables', 1, '* Loading secrets into the environment variables makes them accessible to anyone that has access to the workload. Access will be granted even to users that do not have access to the secret object.<br />The best practice is to load the secret into a file accessible to the service account.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template, playbook_static)  
VALUES (34, 30, 'Apply patches', 1
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\n {{.Yaml}} ```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat {{.FileName}})\"\n```\n'
, 'spec:\n    template:\n      spec:\n        volumes:\n          - emptyDir: {}\n            hostPath: null\n            name: {{.ConfigInstanceName}}\n'
, '* Download the patch(es) for the workload to change the configuration to match the desired remediated configuration: \n ```yaml\nspec:\n    template:\n      spec:\n        volumes:\n          - emptyDir: {}\n            hostPath: null\n            name: {{.VolumeName}}\n```\n* Apply patches to the workload configuration using the command: \n ```bash\n kubectl -n {{.Namespace}} patch {{.Kind}} {{.WorkloadName}} --patch \"$(cat apolicy.Volumes.hostPath.yaml)\"\n```\n');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (35, 30, 'Clean up the docker.sock', 2, '* Find all containers in the workload that are using the volume that was for docker.sock. <br />Remove the volumeMount from each of the containers. <br />Remove the volume from the workload.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (36, 31, 'Update the access mode of the volumeMount', 1, '* Update the volumeMount readOnly attribute. <br />If the attribute exist, set it to true. <br />If the attribute does not exist, add it readOnly = true. <br />Restart the workload.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (37, 17, 'Add SYS_ADMIN to Capabilities.Drop', 1, '* Add SYS_ADMIN to the list of dropped capabilities. <br />If it is already there, no need to add it again.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (38, 17, 'Remove SYS_ADMIN from Capabilities.Add', 1, '* Remove SYS_ADMIN from the list of added capabilities. <br />If it is not there, no need to do anything.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (39, 18, 'Add NET_ADMIN to Capabilities.Drop', 1, '* Add NET_ADMIN to the list of dropped capabilities. <br />If it is already there, no need to add it again.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (40, 18, 'Remove NET_ADMIN from Capabilities.Add', 1, '* Remove NET_ADMIN from the list of added capabilities. <br />If it is not there, no need to do anything.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (41, 19, 'Add NET_RAW to Capabilities.Drop', 1, '* Add NET_RAW to the list of dropped capabilities. <br />If it is already there, no need to add it again.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (42, 19, 'Remove NET_RAW from Capabilities.Add', 1, '* Remove NET_RAW from the list of added capabilities. <br />If it is not there, no need to do anything.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (43, 7, 'Create a unique Service Account with required access level', 1, '* Create a dedicated service account for the workload. <br />Add all the required permissions for the workload to perform its work.', '');

INSERT INTO remediation_step (id, remediation_id, title, step_number, playbook, playbook_yaml_template)  
VALUES (44, 7, 'Patch the workload with the Service Account', 1, '* Update the workload with the newly created service account in the serviceAccountName field. <br />Restart the workload.', '');

####################################
#    INIT REMEDIATION STEPS INPUT  #
####################################
INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (4, 'Please provide the default user id (uid) for containers in the workload', 'securityContext.runAsUser', 'userId', true, 1);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (6, 'Please provide the default group id (gid) for containers in the workload', 'securityContext.runAsGroup', 'groupId', true, 1);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (21, 'Please provide the requested CPU resource minimum for the container', 'resources.requests.cpu', 'requests.cpu', true, 2);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (22, 'Please provide the requested RAM resource minimum for the container', 'resources.requests.memory', 'requests.memory', true, 2);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (13, 'Please provide the default user id (uid) for the container. When no value is set, will be taken from the workload.', 'securityContext.runAsUser', 'userId', true, 1);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (14, 'Please provide the default group id (gid) for the container. When no value is set, will be taken from the workload.', 'securityContext.runAsGroup', 'groupId', true, 1);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (15, 'Please provide the maximum CPU for the container', 'resources.limits.cpu', 'limits.cpu', true, 2);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (16, 'Please provide the maximum RAM for the container', 'resources.limits.memory', 'limits.memory', true, 2);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (1, 'HostNetwork', 'hostNetwork', 'false', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (2, 'HostPID', 'hostPID', 'false', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (3, 'HostIPC', 'hostIPC', 'false', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (5, 'RunAsNonRoot', 'securityContext.runAsNonRoot', 'true', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (31, 'automountServiceAccountToken', 'automountServiceAccountToken', 'false', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (8, 'imagePullPolicy', 'imagePullPolicy', 'Always', false, 2);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (10, 'SecurityContext.privileged', 'securityContext.privileged', 'false', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (11, 'SecurityContext.AllowPrivilegeEscalation', 'securityContext.allowPrivilegeEscalation', 'false', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (12, 'SecurityContext.ReadOnlyRootFileSystem', 'securityContext.readOnlyRootFileSystem', 'true', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (23, 'SecurityContext.runAsNonRoot', 'securityContext.runAsNonRoot', 'true', false, 3);

INSERT INTO remediation_step_input (remediation_step_id, description, field, value, is_user_input, type)
VALUES (9, 'Please provide the image and it''s tag to amend the container''s image', 'image', 'Image', true, 2);


