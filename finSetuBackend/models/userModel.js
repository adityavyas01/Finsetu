const db = require('../config/database');

class User {
  static async findByPhone(phoneNumber) {
    try {
      const query = 'SELECT * FROM users WHERE phone_number = $1';
      const result = await db.query(query, [phoneNumber]);
      
      if (result.rows.length === 0) {
        return null;
      }
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Error finding user by phone: ${error.message}`);
    }
  }

  static async create(userData) {
    try {
      const { username, phoneNumber, password } = userData;
      
      const query = `
        INSERT INTO users (username, phone_number, password, is_phone_verified, created_at, updated_at)
        VALUES ($1, $2, $3, $4, NOW(), NOW())
        RETURNING *
      `;
      
      const result = await db.query(query, [
        username, 
        phoneNumber, 
        password, 
        false
      ]);
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Error creating user: ${error.message}`);
    }
  }

  static async updateById(id, data) {
    try {
      const setClause = Object.keys(data)
        .map((key, index) => {
          // Convert camelCase to snake_case for PostgreSQL
          const snakeKey = key.replace(/([A-Z])/g, '_$1').toLowerCase();
          return `${snakeKey} = $${index + 2}`;
        })
        .join(', ');
      
      const query = `
        UPDATE users 
        SET ${setClause}, updated_at = NOW()
        WHERE id = $1
        RETURNING *
      `;
      
      const values = [id, ...Object.values(data)];
      const result = await db.query(query, values);
      
      if (result.rows.length === 0) {
        throw new Error('User not found');
      }
      
      return result.rows[0];
    } catch (error) {
      throw new Error(`Error updating user: ${error.message}`);
    }
  }
}

module.exports = User;