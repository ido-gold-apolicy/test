// Create the database
db = db.getSiblingDB('apolicy')

// Create the "workloads" collection
db.createCollection("workloads", {
  validator: {
     $jsonSchema: {
        bsonType: "object",
        required: ["tenantId", "clusterId", "scanId", "uid", "isLatest"]
    },
  }
})

db.workloads.createIndex({ tenantId: 1, clusterId: 1, scanId: 1, uid: 1 }, { unique: true })

db.workloads.createIndex(
  { tenantId: 1, clusterId: 1, isLatest: 1 }, 
  { partialFilterExpression: { isLatest: true } },
)

// Create the "scans" collection
db.createCollection("scans", {
  validator: {
     $jsonSchema: {
        bsonType: "object",
        required: ["tenantId", "clusterId", "endDate"]
    },
  }
})

db.scans.createIndex( { tenantId: 1, clusterId: 1, endDate: 1 } )

db.scans.createIndex( 
	{ totalMessagesCount: 1, messagesCount: 1 },
	{ partialFilterExpression: { endDate: null } },
)

//////////////////
// Analysis DB //
////////////////

db = db.getSiblingDB('analysis')

//
// "scans" collection
//
db.createCollection("scans", {
  validator: {
     $jsonSchema: {
        bsonType: "object",
        required: ["tenantId", "clusterId", "taskId", "endDate"]
    },
  }
})

db.scans.createIndex( 
	{ endDate: 1, agentsCount: 1, processedNodes: 1, startDate: 1 },
	{ partialFilterExpression: { endDate: null } },
)

db.scans.createIndex( 
	{ tenantId: 1, clusterId: 1, isLatest: 1, clusterName: 1 },
	{ partialFilterExpression: { isLatest: true } },
)

//
// "nodes" collection
//
db.createCollection("nodes", {
  validator: {
     $jsonSchema: {
        bsonType: "object",
        required: ["tenantId", "clusterId", "scanId", "name"]
    },
  }
})

db.nodes.createIndex(
	{ scanId: 1, tenantId: 1, clusterId: 1, name: 1 }, 
	{ unique: true },
)

//
// "instructions" collection
//
db.createCollection("instructions", {
  validator: {
     $jsonSchema: {
        bsonType: "object",
        required: ["controlId", "component", "operator", "source"]
    },
  }
})

db.instructions.createIndex( 
	{ controlId: 1 },
	{ unique: true },
)

