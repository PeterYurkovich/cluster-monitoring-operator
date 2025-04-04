This document describes the following resources deployed and managed by the Cluster Monitoring Operator (CMO):

* Routes
* Services

Important!

In certain situations, accessing endpoints can degrade the performance and scalability of your cluster, especially if you use endpoints to retrieve, send, or query large amounts of metrics data.

To avoid these issues, follow these recommendations:

* Avoid querying endpoints frequently. Limit queries to a maximum of one every 30 seconds.
* Do not try to retrieve all metrics data via the /federate endpoint. Query it only when you want to retrieve a limited, aggregated data set. For example, retrieving fewer than 1,000 samples for each request helps minimize the risk of performance degradation.

## Routes

### openshift-monitoring/alertmanager-main

Expose the `/api` endpoints of the `alertmanager-main` service via a router.

### openshift-monitoring/prometheus-k8s

Expose the `/api` endpoints of the `prometheus-k8s` service via a router.

### openshift-monitoring/prometheus-k8s-federate

Expose the `/federate` endpoint of the `prometheus-k8s` service via a router.

### openshift-user-workload-monitoring/federate

Expose the `/federate` endpoint of the `prometheus-user-workload` service via a router.

### openshift-monitoring/thanos-querier

Expose the `/api` endpoints of the `thanos-querier` service via a router.

### openshift-user-workload-monitoring/thanos-ruler

Expose the `/api` endpoints of the `thanos-ruler` service via a router.

## Services

### openshift-monitoring/prometheus-operator-admission-webhook

Expose the admission webhook service which validates `PrometheusRules` and `AlertmanagerConfig` custom resources on port 8443.

### openshift-user-workload-monitoring/alertmanager-user-workload

Expose the user-defined Alertmanager web server within the cluster on the following ports:
* Port 9095 provides access to the Alertmanager endpoints. Granting access requires binding a user to the `monitoring-alertmanager-api-reader` role (for read-only operations) or `monitoring-alertmanager-api-writer` role in the `openshift-user-workload-monitoring` project.
* Port 9092 provides access to the Alertmanager endpoints restricted to a given project. Granting access requires binding a user to the `monitoring-rules-edit` cluster role or `monitoring-edit` cluster role in the project.
* Port 9097 provides access to the `/metrics` endpoint only. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/alertmanager-main

Expose the Alertmanager web server within the cluster on the following ports:
* Port 9094 provides access to all the Alertmanager endpoints. Granting access requires binding a user to the `monitoring-alertmanager-view` role (for read-only operations) or `monitoring-alertmanager-edit` role in the `openshift-monitoring` project.
```
# monitoring-alertmanager-view grants read permissions.
$ oc project openshift-monitoring
$ oc create serviceaccount am-ro-client
$ oc adm policy add-role-to-user monitoring-alertmanager-view \
  --role-namespace=openshift-monitoring --rolebinding-name=am-ro-client \
  --serviceaccount=am-ro-client
$ TOKEN=$(oc create token am-ro-client)
$ ROUTE=$(oc get route alertmanager-main -n openshift-monitoring -ojsonpath={.spec.host})
$ curl -H "Authorization: Bearer $TOKEN" -k --fail-with-body "https://$ROUTE/api/v2/alerts?filter=alertname=Watchdog"
```
```
# monitoring-alertmanager-edit grants edit permissions.
$ oc project openshift-monitoring
$ oc create serviceaccount am-rw-client
$ oc adm policy add-role-to-user monitoring-alertmanager-edit \
  --role-namespace=openshift-monitoring --rolebinding-name=am-rw-client \
  --serviceaccount=am-rw-client
$ TOKEN=$(oc create token am-rw-client)
$ ROUTE=$(oc get route alertmanager-main -n openshift-monitoring -ojsonpath={.spec.host})
$ curl -X POST -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{
    "matchers": [
      {
        "name": "alertname",
        "value": "MyTestAlert",
        "isRegex": false
      }
    ],
    "startsAt": "2044-01-01T00:00:00Z",
    "endsAt": "2044-01-01T00:00:01Z",
    "createdBy": "am-rw-client",
    "comment": "Silence test"
  }' \
  -k --fail-with-body "https://$ROUTE/api/v2/silences"
```

