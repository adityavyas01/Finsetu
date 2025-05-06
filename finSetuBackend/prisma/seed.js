const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcrypt');

const prisma = new PrismaClient();

async function main() {
  // Clear existing data
  await prisma.billSplit.deleteMany();
  await prisma.bill.deleteMany();
  await prisma.groupMember.deleteMany();
  await prisma.group.deleteMany();
  await prisma.otp.deleteMany();
  await prisma.user.deleteMany();

  // Create test users
  const users = await Promise.all([
    prisma.user.create({
      data: {
        username: 'John Doe',
        phoneNumber: '1234567890',
        password: await bcrypt.hash('password123', 10),
        isPhoneVerified: true,
      },
    }),
    prisma.user.create({
      data: {
        username: 'Jane Smith',
        phoneNumber: '9876543210',
        password: await bcrypt.hash('password123', 10),
        isPhoneVerified: true,
      },
    }),
    prisma.user.create({
      data: {
        username: 'Mike Johnson',
        phoneNumber: '5555555555',
        password: await bcrypt.hash('password123', 10),
        isPhoneVerified: true,
      },
    }),
    prisma.user.create({
      data: {
        username: 'Sarah Wilson',
        phoneNumber: '4444444444',
        password: await bcrypt.hash('password123', 10),
        isPhoneVerified: true,
      },
    }),
  ]);

  console.log('Created test users:', users);

  // Create a test group
  const group = await prisma.group.create({
    data: {
      name: 'Test Group',
      createdBy: users[0].id,
      description: 'A test group for development',
      members: {
        create: [
          { userId: users[0].id, isAdmin: true },
          { userId: users[1].id },
          { userId: users[2].id },
        ],
      },
    },
  });

  console.log('Created test group:', group);
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  }); 