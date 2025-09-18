import requests
import json

def debug_endpoints():
    """Debug endpoint'ini test et"""
    try:
        response = requests.get("http://127.0.0.1:8000/debug/endpoints")
        print(f"Status: {response.status_code}")
        
        if response.status_code == 200:
            data = response.json()
            endpoints = data.get('endpoints', [])
            
            print(f"\nToplam {len(endpoints)} endpoint bulundu:")
            for endpoint in endpoints:
                path = endpoint.get('path', 'Unknown')
                methods = endpoint.get('methods', [])
                name = endpoint.get('name', 'Unknown')
                
                if 'seller' in path.lower() or 'verification' in path.lower():
                    print(f"  {methods} {path} - {name}")
        else:
            print(f"Response: {response.text}")
            
    except Exception as e:
        print(f"Hata: {e}")

if __name__ == "__main__":
    debug_endpoints()
