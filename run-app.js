const { execSync } = require('child_process');

const platform = process.platform;
const target = platform === 'win32' ? 'windows' : platform === 'darwin' ? 'macos' : null;
const cmd = target ? `flutter run -d ${target}` : 'flutter run';
execSync(cmd, { stdio: 'inherit', cwd: __dirname });
