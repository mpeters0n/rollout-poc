## nginx configuration
## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/nginx-configuration/index.md
##

## Overrides for generated resource names
# See templates/_helpers.tpl
# nameOverride:
# fullnameOverride:

# -- Override the deployment namespace; defaults to .Release.Namespace
namespaceOverride: ${namespace}
## Labels to apply to all resources
##
commonLabels: {}
# scmhash: abc123
# myLabel: aakkmd

controller:
  name: controller
  enableAnnotationValidations: false
  image:
    ## Keep false as default for now!
    chroot: false
    registry: registry.k8s.io
    image: ingress-nginx/controller
    ## for backwards compatibility consider setting the full image url via the repository value below
    ## use *either* current default registry/image or repository format or installing chart by providing the values.yaml will fail
    ## repository:
    tag: "v1.9.6"
    digest: sha256:1405cc613bd95b2c6edd8b2a152510ae91c7e62aea4698500d23b2145960ab9c
    digestChroot: sha256:7eb46ff733429e0e46892903c7394aff149ac6d284d92b3946f3baf7ff26a096
    pullPolicy: IfNotPresent
    runAsNonRoot: true
    # www-data -> uid 101
    runAsUser: 101
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    readOnlyRootFilesystem: false
  # -- Use an existing PSP instead of creating one
  existingPsp: ""
  # -- Configures the controller container name
  containerName: controller
  # -- Configures the ports that the nginx-controller listens on
  containerPort:
    http: 80
    https: 443
  # -- Will add custom configuration options to Nginx https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/
  config: {}
  # -- Annotations to be added to the controller config configuration configmap.
  configAnnotations: {}
  # -- Will add custom headers before sending traffic to backends according to https://github.com/kubernetes/ingress-nginx/tree/main/docs/examples/customization/custom-headers
  proxySetHeaders: {}
  # -- Will add custom headers before sending response traffic to the client according to: https://kubernetes.github.io/ingress-nginx/user-guide/nginx-configuration/configmap/#add-headers
  addHeaders: {}
  # -- Optionally customize the pod dnsConfig.
  dnsConfig: {}
  # -- Optionally customize the pod hostAliases.
  hostAliases: []
  # - ip: 127.0.0.1
  #   hostnames:
  #   - foo.local
  #   - bar.local
  # - ip: 10.1.2.3
  #   hostnames:
  #   - foo.remote
  #   - bar.remote
  # -- Optionally customize the pod hostname.
  hostname: {}
  # -- Optionally change this to ClusterFirstWithHostNet in case you have 'hostNetwork: true'.
  # By default, while using host network, name resolution uses the host's DNS. If you wish nginx-controller
  # to keep resolving names inside the k8s network, use ClusterFirstWithHostNet.
  dnsPolicy: ClusterFirst
  # -- Bare-metal considerations via the host network https://kubernetes.github.io/ingress-nginx/deploy/baremetal/#via-the-host-network
  # Ingress status was blank because there is no Service exposing the Ingress-Nginx Controller in a configuration using the host network, the default --publish-service flag used in standard cloud setups does not apply
  reportNodeInternalIp: false
  # -- Process Ingress objects without ingressClass annotation/ingressClassName field
  # Overrides value for --watch-ingress-without-class flag of the controller binary
  # Defaults to false
  watchIngressWithoutClass: false
  # -- Process IngressClass per name (additionally as per spec.controller).
  ingressClassByName: false
  # -- This configuration enables Topology Aware Routing feature, used together with service annotation service.kubernetes.io/topology-mode="auto"
  # Defaults to false
  enableTopologyAwareRouting: false
  # -- This configuration defines if Ingress Controller should allow users to set
  # their own *-snippet annotations, otherwise this is forbidden / dropped
  # when users add those annotations.
  # Global snippets in ConfigMap are still respected
  allowSnippetAnnotations: false
  # -- Required for use with CNI based kubernetes installations (such as ones set up by kubeadm),
  # since CNI and hostport don't mix yet. Can be deprecated once https://github.com/kubernetes/kubernetes/issues/23920
  # is merged
  hostNetwork: false
  ## Use host ports 80 and 443
  ## Disabled by default
  hostPort:
    # -- Enable 'hostPort' or not
    enabled: false
    ports:
      # -- 'hostPort' http port
      http: 80
      # -- 'hostPort' https port
      https: 443
  # NetworkPolicy for controller component.
  networkPolicy:
    # -- Enable 'networkPolicy' or not
    enabled: false
  # -- Election ID to use for status update, by default it uses the controller name combined with a suffix of 'leader'
  electionID: ""
  ## This section refers to the creation of the IngressClass resource
  ## IngressClass resources are supported since k8s >= 1.18 and required since k8s >= 1.19
  ingressClassResource:
    # -- Name of the ingressClass
    name: nginx
    # -- Is this ingressClass enabled or not
    enabled: true
    # -- Is this the default ingressClass for the cluster
    default: false
    # -- Controller-value of the controller that is processing this ingressClass
    controllerValue: "k8s.io/ingress-nginx"
    # -- Parameters is a link to a custom resource containing additional
    # configuration for the controller. This is optional if the controller
    # does not require extra parameters.
    parameters: {}
  # -- For backwards compatibility with ingress.class annotation, use ingressClass.
  # Algorithm is as follows, first ingressClassName is considered, if not present, controller looks for ingress.class annotation
  ingressClass: nginx
  # -- Labels to add to the pod container metadata
  podLabels: {}
  #  key: value

  # -- Security context for controller pods
  podSecurityContext: {}
  # -- sysctls for controller pods
  ## Ref: https://kubernetes.io/docs/tasks/administer-cluster/sysctl-cluster/
  sysctls: {}
  # sysctls:
  #   "net.core.somaxconn": "8192"
  # -- Security context for controller containers
  containerSecurityContext: {}
  # -- Allows customization of the source of the IP address or FQDN to report
  # in the ingress status field. By default, it reads the information provided
  # by the service. If disable, the status field reports the IP address of the
  # node or nodes where an ingress controller pod is running.
  publishService:
    # -- Enable 'publishService' or not
    enabled: true
    # -- Allows overriding of the publish service to bind to
    # Must be <namespace>/<service_name>
    pathOverride: ""
  # Limit the scope of the controller to a specific namespace
  scope:
    # -- Enable 'scope' or not
    enabled: false
    # -- Namespace to limit the controller to; defaults to $(POD_NAMESPACE)
    namespace: ""
    # -- When scope.enabled == false, instead of watching all namespaces, we watching namespaces whose labels
    # only match with namespaceSelector. Format like foo=bar. Defaults to empty, means watching all namespaces.
    namespaceSelector: ""
  # -- Allows customization of the configmap / nginx-configmap namespace; defaults to $(POD_NAMESPACE)
  configMapNamespace: ""
  tcp:
    # -- Allows customization of the tcp-services-configmap; defaults to $(POD_NAMESPACE)
    configMapNamespace: ""
    # -- Annotations to be added to the tcp config configmap
    annotations: {}
  udp:
    # -- Allows customization of the udp-services-configmap; defaults to $(POD_NAMESPACE)
    configMapNamespace: ""
    # -- Annotations to be added to the udp config configmap
    annotations: {}
  # -- Maxmind license key to download GeoLite2 Databases.
  ## https://blog.maxmind.com/2019/12/18/significant-changes-to-accessing-and-using-geolite2-databases
  maxmindLicenseKey: ""
  # -- Additional command line arguments to pass to Ingress-Nginx Controller
  # E.g. to specify the default SSL certificate you can use
  extraArgs: {}
  ## extraArgs:
  ##   default-ssl-certificate: "<namespace>/<secret_name>"
  ##   time-buckets: "0.005,0.01,0.025,0.05,0.1,0.25,0.5,1,2.5,5,10"
  ##   length-buckets: "10,20,30,40,50,60,70,80,90,100"
  ##   size-buckets: "10,100,1000,10000,100000,1e+06,1e+07"

  # -- Additional environment variables to set
  extraEnvs: []
  # extraEnvs:
  #   - name: FOO
  #     valueFrom:
  #       secretKeyRef:
  #         key: FOO
  #         name: secret-resource

  # -- Use a `DaemonSet` or `Deployment`
  kind: Deployment
  # -- Annotations to be added to the controller Deployment or DaemonSet
  ##
  annotations: {}
  #  keel.sh/pollSchedule: "@every 60m"

  # -- Labels to be added to the controller Deployment or DaemonSet and other resources that do not have option to specify labels
  ##
  labels: {}
  #  keel.sh/policy: patch
  #  keel.sh/trigger: poll

  # -- The update strategy to apply to the Deployment or DaemonSet
  ##
  updateStrategy: {}
  #  rollingUpdate:
  #    maxUnavailable: 1
  #  type: RollingUpdate

  # -- `minReadySeconds` to avoid killing pods before we are ready
  ##
  minReadySeconds: 0
  # -- Node tolerations for server scheduling to nodes with taints
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  ##
  tolerations: []
  #  - key: "key"
  #    operator: "Equal|Exists"
  #    value: "value"
  #    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

  # -- Affinity and anti-affinity rules for server scheduling to nodes
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/#affinity-and-anti-affinity
  ##
  affinity: {}
  # # An example of preferred pod anti-affinity, weight is in the range 1-100
  # podAntiAffinity:
  #   preferredDuringSchedulingIgnoredDuringExecution:
  #   - weight: 100
  #     podAffinityTerm:
  #       labelSelector:
  #         matchExpressions:
  #         - key: app.kubernetes.io/name
  #           operator: In
  #           values:
  #           - ingress-nginx
  #         - key: app.kubernetes.io/instance
  #           operator: In
  #           values:
  #           - ingress-nginx
  #         - key: app.kubernetes.io/component
  #           operator: In
  #           values:
  #           - controller
  #       topologyKey: kubernetes.io/hostname

  # # An example of required pod anti-affinity
  # podAntiAffinity:
  #   requiredDuringSchedulingIgnoredDuringExecution:
  #   - labelSelector:
  #       matchExpressions:
  #       - key: app.kubernetes.io/name
  #         operator: In
  #         values:
  #         - ingress-nginx
  #       - key: app.kubernetes.io/instance
  #         operator: In
  #         values:
  #         - ingress-nginx
  #       - key: app.kubernetes.io/component
  #         operator: In
  #         values:
  #         - controller
  #     topologyKey: "kubernetes.io/hostname"

  # -- Topology spread constraints rely on node labels to identify the topology domain(s) that each Node is in.
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-topology-spread-constraints/
  ##
  topologySpreadConstraints: []
  # - labelSelector:
  #     matchLabels:
  #       app.kubernetes.io/name: '{{ include "ingress-nginx.name" . }}'
  #       app.kubernetes.io/instance: '{{ .Release.Name }}'
  #       app.kubernetes.io/component: controller
  #   topologyKey: topology.kubernetes.io/zone
  #   maxSkew: 1
  #   whenUnsatisfiable: ScheduleAnyway
  # - labelSelector:
  #     matchLabels:
  #       app.kubernetes.io/name: '{{ include "ingress-nginx.name" . }}'
  #       app.kubernetes.io/instance: '{{ .Release.Name }}'
  #       app.kubernetes.io/component: controller
  #   topologyKey: kubernetes.io/hostname
  #   maxSkew: 1
  #   whenUnsatisfiable: ScheduleAnyway

  # -- `terminationGracePeriodSeconds` to avoid killing pods before we are ready
  ## wait up to five minutes for the drain of connections
  ##
  terminationGracePeriodSeconds: 300
  # -- Node labels for controller pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector:
    kubernetes.io/os: linux
  ## Liveness and readiness probe values
  ## Ref: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#container-probes
  ##
  ## startupProbe:
  ##   httpGet:
  ##     # should match container.healthCheckPath
  ##     path: "/healthz"
  ##     port: 10254
  ##     scheme: HTTP
  ##   initialDelaySeconds: 5
  ##   periodSeconds: 5
  ##   timeoutSeconds: 2
  ##   successThreshold: 1
  ##   failureThreshold: 5
  livenessProbe:
    httpGet:
      # should match container.healthCheckPath
      path: "/healthz"
      port: 10254
      scheme: HTTP
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 5
  readinessProbe:
    httpGet:
      # should match container.healthCheckPath
      path: "/healthz"
      port: 10254
      scheme: HTTP
    initialDelaySeconds: 10
    periodSeconds: 10
    timeoutSeconds: 1
    successThreshold: 1
    failureThreshold: 3
  # -- Path of the health check endpoint. All requests received on the port defined by
  # the healthz-port parameter are forwarded internally to this path.
  healthCheckPath: "/healthz"
  # -- Address to bind the health check endpoint.
  # It is better to set this option to the internal node address
  # if the Ingress-Nginx Controller is running in the `hostNetwork: true` mode.
  healthCheckHost: ""
  # -- Annotations to be added to controller pods
  ##
  podAnnotations: {}
  replicaCount: 1
  # -- Minimum available pods set in PodDisruptionBudget.
  # Define either 'minAvailable' or 'maxUnavailable', never both.
  minAvailable: 1
  # -- Maximum unavailable pods set in PodDisruptionBudget. If set, 'minAvailable' is ignored.
  # maxUnavailable: 1

  ## Define requests resources to avoid probe issues due to CPU utilization in busy nodes
  ## ref: https://github.com/kubernetes/ingress-nginx/issues/4735#issuecomment-551204903
  ## Ideally, there should be no limits.
  ## https://engineering.indeedblog.com/blog/2019/12/cpu-throttling-regression-fix/
  resources:
    ##  limits:
    ##    cpu: 100m
    ##    memory: 90Mi
    requests:
      cpu: 100m
      memory: 90Mi
  # Mutually exclusive with keda autoscaling
  autoscaling:
    enabled: false
    annotations: {}
    minReplicas: 1
    maxReplicas: 11
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
    behavior: {}
    # scaleDown:
    #   stabilizationWindowSeconds: 300
    #   policies:
    #   - type: Pods
    #     value: 1
    #     periodSeconds: 180
    # scaleUp:
    #   stabilizationWindowSeconds: 300
    #   policies:
    #   - type: Pods
    #     value: 2
    #     periodSeconds: 60
  autoscalingTemplate: []
  # Custom or additional autoscaling metrics
  # ref: https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/#support-for-custom-metrics
  # - type: Pods
  #   pods:
  #     metric:
  #       name: nginx_ingress_controller_nginx_process_requests_total
  #     target:
  #       type: AverageValue
  #       averageValue: 10000m

  # Mutually exclusive with hpa autoscaling
  keda:
    apiVersion: "keda.sh/v1alpha1"
    ## apiVersion changes with keda 1.x vs 2.x
    ## 2.x = keda.sh/v1alpha1
    ## 1.x = keda.k8s.io/v1alpha1
    enabled: false
    minReplicas: 1
    maxReplicas: 11
    pollingInterval: 30
    cooldownPeriod: 300
    # fallback:
    #   failureThreshold: 3
    #   replicas: 11
    restoreToOriginalReplicaCount: false
    scaledObject:
      annotations: {}
      # Custom annotations for ScaledObject resource
      #  annotations:
      # key: value
    triggers: []
    # - type: prometheus
    #   metadata:
    #     serverAddress: http://<prometheus-host>:9090
    #     metricName: http_requests_total
    #     threshold: '100'
    #     query: sum(rate(http_requests_total{deployment="my-deployment"}[2m]))

    behavior: {}
    # scaleDown:
    #   stabilizationWindowSeconds: 300
    #   policies:
    #   - type: Pods
    #     value: 1
    #     periodSeconds: 180
    # scaleUp:
    #   stabilizationWindowSeconds: 300
    #   policies:
    #   - type: Pods
    #     value: 2
    #     periodSeconds: 60
  # -- Enable mimalloc as a drop-in replacement for malloc.
  ## ref: https://github.com/microsoft/mimalloc
  ##
  enableMimalloc: true
  ## Override NGINX template
  customTemplate:
    configMapName: ""
    configMapKey: ""
  service:
    # -- Enable controller services or not. This does not influence the creation of either the admission webhook or the metrics service.
    enabled: true
    external:
      # -- Enable the external controller service or not. Useful for internal-only deployments.
      enabled: true
    # -- Annotations to be added to the external controller service. See `controller.service.internal.annotations` for annotations to be added to the internal controller service.
    annotations: {}
    # -- Labels to be added to both controller services.
    labels: {}
    # -- Type of the external controller service.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
    type: LoadBalancer
    # -- Pre-defined cluster internal IP address of the external controller service. Take care of collisions with existing services.
    # This value is immutable. Set once, it can not be changed without deleting and re-creating the service.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#choosing-your-own-ip-address
    clusterIP: ""
    # -- List of node IP addresses at which the external controller service is available.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#external-ips
    externalIPs: []
    # -- Deprecated: Pre-defined IP address of the external controller service. Used by cloud providers to connect the resulting load balancer service to a pre-existing static IP.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
    loadBalancerIP: ""
    # -- Restrict access to the external controller service. Values must be CIDRs. Allows any source address by default.
    loadBalancerSourceRanges: []
    # -- Load balancer class of the external controller service. Used by cloud providers to select a load balancer implementation other than the cloud provider default.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-class
    loadBalancerClass: ""
    # -- Enable node port allocation for the external controller service or not. Applies to type `LoadBalancer` only.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-nodeport-allocation
    # allocateLoadBalancerNodePorts: true

    # -- External traffic policy of the external controller service. Set to "Local" to preserve source IP on providers supporting it.
    # Ref: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    externalTrafficPolicy: ""
    # -- Session affinity of the external controller service. Must be either "None" or "ClientIP" if set. Defaults to "None".
    # Ref: https://kubernetes.io/docs/reference/networking/virtual-ips/#session-affinity
    sessionAffinity: ""
    # -- Specifies the health check node port (numeric port number) for the external controller service.
    # If not specified, the service controller allocates a port from your cluster's node port range.
    # Ref: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
    # healthCheckNodePort: 0

    # -- Represents the dual-stack capabilities of the external controller service. Possible values are SingleStack, PreferDualStack or RequireDualStack.
    # Fields `ipFamilies` and `clusterIP` depend on the value of this field.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
    ipFamilyPolicy: SingleStack
    # -- List of IP families (e.g. IPv4, IPv6) assigned to the external controller service. This field is usually assigned automatically based on cluster configuration and the `ipFamilyPolicy` field.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
    ipFamilies:
      - IPv4
    # -- Enable the HTTP listener on both controller services or not.
    enableHttp: true
    # -- Enable the HTTPS listener on both controller services or not.
    enableHttps: true
    ports:
      # -- Port the external HTTP listener is published with.
      http: 80
      # -- Port the external HTTPS listener is published with.
      https: 443
    targetPorts:
      # -- Port of the ingress controller the external HTTP listener is mapped to.
      http: http
      # -- Port of the ingress controller the external HTTPS listener is mapped to.
      https: https
    # -- Declare the app protocol of the external HTTP and HTTPS listeners or not. Supersedes provider-specific annotations for declaring the backend protocol.
    # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#application-protocol
    appProtocol: true
    nodePorts:
      # -- Node port allocated for the external HTTP listener. If left empty, the service controller allocates one from the configured node port range.
      http: ""
      # -- Node port allocated for the external HTTPS listener. If left empty, the service controller allocates one from the configured node port range.
      https: ""
      # -- Node port mapping for external TCP listeners. If left empty, the service controller allocates them from the configured node port range.
      # Example:
      # tcp:
      #   8080: 30080
      tcp: {}
      # -- Node port mapping for external UDP listeners. If left empty, the service controller allocates them from the configured node port range.
      # Example:
      # udp:
      #   53: 30053
      udp: {}
    internal:
      # -- Enable the internal controller service or not. Remember to configure `controller.service.internal.annotations` when enabling this.
      enabled: false
      # -- Annotations to be added to the internal controller service. Mandatory for the internal controller service to be created. Varies with the cloud service.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#internal-load-balancer
      annotations: {}
      # -- Type of the internal controller service.
      # Defaults to the value of `controller.service.type`.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
      type: ""
      # -- Pre-defined cluster internal IP address of the internal controller service. Take care of collisions with existing services.
      # This value is immutable. Set once, it can not be changed without deleting and re-creating the service.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#choosing-your-own-ip-address
      clusterIP: ""
      # -- List of node IP addresses at which the internal controller service is available.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#external-ips
      externalIPs: []
      # -- Deprecated: Pre-defined IP address of the internal controller service. Used by cloud providers to connect the resulting load balancer service to a pre-existing static IP.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#loadbalancer
      loadBalancerIP: ""
      # -- Restrict access to the internal controller service. Values must be CIDRs. Allows any source address by default.
      loadBalancerSourceRanges: []
      # -- Load balancer class of the internal controller service. Used by cloud providers to select a load balancer implementation other than the cloud provider default.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-class
      loadBalancerClass: ""
      # -- Enable node port allocation for the internal controller service or not. Applies to type `LoadBalancer` only.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#load-balancer-nodeport-allocation
      # allocateLoadBalancerNodePorts: true

      # -- External traffic policy of the internal controller service. Set to "Local" to preserve source IP on providers supporting it.
      # Ref: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
      externalTrafficPolicy: ""
      # -- Session affinity of the internal controller service. Must be either "None" or "ClientIP" if set. Defaults to "None".
      # Ref: https://kubernetes.io/docs/reference/networking/virtual-ips/#session-affinity
      sessionAffinity: ""
      # -- Specifies the health check node port (numeric port number) for the internal controller service.
      # If not specified, the service controller allocates a port from your cluster's node port range.
      # Ref: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/#preserving-the-client-source-ip
      # healthCheckNodePort: 0

      # -- Represents the dual-stack capabilities of the internal controller service. Possible values are SingleStack, PreferDualStack or RequireDualStack.
      # Fields `ipFamilies` and `clusterIP` depend on the value of this field.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
      ipFamilyPolicy: SingleStack
      # -- List of IP families (e.g. IPv4, IPv6) assigned to the internal controller service. This field is usually assigned automatically based on cluster configuration and the `ipFamilyPolicy` field.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/dual-stack/#services
      ipFamilies:
        - IPv4
      ports: {}
      # -- Port the internal HTTP listener is published with.
      # Defaults to the value of `controller.service.ports.http`.
      # http: 80
      # -- Port the internal HTTPS listener is published with.
      # Defaults to the value of `controller.service.ports.https`.
      # https: 443

      targetPorts: {}
      # -- Port of the ingress controller the internal HTTP listener is mapped to.
      # Defaults to the value of `controller.service.targetPorts.http`.
      # http: http
      # -- Port of the ingress controller the internal HTTPS listener is mapped to.
      # Defaults to the value of `controller.service.targetPorts.https`.
      # https: https

      # -- Declare the app protocol of the internal HTTP and HTTPS listeners or not. Supersedes provider-specific annotations for declaring the backend protocol.
      # Ref: https://kubernetes.io/docs/concepts/services-networking/service/#application-protocol
      appProtocol: true
      nodePorts:
        # -- Node port allocated for the internal HTTP listener. If left empty, the service controller allocates one from the configured node port range.
        http: ""
        # -- Node port allocated for the internal HTTPS listener. If left empty, the service controller allocates one from the configured node port range.
        https: ""
        # -- Node port mapping for internal TCP listeners. If left empty, the service controller allocates them from the configured node port range.
        # Example:
        # tcp:
        #   8080: 30080
        tcp: {}
        # -- Node port mapping for internal UDP listeners. If left empty, the service controller allocates them from the configured node port range.
        # Example:
        # udp:
        #   53: 30053
        udp: {}
  # shareProcessNamespace enables process namespace sharing within the pod.
  # This can be used for example to signal log rotation using `kill -USR1` from a sidecar.
  shareProcessNamespace: false
  # -- Additional containers to be added to the controller pod.
  # See https://github.com/lemonldap-ng-controller/lemonldap-ng-controller as example.
  extraContainers: []
  #  - name: my-sidecar
  #    image: nginx:latest
  #  - name: lemonldap-ng-controller
  #    image: lemonldapng/lemonldap-ng-controller:0.2.0
  #    args:
  #      - /lemonldap-ng-controller
  #      - --alsologtostderr
  #      - --configmap=$(POD_NAMESPACE)/lemonldap-ng-configuration
  #    env:
  #      - name: POD_NAME
  #        valueFrom:
  #          fieldRef:
  #            fieldPath: metadata.name
  #      - name: POD_NAMESPACE
  #        valueFrom:
  #          fieldRef:
  #            fieldPath: metadata.namespace
  #    volumeMounts:
  #    - name: copy-portal-skins
  #      mountPath: /srv/var/lib/lemonldap-ng/portal/skins

  # -- Additional volumeMounts to the controller main container.
  extraVolumeMounts: []
  #  - name: copy-portal-skins
  #   mountPath: /var/lib/lemonldap-ng/portal/skins

  # -- Additional volumes to the controller pod.
  extraVolumes: []
  #  - name: copy-portal-skins
  #    emptyDir: {}

  # -- Containers, which are run before the app containers are started.
  extraInitContainers: []
  # - name: init-myservice
  #   image: busybox
  #   command: ['sh', '-c', 'until nslookup myservice; do echo waiting for myservice; sleep 2; done;']

  # -- Modules, which are mounted into the core nginx image. See values.yaml for a sample to add opentelemetry module
  extraModules: []
  # - name: mytestmodule
  #   image:
  #     registry: registry.k8s.io
  #     image: ingress-nginx/mytestmodule
  #     ## for backwards compatibility consider setting the full image url via the repository value below
  #     ## use *either* current default registry/image or repository format or installing chart by providing the values.yaml will fail
  #     ## repository:
  #     tag: "v1.0.0"
  #     digest: ""
  #     distroless: false
  #   containerSecurityContext:
  #     runAsNonRoot: true
  #     runAsUser: <user-id>
  #     allowPrivilegeEscalation: false
  #     seccompProfile:
  #       type: RuntimeDefault
  #     capabilities:
  #       drop:
  #       - ALL
  #     readOnlyRootFilesystem: true
  #   resources: {}
  #
  # The image must contain a `/usr/local/bin/init_module.sh` executable, which
  # will be executed as initContainers, to move its config files within the
  # mounted volume.

  opentelemetry:
    enabled: false
    name: opentelemetry
    image:
      registry: registry.k8s.io
      image: ingress-nginx/opentelemetry
      ## for backwards compatibility consider setting the full image url via the repository value below
      ## use *either* current default registry/image or repository format or installing chart by providing the values.yaml will fail
      ## repository:
      tag: "v20230721-3e2062ee5"
      digest: sha256:13bee3f5223883d3ca62fee7309ad02d22ec00ff0d7033e3e9aca7a9f60fd472
      distroless: true
    containerSecurityContext:
      runAsNonRoot: true
      # -- The image's default user, inherited from its base image `cgr.dev/chainguard/static`.
      runAsUser: 65532
      allowPrivilegeEscalation: false
      seccompProfile:
        type: RuntimeDefault
      capabilities:
        drop:
          - ALL
      readOnlyRootFilesystem: true
    resources: {}
  admissionWebhooks:
    name: admission
    annotations: {}
    # ignore-check.kube-linter.io/no-read-only-rootfs: "This deployment needs write access to root filesystem".

    ## Additional annotations to the admission webhooks.
    ## These annotations will be added to the ValidatingWebhookConfiguration and
    ## the Jobs Spec of the admission webhooks.
    enabled: true
    # -- Additional environment variables to set
    extraEnvs: []
    # extraEnvs:
    #   - name: FOO
    #     valueFrom:
    #       secretKeyRef:
    #         key: FOO
    #         name: secret-resource
    # -- Admission Webhook failure policy to use
    failurePolicy: Ignore
    # timeoutSeconds: 10
    port: 8443
    certificate: "/usr/local/certificates/cert"
    key: "/usr/local/certificates/key"
    namespaceSelector: {}
    objectSelector: {}
    # -- Labels to be added to admission webhooks
    labels: {}
    # -- Use an existing PSP instead of creating one
    existingPsp: ""
    service:
      annotations: {}
      # clusterIP: ""
      externalIPs: []
      # loadBalancerIP: ""
      loadBalancerSourceRanges: []
      servicePort: 443
      type: ClusterIP
    createSecretJob:
      name: create
      # -- Security context for secret creation containers
      securityContext:
        runAsNonRoot: true
        runAsUser: 65532
        allowPrivilegeEscalation: false
        seccompProfile:
          type: RuntimeDefault
        capabilities:
          drop:
            - ALL
        readOnlyRootFilesystem: true
      resources: {}
      # limits:
      #   cpu: 10m
      #   memory: 20Mi
      # requests:
      #   cpu: 10m
      #   memory: 20Mi
    patchWebhookJob:
      name: patch
      # -- Security context for webhook patch containers
      securityContext:
        runAsNonRoot: true
        runAsUser: 65532
        allowPrivilegeEscalation: false
        seccompProfile:
          type: RuntimeDefault
        capabilities:
          drop:
            - ALL
        readOnlyRootFilesystem: true
      resources: {}
    patch:
      enabled: true
      image:
        registry: registry.k8s.io
        image: ingress-nginx/kube-webhook-certgen
        ## for backwards compatibility consider setting the full image url via the repository value below
        ## use *either* current default registry/image or repository format or installing chart by providing the values.yaml will fail
        ## repository:
        tag: v20231226-1a7112e06
        digest: sha256:25d6a5f11211cc5c3f9f2bf552b585374af287b4debf693cacbe2da47daa5084
        pullPolicy: IfNotPresent
      # -- Provide a priority class name to the webhook patching job
      ##
      priorityClassName: ""
      podAnnotations: {}
      # NetworkPolicy for webhook patch
      networkPolicy:
        # -- Enable 'networkPolicy' or not
        enabled: false
      nodeSelector:
        kubernetes.io/os: linux
      tolerations: []
      # -- Labels to be added to patch job resources
      labels: {}
      # -- Security context for secret creation & webhook patch pods
      securityContext: {}
    # Use certmanager to generate webhook certs
    certManager:
      enabled: false
      # self-signed root certificate
      rootCert:
        # default to be 5y
        duration: ""
      admissionCert:
        # default to be 1y
        duration: ""
        # issuerRef:
        #   name: "issuer"
        #   kind: "ClusterIssuer"
  metrics:
    port: 10254
    portName: metrics
    # if this port is changed, change healthz-port: in extraArgs: accordingly
    enabled: true
    service:
      annotations: {}
      # prometheus.io/scrape: "true"
      # prometheus.io/port: "10254"
      # -- Labels to be added to the metrics service resource
      labels: {}
      # clusterIP: ""

      # -- List of IP addresses at which the stats-exporter service is available
      ## Ref: https://kubernetes.io/docs/concepts/services-networking/service/#external-ips
      ##
      externalIPs: []
      # loadBalancerIP: ""
      loadBalancerSourceRanges: []
      servicePort: 10254
      type: ClusterIP
      # externalTrafficPolicy: ""
      # nodePort: ""
    serviceMonitor:
      enabled: false
      additionalLabels: {}
      annotations: {}
      ## The label to use to retrieve the job name from.
      ## jobLabel: "app.kubernetes.io/name"
      namespace: ""
      namespaceSelector: {}
      ## Default: scrape .Release.Namespace or namespaceOverride only
      ## To scrape all, use the following:
      ## namespaceSelector:
      ##   any: true
      scrapeInterval: 30s
      # honorLabels: true
      targetLabels: []
      relabelings: []
      metricRelabelings: []
    prometheusRule:
      enabled: false
      additionalLabels: {}
      # namespace: ""
      rules: []
      # # These are just examples rules, please adapt them to your needs
      # - alert: NGINXConfigFailed
      #   expr: count(nginx_ingress_controller_config_last_reload_successful == 0) > 0
      #   for: 1s
      #   labels:
      #     severity: critical
      #   annotations:
      #     description: bad ingress config - nginx config test failed
      #     summary: uninstall the latest ingress changes to allow config reloads to resume
      # # By default a fake self-signed certificate is generated as default and
      # # it is fine if it expires. If `--default-ssl-certificate` flag is used
      # # and a valid certificate passed please do not filter for `host` label!
      # # (i.e. delete `{host!="_"}` so also the default SSL certificate is
      # # checked for expiration)
      # - alert: NGINXCertificateExpiry
      #   expr: (avg(nginx_ingress_controller_ssl_expire_time_seconds{host!="_"}) by (host) - time()) < 604800
      #   for: 1s
      #   labels:
      #     severity: critical
      #   annotations:
      #     description: ssl certificate(s) will expire in less then a week
      #     summary: renew expiring certificates to avoid downtime
      # - alert: NGINXTooMany500s
      #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"5.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
      #   for: 1m
      #   labels:
      #     severity: warning
      #   annotations:
      #     description: Too many 5XXs
      #     summary: More than 5% of all requests returned 5XX, this requires your attention
      # - alert: NGINXTooMany400s
      #   expr: 100 * ( sum( nginx_ingress_controller_requests{status=~"4.+"} ) / sum(nginx_ingress_controller_requests) ) > 5
      #   for: 1m
      #   labels:
      #     severity: warning
      #   annotations:
      #     description: Too many 4XXs
      #     summary: More than 5% of all requests returned 4XX, this requires your attention
  # -- Improve connection draining when ingress controller pod is deleted using a lifecycle hook:
  # With this new hook, we increased the default terminationGracePeriodSeconds from 30 seconds
  # to 300, allowing the draining of connections up to five minutes.
  # If the active connections end before that, the pod will terminate gracefully at that time.
  # To effectively take advantage of this feature, the Configmap feature
  # worker-shutdown-timeout new value is 240s instead of 10s.
  ##
  lifecycle:
    preStop:
      exec:
        command:
          - /wait-shutdown
  priorityClassName: ""
