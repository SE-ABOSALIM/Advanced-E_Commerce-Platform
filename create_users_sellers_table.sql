-- Users-Sellers takip tablosu oluştur
CREATE TABLE IF NOT EXISTS users_sellers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    seller_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, seller_id),  -- Aynı kullanıcı aynı satıcıyı birden fazla takip edemez
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES sellers(id) ON DELETE CASCADE
);

-- Index ekle (performans için)
CREATE INDEX IF NOT EXISTS idx_users_sellers_user_id ON users_sellers(user_id);
CREATE INDEX IF NOT EXISTS idx_users_sellers_seller_id ON users_sellers(seller_id);

-- Örnek veri ekle (test için)
-- INSERT INTO users_sellers (user_id, seller_id) VALUES (1, 1);
