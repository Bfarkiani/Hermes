package edu.wustl.onl.envoylocalproxy

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.HandlerThread
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import io.envoyproxy.envoymobile.*



class LocalProxy(): Service() {
    private var statsdPort = Settings.statsdPort
    private var statsdAddress = Settings.statsdAddress
    private var xDSPort = Settings.xDSPort
    private var xDSAddress = Settings.xDSAddress
    private var envoyName = Settings.envoyName
    protected lateinit var proxyEngine: Engine
    protected lateinit var engine: EngineBuilder
    private var staticProxy = Settings.mode
    private lateinit var serviceHandler: Handler


    override fun onBind(p0: Intent?): IBinder? {
        return null
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
        val handlerThread = HandlerThread("ServiceHandlerThread")
        handlerThread.start()
        serviceHandler = Handler(handlerThread.looper)
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {

        //engine=envoyConfig(application).configStatic2("192.168.170.128",8125,12000)
        //engine=envoyConfig(application).configDynamic("192.168.170.128",8125,"192.168.1.28",18000)
        if (staticProxy == "Static") {
            //engine=configStatic(application,statsdAddress,statsdPort, envoyName)
            engine = configStaticNew(application,statsdAddress,statsdPort,envoyName) //-> To do resolution at an upstream proxy
            //engine=configStaticTest2(application,statsdAddress,statsdPort, envoyName) // work with new versions but new versions have useless listeners

        } else if (staticProxy == "Dynamic") {
            engine = configDynamic(
                application,
                statsdAddress,
                statsdPort,
                xDSAddress,
                xDSPort,
                envoyName
            )
        } else if (staticProxy == "DynamicSecure") {
            engine = configDynamicSecure(
                application,
                statsdAddress,
                statsdPort,
                xDSAddress,
                xDSPort,
                envoyName
            )
        }

        serviceHandler.post {
            proxyEngine = engine
                .addLogLevel(LogLevel.DEBUG)
                .setOnEngineRunning {
                    Log.d("EnvoyProxyLog", "Envoy async internal setup completed")
                    LogStorage.addLog("Envoy async internal setup completed")
                }
                .setLogger {
                    Log.d("EnvoyProxyLog", "EnvoyProxyLog: $it")
                    LogStorage.addLog("EnvoyProxyLog: $it")
                }
                .enableSocketTagging(true)
                .build()
        }
        startForegroundServiceWithNotification()
        return START_STICKY
    }


    private fun createNotificationChannel() {
        val name = "Envoy Proxy"
        val descriptionText = "Envoy Proxy Service"
        val importance = NotificationManager.IMPORTANCE_DEFAULT
        val mChannel = NotificationChannel("ENVOY_CHANNEL", name, importance)
        mChannel.description = descriptionText
        val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.createNotificationChannel(mChannel)

    }

    private fun startForegroundServiceWithNotification() {

        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntentFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_UPDATE_CURRENT
        } else {
            PendingIntent.FLAG_UPDATE_CURRENT
        }
        val pendingIntent =
            PendingIntent.getActivity(this, 0, notificationIntent, pendingIntentFlags)

        val notification: Notification = NotificationCompat.Builder(this, "ENVOY_CHANNEL")
            .setContentTitle("Envoy Local Proxy Service")
            .setContentText("Local Proxy is running...")
            .setSmallIcon(R.drawable.envoy_icon_color)
            .setContentIntent(pendingIntent)
            .build()
        startForeground(1, notification)
    }

    override fun onDestroy() {
        super.onDestroy()
        proxyEngine.terminate()
        serviceHandler.removeCallbacksAndMessages(null)
        Log.d("EnvoyProxyLog", "Envoy proxy service destroyed")
        LogStorage.addLog("Envoy proxy service destroyed")
        stopSelf()
    }

