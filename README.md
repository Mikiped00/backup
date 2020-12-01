# Backup
Shell script to backup user's /home directory in GNU/Linux distros.

## What is it? 📖
<p align="justify">The script carries out a backup of /home directory of one or more users, depending on the arguments that it receives. It copies all the files and subdirectories located from the <b>/home</b> directory, excluding hidden files. The backup will be stored in a <b>.tar.gz</b> file in <b>/tmp</b> directory, and its name will be <i>username_date.tar.gz</i>. The date format will be <i>YYYY_MM_DD</i>.</p>
<p align="justify">Some data will be sent to the Standard Output:</p>

* The username that runs the script
* Date and time of execution, and bash version
* Username of each user on which the backup is carried out
* Number of files and directories to copy
* Backup file permissions, if backup was successful
* Execution errors, if any

### Used tools 🛠️
* [Visual Studio Code](https://code.visualstudio.com/) - The code editor

### Tests ⚙️
<p align="justify">The script was tested in Ubuntu 20.04 LTS distros.</p>

## Usage 📦
Download the script by executing `git clone https://github.com/Kaputt4/Backup` and grant execute permission to the file with `sudo chmod u+x backup.sh`

There are three different options to run the script.

Option | Syntax | Result
------------ | ------------- | -------------
<b>Without any argument</b> | `./backup.sh` | Carries out the backup of every user with <i>home</i> directory.
<b>With one username</b> | `./backup.sh username` | Carries out the backup of the user's <i>home</i> directory if it exists.
<b>With a set of users</b> | `./backup.sh username1 username2 ... usernameN` | Carries out the backup of each user's <i>home</i> directory if they exist.

### Error codes ⛔
<p align="justify">This errors are handled by the script and sent to Standard Error:</p>

Code | Error
---- | -------------
<b>1</b> | Error compressing files
<b>1</b> | User is not registered in the system
<b>2</b> | User can not be used to login, so it does not have <i>home </i> directory
<b>2</b> | Arguments do not have the correct syntax
<b>2</b> | Command <i>{command}</i> is not installed

## Authors ✒️
* [Kaputt4](https://github.com/Kaputt4)
* [Mikiped00](https://github.com/Mikiped00)
