from flask import Flask, jsonify, Response
from prometheus_client import Counter, generate_latest, CONTENT_TYPE_LATEST

app = Flask(__name__)

# Declare the Prometheus Counter metric
PAYMENTS_PROCESSED_TOTAL = Counter('payments_processed_total', 'Total number of payments processed')

@app.route('/payment', methods=['POST']) # adjust to match your exact route
def process_payment():
    # ... your existing payment logic ...
    
    # Increment the metric tracker
    PAYMENTS_PROCESSED_TOTAL.inc()
    
    return jsonify({"payment_status": "success", "transaction_id": "tx-8899-999"})

# Expose the metrics endpoint
@app.route('/metrics')
def metrics():
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5003)