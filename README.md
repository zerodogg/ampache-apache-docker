docker-ampache
==============

docker run --name=ampache -d -v /path/to/your/music:/data:ro -p 8000:80 eric.frederich/ampache

Installation:
MySQL Administrative Username: root # leave alone
MySQL Administrative Password:      # (blank) leave alone
Check "Create Database User"

Ampache Database Username: ampache
Ampache Database User Password: ampache # or whatever you want, but remember it on the next page

next page fill out MySQL Username / Password
Click the "Write" buttons from BOTTOM to TOP
Do this because it is the last one that needs the username and password and they get blanked out on every click