const express = require('express');
const app = express();
const port = 3000;

app.use(express.static('public'));

// GitOps deployment status
let deploymentStatus = {
    currentVersion: 'v1.0.0',
    targetVersion: 'v1.0.0',
    status: 'Synced',
    lastSync: new Date().toISOString(),
    health: 'Healthy',
    deployments: [
        { version: 'v1.0.0', timestamp: new Date().toISOString(), status: 'Success', commit: 'abc123def' }
    ]
};

app.get('/api/status', (req, res) => {
    res.json(deploymentStatus);
});

app.post('/api/deploy/:version', (req, res) => {
    const version = req.params.version;
    
    deploymentStatus.targetVersion = version;
    deploymentStatus.status = 'Syncing';
    deploymentStatus.lastSync = new Date().toISOString();
    
    // Simulate deployment
    setTimeout(() => {
        deploymentStatus.currentVersion = version;
        deploymentStatus.status = 'Synced';
        deploymentStatus.deployments.unshift({
            version: version,
            timestamp: new Date().toISOString(),
            status: 'Success',
            commit: version === 'v2.0.0' ? 'xyz789abc' : 'abc123def'
        });
    }, 3000);
    
    res.json({ message: `Deploying ${version}...` });
});

app.listen(port, () => {
    console.log(`GitOps dashboard running on port ${port}`);
});