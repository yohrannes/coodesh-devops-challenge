import random
import time
from prometheus_client import start_http_server, Gauge

# Create a Prometheus gauge metric
random_number_metric = Gauge('random_number', 'Random number generated every 30 sec')

def generate_random_number():
    # Generate a random number between 1 and 10
    return random.randint(1, 10)

if __name__ == '__main__':
    # Start the Prometheus HTTP server on port 8000
    start_http_server(8000)
    
    while True:
        # Generate a random number
        random_number = generate_random_number()
        print('Random number is: ', random_number)
        # Set the value of the Prometheus metric
        random_number_metric.set(random_number)
        
        # Sleep for 30 sec
        time.sleep(30)
