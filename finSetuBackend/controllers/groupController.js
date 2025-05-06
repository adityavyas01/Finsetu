const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Create a new group
const createGroup = async (req, res) => {
  try {
    const { name, description, members } = req.body;
    const userId = parseInt(req.user.id);

    console.log('Creating group with:', { name, description, members, userId });

    // Validate input
    if (!name || !members || !Array.isArray(members)) {
      return res.status(400).json({
        success: false,
        message: 'Invalid input: name and members array are required'
      });
    }

    // Create the group
    const group = await prisma.group.create({
      data: {
        name,
        description: description || '',
        createdBy: userId,
        members: {
          create: [
            // Add creator as admin
            {
              user: { connect: { id: userId } },
              isAdmin: true
            },
            // Add other members
            ...members.map(memberId => ({
              user: { connect: { id: parseInt(memberId) } },
              isAdmin: false
            }))
          ]
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
      }
    });

    // Format the response with string IDs
    const formattedGroup = {
      id: group.id.toString(),
      name: group.name,
      description: group.description,
      createdAt: group.createdAt,
      memberCount: group.members.length,
      members: group.members.map(member => ({
        id: member.user.id.toString(),
        username: member.user.username,
        phoneNumber: member.user.phoneNumber,
        isAdmin: member.isAdmin
      })),
      isAdmin: true // Creator is always admin
    };

    res.status(201).json({
      success: true,
      data: formattedGroup,
      message: 'Group created successfully'
    });
  } catch (error) {
    console.error('Create group error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create group: ' + error.message
    });
  }
};

// Get user's groups
const getUserGroups = async (req, res) => {
  try {
    const userId = parseInt(req.user.id);
    console.log('=== Get User Groups ===');
    console.log('User ID:', userId);

    const user = await prisma.user.findUnique({
      where: { id: userId }
    });
    console.log('User object:', user);

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
      }
    });

    console.log('Found groups:', groups.length);
    console.log('Groups data:', JSON.stringify(groups, null, 2));

    // Format the groups for response with string IDs
    const formattedGroups = groups.map(group => ({
      id: group.id.toString(),
      name: group.name,
      description: group.description,
      createdAt: group.createdAt,
      memberCount: group.members.length,
      members: group.members.map(member => ({
        id: member.user.id.toString(),
        username: member.user.username,
        phoneNumber: member.user.phoneNumber,
        isAdmin: member.isAdmin
      })),
      isAdmin: group.members.some(member => member.userId === userId && member.isAdmin)
    }));

    console.log('Formatted groups:', JSON.stringify(formattedGroups, null, 2));

    res.json({
      success: true,
      data: formattedGroups
    });
  } catch (error) {
    console.error('Get user groups error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch groups'
    });
  }
};

// Delete a group
const deleteGroup = async (req, res) => {
  try {
    const { groupId } = req.params;
    const userId = parseInt(req.user.id);

    // Check if user is admin of the group
    const group = await prisma.group.findFirst({
      where: {
        id: parseInt(groupId),
        members: {
          some: {
            userId: userId,
            isAdmin: true
          }
        }
      }
    });

    if (!group) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to delete this group'
      });
    }

    // Delete the group and its members (cascade)
    await prisma.group.delete({
      where: {
        id: parseInt(groupId)
      }
    });

    res.json({
      success: true,
      message: 'Group deleted successfully'
    });
  } catch (error) {
    console.error('Delete group error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to delete group'
    });
  }
};

module.exports = {
  createGroup,
  getUserGroups,
  deleteGroup
}; 