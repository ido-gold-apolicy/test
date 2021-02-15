create database auth;
use auth;

DROP TABLE IF EXISTS `user`;
CREATE TABLE `user` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(320) NOT NULL,
  `hashed_password` varchar(300) DEFAULT NULL,
  `last_login` datetime DEFAULT NULL,
  `locked` tinyint NOT NULL DEFAULT '0',
  `tenant_id` bigint NOT NULL,
  `incorrect_password_count` int NOT NULL DEFAULT '0',
  `reset_password_token` varchar(45) DEFAULT NULL,
  `reset_password_date` datetime DEFAULT NULL,
  `goals` varchar(1000) DEFAULT NULL,
  `details` TEXT NOT NULL,
  `is_api_user` tinyint NOT NULL DEFAULT '0',
  `api_key` varchar(2100) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  UNIQUE KEY `id_UNIQUE` (`id`)
);

DROP TABLE IF EXISTS `role`;
CREATE TABLE `role` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `tenant_id` bigint NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `role_permission`;
CREATE TABLE `role_permission` (
  `role_id` bigint NOT NULL,
  `permission_id` bigint NOT NULL,
  PRIMARY KEY (role_id, permission_id)
);

DROP TABLE IF EXISTS `permission`;
CREATE TABLE `permission` (
  `id` bigint NOT NULL,
  `name` varchar(100) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `permission_atomic_permission`;
CREATE TABLE `permission_atomic_permission` (
  `permission_id` bigint NOT NULL,
  `atomic_permission_id` bigint NOT NULL,
  PRIMARY KEY (permission_id, atomic_permission_id)
);

DROP TABLE IF EXISTS `atomic_permission`;
CREATE TABLE `atomic_permission` (
  `id` bigint NOT NULL,
  `url` varchar(2000) NOT NULL,
  `method` varchar(20) NOT NULL,
  PRIMARY KEY (`id`)
);

DROP TABLE IF EXISTS `user_role`;
CREATE TABLE `user_role` (
  `user_id` bigint NOT NULL,
  `role_id` bigint NOT NULL,
  PRIMARY KEY (user_id, role_id)
);

DROP TABLE IF EXISTS `config`;
CREATE TABLE `config` (
  `authorization_policy` text NOT NULL,
  `revision` int NOT NULL,
  `forgot_password_template` text NOT NULL,
  `signup_template` text NOT NULL,
  `invite_user_template` text NOT NULL
);
INSERT INTO `config` VALUES (
  'package httpapi.authz \ndefault allow = false\n routeKey = sprintf("%v|%v", [input.path, input.method]) \nallow {    \n	input.token.payload.Roles[_] == data.path[routeKey][_]   \n}',
  0,
  'Subject: Apolicy - Reset Password Request\nMIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n<head><style>#box {color: #3C434D;font-size: 12px;font-family: "Roboto", sans-serif;}.dark-button:hover {color: white; border: 1px solid #98a4fc;}a {cursor: pointer;color: #6a75ca;text-decoration: none;}a:hover {text-decoration: none;color: #6e7b8f;}#box {width: 600px;}</style></head><body><table align="center" style="width:100%;height:100%;background-color:#fafafa;margin:20px 0;"><tbody><tr><td align="center" valign="top" style="width:100%;max-width:650px;margin:0 auto"><div id="box" style="text-align: center;background-color:#ffffff!important;"> <div id="banner"><img src="https://storage.googleapis.com/apolicy-assets-bucket/Header.jpg"> </div> <div style="margin-top:63px;"><img src="https://storage.googleapis.com/apolicy-assets-bucket/lock.png"> </div> <table align="center" style="margin-top: 32px;"><tbody><tr><td align="center" valign="top" style="width:100%;max-width:440px;margin:0 auto"><h1 style="font-size: 20px;color:#3C434D !important;">Forgot your password?</h1><div id="instructions" style="margin-top: 24px; line-height: 22px;color:#3C434D !important;font-size:12px;"><p>Please click on the button below to set your new password.</p><p>If you didn''t mean to reset your password, ignore this email and your password will remain the same.</p><p>If you think someone is trying to access your account, please forward this email to <a class="sc-sVRsr jzzRJ" title="mailto:passwords@apolicy.io" href="mailto:passwords@apolicy.io" data-renderer-mark="true">passwords@apolicy.io.</a></p></div><div class="button-container" style="margin-top: 48px;"><a href="https://my.apolicy.io/auth/reset-password?username={{.Username}}&amp;otp={{.Otp}}" target="_blank" rel="noopener"><span class="dark-button" style="text-decoration: none;cursor: pointer;font-size: 12px;color: white;padding: 9px 25px;background: #3C434D;box-shadow: inset 0px 0px 5px rgba(0, 0, 0, 0.15);border-radius: 4px;">CREATE NEW PASSWORD</span></a></div></td></tr></tbody> </table> <table style="width:100%;max-width:650px;margin:0 auto"><tbody><tr><td align="center" valign="top"><hr class="line" style="margin-top: 50px;"><h4 style="font-size: 12px;color:#999CAF !important;">FOLLOW US</h4><p style="font-size: 12px;"><a href="https://apolicy.io/">Apolicy.io</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://twitter.com/apolicyio">Twitter</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://www.linkedin.com/company/apolicy">LinkedIn</a></a></p><p style="color:#999CAF;line-height:22px;font-size:12px;">All rights reserved &#169;apolicy.io inc. {{.Year}}</p></td></tr></tbody></table></div></td></tr></tbody></table></body>', 
  'Subject: Apolicy - Welcome\nMIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n<head><style>#box {color: #3C434D;font-size: 12px;font-family: "Roboto", sans-serif;}.dark-button:hover {color: white; border: 1px solid #98a4fc;}a {cursor: pointer;color: #6a75ca;text-decoration: none;}a:hover {text-decoration: none;color: #6e7b8f;}#box {width: 600px;}</style></head><body><table align="center" style="width:100%;height:100%;background-color:#fafafa;margin:20px 0;"><tbody><tr><td align="center" valign="top" style="width:100%;max-width:650px;margin:0 auto"><div id="box" style="text-align: center;background-color:#ffffff!important;"> <div id="banner"><img src="https://storage.googleapis.com/apolicy-assets-bucket/Header.jpg"> </div> <div style="margin-top:63px;"><img src="https://storage.googleapis.com/apolicy-assets-bucket/success-icon.png"> </div> <table align="center" style="margin-top: 32px;"><tbody><tr><td align="center" valign="top" style="width:100%;max-width:500px;margin:0 auto"><h1 style="font-size: 20px;color:#3C434D !important;">Welcome to Apolicy!</h1><div id="instructions" style="margin-top: 24px; line-height: 22px;color:#3C434D !important;font-size:12px;"><p>Please click on the button below to verify your e-mail and continue the registration process.</p></div><div class="button-container" style="margin-top: 48px;"><a href="https://my.apolicy.io/auth/reset-password?newuser=true&username={{.Username}}&amp;otp={{.Otp}}" target="_blank" rel="noopener"><span class="dark-button" style="text-decoration: none;cursor: pointer;font-size: 12px;color: white;padding: 9px 25px;background: #3C434D;box-shadow: inset 0px 0px 5px rgba(0, 0, 0, 0.15);border-radius: 4px;">CLICK HERE TO VERIFY</span></a></div></td></tr></tbody> </table> <table style="width:100%;max-width:650px;margin:0 auto"><tbody><tr><td align="center" valign="top"><hr class="line" style="margin-top: 150px;"><h4 style="font-size: 12px;color:#999CAF !important;">FOLLOW US</h4><p style="font-size: 12px;"><a href="https://apolicy.io/">Apolicy.io</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://twitter.com/apolicyio">Twitter</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://www.linkedin.com/company/apolicy">LinkedIn</a></a></p><p style="color:#999CAF;line-height:22px;font-size:12px;">All rights reserved &#169;apolicy.io inc. {{.Year}}</p></td></tr></tbody></table></div></td></tr></tbody></table></body>',
  'Subject: Your friend invited you to join him on Apolicy\nMIME-version: 1.0;\nContent-Type: text/html; charset=\"UTF-8\";\n\n<head><style>#box {color: #3C434D;font-size: 12px;font-family: "Roboto", sans-serif;}.dark-button:hover {color: white; border: 1px solid #98a4fc;}a {cursor: pointer;color: #6a75ca;text-decoration: none;}a:hover {text-decoration: none;color: #6e7b8f;}#box {width: 600px;}</style></head><body><table align="center" style="width:100%;height:100%;background-color:#fafafa;margin:20px 0;"><tbody><tr><td align="center" valign="top" style="width:100%;max-width:650px;margin:0 auto"><div id="box" style="text-align: center;background-color:#ffffff!important;"> <div id="banner"><img src="https://storage.googleapis.com/apolicy-assets-bucket/Header.jpg"> </div> <div style="margin-top:63px;"><img src="https://storage.googleapis.com/apolicy-assets-bucket/group.png"> </div> <table align="center" style="margin-top: 32px;"><tbody><tr><td align="center" valign="top" style="width:100%;max-width:440px;margin:0 auto"><h1 style="font-size: 20px;color:#3C434D !important;">You''ve recieved an invitation!</h1><div id="instructions" style="margin-top: 24px; line-height: 22px;color:#3C434D !important;font-size:12px;"><p>{{.InviterName}} invited you to join his <b>Apolicy</b> environment.</p><p><b>Apolicy</b> is a Kubernetes Policy Orchestration solution assisting DevOps to manage security, risk & compliance.</p><p>Click <a href="https://www.apolicy.io">here</a> to learn more.</p><br><p>Click on the button below to set a password and continue the registration process.</p><p>By continuing you agree to our <a href="https://my.apolicy.io/assets/agreements/services-agreement.pdf">Services Agreement</a> and <a href="https://my.apolicy.io/assets/agreements/end-user-license-agreement.pdf">End User License.</a></p></div><div class="button-container" style="margin-top: 48px;"><a href="https://my.apolicy.io/auth/reset-password?newuser=true&username={{.Username}}&amp;otp={{.Otp}}" target="_blank" rel="noopener"><span class="dark-button" style="text-decoration: none;cursor: pointer;font-size: 12px;color: white;padding: 9px 25px;background: #3C434D;box-shadow: inset 0px 0px 5px rgba(0, 0, 0, 0.15);border-radius: 4px;">ACCEPT INVITATION</span></a></div></td></tr></tbody> </table> <table style="width:100%;max-width:650px;margin:0 auto"><tbody><tr><td align="center" valign="top"><hr class="line" style="margin-top: 50px;"><h4 style="font-size: 12px;color:#999CAF !important;">FOLLOW US</h4><p style="font-size: 12px;"><a href="https://apolicy.io/">Apolicy.io</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://twitter.com/apolicyio">Twitter</a>&nbsp;&nbsp;|&nbsp;&nbsp;<a href="https://www.linkedin.com/company/apolicy">LinkedIn</a></a></p><p style="color:#999CAF;line-height:22px;font-size:12px;">All rights reserved &#169;apolicy.io inc. {{.Year}}</p></td></tr></tbody></table></div></td></tr></tbody></table></body>'
  );

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (1000, 'Read Workloads');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (1001, '/workloads', 'POST');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (1002, '/workloads/scan-stats', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (1003, '/workloads/distinct-values', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (1004, '/workloads/view', 'GET');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (1000, 1001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (1000, 1002);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (1000, 1003);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (1000, 1004);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (2000, 'Read Config');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (2001, '/config/clusters', 'GET');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (2000, 2001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (2000, 2002);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (3000, 'Hosted App');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 1001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 1003);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 1004);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 2002);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 4001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 4002);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 4004);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 4007);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 4008);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 6001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 6002);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (3000, 8001);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (4000, 'Read Access');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (4001, '/access/subjects', 'POST');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (4002, '/access/distinct-values', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (4003, '/access/scan-stats', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (4004, '/access/subjects', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (4007, '/access/roles', 'POST');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (4008, '/access/roles', 'GET');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (4000, 4001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (4000, 4002);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (4000, 4003);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (4000, 4004);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (4000, 4007);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (4000, 4008);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (5000, 'Read Users');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (5001, '/users/api-key', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (5002, '/users/set-goals', 'POST');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (5003, '/users/invite', 'POST');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (5000, 5001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (5000, 5002);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (5000, 5003);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (6000, 'Write Config');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (6001, '/config/clusters', 'POST');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (6002, '/config/clusters', 'PUT');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (6000, 6001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (6000, 6002);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (7000, 'Write Scheduler');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (7001, '/tasks/startScan', 'PUT');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (7000, 7001);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (8000, 'Write Workloads');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (8001, '/workloads/remediate', 'POST');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (8000, 8001);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (9000, 'Read Policy');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9001, '/policy/policies', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9002, '/policy/recommendations', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9003, '/policy/policies/view', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9004, '/policy/requirementRiskStatuses/view', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9005, '/policy/policies/distinct-values', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9006, '/policy/requirements/distinct-values', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9007, '/policy/recommendation', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (9008, '/policy/recommendations/control-recommendation', 'GET');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9002);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9003);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9004);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9005);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9006);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9007);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (9000, 9008);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (10000, 'Read Controls');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (10001, '/policy/controls', 'GET');
INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (10002, '/policy/controls/view', 'GET');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (10000, 10001);
INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (10000, 10002);

INSERT INTO `auth`.`permission` (`id`, `name`) VALUES (11000, 'Read Violations');

INSERT INTO `auth`.`atomic_permission` (`id`, `url`, `method`) VALUES (11001, '/compliance/violations', 'POST');

INSERT INTO `auth`.`permission_atomic_permission` (`permission_id`, `atomic_permission_id`) VALUES (11000, 11001);


INSERT INTO `auth`.`role` (`id`,`name`,`tenant_id`) VALUES (1, 'Administrator', 0);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 1000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 2000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 4000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 5000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 6000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 7000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 8000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 9000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 10000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (1, 11000);

INSERT INTO `auth`.`role` (`id`,`name`,`tenant_id`) VALUES (2, 'Read Only', 0);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (2, 1000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (2, 2000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (2, 4000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (2, 5000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (2, 9000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (2, 10000);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (2, 11000);

INSERT INTO `auth`.`role` (`id`,`name`,`tenant_id`) VALUES (3, 'Hosted App User', 0);
INSERT INTO `auth`.`role_permission` (`role_id`, `permission_id`) VALUES (3, 3000);

update auth.config set revision=1;