# -- Rollback limit
##
revisionHistoryLimit: 10
## Default 404 backend
##
defaultBackend:
  ##
  enabled: false
  name: defaultbackend
  image:
    registry: registry.k8s.io
    image: defaultbackend-amd64
    ## for backwards compatibility consider setting the full image url via the repository value below
    ## use *either* current default registry/image or repository format or installing chart by providing the values.yaml will fail
    ## repository:
    tag: "1.5"
    pullPolicy: IfNotPresent
    runAsNonRoot: true
    # nobody user -> uid 65534
    runAsUser: 65534
    allowPrivilegeEscalation: false
    seccompProfile:
      type: RuntimeDefault
    readOnlyRootFilesystem: true
  # -- Use an existing PSP instead of creating one
  existingPsp: ""
  extraArgs: {}
  serviceAccount:
    create: true
    name: ""
    automountServiceAccountToken: true
  # -- Additional environment variables to set for defaultBackend pods
  extraEnvs: []
  port: 8080
  ## Readiness and liveness probes for default backend
  ## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-probes/
  ##
  livenessProbe:
    failureThreshold: 3
    initialDelaySeconds: 30
    periodSeconds: 10
    successThreshold: 1
    timeoutSeconds: 5
  readinessProbe:
    failureThreshold: 6
    initialDelaySeconds: 0
    periodSeconds: 5
    successThreshold: 1
    timeoutSeconds: 5
  # -- The update strategy to apply to the Deployment or DaemonSet
  ##
  updateStrategy: {}
  #  rollingUpdate:
  #    maxUnavailable: 1
  #  type: RollingUpdate

  # -- `minReadySeconds` to avoid killing pods before we are ready
  ##
  minReadySeconds: 0
  # -- Node tolerations for server scheduling to nodes with taints
  ## Ref: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
  ##
  tolerations: []
  #  - key: "key"
  #    operator: "Equal|Exists"
  #    value: "value"
  #    effect: "NoSchedule|PreferNoSchedule|NoExecute(1.6 only)"

  affinity: {}
  # -- Security context for default backend pods
  podSecurityContext: {}
  # -- Security context for default backend containers
  containerSecurityContext: {}
  # -- Labels to add to the pod container metadata
  podLabels: {}
  #  key: value

  # -- Node labels for default backend pod assignment
  ## Ref: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/
  ##
  nodeSelector:
    kubernetes.io/os: linux
  # -- Annotations to be added to default backend pods
  ##
  podAnnotations: 
    "prometheus.io/scrape": true
    "prometheus.io/port": 10254
  replicaCount: 1
  minAvailable: 1
  resources: {}
  # limits:
  #   cpu: 10m
  #   memory: 20Mi
  # requests:
  #   cpu: 10m
  #   memory: 20Mi

  extraVolumeMounts: []
  ## Additional volumeMounts to the default backend container.
  #  - name: copy-portal-skins
  #   mountPath: /var/lib/lemonldap-ng/portal/skins

  extraVolumes: []
  ## Additional volumes to the default backend pod.
  #  - name: copy-portal-skins
  #    emptyDir: {}

  extraConfigMaps: []
  ## Additional configmaps to the default backend pod.
  #  - name: my-extra-configmap-1
  #    labels:
  #      type: config-1
  #    data:
  #      extra_file_1.html: |
  #        <!-- Extra HTML content for ConfigMap 1 -->
  #  - name: my-extra-configmap-2
  #    labels:
  #      type: config-2
  #    data:
  #      extra_file_2.html: |
  #        <!-- Extra HTML content for ConfigMap 2 -->

  autoscaling:
    annotations: {}
    enabled: false
    minReplicas: 1
    maxReplicas: 2
    targetCPUUtilizationPercentage: 50
    targetMemoryUtilizationPercentage: 50
  # NetworkPolicy for default backend component.
  networkPolicy:
    # -- Enable 'networkPolicy' or not
    enabled: false
  service:
    annotations: {}
    # clusterIP: ""

    # -- List of IP addresses at which the default backend service is available
    ## Ref: https://kubernetes.io/docs/concepts/services-networking/service/#external-ips
    ##
    externalIPs: []
    # loadBalancerIP: ""
    loadBalancerSourceRanges: []
    servicePort: 80
    type: ClusterIP
  priorityClassName: ""
  # -- Labels to be added to the default backend resources
  labels: {}
