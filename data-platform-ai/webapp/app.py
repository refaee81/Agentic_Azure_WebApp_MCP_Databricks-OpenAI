import os  
import csv  
from flask import Flask, render_template, request, jsonify  
import requests  
from datetime import datetime  
  
app = Flask(__name__)  
  
# Databricks endpoint details  
DATABRICKS_ENDPOINT = "https://adb-27179xxx-xxxxxx-xxxxxxxxx-x7.17.azuredatabricks.net/serving-endpoints/agents_mdlg_aixxx-xxxxxx-xxxxxxxxx-xv02/invocations"  
# DATABRICKS_TOKEN = os.environ.get('DATABRICKS_TOKEN')  # Use env var in production!  
DATABRICKS_TOKEN = 'dapixxx-xxxxxx-xxxxxxxxx-xd'  
  
@app.route('/')  
def index():  
    return render_template('index.html')  
  
@app.route('/chat', methods=['POST'])  
def chat():  
    user_message = request.json.get('message')  
    if not user_message:  
        return jsonify({"error": "No message provided"}), 400  
  
    headers = {  
        "Authorization": f"Bearer {DATABRICKS_TOKEN}",  
        "Content-Type": "application/json"  
    }  
    payload = {  
        "messages": [  
            {"role": "user", "content": user_message}  
        ]  
    }  
  
    try:  
        response = requests.post(DATABRICKS_ENDPOINT, headers=headers, json=payload)  
        response.raise_for_status()  
        data = response.json()  
        # Extract the assistant's reply  
        answer = data.get('choices', [{}])[0].get('message', {}).get('content', 'No answer found.')  
        return jsonify({'answer': answer})  
    except Exception as e:  
        return jsonify({'error': str(e)}), 500  
  
#@app.route('/feedback', methods=['POST'])  
#def feedback():  
#    data = request.json  
#    message = data.get('message')  
#    feedback_value = data.get('feedback')  
#    timestamp = datetime.now().isoformat()  
  
#    if not message or not feedback_value:  
#        return jsonify({'status': 'error', 'message': 'Missing data'}), 400  
  
#    # Save to CSV in the same directory  
#    csv_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'feedback_log.csv')  
#    write_header = not os.path.exists(csv_file)  
#    with open(csv_file, 'a', newline='', encoding='utf-8') as f:  
#        writer = csv.writer(f)  
#        if write_header:  
#            writer.writerow(['timestamp', 'bot_message', 'feedback'])  
#        writer.writerow([timestamp, message, feedback_value])  
  
#    return jsonify({'status': 'success'})  
  
if __name__ == '__main__':  
    app.run(debug=True)  