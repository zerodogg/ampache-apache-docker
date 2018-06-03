# ampache-docker

Docker container for Ampache, a web based audio/video streaming application and file manager allowing you to access your music & videos from anywhere, using almost any internet enabled device.

This version does **NOT** come with a database, you will need to provide your
own and then `--link my-mysql:mysql`

## Usage
```bash
docker run --link my-mysql:mysql --name=ampache -d -v /path/to/your/music:/media:ro -p 80:80 zerodogg/ampache
```

## Installation
- MySQL Administrative Username: your-admin-user
- MySQL Administrative Password: your-admin-pw
- Check "Create Database User"
- Ampache Database Username: your-choice
- Ampache Database User Password: your-choice
- next page fill out MySQL Username / Password
- Click the "Write" buttons from BOTTOM to TOP
- Do this because it is the last one that needs the username and password and they get blanked out on every click

## Thanks to
- @ericfrederich for his original work
- @velocity303 and @goldy for the other ampache-docker inspiration
