const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

class User {
  static async create(userData) {
    try {
      const user = await prisma.user.create({
        data: {
          username: userData.username,
          phoneNumber: userData.phoneNumber,
          password: userData.password
        }
      });
      return user;
    } catch (error) {
      throw new Error(`User creation failed: ${error.message}`);
    }
  }

  static async findByPhone(phoneNumber) {
    try {
      const user = await prisma.user.findUnique({
        where: {
          phoneNumber
        }
      });
      return user;
    } catch (error) {
      throw new Error(`User lookup failed: ${error.message}`);
    }
  }

  static async findById(userId) {
    try {
      const user = await prisma.user.findUnique({
        where: {
          id: parseInt(userId)
        }
      });
      return user;
    } catch (error) {
      throw new Error(`User lookup failed: ${error.message}`);
    }
  }

  static async updateVerificationStatus(userId, isVerified) {
    try {
      const user = await prisma.user.update({
        where: {
          id: parseInt(userId)
        },
        data: {
          isPhoneVerified: isVerified
        }
      });
      return user;
    } catch (error) {
      throw new Error(`User verification update failed: ${error.message}`);
    }
  }

  static async updateById(userId, updateData) {
    try {
      const user = await prisma.user.update({
        where: {
          id: parseInt(userId)
        },
        data: updateData
      });
      return user;
    } catch (error) {
      throw new Error(`User update failed: ${error.message}`);
    }
  }
}

module.exports = User;