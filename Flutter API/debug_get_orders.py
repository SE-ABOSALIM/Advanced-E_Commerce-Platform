import requests
import json

def debug_get_orders():
    url = "http://127.0.0.1:8000/order"
    
    try:
        response = requests.get(url)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            orders = response.json()
            print(f"Number of orders: {len(orders)}")
            
            for i, order in enumerate(orders):
                print(f"\n--- Order {i+1} ---")
                print(f"Raw order data: {order}")
                print(f"All fields: {list(order.keys())}")
                
                # Her alanı tek tek kontrol et
                for key, value in order.items():
                    print(f"  {key}: {value} ({type(value)})")
                
                # Özellikle delivered siparişleri kontrol et
                if order.get('order_status') == 'delivered':
                    print("🔍 DELIVERED ORDER DETAILS:")
                    print(f"  Delivered Date: {order.get('order_delivered_date')}")
                    print(f"  Delivered Date Type: {type(order.get('order_delivered_date'))}")
        else:
            print(f"Error: {response.text}")
            
    except Exception as e:
        print(f"Exception: {e}")

if __name__ == "__main__":
    debug_get_orders() 