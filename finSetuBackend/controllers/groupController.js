const { PrismaClient } = require('@prisma/client');
const prisma = new PrismaClient();

// Create a new group
exports.createGroup = async (req, res) => {
  try {
    console.log('=== Create Group Request ===');
    console.log('Request Body:', req.body);
    console.log('User ID:', req.user.id);
    
    const { name, members, description } = req.body;
    const createdBy = req.user.id;

    // Validate input
    if (!name || !members || !Array.isArray(members) || members.length === 0) {
      console.log('Invalid input:', { name, members });
      return res.status(400).json({
        success: false,
        message: 'Invalid input. Name and at least one member required.'
      });
    }

    // Validate that all member IDs are valid users
    const validMembers = await Promise.all(
      members.map(async (memberId) => {
        const user = await prisma.user.findUnique({
          where: { id: parseInt(memberId) }
        });
        return user ? parseInt(memberId) : null;
      })
    );

    const validMemberIds = validMembers.filter(id => id !== null);
    if (validMemberIds.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No valid member IDs provided'
      });
    }

    console.log('Starting transaction with data:', {
      name,
      description,
      createdBy,
      members: validMemberIds
    });

    // Start a transaction
    const result = await prisma.$transaction(async (prisma) => {
      // Create the group
      console.log('Creating group...');
      const group = await prisma.group.create({
        data: {
          name,
          description,
          createdBy,
        }
      });
      console.log('Group created:', group);

      // Add creator as admin member
      console.log('Adding creator as admin...');
      await prisma.groupMember.create({
        data: {
          groupId: group.id,
          userId: createdBy,
          isAdmin: true
        }
      });

      // Add other members
      console.log('Adding other members...');
      const memberPromises = validMemberIds.map(memberId => {
        if (memberId === createdBy) return null; // Skip if it's the creator
        console.log('Adding member:', memberId);
        return prisma.groupMember.create({
          data: {
            groupId: group.id,
            userId: memberId,
            isAdmin: false
          }
        });
      }).filter(Boolean); // Remove null promises

      await Promise.all(memberPromises);
      console.log('All members added successfully');

      // Fetch the complete group with members
      const completeGroup = await prisma.group.findUnique({
        where: { id: group.id },
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

      return completeGroup;
    });

    console.log('Transaction completed successfully:', result);

    // Format the response
    const formattedGroup = {
      id: result.id,
      name: result.name,
      description: result.description,
      createdAt: result.createdAt,
      memberCount: result.members.length,
      members: result.members.map(member => ({
        id: member.user.id,
        username: member.user.username,
        phoneNumber: member.user.phoneNumber,
        isAdmin: member.isAdmin
      })),
      isAdmin: result.members.some(member => member.userId === createdBy && member.isAdmin)
    };

    return res.status(201).json({
      success: true,
      message: 'Group created successfully',
      data: formattedGroup
    });
  } catch (error) {
    console.error('Group creation error:', error);
    console.error('Error stack:', error.stack);
    return res.status(500).json({
      success: false,
      message: 'Failed to create group',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// Get user's groups
exports.getUserGroups = async (req, res) => {
  try {
    const userId = req.user.id;
    console.log('Getting groups for user:', userId);

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

    // Format the response
    const formattedGroups = groups.map(group => ({
      id: group.id,
      name: group.name,
      description: group.description,
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
      message: 'Failed to fetch groups'
    });
  }
};

// Delete a group
exports.deleteGroup = async (req, res) => {
  try {
    const { groupId } = req.params;
    const userId = req.user.id;

    // Check if user is admin of the group
    const groupMember = await prisma.groupMember.findFirst({
      where: {
        groupId: parseInt(groupId),
        userId: userId,
        isAdmin: true
      }
    });

    if (!groupMember) {
      return res.status(403).json({
        success: false,
        message: 'Only group admins can delete groups'
      });
    }

    // Delete the group (cascade will handle group members)
    await prisma.group.delete({
      where: {
        id: parseInt(groupId)
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
      message: 'Failed to delete group'
    });
  }
}; 