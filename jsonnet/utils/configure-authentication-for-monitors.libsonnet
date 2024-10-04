{
  configureAuthenticationForMonitors(o): {
    local configureAuthentication(o) = o {
      [if o.kind == 'ServiceMonitor' || o.kind == 'PodMonitor' then 'spec']+: {
        scrapeClass: 'tls-client-certificate-auth',
        [if o.kind == 'ServiceMonitor' then 'endpoints' else 'podMetricsEndpoints']: [
          if std.objectHas(e, 'scheme') && e.scheme == 'https' then
            e {
              bearerTokenFile: '',
              tlsConfig+:
                { insecureSkipVerify: false } +
                if !(std.objectHas(o.metadata.labels, 'app.kubernetes.io/name') && o.metadata.labels['app.kubernetes.io/name'] == 'kubelet') then
                  {
                    // For setting serverName the following logic is applied:
                    // 1. Prometheus thanos sidecar, the SA that is created for thanos sidescars has a
                    //    different name than the ServiceMonitor. The name format follows the following convention
                    //    "prometheus-$PROM_INSTANCE-thanos-sidecar", $PROM_INSTANCE is either "k8s" or "user-workload"
                    // 2. ServiceMonitors that adopted CollectionProfiles end with -$COLLECTION_PROFILE,
                    //    thus we strip - and $PROFILE_NAME from o.metadata.name
                    // 3. Default behaviour for the majority of ServiceMonitors. ServiceMonitor has the same
                    //    name as the SA
                    serverName: std.format('%s.%s.svc',
                                           [
                                             if o.metadata.name == 'thanos-sidecar' then
                                               'prometheus-' + o.metadata.labels['app.kubernetes.io/instance'] + '-' + o.metadata.name
                                             else
                                               if std.objectHas(o.metadata.labels, 'monitoring.openshift.io/collection-profile') then
                                                 std.rstripChars(o.metadata.name, '-' + o.metadata.labels['monitoring.openshift.io/collection-profile'])
                                               else
                                                 o.metadata.name,
                                             o.metadata.namespace,
                                           ]),
                  }
                else
                  {},
            }
          else
            e
          for e in super.endpoints
        ],
      },
    },
    [k]: configureAuthentication(o[k])
    for k in std.objectFieldsAll(o)
  },
}
