#! /usr/bin/python3
import os
import sys
import time
import subprocess
import traceback
# from opentelemetry.sdk.resources import Resource
# from opentelemetry import metrics
# from opentelemetry.sdk.metrics import MeterProvider
# from opentelemetry.sdk.metrics.export import (
#     ConsoleMetricExporter,
#     PeriodicExportingMetricReader,
#     AggregationTemporality,
# )
# from opentelemetry.sdk.metrics import UpDownCounter

# from opentelemetry.exporter.otlp.proto.grpc.metric_exporter import (
#     OTLPMetricExporter
# )




class LinkParams:
    def __init__(self, argv):
        self.uname = None
        self.delay = '0'
        self.loss = '0'
        self.up_time = 1
        self.down_time = 1
        self.statsm = None
        self.cmd_pref = 'sudo /users/onl/swr/scripts/change_link_from_onlusr.sh'
        i = 0
        while ( i < len(argv) ):
            if '-dt' in argv[i]:
                i += 1
                self.down_time = int(argv[i])
            elif '-ut' in argv[i]:
                i += 1
                self.up_time = int(argv[i])
            elif '-u' in argv[i]:
                i += 1
                self.uname = argv[i]
            elif '-d' in argv[i]:
                i += 1
                self.delay = argv[i]   
            # elif '-otlp' in argv[i]:
            #     i += 1
            #     #self.statsm = argv[i]
            #     #cproc = subprocess.run(['getent', 'hosts', argv[i]], capture_output=True, text=True)
            #     cproc = subprocess.run(['getent', 'hosts', argv[i]], encoding='ascii', stdout=subprocess.PIPE)
            #     print(repr(cproc), flush=True)
            #     self.statsm = cproc.stdout.split(' ')[0]
            elif '-l' in argv[i]:
                i += 1
                self.loss = argv[i]
            i += 1

    def is_valid(self):
        return (not (self.uname == None))

class NodeInfo:
    def __init__(self, hst, p, q):
        self.rli_hst = hst
        self.port = p
        self.queue = q

        
    def __str__(self):
        return self.rli_hst + ' ' + self.port + ' ' + self.queue
            
class LinkInfo:
    def __init__(self, linkp, node1, node2, lid):
        self.linkp = linkp
        self.linkid = lid
        self.node1 = node1
        self.node2 = node2
        self.gauge = None

    def get_down_cmd(self):
        return self.linkp.cmd_pref + ' ' + self.linkp.uname + ' ' + self.linkp.delay + ' 100 ' + str(self.node1) + ' ' + str(self.node2) + ' ' + self.linkid
    def get_up_cmd(self):
        return self.linkp.cmd_pref + ' ' + self.linkp.uname + ' ' + self.linkp.delay + ' ' + self.linkp.loss + ' ' + str(self.node1) + ' ' + str(self.node2) + ' ' + self.linkid
    
def run_links(linkp):
    
    
    # endpoint_str = 'http://' + linkp.statsm + ':4319'
    # print( 'endpoint:' + endpoint_str, flush=True)
    #meter setup
    # resource = Resource(attributes={
    #     "service.name": "onl_exp"
    # })
    # #meterExporter = OTLPMetricExporter(endpoint=endpoint_str)
    # meterExporter = OTLPMetricExporter(endpoint=endpoint_str,
    #                                    preferred_temporality = {
    #                                        UpDownCounter: AggregationTemporality.CUMULATIVE,
    #                                    })
    # reader = PeriodicExportingMetricReader(meterExporter, export_interval_millis=500, export_timeout_millis=30000)
    # provider = MeterProvider(metric_readers=[reader], resource=resource)
    # metrics.set_meter_provider(provider)
    
    link1 = LinkInfo(linkp, NodeInfo('SWR5_14', '2', '2'), NodeInfo('SWR5_15', '4', '2'), 'link1')
    link2 = LinkInfo(linkp, NodeInfo('SWR5_15', '2', '2'), NodeInfo('SWR5_16', '4', '2'), 'link2')
    link3 = LinkInfo(linkp, NodeInfo('SWR5_16', '2', '2'), NodeInfo('SWR5_17', '4', '2'), 'link3')

    links = [link1,link2,link3]
    # meter = metrics.get_meter("onl_test")
    #for l in links:
        #l.gauge =  meter.create_up_down_counter(name=l.linkid, unit='1', description=(l.linkid + ' state'))

    try:
        # lgauge =  meter.create_up_down_counter(name='link_state', unit='1', description=('link state'))
        # reader.force_flush()
        for l in links:
            print('DOWN ' + l.linkid + ': ' + l.get_down_cmd(), flush=True)
            if not (os.WEXITSTATUS(os.system(l.get_down_cmd())) == 0):
                print('Error: change link failed', flush=True)
                break
           
        while True: 
            for l in links:
                print('Up ' + l.linkid + ': ' + l.get_up_cmd(), flush=True)
                # lgauge.add(1, {'linkid': l.linkid})
                # reader.force_flush()
                if not (os.WEXITSTATUS(os.system(l.get_up_cmd())) == 0):
                    print('Error: change link failed', flush=True)
                    break
                if linkp.up_time:
                    time.sleep(linkp.up_time)
                print('DOWN ' + l.linkid + ': ' + l.get_down_cmd(), flush=True)
                # lgauge.add(-1, {'linkid': l.linkid})
                # reader.force_flush()
                if not (os.WEXITSTATUS(os.system(l.get_down_cmd())) == 0):
                    print('Error: change link failed', flush=True)
                    break
    except: # KeyboardInterrupt,RuntimeError:
        print('got exception', flush=True)
        traceback.print_exc()
    
        
    
def main(arv=None):
    argv = sys.argv
    linkp = LinkParams(argv)
    if linkp.is_valid():
        #init_tracer(linkp.statsm)
        run_links(linkp)
    else:
        print('argument not valid')
        

if __name__ == '__main__':
  status = main()
  sys.exit(status)