    fun configStatic(
        context: Context,
        statsDIP: String,
        statsDPort: Int,
        envoyName: String
    ): EngineBuilder {
        val config = """
node:
  cluster: test
  id: $envoyName
  metadata:
    secretKey: mobilepass
stats_sinks:
  - name: envoy.stat_sinks.statsd
    typed_config:
      "@type": type.googleapis.com/envoy.config.metrics.v3.StatsdSink
      address:
        socket_address:
          address: $statsDIP
          port_value: $statsDPort
static_resources:
  listeners:
    - name: base_api_listener
      address:
        socket_address:
          protocol: TCP
          address: 127.0.0.1
          port_value: 10000
      api_listener:
        api_listener:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.EnvoyMobileHttpConnectionManager
          config:
            stat_prefix: api_stats
            route_config:
              name: api_router
              virtual_hosts:
                - name: api
                  domains:
                    - "*"
                  routes:
                    - match:
                        prefix: /
                      direct_response:
                        status: 200
                        body:
                          inline_string: "Hello!"
    - name: listener_proxy
      address:
        socket_address:
          address: 127.0.0.1
          port_value: 12000
      filter_chains:
        - filters:
            - name: envoy.filters.network.http_connection_manager
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
                stat_prefix: mobile_stats
                route_config:
                  name: remote_route
                  virtual_hosts:
                    - name: example
                      domains: ["httpforever.com", "*.httpforever.com"]
                      routes:
                        - match:
                            prefix: "/"
                          direct_response:
                            status: 404
                            body:
                              inline_string: "Hello World\n"
                    - name: https
                      domains: ["*"]
                      routes:
                        - match:
                            connect_matcher: {}
                          route:
                            cluster: cluster_proxy
                            upgrade_configs:
                              - upgrade_type: CONNECT
                                connect_config: {}
                        - match:
                            prefix: "/"
                          route:
                            timeout: 0s
                            idle_timeout: 0s
                            retry_policy:
                              retry_on: 5xx,refused-stream,connect-failure,gateway-error,reset,refused-stream
                              num_retries: 4
                              per_try_timeout: 180s                          
                            cluster: cluster_proxy                                
                  response_headers_to_add:
                    - append_action: OVERWRITE_IF_EXISTS_OR_ADD
                      header:
                        key: x-response-header-that-should-be-stripped
                        value: "true"
                http_filters:
                  - name: envoy.filters.http.dynamic_forward_proxy
                    typed_config:
                      "@type": type.googleapis.com/envoy.extensions.filters.http.dynamic_forward_proxy.v3.FilterConfig
                      dns_cache_config:
                        name: base_dns_cache
                        dns_lookup_family: ALL
                        host_ttl: 86400s
                        dns_min_refresh_rate: 20s
                        dns_refresh_rate: 60s
                        dns_failure_refresh_rate:
                          base_interval: 2s
                          max_interval: 10s
                        dns_query_timeout: 25s
                        typed_dns_resolver_config:
                          name: envoy.network.dns_resolver.getaddrinfo
                          typed_config:
                            "@type": type.googleapis.com/envoy.extensions.network.dns_resolver.getaddrinfo.v3.GetAddrInfoDnsResolverConfig
                  - name: envoy.router
                    typed_config:
                      "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
  clusters:
    - name: cluster_proxy
      connect_timeout: 30s
      lb_policy: CLUSTER_PROVIDED
      dns_lookup_family: ALL
      cluster_type:
        name: envoy.clusters.dynamic_forward_proxy
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.clusters.dynamic_forward_proxy.v3.ClusterConfig
          dns_cache_config:
            name: base_dns_cache
            dns_lookup_family: ALL
            host_ttl: 86400s
            dns_min_refresh_rate: 20s
            dns_refresh_rate: 60s
            dns_failure_refresh_rate:
              base_interval: 2s
              max_interval: 10s
            dns_query_timeout: 25s
            typed_dns_resolver_config:
              name: envoy.network.dns_resolver.getaddrinfo
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.network.dns_resolver.getaddrinfo.v3.GetAddrInfoDnsResolverConfig
"""
        return AndroidEngineBuilder(context, Custom(config))
    }

