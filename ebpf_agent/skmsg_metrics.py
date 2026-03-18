import threading
import time
import re

from flask import Flask
from flask_apscheduler import APScheduler
from prometheus_client import (Counter, generate_latest, CONTENT_TYPE_LATEST)

class Config:
    SCHEDULER_API_ENABLED = True

app = Flask(__name__)
app.config.from_object(Config())

file_name = '/sys/fs/bpf/skmsg_stats_map'
last_total = None  # None until first read; initialized to current BPF map value to avoid startup spike

# prometheus metric (counter), just increments.
REQUEST_COUNT = Counter(
    'func_request_count',
    'Request count'
)


def read_metrics():
    result = {}
    current_func = None
    current_cpu = None
    global last_total

    # read metrics into (nested) dictionary
    # outer dict: function id
    # inner dict: cpu id
    # value in the inner dict: number of requests received
    with open(file_name) as f:
        for line in f:
            line = line.strip()
            # ignore trailing }
            if not line or line == '}':
                continue

            # function entry (top level): "0: {"
            # regex line by line, get the function id and add it to the dictionary
            if re.match(r'^\d+:\s*\{$', line):
                current_func = int(line.split(':')[0])
                result[current_func] = {}

            # cpu entry: "cpu0: {0,}" or whatever
            # get the cpu id and the value and add them to the nested dictionary
            elif m := re.match(r'(\w+):\s*\{([\d,\s]*)\}', line):
                key = m.group(1)
                values = int(m.group(2).split(',')[0].strip()) # remove the trailing comma in the { }
                result[current_func][key] = values

    rx_sum = 0
    for func, cpus in result.items():
        # print(func)
        for cpu in cpus:
            rx_sum += cpus[cpu]

    if last_total is None:
        last_total = rx_sum  # use current value, not historical accumulation
    print("new requests: " + str(rx_sum - last_total))
    REQUEST_COUNT.inc(rx_sum - last_total) # increment prometheus counter
    last_total = rx_sum


@app.route('/metrics')
def metrics():
    # expose func request metrics to prometheus
    return generate_latest(), 200, {'Content-Type': CONTENT_TYPE_LATEST}


if __name__ == "__main__":
    scheduler = APScheduler()

    scheduler.init_app(app)
    scheduler.add_job(id='read_metrics_job', func=read_metrics, trigger='interval', seconds=5)
    scheduler.start()

    app.run(host='0.0.0.0', port=5000)