* Port 9092 provides access to the Alertmanager endpoints restricted to a given project. Granting access requires binding a user to the `monitoring-rules-edit` cluster role or `monitoring-edit` cluster role in the project.
* Port 9097 provides access to the `/metrics` endpoint only. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/kube-state-metrics

Expose kube-state-metrics `/metrics` endpoints within the cluster on the following ports:
* Port 8443 provides access to the Kubernetes resource metrics. This port is for internal use, and no other usage is guaranteed.
* Port 9443 provides access to the internal kube-state-metrics metrics. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/metrics-server

Expose the metrics-server web server on port 443. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/monitoring-plugin

Expose the monitoring plugin service on port 9443. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/node-exporter

Expose the `/metrics` endpoint on port 9100. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/openshift-state-metrics

Expose openshift-state-metrics `/metrics` endpoints within the cluster on the following ports:
* Port 8443 provides access to the OpenShift resource metrics. This port is for internal use, and no other usage is guaranteed.
* Port 9443 provides access to the internal `openshift-state-metrics` metrics. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/prometheus-k8s

Expose the Prometheus web server within the cluster on the following ports:
* Port 9091 provides access to all the Prometheus endpoints. Granting access requires binding a user to the `cluster-monitoring-view` cluster role.
* Port 9092 provides access to the `/metrics` and `/federate` endpoints only. This port is for internal use, and no other usage is guaranteed.

### openshift-user-workload-monitoring/prometheus-operator

Expose the `/metrics` endpoint on port 8443. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/prometheus-operator

Expose the `/metrics` endpoint on port 8443. This port is for internal use, and no other usage is guaranteed.

### openshift-user-workload-monitoring/prometheus-user-workload

Expose the Prometheus web server within the cluster on the following ports:
* Port 9091 provides access to the `/metrics` endpoint only. This port is for internal use, and no other usage is guaranteed.
* Port 9092 provides access to the `/federate` endpoint only. Granting access requires binding a user to the `cluster-monitoring-view` cluster role.

This also exposes the `/metrics` endpoint of the Thanos sidecar web server on port 10902. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/telemeter-client

Expose the `/metrics` endpoint on port 8443. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/thanos-querier

Expose the Thanos Querier web server within the cluster on the following ports:
* Port 9091 provides access to all the Thanos Querier endpoints. Granting access requires binding a user to the `cluster-monitoring-view` cluster role.
* Port 9092 provides access to the `/api/v1/query`, `/api/v1/query_range/`, `/api/v1/labels`, `/api/v1/label/*/values`, and `/api/v1/series` endpoints restricted to a given project. Granting access requires binding a user to the `view` cluster role in the project.
* Port 9093 provides access to the `/api/v1/alerts`, and `/api/v1/rules` endpoints restricted to a given project. Granting access requires binding a user to the `monitoring-rules-edit` cluster role or `monitoring-edit` cluster role or `monitoring-rules-view` cluster role in the project.
* Port 9094 provides access to the `/metrics` endpoint only. This port is for internal use, and no other usage is guaranteed.

### openshift-user-workload-monitoring/thanos-ruler

Expose the Thanos Ruler web server within the cluster on the following ports:
* Port 9091 provides access to all Thanos Ruler endpoints. Granting access requires binding a user to the `cluster-monitoring-view` cluster role.
* Port 9092 provides access to the `/metrics` endpoint only. This port is for internal use, and no other usage is guaranteed.

This also exposes the gRPC endpoints on port 10901. This port is for internal use, and no other usage is guaranteed.

### openshift-monitoring/cluster-monitoring-operator

Expose the `/metrics` and `/validate-webhook` endpoints on port 8443. This port is for internal use, and no other usage is guaranteed.