    fun configDynamic(
        context: Context,
        statsDIP: String,
        statsDPort: Int,
        xDSIP: String,
        xDSPort: Int,
        envoyName: String
    ): EngineBuilder {
        val config = """
node:
  cluster: test
  id: $envoyName
  metadata:
    secretKey: mobilepass
stats_sinks:
  - name: envoy.stat_sinks.statsd
    typed_config:
      "@type": type.googleapis.com/envoy.config.metrics.v3.StatsdSink
      address:
        socket_address:
          address: $statsDIP
          port_value: $statsDPort
dynamic_resources:
  ads_config:
    api_type: GRPC
    transport_api_version: V3
    grpc_services:
    - envoy_grpc:
        cluster_name: xds_cluster
  cds_config:
    resource_api_version: V3
    ads: {}
    initial_fetch_timeout: 300s
  lds_config:
    resource_api_version: V3
    ads: {}
    initial_fetch_timeout: 300s

static_resources:
  listeners:
    - name: base_api_listener
      address:
        socket_address:
          protocol: TCP
          address: 127.0.0.1
          port_value: 10000
      api_listener:
        api_listener:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.EnvoyMobileHttpConnectionManager
          config:
            stat_prefix: api_stats
            route_config:
              name: api_router
              virtual_hosts:
                - name: api
                  domains:
                    - "*"
                  routes:
                    - match:
                        prefix: /
                      direct_response:
                        status: 200
                        body:
                          inline_string: "Hello!"

  clusters:
  - name: xds_cluster
    connect_timeout: 5s
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    upstream_connection_options:
      tcp_keepalive: {}
    load_assignment:
      cluster_name: xds_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: $xDSIP
                port_value: $xDSPort 
    typed_extension_protocol_options:
      envoy.extensions.upstreams.http.v3.HttpProtocolOptions:
        "@type": type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions
        explicit_http_config:
          http2_protocol_options:
            connection_keepalive:
              interval: 30s
              timeout: 5s            

"""
        return AndroidEngineBuilder(context, Custom(config))
    }


    fun configDynamicSecure(
        context: Context,
        statsDIP: String,
        statsDPort: Int,
        xDSIP: String,
        xDSPort: Int,
        envoyName: String
    ): EngineBuilder {
        val config = """
node:
  cluster: test
  id: $envoyName
  metadata:
    secretKey: mobilepass
stats_sinks:
  - name: envoy.stat_sinks.statsd
    typed_config:
      "@type": type.googleapis.com/envoy.config.metrics.v3.StatsdSink
      address:
        socket_address:
          address: $statsDIP
          port_value: $statsDPort    
dynamic_resources:
  ads_config:
    api_type: GRPC
    transport_api_version: V3
    grpc_services:
    - envoy_grpc:
        cluster_name: xds_cluster
  cds_config:
    resource_api_version: V3
    ads: {}
    initial_fetch_timeout: 300s
  lds_config:
    resource_api_version: V3
    ads: {}
    initial_fetch_timeout: 300s

static_resources:
  listeners:
    - name: base_api_listener
      address:
        socket_address:
          protocol: TCP
          address: 127.0.0.1
          port_value: 10000
      api_listener:
        api_listener:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.EnvoyMobileHttpConnectionManager
          config:
            stat_prefix: api_stats
            route_config:
              name: api_router
              virtual_hosts:
                - name: api
                  domains:
                    - "*"
                  routes:
                    - match:
                        prefix: /
                      direct_response:
                        status: 200
                        body:
                          inline_string: "Hello!"

  clusters:
  - name: xds_cluster
    connect_timeout: 5s
    lb_policy: ROUND_ROBIN
    http2_protocol_options: {}
    upstream_connection_options:
      tcp_keepalive: {}
    load_assignment:
      cluster_name: xds_cluster
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: $xDSIP
                port_value: $xDSPort 
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          tls_params:
            tls_minimum_protocol_version: TLSv1_3
            tls_maximum_protocol_version: TLSv1_3
    typed_extension_protocol_options:
      envoy.extensions.upstreams.http.v3.HttpProtocolOptions:
        "@type": type.googleapis.com/envoy.extensions.upstreams.http.v3.HttpProtocolOptions
        explicit_http_config:
          http2_protocol_options:
            connection_keepalive:
              interval: 30s
              timeout: 5s            

"""
        return AndroidEngineBuilder(context, Custom(config))
    }