//
// Insert controls instructions
//
db.instructions.insertMany([
    {"controlId": 4000, "component": 1, "operator": 1, "source": "###apiserver.config###"},  
    {"controlId": 4001, "component": 1, "operator": 2, "source": "###apiserver.config###"},
    
    {"controlId": 4002, "component": 3, "operator": 1, "source": "###controllermanager.config###"},  
    {"controlId": 4003, "component": 3, "operator": 2, "source": "###controllermanager.config###"},
    
    {"controlId": 4004, "component": 2, "operator": 1, "source": "###scheduler.config###"},  
    {"controlId": 4005, "component": 2, "operator": 2, "source": "###scheduler.config###"},
    
    {"controlId": 4006, "component": 4, "operator": 1, "source": "###etcd.config###"},  
    {"controlId": 4007, "component": 4, "operator": 2, "source": "###etcd.config###"},
    
    {"controlId": 4008, "component": 4, "operator": 1, "source": ""},  
    {"controlId": 4009, "component": 4, "operator": 2, "source": ""},
	{"controlId": 4010, "component": 4, "operator": 1, "source": ""},  
    {"controlId": 4011, "component": 4, "operator": 2, "source": ""},
    
    {"controlId": 4012, "component": 7, "operator": 1, "source": "/etc/kubernetes/admin.conf"},
    {"controlId": 4013, "component": 7, "operator": 2, "source": "/etc/kubernetes/admin.conf"},
    
    {"controlId": 4014, "component": 2, "operator": 1, "source": "###scheduler.kubeconfig###"},
    {"controlId": 4015, "component": 2, "operator": 2, "source": "###scheduler.kubeconfig###"},
    
    {"controlId": 4016, "component": 3, "operator": 1, "source": "###controllermanager.kubeconfig###"},
    {"controlId": 4017, "component": 3, "operator": 2, "source": "###controllermanager.kubeconfig###"},

    {"controlId": 4018, "component": 7, "operator": 2, "source": "/etc/kubernetes/pki/"},
	
	{"controlId": 4019, "component": 7, "operator": 1, "source": ""},
	{"controlId": 4020, "component": 7, "operator": 1, "source": ""},
    
    {"controlId": 4021, "component": 1, "operator": 3, "source": "###apiserver.bin### --anonymous-auth"},
    {"controlId": 4022, "component": 1, "operator": 3, "source": "###apiserver.bin### --basic-auth-file"},
    {"controlId": 4023, "component": 1, "operator": 3, "source": "###apiserver.bin### --token-auth-file"},
    {"controlId": 4024, "component": 1, "operator": 3, "source": "###apiserver.bin### --kubelet-https"},
    {"controlId": 4025, "component": 1, "operator": 3, "source": "###apiserver.bin### --kubelet-client-certificate"},
    {"controlId": 4026, "component": 1, "operator": 3, "source": "###apiserver.bin### --kubelet-client-key"},
    {"controlId": 4027, "component": 1, "operator": 3, "source": "###apiserver.bin### --kubelet-certificate-authority"},
    {"controlId": 4028, "component": 1, "operator": 3, "source": "###apiserver.bin### --authorization-mode"},
    {"controlId": 4029, "component": 1, "operator": 3, "source": "###apiserver.bin### --authorization-mode"},
    {"controlId": 4030, "component": 1, "operator": 3, "source": "###apiserver.bin### --authorization-mode"},
    {"controlId": 4031, "component": 1, "operator": 3, "source": "###apiserver.bin### --enable-admission-plugins"},
    {"controlId": 4032, "component": 1, "operator": 3, "source": "###apiserver.bin### --enable-admission-plugins"},
    {"controlId": 4033, "component": 1, "operator": 3, "source": "###apiserver.bin### --enable-admission-plugins"},
    {"controlId": 4034, "component": 1, "operator": 3, "source": "###apiserver.bin### --enable-admission-plugins"},
    {"controlId": 4035, "component": 1, "operator": 3, "source": "###apiserver.bin### --disable-admission-plugins"},
    {"controlId": 4036, "component": 1, "operator": 3, "source": "###apiserver.bin### --disable-admission-plugins"},
    {"controlId": 4037, "component": 1, "operator": 3, "source": "###apiserver.bin### --enable-admission-plugins"},
    {"controlId": 4038, "component": 1, "operator": 3, "source": "###apiserver.bin### --enable-admission-plugins"},
    {"controlId": 4039, "component": 1, "operator": 3, "source": "###apiserver.bin### --insecure-bind-address"},
    {"controlId": 4040, "component": 1, "operator": 3, "source": "###apiserver.bin### --insecure-port"},
    {"controlId": 4041, "component": 1, "operator": 3, "source": "###apiserver.bin### --secure-port"},
    {"controlId": 4042, "component": 1, "operator": 3, "source": "###apiserver.bin### --profiling"},
    {"controlId": 4043, "component": 1, "operator": 3, "source": "###apiserver.bin### --audit-log-path"},
    {"controlId": 4044, "component": 1, "operator": 3, "source": "###apiserver.bin### --audit-log-maxage"},
    {"controlId": 4045, "component": 1, "operator": 3, "source": "###apiserver.bin### --audit-log-maxbackup"},
    {"controlId": 4046, "component": 1, "operator": 3, "source": "###apiserver.bin### --audit-log-maxsize"},
    {"controlId": 4047, "component": 1, "operator": 3, "source": "###apiserver.bin### --request-timeout"},
    {"controlId": 4048, "component": 1, "operator": 3, "source": "###apiserver.bin### --service-account-lookup"},
    {"controlId": 4049, "component": 1, "operator": 3, "source": "###apiserver.bin### --service-account-key-file"},
    
    {"controlId": 4050, "component": 1, "operator": 3, "source": "###apiserver.bin### --etcd-certfile"},
	{"controlId": 4051, "component": 1, "operator": 3, "source": "###apiserver.bin### --etcd-keyfile"},
    {"controlId": 4052, "component": 1, "operator": 3, "source": "###apiserver.bin### --tls-cert-file"},
	{"controlId": 4053, "component": 1, "operator": 3, "source": "###apiserver.bin### --tls-private-key-file"},
    
	{"controlId": 4054, "component": 1, "operator": 3, "source": "###apiserver.bin### --client-ca-file"},
    {"controlId": 4055, "component": 1, "operator": 3, "source": "###apiserver.bin### --etcd-cafile"},
    {"controlId": 4056, "component": 1, "operator": 3, "source": "###apiserver.bin### --encryption-provider-config"},

	{"controlId": 4057, "component": 1, "operator": 3, "source": "###apiserver.bin### --encryption-provider-config"},
    
	{"controlId": 4058, "component": 1, "operator": 3, "source": "###apiserver.bin### --tls-cipher-suites"},
    
    {"controlId": 4059, "component": 3, "operator": 3, "source": "###controllermanager.bin### --terminated-pod-gc-threshold"},
    {"controlId": 4060, "component": 3, "operator": 3, "source": "###controllermanager.bin### --profiling"},
    {"controlId": 4061, "component": 3, "operator": 3, "source": "###controllermanager.bin### --use-service-account-credentials"},
    {"controlId": 4062, "component": 3, "operator": 3, "source": "###controllermanager.bin### --service-account-private-key-file"},
    {"controlId": 4063, "component": 3, "operator": 3, "source": "###controllermanager.bin### --root-ca-file"},
    {"controlId": 4064, "component": 3, "operator": 3, "source": "###controllermanager.bin### --feature-gates"},
    {"controlId": 4065, "component": 3, "operator": 3, "source": "###controllermanager.bin### --bind-address"},
    
    {"controlId": 4066, "component": 2, "operator": 3, "source": "###scheduler.bin### --profiling"},
    {"controlId": 4067, "component": 2, "operator": 3, "source": "###scheduler.bin### --bind-address"},
    
    {"controlId": 4068, "component": 4, "operator": 3, "source": "###etcd.bin### --key-file"},
    {"controlId": 4069, "component": 4, "operator": 3, "source": "###etcd.bin### --cert-file"},
    {"controlId": 4070, "component": 4, "operator": 3, "source": "###etcd.bin### --client-cert-auth"},
    {"controlId": 4071, "component": 4, "operator": 3, "source": "###etcd.bin### --auto-tls"},
    {"controlId": 4072, "component": 4, "operator": 3, "source": "###etcd.bin### --peer-cert-file"},
    {"controlId": 4073, "component": 4, "operator": 3, "source": "###etcd.bin### --peer-key-file"},
    {"controlId": 4074, "component": 4, "operator": 3, "source": "###etcd.bin### --peer-client-cert-auth"},
    {"controlId": 4075, "component": 4, "operator": 3, "source": "###etcd.bin### --peer-auto-tls"},

	{"controlId": 4076, "component": 4, "operator": 3, "source": ""},
	
	{"controlId": 4078, "component": 1, "operator": 3, "source": "###apiserver.bin### --audit-policy-file"},
    
    {"controlId": 4080, "component": 5, "operator": 1, "source": "###kubelet.service###"},
    {"controlId": 4081, "component": 5, "operator": 2, "source": "###kubelet.service###"},
    
    {"controlId": 4082, "component": 6, "operator": 1, "source": "###proxy.kubeconfig###"},
    {"controlId": 4083, "component": 6, "operator": 2, "source": "###proxy.kubeconfig###"},
    
    {"controlId": 4084, "component": 5, "operator": 1, "source": "###kubelet.kubeconfig###"},
    {"controlId": 4085, "component": 5, "operator": 2, "source": "###kubelet.kubeconfig###"},
    
	{"controlId": 4086, "component": 5, "operator": 1, "source": ""},
	{"controlId": 4087, "component": 5, "operator": 2, "source": ""},
	
    {"controlId": 4088, "component": 5, "operator": 1, "source": "###kubelet.config###"},
    {"controlId": 4089, "component": 5, "operator": 2, "source": "###kubelet.config###"},
    
	// Argument operator with fallback to configuration file.
	// The format is: [BIN] [FLAG] [CONFIG FILE] [ATTRIBUTE PATH]
    {"controlId": 4090, "component": 5, "operator": 3, "source": "###kubelet.bin### --anonymous-auth ###kubelet.config### authentication.anonymous.enabled"},
    {"controlId": 4091, "component": 5, "operator": 3, "source": "###kubelet.bin### --authorization-mode ###kubelet.config### authorization.mode"},
    {"controlId": 4092, "component": 5, "operator": 3, "source": "###kubelet.bin### --client-ca-file ###kubelet.config### authentication.x509.clientCAFile"},
    {"controlId": 4093, "component": 5, "operator": 3, "source": "###kubelet.bin### --read-only-port ###kubelet.config### readOnlyPort"},
    {"controlId": 4094, "component": 5, "operator": 3, "source": "###kubelet.bin### --streaming-connection-idle-timeout ###kubelet.config### streamingConnectionIdleTimeout"},
    {"controlId": 4095, "component": 5, "operator": 3, "source": "###kubelet.bin### --protect-kernel-defaults ###kubelet.config### protectKernelDefaults"},
    {"controlId": 4096, "component": 5, "operator": 3, "source": "###kubelet.bin### --make-iptables-util-chains ###kubelet.config### makeIPTablesUtilChains"},
	
    {"controlId": 4097, "component": 5, "operator": 3, "source": "###kubelet.bin### --hostname-override"},
	
    {"controlId": 4098, "component": 5, "operator": 3, "source": "###kubelet.bin### --event-qps ###kubelet.config### eventRecordQPS"},
    {"controlId": 4099, "component": 5, "operator": 3, "source": "###kubelet.bin### --tls-cert-file ###kubelet.config### tlsCertFile"},
    {"controlId": 4100, "component": 5, "operator": 3, "source": "###kubelet.bin### --tls-private-key-file ###kubelet.config### tlsPrivateKeyFile"},
    {"controlId": 4101, "component": 5, "operator": 3, "source": "###kubelet.bin### --rotate-certificates ###kubelet.config### rotateCertificates"},
    {"controlId": 4102, "component": 5, "operator": 3, "source": "###kubelet.bin### RotateKubeletServerCertificate ###kubelet.config### featureGates.RotateKubeletServerCertificate"},
    {"controlId": 4103, "component": 5, "operator": 3, "source": "###kubelet.bin### --tls-cipher-suites ###kubelet.config### tlsCipherSuites"},
])

/////////////
// IAC DB //
///////////

db = db.getSiblingDB('iac')

//
// "scans" collection
//
db.createCollection("scans", {
  validator: {
     $jsonSchema: {
        bsonType: "object",
        required: ["tenantId", "taskId", "endDate"]
    },
  }
})

// db.scans.createIndex( 
	// { endDate: 1, agentsCount: 1, processedNodes: 1, startDate: 1 },
	// { partialFilterExpression: { endDate: null } },
// )

//
// "resources" collection
//
db.createCollection("resources", {
  validator: {
     $jsonSchema: {
        bsonType: "object",
        required: ["tenantId", "name", "kind", "namespace"]
    },
  }
})

// db.resources.createIndex(
	// { tenantId: 1, name: 1, kind: 1, namespace: 1 },
	// { unique: true },
// )