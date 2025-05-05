const express = require('express');
const router = express.Router();
const groupController = require('../controllers/groupController');
const auth = require('../middleware/auth');

// All routes require authentication
router.use(auth);

// Create a new group
router.post('/', groupController.createGroup);

// Get user's groups
router.get('/', groupController.getUserGroups);

// Delete a group
router.delete('/:groupId', groupController.deleteGroup);

module.exports = router; 