    fun configStaticNew(
        context: Context,
        statsDIP: String,
        statsDPort: Int,
        envoyName: String
    ): EngineBuilder {
        //192.168.170.128 is the remote TCP proxy. I tested with Dynamic_TLS_Forwarding https://bitbucket.org/jdehart2/envoystatsdexperiment/src/master/Dynamic_TLS_Forwarding/envoyMiddle/
        val config = """
node:
  cluster: test
  id: $envoyName
  metadata:
    secretKey: mobilepass
static_resources:
  listeners:
    - name: base_api_listener
      address:
        socket_address:
          protocol: TCP
          address: 127.0.0.1
          port_value: 10000
      api_listener:
        api_listener:
          "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.EnvoyMobileHttpConnectionManager
          config:
            stat_prefix: api_stats
            route_config:
              name: api_router
              virtual_hosts:
                - name: api
                  domains:
                    - "*"
                  routes:
                    - match:
                        prefix: /
                      direct_response:
                        status: 200
                        body:
                          inline_string: "Hello!"
    - name: listener_proxy
      address:
        socket_address:
          address: 127.0.0.1
          port_value: 12000
      filter_chains:
        - filters:
            - name: envoy.filters.network.http_connection_manager
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
                stat_prefix: mobile_stats
                route_config:
                  name: remote_route
                  virtual_hosts:
                    - name: https
                      domains: ["*"]
                      routes:
                        - match:
                            connect_matcher: {}
                          route:
                            cluster: cluster_proxy
                        - match:
                            prefix: "/"
                          route:
                            timeout: 0s
                            idle_timeout: 0s
                            retry_policy:
                              retry_on: 5xx,refused-stream,connect-failure,gateway-error,reset,refused-stream
                              num_retries: 4
                              per_try_timeout: 180s                          
                            cluster: cluster_proxy                                
                  response_headers_to_add:
                    - append_action: OVERWRITE_IF_EXISTS_OR_ADD
                      header:
                        key: x-response-header-that-should-be-stripped
                        value: "true"
                http_filters:
                - name: envoy.router
                  typed_config:
                    "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
                http2_protocol_options:
                  allow_connect: true
                upgrade_configs:
                - upgrade_type: CONNECT                      
  clusters:
  - name: cluster_proxy
    connect_timeout: 5s
    lb_policy: ROUND_ROBIN
    load_assignment:
      cluster_name: cluster_proxy
      endpoints:
      - lb_endpoints:
        - endpoint:
            address:
              socket_address:
                address: 10.232.148.70               
                port_value: 10000
    transport_socket:
      name: envoy.transport_sockets.tls
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.transport_sockets.tls.v3.UpstreamTlsContext
        common_tls_context:
          tls_params:
            tls_minimum_protocol_version: TLSv1_3
            tls_maximum_protocol_version: TLSv1_3
              
"""
        return AndroidEngineBuilder(context, Custom(config))
    }

