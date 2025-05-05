const express = require('express');
const router = express.Router();
const groupController = require('../controllers/groupController');
const { authenticateToken } = require('../middleware/auth');

// All routes require authentication
router.use(authenticateToken);

// Create a new group
router.post('/', groupController.createGroup);

// Get all groups for the authenticated user
router.get('/', groupController.getUserGroups);

// Delete a group
router.delete('/:groupId', groupController.deleteGroup);

module.exports = router; 