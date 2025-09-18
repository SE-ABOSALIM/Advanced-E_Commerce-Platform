import requests
import json

def test_endpoints():
    """Backend endpoint'lerini test et"""
    base_url = "http://127.0.0.1:8000"
    
    print("=== BACKEND ENDPOINT TESTLERİ ===")
    
    # 1. Ana endpoint
    print("\n1. Ana endpoint testi:")
    try:
        response = requests.get(f"{base_url}/")
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
    except Exception as e:
        print(f"   Hata: {e}")
    
    # 2. Seller doğrulama endpoint'i
    print("\n2. Seller doğrulama endpoint testi:")
    try:
        data = {
            "phone_number": "05389874376",
            "language": "tr"
        }
        response = requests.post(
            f"{base_url}/send-seller-verification-code",
            headers={"Content-Type": "application/json"},
            data=json.dumps(data)
        )
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
    except Exception as e:
        print(f"   Hata: {e}")
    
    # 3. Normal doğrulama endpoint'i
    print("\n3. Normal doğrulama endpoint testi:")
    try:
        data = {
            "phone_number": "05389874376",
            "language": "tr"
        }
        response = requests.post(
            f"{base_url}/send-verification-code",
            headers={"Content-Type": "application/json"},
            data=json.dumps(data)
        )
        print(f"   Status: {response.status_code}")
        print(f"   Response: {response.text}")
    except Exception as e:
        print(f"   Hata: {e}")

if __name__ == "__main__":
    test_endpoints()
