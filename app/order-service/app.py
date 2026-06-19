from flask import Flask, jsonify, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST
import os

app = Flask(__name__)

# Declare the Prometheus Counter metric
ORDERS_CREATED_TOTAL = Counter('orders_created_total', 'Total number of orders created')

@app.route('/order', methods=['POST', 'GET']) # adjust to match your exact route if different
def create_order():
    # ... your existing order logic ...
    
    # Increment the metric tracker
    ORDERS_CREATED_TOTAL.inc()
    
    return jsonify({"order_id": "8899", "status": "Order Placed"})

# Expose the metrics endpoint for Prometheus to scrape
@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5002)