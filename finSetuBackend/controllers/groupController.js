const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Create a new group
exports.createGroup = async (req, res) => {
  try {
    const { name, members } = req.body;
    const createdBy = parseInt(req.user.id); // Will be set by auth middleware

    // Validate input
    if (!name || !members || !Array.isArray(members) || members.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid input. Name and at least one member required.'
      });
    }

    // Start a transaction
    const result = await prisma.$transaction(async (prisma) => {
      // Create the group
      const group = await prisma.group.create({
        data: {
          name,
          createdBy,
        }
      });

      // Add creator as admin member
      await prisma.groupMember.create({
        data: {
          groupId: group.id,
          userId: createdBy,
          isAdmin: true
        }
      });

      // Add other members
      const memberPromises = members.map(memberId => 
        prisma.groupMember.create({
          data: {
            groupId: group.id,
            userId: parseInt(memberId),
            isAdmin: false
          }
        })
      );

      await Promise.all(memberPromises);

      return group;
    });

    return res.status(201).json({
      success: true,
      message: 'Group created successfully',
      data: result
    });
  } catch (error) {
    console.error('Group creation error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to create group',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get all groups for a user
exports.getUserGroups = async (req, res) => {
  try {
    const userId = parseInt(req.user.id); // Will be set by auth middleware

    const groups = await prisma.group.findMany({
      where: {
        members: {
          some: {
            userId: userId
          }
        }
      },
      include: {
        members: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
                phoneNumber: true
              }
            }
          }
        }
      },
      orderBy: {
        createdAt: 'desc'
      }
    });

    // Format the response
    const formattedGroups = groups.map(group => ({
      id: group.id,
      name: group.name,
      createdAt: group.createdAt,
      memberCount: group.members.length,
      members: group.members.map(member => ({
        id: member.user.id,
        username: member.user.username,
        phoneNumber: member.user.phoneNumber,
        isAdmin: member.isAdmin
      })),
      isAdmin: group.members.some(member => member.userId === userId && member.isAdmin)
    }));

    return res.status(200).json({
      success: true,
      data: formattedGroups
    });
  } catch (error) {
    console.error('Get user groups error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to fetch groups',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Delete a group
exports.deleteGroup = async (req, res) => {
  try {
    const groupId = parseInt(req.params.groupId);
    const userId = parseInt(req.user.id); // Will be set by auth middleware

    // Check if user is admin of the group
    const membership = await prisma.groupMember.findFirst({
      where: {
        groupId,
        userId,
        isAdmin: true
      }
    });

    if (!membership) {
      return res.status(403).json({
        success: false,
        message: 'Not authorized to delete this group'
      });
    }

    // Delete the group (this will cascade delete all members due to our schema)
    await prisma.group.delete({
      where: {
        id: groupId
      }
    });

    return res.status(200).json({
      success: true,
      message: 'Group deleted successfully'
    });
  } catch (error) {
    console.error('Delete group error:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to delete group',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
}; 