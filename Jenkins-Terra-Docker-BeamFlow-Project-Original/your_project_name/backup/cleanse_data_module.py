import json
import logging
from datetime import datetime

def cleanse_data(element):
    """Function to cleanse and transform input data."""
    
    # Convert byte format to string and load as JSON
    element = element.decode('utf-8')
    element = json.loads(element)

    result = {}

    # Cleanse string fields
    for field in ['tr_time_str', 'first_name', 'last_name', 'city', 'state', 'product']:
        if field in element:
            result[field] = element[field].strip()

    # Handle 'amount' field
    if 'amount' in element:
        try:
            result['amount'] = float(element['amount'])
        except ValueError:
            result['amount'] = None
            logging.error(f"Failed to parse 'amount': {element['amount']}")

    # Handle 'tr_time_str' field to get datetime object and 'dayofweek'
    if 'tr_time_str' in element:
        try:
            date_time_obj = datetime.strptime(element['tr_time_str'], "%Y-%m-%d %H:%M:%S")
            result['dayofweek'] = date_time_obj.weekday()
            result['tr_time_str'] = date_time_obj.strftime("%Y-%m-%d %H:%M:%S")
        except ValueError:
            result['dayofweek'] = None
            logging.error(f"Failed to parse 'tr_time_str': {element['tr_time_str']}")

    logging.info(f"Processed element: {result}")
    return result