    private fun configStaticTest(
        context: Context,
        statsDIP: String,
        statsDPort: Int,
        envoyName: String
    ): EngineBuilder {
        //this one works for versions after 0.5.0.20221205. Then you need to add google protobuf library in gradle to work
        //type.googleapis.com/envoy.config.listener.v3.ApiListenerManager  this one is required for newer versions, otherwise it doesn't work
        // but this version doesn't listen to anything per design and I already submitted an issue here https://github.com/envoyproxy/envoy/issues/31206

        val config = """
listener_manager:
    name: envoy.listener_manager_impl.api
    typed_config:
      "@type": type.googleapis.com/envoy.config.listener.v3.ApiListenerManager
static_resources:
  listeners:
  - name: base_api_listener
    address:
      socket_address:
        protocol: TCP
        address: 0.0.0.0
        port_value: 10000
    api_listener:
      api_listener:
        "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.EnvoyMobileHttpConnectionManager
        config:
          stat_prefix: hcm
          route_config:
            name: api_router
            virtual_hosts:
              - name: api
                domains:
                  - "*"
                routes:
                  - match:
                      prefix: "/"
                    direct_response:
                      status: 200
                      body:
                        inline_string: "Hello!"
          http_filters:
            - name: envoy.router
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
  - name: listener_proxy
    address:
      socket_address:
        address: 127.0.0.1
        port_value: 12000
    filter_chains:
      - filters:
          - name: envoy.filters.network.http_connection_manager
            typed_config:
              "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
              stat_prefix: mobile_stats
              route_config:
                name: remote_route
                virtual_hosts:
                  - name: example
                    domains: ["httpforever.com", "*.httpforever.com"]
                    routes:
                      - match:
                          prefix: "/"
                        direct_response:
                          status: 404
                          body:
                            inline_string: "Hello World\n"
                  - name: https
                    domains: ["*"]
                    routes:
                      - match:
                          connect_matcher: {}
                        route:
                          cluster: cluster_proxy
                          upgrade_configs:
                            - upgrade_type: CONNECT
                              connect_config: {}
                      - match:
                          prefix: "/"
                        route:
                          timeout: 0s
                          idle_timeout: 0s
                          retry_policy:
                            retry_on: 5xx,refused-stream,connect-failure,gateway-error,reset,refused-stream
                            num_retries: 4
                            per_try_timeout: 180s                          
                          cluster: cluster_proxy                                
                response_headers_to_add:
                  - append_action: OVERWRITE_IF_EXISTS_OR_ADD
                    header:
                      key: x-response-header-that-should-be-stripped
                      value: "true"
              http_filters:
                - name: envoy.filters.http.dynamic_forward_proxy
                  typed_config:
                    "@type": type.googleapis.com/envoy.extensions.filters.http.dynamic_forward_proxy.v3.FilterConfig
                    dns_cache_config:
                      name: base_dns_cache
                      dns_lookup_family: ALL
                      host_ttl: 86400s
                      dns_min_refresh_rate: 20s
                      dns_refresh_rate: 60s
                      dns_failure_refresh_rate:
                        base_interval: 2s
                        max_interval: 10s
                      dns_query_timeout: 25s
                      typed_dns_resolver_config:
                        name: envoy.network.dns_resolver.getaddrinfo
                        typed_config:
                          "@type": type.googleapis.com/envoy.extensions.network.dns_resolver.getaddrinfo.v3.GetAddrInfoDnsResolverConfig
                - name: envoy.router
                  typed_config:
                    "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
  clusters:
    - name: cluster_proxy
      connect_timeout: 30s
      lb_policy: CLUSTER_PROVIDED
      dns_lookup_family: ALL
      cluster_type:
        name: envoy.clusters.dynamic_forward_proxy
        typed_config:
          "@type": type.googleapis.com/envoy.extensions.clusters.dynamic_forward_proxy.v3.ClusterConfig
          dns_cache_config:
            name: base_dns_cache
            dns_lookup_family: ALL
            host_ttl: 86400s
            dns_min_refresh_rate: 20s
            dns_refresh_rate: 60s
            dns_failure_refresh_rate:
              base_interval: 2s
              max_interval: 10s
            dns_query_timeout: 25s
            typed_dns_resolver_config:
              name: envoy.network.dns_resolver.getaddrinfo
              typed_config:
                "@type": type.googleapis.com/envoy.extensions.network.dns_resolver.getaddrinfo.v3.GetAddrInfoDnsResolverConfig            
"""
        return AndroidEngineBuilder(context, Custom(config))
    }

