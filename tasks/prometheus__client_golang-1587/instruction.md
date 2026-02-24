After upgrading from v1.19.1 to v1.20.0, scraping the /metrics endpoint can fail with an error like:

"An error has occurred while serving metrics:

2 error(s) occurred:
* collected metric process_network_receive_bytes_total counter:{value:...} with unregistered descriptor Desc{fqName: \"process_network_receive_bytes_total\", help: \"Number of bytes received by the process over the network.\", constLabels: {}, variableLabels: {}}
* collected metric process_network_transmit_bytes_total counter:{value:...} with unregistered descriptor Desc{fqName: \"process_network_transmit_bytes_total\", help: \"Number of bytes sent by the process over the network.\", constLabels: {}, variableLabels: {}}"

This happens when using the process collector via NewProcessCollector(ProcessCollectorOpts{}), and it also affects namespaced collectors created with options like ProcessCollectorOpts{Namespace: "foobar", ReportErrors: true}.

The process collector must never emit metrics whose descriptors were not registered/returned during Describe. In particular, the network byte counters must be fully described/registered so that gathering with a pedantic registry does not fail, and so that exposing metrics over HTTP does not return the "collected metric ... with unregistered descriptor" error.

Expected behavior:
- Registering one or more process collectors (including a default one and a namespaced one) into a pedantic registry and calling Gather() succeeds without error.
- The gathered exposition includes valid samples for both:
  - process_network_receive_bytes_total
  - process_network_transmit_bytes_total
  and when a namespace is set, also includes:
  - <namespace>_process_network_receive_bytes_total
  - <namespace>_process_network_transmit_bytes_total
- The metric names and help strings match the descriptors used by the collector.

Actual behavior:
- Gathering/scraping fails because the collector emits process_network_receive_bytes_total and process_network_transmit_bytes_total but the registry considers their descriptors unregistered.

Implement a fix in the process collector so that these network metrics are consistently described and collected (including for namespaced collectors) and do not trigger unregistered-descriptor errors under pedantic gathering.