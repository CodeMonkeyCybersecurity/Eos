#!/usr/bin/env zx

const os = require('os');
const path = require('path');

const homeDir = os.homedir();
const backupConfig = {
  baseDir: `${homeDir}/dockerBackups`,
  volumes: `${homeDir}/dockerBackups/Volumes`,
  containers: `${homeDir}/dockerBackups/Containers`,
  images: `${homeDir}/dockerBackups/Images`,
  networks: `${homeDir}/dockerBackups/Networks`,
  envVars: `${homeDir}/dockerBackups/EnvVars`,
  bindMounts: `${homeDir}/dockerBackups/BindMounts`,
  swarm: `${homeDir}/dockerBackups/Swarm`,
  repoDir: `${homeDir}/dockerBackups/borg_repo`,
};

const TIMESTAMP = new Date().toISOString().replace(/[-:.T]/g, '').split('.')[0];

// Function to create directories
async function createDirectories(dirs) {
  await Promise.all(dirs.map(dir => $`mkdir -p ${dir}`));
}

// Function to initialize Borg repository
async function initializeBorgRepo() {
  const repoExists = await $`borg list ${backupConfig.repoDir} || true`;
  if (!repoExists.stdout) {
    await $`borg init --encryption=repokey ${backupConfig.repoDir}`;
  }
}

// Function to back up Docker volumes
async function backupVolumes() {
  const { stdout: volumesStdout } = await $`docker volume ls -q`;
  const volumes = volumesStdout.trim().split('\n').filter(volume => volume);

  for (const volume of volumes) {
    console.log(`Backing up volume: ${volume}`);
    try {
      await $`docker run --rm -v ${volume}:/volume alpine sh -c "borg create --stats --progress ${backupConfig.repoDir}::${volume}_${TIMESTAMP} /volume"`;
    } catch (error) {
      console.error(`Failed to back up volume: ${volume}`);
      console.error(error);
    }
  }
}

// Function to back up bind mounts
async function backupBindMounts(bindMounts) {
  for (const bindMount of bindMounts) {
    const bindMountName = bindMount.replace(/[\/\\]/g, '_'); // Replace slashes for a valid filename
    console.log(`Backing up bind mount: ${bindMount}`);
    try {
      await $`borg create --stats --progress ${backupConfig.repoDir}::${bindMountName}_${TIMESTAMP} ${bindMount}`;
    } catch (error) {
      console.error(`Failed to back up bind mount: ${bindMount}`);
      console.error(error);
    }
  }
}

// Main script execution
(async () => {
  await createDirectories(Object.values(backupConfig));
  await initializeBorgRepo();

  const { stdout: containersStdout } = await $`docker ps -q`;
  const containerIds = containersStdout.trim().split('\n').filter(id => id);

  const bindMounts = new Set();
  for (const containerId of containerIds) {
    const { stdout: mountsStdout } = await $`docker inspect ${containerId} --format='{{json .Mounts}}'`;
    const mounts = JSON.parse(mountsStdout);
    for (const mount of mounts) {
      if (mount.Type === 'bind') {
        bindMounts.add(mount.Source);
      }
    }
  }

  await backupVolumes();
  await backupBindMounts(Array.from(bindMounts));

  console.log('Backup completed successfully!');
})();