## Enable RBAC as per https://github.com/kubernetes/ingress-nginx/blob/main/docs/deploy/rbac.md and https://github.com/kubernetes/ingress-nginx/issues/266
rbac:
  create: true
  scope: false
## If true, create & use Pod Security Policy resources
## https://kubernetes.io/docs/concepts/policy/pod-security-policy/
podSecurityPolicy:
  enabled: false
serviceAccount:
  create: true
  name: ""
  automountServiceAccountToken: true
  # -- Annotations for the controller service account
  annotations: {}
# -- Optional array of imagePullSecrets containing private registry credentials
## Ref: https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
imagePullSecrets: []
# - name: secretName

# -- TCP service key-value pairs
## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/exposing-tcp-udp-services.md
##
tcp: {}
#  8080: "default/example-tcp-svc:9000"

# -- UDP service key-value pairs
## Ref: https://github.com/kubernetes/ingress-nginx/blob/main/docs/user-guide/exposing-tcp-udp-services.md
##
udp: {}
#  53: "kube-system/kube-dns:53"

# -- Prefix for TCP and UDP ports names in ingress controller service
## Some cloud providers, like Yandex Cloud may have a requirements for a port name regex to support cloud load balancer integration
portNamePrefix: ""
# -- (string) A base64-encoded Diffie-Hellman parameter.
# This can be generated with: `openssl dhparam 4096 2> /dev/null | base64`
## Ref: https://github.com/kubernetes/ingress-nginx/tree/main/docs/examples/customization/ssl-dh-param
dhParam: ""
