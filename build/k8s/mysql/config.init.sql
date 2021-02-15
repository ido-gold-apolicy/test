create database config;
use config;

DROP TABLE IF EXISTS `tenant`;
CREATE TABLE `tenant` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `gcp_sa_id` varchar(320) DEFAULT NULL,
  `gcp_sa_key` blob DEFAULT NULL,
  `status` int NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1;

DROP TABLE IF EXISTS `cluster`;
CREATE TABLE `cluster` (
  `id` binary(16) NOT NULL,
  `name` varchar(255) NOT NULL,
  `tenant_id` bigint NOT NULL,
  `public_key` blob NOT NULL,
  CONSTRAINT fk_cluster_tenant_id FOREIGN KEY (tenant_id) REFERENCES tenant(id),
  CONSTRAINT uc_cluster_tenant_name UNIQUE (`name`, `tenant_id`),
  PRIMARY KEY (`id`),
  INDEX `idx_cluster_tenant_id` (`tenant_id`)
);

DROP TABLE IF EXISTS `cluster_deployment`;
CREATE TABLE `cluster_deployment` (
  `id` int NOT NULL,
  `template` text NOT NULL,
  PRIMARY KEY (`id`)
);

##################################
#    INIT DEPLOYMENT TEMPLATE    #
##################################

INSERT INTO cluster_deployment (`id`, `template`) VALUES (1,
'apiVersion: v1
kind: Namespace
metadata:
  name: apolicy
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-apolicy
  namespace: apolicy
  labels:
    app: apolicy-krm
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  namespace: apolicy
  name: apolicy-reader
  labels:
    app: apolicy-krm
rules:
  - apiGroups:
      - ''''
      - ''rbac.authorization.k8s.io''
      - ''extensions''
      - ''apps''
      - ''batch''
      - ''networking.k8s.io''
    resources:
      - ''pods''
      - ''pods/log''
      - ''namespaces''
      - ''deployments''
      - ''daemonsets''
      - ''statefulsets''
      - ''jobs''
      - ''cronjobs''
      - ''clusterroles''
      - ''clusterrolebindings''
      - ''roles''
      - ''rolebindings''
      - ''services''
      - ''serviceaccounts''
      - ''nodes''
      - ''ingresses''
    verbs:
      - ''get''
      - ''list''
      - ''watch''
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  namespace: apolicy
  name: croleb-apolicy-krm
  labels:
    app: apolicy-krm
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: apolicy-reader
subjects:
  - kind: ServiceAccount
    name: sa-apolicy
    namespace: apolicy
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    component: collector
    app: apolicy-krm
  name: collector-deployment
  namespace: apolicy
spec:
  replicas: 1
  selector:
    matchLabels:
      component: collector
  template:
    metadata:
      labels:
        component: collector
    spec:
      serviceAccountName: sa-apolicy
      containers:
        - name : collector
          image: apolicyio/collector:1.0.0
          env:
            - name: CLUSTER_ID
              value: "{{.clusterID}}"
            - name: PRIVATE_KEY
              value: "{{.encodedKey}}"
            - name: GCP_CREDENTIALS
              value: "{{.gcpSAKey}}"
            - name: K8S_HOST
              value:
            - name: K8S_REMOTE
              value: "false"
            - name: INCLUDED_NAMESPACES
              value:
            - name: EXCLUDED_NAMESPACES
              value: apolicy
            - name: INCLUDED_WORKLOADS
              value:
            - name: EXCLUDED_WORKLOADS
              value:
            - name: GOOGLE_CLOUD_PROJECT
              value: "ido-test-282609"
            - name: LOGS_TOPIC
              value: collector-logs
            - name: SUBSCRIPTION
              value: "{{.subscription}}"'
);