    private fun configStaticTest2(
        context: Context,
        statsDIP: String,
        statsDPort: Int,
        envoyName: String
    ): EngineBuilder {
        //this one works for versions after 0.5.0.20221205. Then you need to add google protobuf library in gradle to work
        //type.googleapis.com/envoy.config.listener.v3.ApiListenerManager  this one is required for newer versions, otherwise it doesn't work
        // but this version doesn't listen to anything per design and I already submitted an issue here https://github.com/envoyproxy/envoy/issues/31206

        val config = """
static_resources:
  listeners:
  - name: base_api_listener
    address:
      socket_address: { protocol: TCP, address: 127.0.0.1, port_value: 10000 }
    api_listener:
      api_listener:
        "@type": "type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.EnvoyMobileHttpConnectionManager"
        config:
          stat_prefix: api_hcm
          route_config:
            name: api_router
            virtual_hosts:
            - name: api
              domains: ["*"]
              routes:
              - match: { prefix: "/" }
                direct_response: { status: 400, body: { inline_string: "not found" } }
  - name: listener_proxy
    address:
      socket_address: { address: 127.0.0.1, port_value: 12000 }
    filter_chains:
      - filters:
        - name: envoy.filters.network.http_connection_manager
          typed_config:
            "@type": type.googleapis.com/envoy.extensions.filters.network.http_connection_manager.v3.HttpConnectionManager
            stat_prefix: remote_hcm
            route_config:
              name: remote_route
              virtual_hosts:
              - name: remote_service
                domains: ["*"]
                routes:
                - match: { prefix: "/" }
                  route: { cluster: cluster_proxy }
              response_headers_to_add:
                - append_action: OVERWRITE_IF_EXISTS_OR_ADD
                  header:
                    key: x-proxy-response
                    value: 'true'
            http_filters:
              - name: envoy.filters.http.local_error
                typed_config:
                  "@type": type.googleapis.com/envoymobile.extensions.filters.http.local_error.LocalError
              - name: envoy.filters.http.dynamic_forward_proxy
                typed_config:
                  "@type": type.googleapis.com/envoy.extensions.filters.http.dynamic_forward_proxy.v3.FilterConfig
                  dns_cache_config: &dns_cache_config
                    name: base_dns_cache
                    dns_lookup_family: ALL
                    host_ttl: 86400s
                    dns_min_refresh_rate: 20s
                    dns_refresh_rate: 60s
                    dns_failure_refresh_rate:
                      base_interval: 2s
                      max_interval: 10s
                    dns_query_timeout: 25s
                    typed_dns_resolver_config:
                      name: envoy.network.dns_resolver.getaddrinfo
                      typed_config: {"@type":"type.googleapis.com/envoy.extensions.network.dns_resolver.getaddrinfo.v3.GetAddrInfoDnsResolverConfig"}
              - name: envoy.router
                typed_config:
                  "@type": type.googleapis.com/envoy.extensions.filters.http.router.v3.Router
  clusters:
  - name: cluster_proxy
    connect_timeout: 30s
    lb_policy: CLUSTER_PROVIDED
    dns_lookup_family: ALL
    cluster_type:
      name: envoy.clusters.dynamic_forward_proxy
      typed_config:
        "@type": type.googleapis.com/envoy.extensions.clusters.dynamic_forward_proxy.v3.ClusterConfig
        dns_cache_config: *dns_cache_config
layered_runtime:
  layers:
    - name: static_layer_0
      static_layer:
        envoy:
          # This disables envoy bug stats, which are filtered out of our stats inclusion list anyway
          # Global stats do not play well with engines with limited lifetimes
          disallow_global_stats: true
            
"""
        return AndroidEngineBuilder(context, Custom(config))


    }
}