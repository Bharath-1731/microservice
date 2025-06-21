from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

# Track current replica count for all services (initialize as needed)
replica_counts = {
    "ocelotgateway": 2,
    "servicea": 2,
    "serviceb": 2,
    "servicec": 2
}

@app.route('/alert', methods=['POST'])
def alert():
    data = request.json
    alerts = data.get('alerts', [])
    for alert in alerts:
        service = alert['labels'].get('service')
        action = alert['labels'].get('action')
        if service and action and service in replica_counts:
            current = replica_counts.get(service, 2)
            if action == "scaleup":
                new_count = current + 1
            elif action == "scaledown" and current > 1:
                new_count = current - 1
            else:
                new_count = current
            if new_count != current:
                subprocess.run(["docker", "service", "scale", f"mystack_{service}={new_count}"])
                replica_counts[service] = new_count
                print(f"Scaled {service} to {new_count} replicas.")
    return jsonify({"status": "ok"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8081)